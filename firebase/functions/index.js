const admin = require("firebase-admin");
const { onCall, onRequest, HttpsError } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const logger = require("firebase-functions/logger");

const {
  AppStoreServerAPIClient,
  Environment,
  SignedDataVerifier,
} = require("@apple/app-store-server-library");

admin.initializeApp();
const db = admin.firestore();

const APPLE_BUNDLE_ID = process.env.APPLE_BUNDLE_ID || "com.heartrateios.senior";
const APPLE_APP_ID = process.env.APPLE_APP_ID || "6757157988";
const APPLE_ENV = process.env.APPLE_ENV || "PRODUCTION";

const COLLECTIONS = {
  billingTransactions: "billing_transactions",
  billingUnlinked: "billing_unlinked",
  subscriptionLinks: "subscription_links",
};

function nowTimestamp() {
  return admin.firestore.FieldValue.serverTimestamp();
}

function parseDecimalAmount(priceField) {
  if (priceField === null || priceField === undefined) {
    return { amountMinor: null, amountDecimal: null };
  }

  if (typeof priceField === "number") {
    return {
      amountMinor: Math.round(priceField),
      amountDecimal: Number((priceField / 1000).toFixed(6)),
    };
  }

  return { amountMinor: null, amountDecimal: null };
}

function decodeJWSPayloadWithoutVerification(signedData) {
  if (!signedData || typeof signedData !== "string") return null;
  const parts = signedData.split(".");
  if (parts.length < 2) return null;
  const normalized = parts[1].replace(/-/g, "+").replace(/_/g, "/");
  const padded = normalized + "=".repeat((4 - (normalized.length % 4)) % 4);
  const payload = Buffer.from(padded, "base64").toString("utf8");
  return JSON.parse(payload);
}

function resolveEnvironment() {
  return APPLE_ENV === "SANDBOX" ? Environment.SANDBOX : Environment.PRODUCTION;
}

function parseRootCAs() {
  const raw = process.env.APPLE_ROOT_CA_BASE64_JSON;
  if (!raw) return [];

  try {
    const arr = JSON.parse(raw);
    if (!Array.isArray(arr)) return [];
    return arr.map((item) => Buffer.from(item, "base64"));
  } catch (error) {
    logger.error("Failed to parse APPLE_ROOT_CA_BASE64_JSON", error);
    return [];
  }
}

function createSignedDataVerifier() {
  const rootCAs = parseRootCAs();
  return new SignedDataVerifier(
    rootCAs,
    true,
    resolveEnvironment(),
    APPLE_BUNDLE_ID,
    Number(APPLE_APP_ID)
  );
}

async function decodeSignedTransactionInfo(verifier, signedTransactionInfo) {
  if (!signedTransactionInfo) return null;
  if (typeof signedTransactionInfo === "object") return signedTransactionInfo;

  if (typeof verifier.verifyAndDecodeTransaction === "function") {
    return verifier.verifyAndDecodeTransaction(signedTransactionInfo);
  }

  return decodeJWSPayloadWithoutVerification(signedTransactionInfo);
}

function createAppStoreServerClient() {
  const privateKey = process.env.APPLE_SERVER_API_PRIVATE_KEY;
  const keyId = process.env.APPLE_SERVER_API_KEY_ID;
  const issuerId = process.env.APPLE_SERVER_API_ISSUER_ID;

  if (!privateKey || !keyId || !issuerId) {
    throw new Error("Missing App Store Server API credentials");
  }

  return new AppStoreServerAPIClient(
    privateKey,
    keyId,
    issuerId,
    APPLE_BUNDLE_ID,
    resolveEnvironment()
  );
}

async function findUidByAppAccountToken(appAccountToken) {
  if (!appAccountToken) return null;

  const snapshot = await db
    .collection(COLLECTIONS.subscriptionLinks)
    .where("appAccountToken", "==", appAccountToken)
    .limit(1)
    .get();

  if (snapshot.empty) return null;
  const doc = snapshot.docs[0].data();
  return doc.uid || null;
}

