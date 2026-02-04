//
//  Article.swift
//  HeartRateSenior
//
//  Article data model for health knowledge articles
//

import SwiftUI

// MARK: - Article Category
enum ArticleCategory: String, CaseIterable {
    case diseaseWarning = "Disease Warning"
    case chronicManagement = "Chronic Management"
    case nutrition = "Nutrition"
    case activity = "Activity"
    case mentalHealth = "Mental Health"
    case sleep = "Sleep"
    
    var color: Color {
        switch self {
        case .diseaseWarning: return Color(hex: "F4403A")      // Red
        case .chronicManagement: return Color(hex: "007AFF")   // Blue
        case .nutrition: return Color(hex: "34C759")           // Green
        case .activity: return Color(hex: "FF9500")            // Orange
        case .mentalHealth: return Color(hex: "AF52DE")        // Purple
        case .sleep: return Color(hex: "5856D6")               // Indigo
        }
    }
    
    var gradientColors: [Color] {
        switch self {
        case .diseaseWarning: 
            return [Color(hex: "FF6B6B"), Color(hex: "EE5A5A")]
        case .chronicManagement: 
            return [Color(hex: "4A90D9"), Color(hex: "357ABD")]
        case .nutrition: 
            return [Color(hex: "6BCB77"), Color(hex: "4CAF50")]
        case .activity: 
            return [Color(hex: "FFB347"), Color(hex: "FF9500")]
        case .mentalHealth: 
            return [Color(hex: "B39DDB"), Color(hex: "9575CD")]
        case .sleep: 
            return [Color(hex: "7986CB"), Color(hex: "5C6BC0")]
        }
    }
    
    var icon: String {
        switch self {
        case .diseaseWarning: return "exclamationmark.heart.fill"
        case .chronicManagement: return "heart.text.square.fill"
        case .nutrition: return "leaf.fill"
        case .activity: return "figure.run"
        case .mentalHealth: return "brain.head.profile"
        case .sleep: return "moon.zzz.fill"
        }
    }
}

// MARK: - Article Model
struct Article: Identifiable {
    let id: Int
    let title: String
    let shortTitle: String
    let category: ArticleCategory
    let content: String
    let coverImageName: String? // For future custom images
    // Placeholder image name (will be replaced with actual images later)
    var placeholderImageName: String {
        "article_cover_\(id)"
    }
}

