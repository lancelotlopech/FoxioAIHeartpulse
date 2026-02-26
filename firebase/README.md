# Firebase Billing Backend

## Structure
- `functions/index.js`: Cloud Functions for subscription identity linking, App Store notifications, and backfill.
- `firestore.rules`: Firestore security policy for billing data.
- `firebase.json`: Firebase deploy configuration.

## Required Secrets / Env
Set these before deployment:
- `APPLE_BUNDLE_ID` (default: `com.heartrateios.senior`)
- `APPLE_APP_ID` (default: `6757157988`)
- `APPLE_ENV` (`PRODUCTION` or `SANDBOX`)
- `APPLE_SERVER_API_PRIVATE_KEY`
- `APPLE_SERVER_API_KEY_ID`
- `APPLE_SERVER_API_ISSUER_ID`
- `APPLE_ROOT_CA_BASE64_JSON` (JSON array of base64-encoded Apple root CA certs)

## Deploy
```bash
cd firebase/functions
npm install
cd ../..
firebase deploy --only functions,firestore
```

## Endpoints (Callable)
- `linkSubscriptionIdentity`
- `appleNotificationV2`
- `backfillTransactions`
- Scheduler: `dailyBackfillRetry`