async function updateBillingSummary(uid, transaction) {
  const summaryRef = db
    .collection("users")
    .doc(uid)
    .collection("billing_summary")
    .doc("current");

  await db.runTransaction(async (trx) => {
    const summaryDoc = await trx.get(summaryRef);
    const current = summaryDoc.exists ? summaryDoc.data() : {};

    const currency = transaction.currency || "UNKNOWN";
    const amountMinor = transaction.amountMinor || 0;
    const isRenewal = transaction.isRenewal === true;
    const isCharge = amountMinor > 0;

    const totalMap = {
      ...(current.total_paid_by_currency || {}),
    };
    totalMap[currency] = (totalMap[currency] || 0) + amountMinor;

    const next = {
      subscription_purchase_count:
        (current.subscription_purchase_count || 0) + (isCharge && !isRenewal ? 1 : 0),
      renewal_count: (current.renewal_count || 0) + (isCharge && isRenewal ? 1 : 0),
      total_paid_by_currency: totalMap,
      last_transaction_at: nowTimestamp(),
      updated_at: nowTimestamp(),
    };

    trx.set(summaryRef, next, { merge: true });
  });
}

async function upsertTransaction({
  transactionId,
  notificationUUID,
  uid,
  appAccountToken,
  originalTransactionId,
  productId,
  purchaseDateMs,
  expiresDateMs,
  currency,
  amountMinor,
  amountDecimal,
  source,
  notificationType,
  subtype,
  isRenewal,
}) {
  const targetCollection = uid ? COLLECTIONS.billingTransactions : COLLECTIONS.billingUnlinked;
  const ref = db.collection(targetCollection).doc(transactionId);

  await db.runTransaction(async (trx) => {
    const existing = await trx.get(ref);
    if (existing.exists) {
      const existingData = existing.data();
      if (existingData.notificationUUID === notificationUUID) {
        return;
      }
    }

    trx.set(
      ref,
      {
        uid: uid || null,
        appAccountToken: appAccountToken || null,
        originalTransactionId,
        transactionId,
        productId,
        purchaseDateMs: purchaseDateMs || null,
        expiresDateMs: expiresDateMs || null,
        currency: currency || null,
        amountMinor: amountMinor ?? null,
        amountDecimal: amountDecimal ?? null,
        source,
        notificationType,
        subtype: subtype || null,
        isRenewal,
        notificationUUID: notificationUUID || null,
        updatedAt: nowTimestamp(),
        createdAt: existing.exists ? existing.data().createdAt || nowTimestamp() : nowTimestamp(),
      },
      { merge: true }
    );
  });

  if (uid) {
    await updateBillingSummary(uid, {
      currency,
      amountMinor,
      isRenewal,
    });
  }
}

function buildTransactionDocFromNotification(notification, signedTransactionInfo) {
  const transactionId = String(signedTransactionInfo.transactionId || "");
  const originalTransactionId = String(
    signedTransactionInfo.originalTransactionId || signedTransactionInfo.originalTransactionID || transactionId
  );
  const appAccountToken = signedTransactionInfo.appAccountToken || null;
  const { amountMinor, amountDecimal } = parseDecimalAmount(signedTransactionInfo.price);
  const notificationType = notification.notificationType || "UNKNOWN";
  const subtype = notification.subtype || null;

  return {
    transactionId,
    originalTransactionId,
    appAccountToken,
    productId: signedTransactionInfo.productId || "",
    purchaseDateMs: signedTransactionInfo.purchaseDate || null,
    expiresDateMs: signedTransactionInfo.expiresDate || null,
    currency: signedTransactionInfo.currency || null,
    amountMinor,
    amountDecimal,
    notificationType,
    subtype,
    isRenewal: notificationType === "DID_RENEW",
  };
}