// MARK: - Article Data
struct ArticleData {
    static let articles: [Article] = [
        Article(
            id: 1,
            title: "Decoding Heart Rate Variability (HRV): The \"Stress Bucket\" Analogy",
            shortTitle: "Heart Rate Variability",
            category: .diseaseWarning,
            content: """
## Decoding Heart Rate Variability (HRV): The "Stress Bucket" Analogy
**Category:** Disease Warning / Body Signals

We tend to think that a steady heart is a healthy heart. While this is true for your *Resting Heart Rate*, there is another metric where "instability" is actually the gold standard of health: **Heart Rate Variability (HRV).**

Unlike resting heart rate (where lower is generally better), HRV measures the time gap *in milliseconds* between heartbeats. Surprisingly, you want this gap to vary.

### The Science: It's All About the Nervous System
HRV is essentially a tug-of-war between two branches of your Autonomic Nervous System:
1.  **The Sympathetic (Fight or Flight):** Tells your heart to beat faster.
2.  **The Parasympathetic (Rest and Digest):** Tells your heart to slow down.

When you are healthy and resilient, these two systems are constantly making micro-adjustments, causing high variability. When you are stressed or sick, one system dominates (usually the Sympathetic), making the beats metronomic and rigid (Low HRV).

### The "Stress Bucket" Analogy
Think of your body as a bucket. Every stressor pours water into it:
*   **Physical Stress:** A hard workout.
*   **Chemical Stress:** Alcohol, processed sugar, or an immune response to a virus.
*   **Mental Stress:** A deadline at work.

**Low HRV** means your bucket is overflowing. You have no room for more stress.
**High HRV** means your bucket is empty. You are resilient and ready to take on challenges.

### 🚩 Red Flags: What Causes a Sudden Drop?
If your tracker shows a sudden drop in HRV baseline for 3+ days, investigate:
*   **Impending Illness:** Your body often detects a virus 24-48 hours before you feel symptoms.
*   **Overtraining:** You worked out hard but didn't prioritize recovery.
*   **Late Meals:** Eating a heavy meal right before bed keeps the digestive system active, suppressing HRV.

### ✅ Pro Tip: The "Morning Readiness" Check
Don't check your HRV at 2 PM after coffee. The most accurate reading is the average taken during sleep or immediately upon waking. Use this score to plan your day:
*   **Low Score:** Skip the HIIT workout; go for a walk or do yoga. Sleep an extra hour.
*   **High Score:** Push yourself. It's a great day for a personal best.

> **References:**
> *   Harvard Health: Heart Rate Variability
> *   Frontiers in Public Health: HRV and Stress
""",
            coverImageName: nil
        ),
        
        Article(
            id: 2,
            title: "The \"White Coat\" Effect: The Ultimate Guide to Home Blood Pressure Monitoring",
            shortTitle: "Home BP Monitoring",
            category: .chronicManagement,
            content: """
## The "White Coat" Effect: The Ultimate Guide to Home Blood Pressure Monitoring
**Category:** Chronic Disease Management

You walk into a doctor's office. The air smells like antiseptic, you've been waiting for 20 minutes, and a nurse straps a cuff tightly around your arm. Suddenly, your blood pressure reads 145/90.

Are you hypertensive? Or are you just nervous? This is known as **"White Coat Hypertension,"** affecting nearly 15-30% of patients. Conversely, **"Masked Hypertension"** occurs when you are calm at the doctor's but stressed (and hypertensive) at home.

### Why Home Monitoring Wins
Your heart health cannot be defined by a single snapshot taken once a year. Blood pressure fluctuates continuously. Home monitoring provides the "True Mean"—the average load your heart bears daily.

### The 7-Step Protocol for Accurate Readings
Most people measure BP incorrectly. Here is the clinical standard:

1.  **Empty Bladder:** A full bladder can add 10–15 points to your reading.
2.  **The 5-Minute Rule:** Sit quietly for 5 minutes before measuring. No phone, no TV, no talking.
3.  **Position Matters:** Feet flat on the floor (no crossed legs). Back supported. Arm resting on a table at *heart level*.
4.  **Cuff Size:** If the cuff is too small, it will artificially raise the reading. It should fit snugly but allow two fingers to slide under.
5.  **Skin Contact:** Measure over bare skin, not over a sweater.
6.  **Take Two:** Take a reading, wait one minute, then take another. Average the two.
7.  **Consistency:** Measure at the same time daily (e.g., 7:00 AM and 7:00 PM).

### 💡 When to Call the Doctor
If your home readings are consistently above **130/80** (the new guideline for Stage 1 Hypertension), bring your device and your log to your doctor to discuss lifestyle changes or medication.

> **References:**
> *   AHA: Monitoring Your Blood Pressure at Home
> *   Mayo Clinic: White coat hypertension
""",
            coverImageName: nil
        ),
        
        Article(
            id: 3,
            title: "Palpitations, PVCs, and AFib: Reading Your Heart's Rhythm",
            shortTitle: "Heart Rhythm Guide",
            category: .chronicManagement,
            content: """
## Palpitations, PVCs, and AFib: Reading Your Heart's Rhythm
**Category:** Chronic Disease Management / Warning

Have you ever felt a "flutter" in your chest? Or a sensation that your heart skipped a beat and then thumped hard?

In the age of smartwatches, we are more aware of our heartbeats than ever. But how do you tell the difference between a harmless hiccup and a dangerous condition?

### 1. Benign Ectopic Beats (PVCs/PACs)
*   **The Feeling:** A distinct "skipped" beat followed by a strong thud.
*   **The Cause:** Often stress, caffeine, dehydration, or lack of sleep.
*   **The Verdict:** Usually harmless. Think of it as your heart briefly "stumbling" and then correcting itself.

### 2. Atrial Fibrillation (AFib)
*   **The Feeling:** A "quivering" fish in the chest. It feels chaotic, rapid, and uneven. There is no pattern.
*   **The Danger:** In AFib, the upper chambers (atria) stop pumping effectively, causing blood to pool and potentially clot. If a clot travels to the brain, it causes a stroke.
*   **The Verdict:** Requires medical attention.

### 🚩 When to Seek Immediate Help
Wearables are great tools, but trust your body first. Call emergency services if palpitations are accompanied by:
*   Chest pain or pressure.
*   Shortness of breath.
*   Dizziness or fainting.

### Prevention Checklist
To calm a "jumpy" heart:
*   **Cut the stimulants:** Reduce coffee and nicotine.
*   **Check electrolytes:** Are you low on Magnesium? (See Article 4).
*   **Hydrate:** Dehydration thickens blood, increasing heart strain.

> **References:**
> *   CDC: Atrial Fibrillation Fact Sheet
> *   Heart Rhythm Society: Patient Resources
""",
            coverImageName: nil
        ),
        
        Article(
            id: 4,
            title: "The Electric Heart: Why Sodium is Only Half the Story",
            shortTitle: "Electrolytes & Heart",
            category: .nutrition,
            content: """
## The Electric Heart: Why Sodium is Only Half the Story (Enter Potassium & Magnesium)
**Category:** Nutrition

Your heart is essentially an electrical pump. Every beat is triggered by an electrical impulse generated by the movement of electrolytes in and out of your cells.

Public health advice focuses heavily on "Cutting Salt" (Sodium). While important, Sodium is only dangerous *in relation* to its partner: **Potassium**.

### The Sodium-Potassium See-Saw
*   **Sodium:** Increases blood pressure and fluid retention.
*   **Potassium:** Relaxes blood vessel walls and helps excrete sodium through urine.

*The Problem:* The modern diet is high in Sodium (processed food) and low in Potassium (fresh food). To protect your heart, you don't just need to subtract salt; you need to add potassium.

### The Magnesium Factor
Magnesium is the "Rhythm Keeper." It regulates the recovery phase of the heartbeat. Low magnesium levels are strongly linked to arrhythmias and palpitations.

### 🥗 The "Electric Heart" Menu
Try to incorporate these "Power Pairings" into your weekly diet:

| Nutrient | Top Sources | Goal |
| :--- | :--- | :--- |
| **Potassium** | Avocado, Sweet Potato, Spinach, Bananas, Salmon | ~3,500 - 4,700 mg/day |
| **Magnesium** | Pumpkin Seeds, Almonds, Dark Chocolate (>70%), Black Beans | ~300 - 400 mg/day |

**Pro Tip:** Avoid potassium supplements unless prescribed by a doctor, as too much can be dangerous. Get it from food—it's safer and absorbs better.

> **References:**
> *   Cleveland Clinic: Electrolytes
> *   NIH: Potassium Fact Sheet
""",
            coverImageName: nil
        ),
        
        Article(
            id: 5,
            title: "Coffee & Cardiology: The Truth About Caffeine, Cortisol, and Heart Rate",
            shortTitle: "Coffee & Heart",
            category: .nutrition,
            content: """
## Coffee & Cardiology: The Truth About Caffeine, Cortisol, and Heart Rate
**Category:** Nutrition

It's the morning ritual for billions. But for those watching their heart rate data, that morning spike can be alarming. Is coffee a friend or foe?

### The "Acute" vs. "Chronic" Effect
*   **Short Term:** Caffeine is a stimulant. It blocks adenosine (the "sleepy chemical") and triggers adrenaline. Yes, your heart rate and blood pressure will rise for 1-3 hours after consumption.
*   **Long Term:** Surprisingly, large-scale studies show that moderate coffee drinkers (2-4 cups/day) have a *lower* risk of heart failure and stroke than non-drinkers. Coffee is packed with antioxidants and polyphenols that protect blood vessels.

### The "Slow Metabolizer" Warning
Genetics play a huge role. If you have a specific variant of the *CYP1A2* gene, you metabolize caffeine slowly. For these people, coffee can cause sustained high blood pressure and anxiety.
*   *Self Test:* If one cup of coffee makes you jittery for 6+ hours or affects your sleep even when taken at noon, switch to Decaf.

### ☕ Optimized Consumption Rules
1.  **The 90-Minute Rule:** Wait 90 minutes after waking up before drinking coffee. This allows your body's natural "waking hormone" (Cortisol) to level out, preventing a mid-afternoon crash.
2.  **The 2 PM Cutoff:** Caffeine has a half-life of 5-6 hours. Drinking it at 4 PM means 50% of it is still in your system at 10 PM, destroying your Deep Sleep.
3.  **Filter It:** Use a paper filter. Unfiltered coffee (like French Press) contains *cafestol*, which can raise LDL cholesterol slightly.

> **References:**
> *   ACC: Coffee and Heart Health
> *   Johns Hopkins: Is Coffee Good for Your Heart?
""",
            coverImageName: nil
        ),
        
        Article(
            id: 6,
            title: "The \"Talk Test\" & The Science of Zone 2 Training",
            shortTitle: "Zone 2 Training",
            category: .activity,
            content: """
## The "Talk Test" & The Science of Zone 2 Training
**Category:** Physical Activity

"No Pain, No Gain" is outdated advice. When it comes to heart longevity and metabolic health, the magic happens in the "Easy Zone."

### Defining Zone 2
Zone 2 is training at 60-70% of your Maximum Heart Rate.
*   **The Talk Test:** You should be able to hold a full conversation while exercising, but you should sound a little breathless. If you can sing, you're going too slow. If you can't speak in full sentences, you're going too fast.

### Why Go Slow?
1.  **Mitochondrial Efficiency:** Zone 2 builds the "power plants" in your cells. It teaches your body to burn fat for fuel instead of sugar.
2.  **Heart Remodeling:** It increases the size of the heart's left ventricle, allowing it to pump more blood with each beat (Stroke Volume) without thickening the heart wall (which is bad).
3.  **Sustainability:** You can do it every day without burnout.

### The 80/20 Rule (Polarized Training)
Elite athletes don't sprint every day. They follow the 80/20 split:
*   **80% of the time:** Zone 2 (Jogging, Brisk Walking, Easy Cycling).
*   **20% of the time:** Zone 4/5 (HIIT, Sprints, Heavy Lifting).

This combination builds a massive aerobic base *and* a high-performance peak.

> **References:**
> *   Cleveland Clinic: Heart Rate Zones
> *   CDC: Target Heart Rate
""",
            coverImageName: nil
        ),
        
        Article(
            id: 7,
            title: "Heart Rate Recovery (HRR): The Hidden Metric That Predicts Longevity",
            shortTitle: "Heart Rate Recovery",
            category: .activity,
            content: """
## Heart Rate Recovery (HRR): The Hidden Metric That Predicts Longevity
**Category:** Physical Activity

You just finished a run. You stop moving. What happens in the next 60 seconds is one of the most powerful predictors of your future cardiovascular health.

**Heart Rate Recovery (HRR)** is the measurement of how fast your heart rate drops after stopping peak exercise.

### Why It Matters
HRR tests the agility of your nervous system. It answers the question: *How quickly can your body switch off the "Fire Alarm" (Sympathetic) and turn on the "Cool Down" (Parasympathetic) systems?*

### The Numbers
1.  **Stop exercising.**
2.  **Measure immediately.** (e.g., 150 bpm)
3.  **Wait exactly 1 minute** (standing or sitting still).
4.  **Measure again.** (e.g., 130 bpm)
5.  **Calculate the difference.** (150 - 130 = 20)

*   **< 12 beats:** Poor. (Higher risk of cardiac issues).
*   **12 - 20 beats:** Average.
*   **20 - 30 beats:** Good.
*   **> 30 beats:** Excellent (Athlete level).

### 🚀 How to Improve Your Score
If your HRR is low, don't panic. It is highly trainable.
*   **Incorporate Interval Training:** Getting your heart rate up and bringing it down repeatedly teaches the heart to recover faster.
*   **Stay Hydrated:** Dehydration prevents the heart rate from dropping quickly.
*   **Cool Down Properly:** Don't just sit down. Walking slowly helps flush metabolic waste (lactate) and assists the heart.

> **References:**
> *   NEJM: Heart-Rate Recovery Predictor of Mortality
> *   WebMD: What is Heart Rate Recovery?
""",
            coverImageName: nil
        ),
        
        Article(
            id: 8,
            title: "Biohacking Anxiety: Stimulating the Vagus Nerve to Lower Heart Rate",
            shortTitle: "Vagus Nerve Hacks",
            category: .mentalHealth,
            content: """
## Biohacking Anxiety: Stimulating the Vagus Nerve to Lower Heart Rate
**Category:** Mental Health

When you are stressed, your heart races. This is biology. But did you know you can use a biological "backdoor" to slow it down manually?

This backdoor is the **Vagus Nerve**. It is the longest nerve in the autonomic nervous system, running from your brainstem to your colon, touching the heart along the way.

### The "Physiological Sigh" & Breathing Hacks
You cannot "think" your heart rate down, but you can "breathe" it down.
*   **The 4-7-8 Method:** Inhale for 4s, Hold for 7s, Exhale for 8s.
*   **Why it works:** When you inhale, your diaphragm moves down and your heart speeds up slightly. When you **exhale**, the diaphragm moves up, and the Vagus nerve releases *acetylcholine*, which slows the heart. *Long exhales = Slow Heart.*

### Other Vagus Nerve Stimulators
Besides breathing, you can activate this relaxation pathway by:
1.  **Cold Exposure:** Splashing freezing cold water on your face triggers the "Dive Reflex," instantly lowering heart rate.
2.  **Humming or Chanting:** The Vagus nerve passes through the vocal cords. Humming creates vibrations that stimulate the nerve.
3.  **Massage:** Gently massaging the side of the neck (carotid sinus) can lower heart rate—but be gentle!

> **References:**
> *   Psychology Today: Vagus Nerve Survival Guide
> *   PubMed: Breathing techniques for stress relief
""",
            coverImageName: nil
        ),
        
        Article(
            id: 9,
            title: "Alcohol & The Heart: Why Your \"Nightcap\" is Ruining Your Recovery",
            shortTitle: "Alcohol & Sleep",
            category: .sleep,
            content: """
## Alcohol & The Heart: Why Your "Nightcap" is Ruining Your Recovery
**Category:** Sleep & Habits

"I drink wine to help me sleep." It's a common sentiment. While alcohol is a sedative that helps you lose consciousness faster, it is arguably the biggest enemy of *restorative* sleep and heart health.

### The "Rebound Effect"
Alcohol paralyzes your nervous system initially. But about 3-4 hours later, as your liver finishes metabolizing the alcohol, your body experiences a **Sympathetic Rebound**.
*   **Heart Rate Spikes:** You might wake up sweating, with a racing heart.
*   **REM Blockage:** Alcohol significantly reduces REM sleep (critical for memory and emotional regulation).

### The "Double Dip" Data
If you wear a tracker, compare a "Dry Night" vs. a "Drinking Night."
*   **Dry Night:** Resting Heart Rate drops into a "hammock" shape.
*   **Drinking Night:** Resting Heart Rate stays flat and high (a "slope" shape). Your heart beats thousands of extra times per night, exhausting the muscle instead of resting it.

### 🛡️ Damage Control
If you are going to drink:
1.  **Day Drinking > Night Drinking:** Finish your last drink 3-4 hours before bed.
2.  **Hydrate:** Drink one glass of water for every alcoholic beverage.
3.  **Magnesium:** Alcohol depletes magnesium. Take a supplement before bed to help stabilize heart rhythm.

> **References:**
> *   Sleep Foundation: Alcohol and Sleep
> *   NIH: Alcohol and the Sleeping Heart
""",
            coverImageName: nil
        ),
        
        Article(
            id: 10,
            title: "The \"Non-Dipper\" Phenomenon: Assessing Your Nighttime Cardiovascular Risk",
            shortTitle: "Nighttime BP Risk",
            category: .sleep,
            content: """
## The "Non-Dipper" Phenomenon: Assessing Your Nighttime Cardiovascular Risk
**Category:** Sleep & Habits / Disease Warning

Biology runs on rhythm. In a healthy person, blood pressure and heart rate should drop by **10% to 20%** during sleep compared to daytime levels. This is the heart's "maintenance window."

### Who are "Non-Dippers"?
Some people's blood pressure stays the same—or even rises—at night. These people are classified medically as "Non-Dippers" or "Reverse Dippers."
*   **The Risk:** Research shows that nighttime blood pressure is a *better* predictor of heart attack and stroke than daytime pressure. Non-dippers essentially have a heart that works a 24-hour shift with no break.

### Common Causes
1.  **Sleep Apnea:** If you stop breathing, oxygen drops, and the heart races to compensate.
2.  **Salt Sensitivity:** High sodium intake at dinner keeps blood volume high.
3.  **Nocturia:** Waking up frequently to urinate disrupts the dipping cycle.

### 📉 How to Encourage "Dipping"
*   **Screen for Snoring:** If your partner says you gasp for air, get a sleep study.
*   **Melatonin:** Some studies suggest melatonin helps regulate the circadian rhythm of blood pressure.
*   **Front-Load Hydration:** Stop drinking fluids 2 hours before bed to prevent waking up.
*   **Early Dinner:** Eat at least 3 hours before sleep to ensure digestion doesn't keep your heart rate up.

> **References:**
> *   JAHA: Nighttime Blood Pressure Risk
> *   Columbia University: The Importance of Dipping
""",
            coverImageName: nil
        )
    ]
}