exports.linkSubscriptionIdentity = onCall({ region: "us-central1" }, async (request) => {
  const auth = request.auth;
  if (!auth || !auth.uid) {
    throw new HttpsError("unauthenticated", "Auth is required");
  }

  const data = request.data || {};
  const uid = auth.uid;
  const appAccountToken = data.appAccountToken;
  const originalTransactionId = data.originalTransactionId;
  const transactionId = data.transactionId;

  if (!appAccountToken || !originalTransactionId || !transactionId) {
    throw new HttpsError("invalid-argument", "Missing required fields");
  }

  await db
    .collection(COLLECTIONS.subscriptionLinks)
    .doc(String(originalTransactionId))
    .set(
      {
        uid,
        appAccountToken,
        originalTransactionId: String(originalTransactionId),
        latestTransactionId: String(transactionId),
        productId: data.productId || null,
        source: data.source || "ios",
        updatedAt: nowTimestamp(),
        createdAt: nowTimestamp(),
      },
      { merge: true }
    );

  return { ok: true, uid, originalTransactionId: String(originalTransactionId) };
});

exports.appleNotificationV2 = onRequest({ region: "us-central1" }, async (req, res) => {
  if (req.method !== "POST") {
    res.status(405).json({ ok: false, error: "Method Not Allowed" });
    return;
  }

  const signedPayload = req.body?.signedPayload;
  if (!signedPayload) {
    res.status(400).json({ ok: false, error: "signedPayload is required" });
    return;
  }

  let notification;
  let verifier;
  try {
    verifier = createSignedDataVerifier();
    notification = await verifier.verifyAndDecodeNotification(signedPayload);
  } catch (error) {
    logger.error("appleNotificationV2 verification failed", error);
    res.status(403).json({ ok: false, error: "Invalid signedPayload" });
    return;
  }

  const signedTransactionInfoRaw = notification.data?.signedTransactionInfo || null;
  if (!signedTransactionInfoRaw) {
    res.json({ ok: true, ignored: true, reason: "No signedTransactionInfo" });
    return;
  }

  let signedTransactionInfo;
  try {
    signedTransactionInfo = await decodeSignedTransactionInfo(verifier, signedTransactionInfoRaw);
  } catch (error) {
    logger.error("appleNotificationV2 transaction decode failed", error);
    res.status(400).json({ ok: false, error: "Failed to decode signedTransactionInfo" });
    return;
  }

  const transaction = buildTransactionDocFromNotification(notification, signedTransactionInfo);
  if (!transaction.transactionId) {
    res.json({ ok: true, ignored: true, reason: "Missing transactionId" });
    return;
  }

  let uid = await findUidByAppAccountToken(transaction.appAccountToken);

  if (!uid && transaction.originalTransactionId) {
    const linkDoc = await db.collection(COLLECTIONS.subscriptionLinks).doc(transaction.originalTransactionId).get();
    if (linkDoc.exists) {
      uid = linkDoc.data().uid || null;
    }
  }

  await upsertTransaction({
    ...transaction,
    uid,
    source: "apple_notification_v2",
    notificationUUID: notification.notificationUUID || null,
  });

  res.json({
    ok: true,
    linked: !!uid,
    transactionId: transaction.transactionId,
    originalTransactionId: transaction.originalTransactionId,
  });
});

async function fetchTransactionHistoryPage(client, originalTransactionId, revisionToken) {
  const requestBody = {
    sort: "ASCENDING",
    revoked: false,
    productTypes: ["AUTO_RENEWABLE"],
  };

  // The official SDK method signatures may vary across versions.
  // This call path is intentionally defensive to keep compatibility.
  if (typeof client.getTransactionHistory === "function") {
    return client.getTransactionHistory(originalTransactionId, revisionToken || null, requestBody, "V2");
  }

  throw new Error("AppStoreServerAPIClient.getTransactionHistory is unavailable");
}

async function upsertBackfilledTransactions(originalTransactionId, uid, appAccountToken, pages) {
  const verifier = createSignedDataVerifier();

  for (const page of pages) {
    const signedTransactions = page.signedTransactions || [];

    for (const raw of signedTransactions) {
      const tx = await decodeSignedTransactionInfo(verifier, raw);
      if (!tx) continue;

      const transactionId = String(tx.transactionId || tx.transactionID || "");
      if (!transactionId) continue;

      const { amountMinor, amountDecimal } = parseDecimalAmount(tx.price);

      await upsertTransaction({
        transactionId,
        notificationUUID: null,
        uid,
        appAccountToken,
        originalTransactionId,
        productId: tx.productId || "",
        purchaseDateMs: tx.purchaseDate || null,
        expiresDateMs: tx.expiresDate || null,
        currency: tx.currency || null,
        amountMinor,
        amountDecimal,
        source: "apple_history_backfill",
        notificationType: "BACKFILL",
        subtype: null,
        isRenewal: tx.transactionReason === "RENEWAL",
      });
    }
  }
}

async function runBackfillForOriginalTransactionId(originalTransactionId) {
  const linkDoc = await db.collection(COLLECTIONS.subscriptionLinks).doc(originalTransactionId).get();
  if (!linkDoc.exists) {
    return { ok: false, reason: "No subscription link", originalTransactionId };
  }

  const link = linkDoc.data();
  const uid = link.uid || null;
  const appAccountToken = link.appAccountToken || null;

  if (!uid) {
    return { ok: false, reason: "No uid linked", originalTransactionId };
  }

  const client = createAppStoreServerClient();

  const pages = [];
  let revision = null;
  let hasMore = true;

  while (hasMore) {
    const page = await fetchTransactionHistoryPage(client, originalTransactionId, revision);
    pages.push(page);

    revision = page.revision || null;
    hasMore = page.hasMore === true;
  }

  await upsertBackfilledTransactions(originalTransactionId, uid, appAccountToken, pages);

  await db.collection(COLLECTIONS.subscriptionLinks).doc(originalTransactionId).set(
    {
      backfillAt: nowTimestamp(),
      updatedAt: nowTimestamp(),
    },
    { merge: true }
  );

  return {
    ok: true,
    originalTransactionId,
    pages: pages.length,
  };
}

exports.backfillTransactions = onCall({ region: "us-central1", timeoutSeconds: 540 }, async (request) => {
  const auth = request.auth;
  if (!auth || !auth.uid) {
    throw new HttpsError("unauthenticated", "Auth is required");
  }

  const data = request.data || {};
  const originalTransactionIds = Array.isArray(data.originalTransactionIds)
    ? data.originalTransactionIds.map((v) => String(v)).filter(Boolean)
    : [];

  if (originalTransactionIds.length === 0) {
    throw new HttpsError("invalid-argument", "originalTransactionIds is required");
  }

  const results = [];

  for (const originalTransactionId of originalTransactionIds) {
    try {
      const result = await runBackfillForOriginalTransactionId(originalTransactionId);
      results.push(result);
    } catch (error) {
      logger.error("backfillTransactions failed", { originalTransactionId, error });
      results.push({ ok: false, originalTransactionId, reason: String(error.message || error) });
    }
  }

  return { ok: true, results };
});

exports.dailyBackfillRetry = onSchedule(
  {
    schedule: "every day 03:00",
    timeZone: "UTC",
    region: "us-central1",
    timeoutSeconds: 540,
  },
  async () => {
    const snapshot = await db.collection(COLLECTIONS.subscriptionLinks).limit(200).get();

    for (const doc of snapshot.docs) {
      const originalTransactionId = doc.id;
      try {
        await runBackfillForOriginalTransactionId(originalTransactionId);
      } catch (error) {
        logger.error("dailyBackfillRetry failed", { originalTransactionId, error });
      }
    }

    return null;
  }
);
