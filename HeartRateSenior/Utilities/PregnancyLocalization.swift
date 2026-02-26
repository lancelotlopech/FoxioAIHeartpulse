//
//  PregnancyLocalization.swift
//  HeartRateSenior
//
//  Module-scoped localization for Pregnancy (HIV reserved for future).
//

import Foundation

enum LocalizedModule {
    case pregnancy
    case hiv
}

enum LocalizedLanguage {
    case english
    case chinese
}

enum PregnancyL10nKey: String, CaseIterable {
    case next
    case done
    case back
    case previous
    case close
    case save
    case cancel
    case openSettings = "open_settings"
    case ok
    case tips
    case important
    case recommendations
    case score
    case viewHistory = "view_history"
    case upgrade
    case enableNotificationsTitle = "enable_notifications_title"
    case enableNotificationsMessage = "enable_notifications_message"
    case reminderCreatedTitle = "reminder_created_title"
    case reminderCreatedMessage = "reminder_created_message"
    case dayOfCycleFormat = "day_of_cycle_format"
    case predictionDaysAwayFormat = "prediction_days_away_format"
    case scoreWithValueFormat = "score_with_value_format"
    case retestOnDateFormat = "retest_on_date_format"
    case retestBadgeFormat = "retest_badge_format"
    case repeatTimesFormat = "repeat_times_format"
}

private let pregnancyEnglishByKey: [PregnancyL10nKey: String] = [
    .next: "Next",
    .done: "Done",
    .back: "Back",
    .previous: "Previous",
    .close: "Close",
    .save: "Save",
    .cancel: "Cancel",
    .openSettings: "Open Settings",
    .ok: "OK",
    .tips: "Tips",
    .important: "Important",
    .recommendations: "Recommendations",
    .score: "Score",
    .viewHistory: "View History",
    .upgrade: "Upgrade",
    .enableNotificationsTitle: "Enable Notifications",
    .enableNotificationsMessage: "Please enable notifications in Settings to receive reminders.",
    .reminderCreatedTitle: "Reminder Created",
    .reminderCreatedMessage: "Your pregnancy test reminder has been added.",
    .dayOfCycleFormat: "Day %d of %d",
    .predictionDaysAwayFormat: "%d days away",
    .scoreWithValueFormat: "Score: %d",
    .retestOnDateFormat: "Retest on %@ if your period is still late.",
    .retestBadgeFormat: "Retest: %@",
    .repeatTimesFormat: "Repeat %d times"
]

private let pregnancyChineseByKey: [PregnancyL10nKey: String] = [
    .next: "下一步",
    .done: "完成",
    .back: "返回",
    .previous: "上一页",
    .close: "关闭",
    .save: "保存",
    .cancel: "取消",
    .openSettings: "打开设置",
    .ok: "确定",
    .tips: "提示",
    .important: "重要",
    .recommendations: "建议",
    .score: "得分",
    .viewHistory: "查看历史",
    .upgrade: "升级",
    .enableNotificationsTitle: "开启通知",
    .enableNotificationsMessage: "请在系统设置中开启通知，以接收提醒。",
    .reminderCreatedTitle: "提醒已创建",
    .reminderCreatedMessage: "已添加妊娠测试提醒。",
    .dayOfCycleFormat: "周期第 %d / %d 天",
    .predictionDaysAwayFormat: "%d 天后",
    .scoreWithValueFormat: "得分：%d",
    .retestOnDateFormat: "如果月经仍未到来，请在 %@ 复测。",
    .retestBadgeFormat: "复测：%@",
    .repeatTimesFormat: "重复 %d 次"
]

private let pregnancyRawChinese: [String: String] = [
    "Pregnancy": "怀孕",
    "Center": "中心",
    "NURTURING YOUR JOURNEY": "陪伴你的旅程",
    "FEATURED": "精选",
    "Learn About\nPregnancy": "了解\n怀孕",
    "Essential guide for your 9 months": "为你孕期旅程准备的基础指南",
    "When Should I Test?": "我该何时测试？",
    "Find the right timing for accurate results": "掌握正确时间，提高结果准确性",
    "Probability": "概率评估",
    "Self Check": "自我检测",
    "Cycle Tracker": "周期追踪",
    "Monitor Period": "经期监测",
    "Support": "支持",
    "Emotional": "情绪",
    "Testing": "检测",
    "How to use": "使用方法",
    "Reminders": "提醒",
    "Set Alerts & Appointments": "设置提醒与安排",
    "Medical Disclaimer": "医疗免责声明",
    "Learn About Pregnancy": "了解怀孕",
    "How to Use a Test": "如何使用测试",
    "Choose your situation": "请选择你的情况",
    "Why This Timing?": "为什么这个时间点？",
    "Got It": "知道了",
    "Best Time": "最佳时间",
    "Time of Day": "测试时段",
    "Accuracy": "准确度",
    "Step-by-Step Guide": "分步指南",
    "Emotional Support": "情绪支持",
    "Current Phase": "当前阶段",
    "days": "天",
    "Cycle Settings": "周期设置",
    "Last Period": "最近一次月经",
    "Cycle Length": "周期长度",
    "Period Length": "经期长度",
    "Predictions": "预测",
    "Next Period": "下次月经",
    "Ovulation": "排卵期",
    "Fertile Window": "易孕期",
    "Estimated": "预估",
    "This is a basic tracker for reference only. For accurate fertility tracking, consult a healthcare provider.": "本追踪仅供参考。若需更准确的生育追踪，请咨询专业医生。",
    "No Reminders Yet": "暂无提醒",
    "Tap + to add your first pregnancy test reminder": "点击 + 添加你的第一个妊娠测试提醒",
    "Free plan: 1 enabled pregnancy test reminder. Upgrade for unlimited.": "免费版最多启用 1 个妊娠测试提醒，升级后可无限使用。",
    "No history yet": "暂无历史记录",
    "Complete the self-check to save your first result.": "完成一次自测后即可保存首条结果。",
    "Unlock full history": "解锁完整历史",
    "Upgrade to see all your previous assessments and retest dates.": "升级后可查看所有历史评估与复测日期。",
    "Assessment History": "评估历史",
    "Low Probability": "低概率",
    "Moderate Probability": "中等概率",
    "Higher Probability": "较高概率",
    "Result": "结果",
    "Suggested Retest Date": "建议复测日期",
    "Unlock Smart Retest Plan": "解锁智能复测计划",
    "Get a personalized testing window and one-tap reminders": "获取个性化测试窗口与一键提醒",
    "Smart Retest Plan": "智能复测计划",
    "Personalized next steps": "个性化下一步建议",
    "Best testing window": "最佳测试窗口",
    "Start": "开始",
    "End": "结束",
    "If the result is negative": "如果结果为阴性",
    "Add Retest Reminder": "添加复测提醒",
    "PRO": "专业版",
    "Use first morning urine when possible.": "尽量使用晨尿进行测试。",
    "Follow the test instructions and timing exactly.": "严格按照试纸说明和时间读取结果。",
    "This is educational guidance, not a diagnosis.": "这是教育性建议，不构成诊断。",
    "Pregnancy Test (Retest)": "妊娠测试（复测）",
    "Suggested retest date from Pregnancy self-check.": "来自怀孕自测的建议复测日期。",
    "Set Up Your Cycle": "设置你的周期",
    "Enter your last period date and typical cycle length to get more accurate predictions.": "填写最近一次月经日期和典型周期长度，以获得更准确预测。",
    "While Waiting": "等待期间",
    "If Negative": "阴性结果时",
    "If Positive": "阳性结果时",
    "Breathing Exercise": "呼吸练习",
    "Tap to Start": "点击开始",
    "Inhale...": "吸气...",
    "Hold...": "屏气...",
    "Exhale...": "呼气...",
    "Done ✓": "完成 ✓",
    "Inhale": "吸气",
    "Hold": "屏气",
    "Exhale": "呼气",
    "Next Steps": "下一步",
    "Wait for expected period": "等待预计月经日",
    "Test if period is late": "若月经推迟则进行测试",
    "Test after missed period": "月经推迟后测试",
    "Consider retesting if negative": "若为阴性可考虑复测",
    "Take a home pregnancy test": "进行一次家庭妊娠测试",
    "Consider medical confirmation": "考虑进行医疗确认",
    "When Should I Test": "我该何时测试",
    "Testing Guide": "测试指南",
    "Set Reminder": "设置提醒",
    "Select all that apply": "可多选",
    "Timing": "时间",
    "Ovulation Window": "排卵窗口",
    "Protection": "防护",
    "Period Status": "月经状态",
    "Symptoms": "症状",
    "When was your last unprotected intercourse?": "你上次无保护性行为是什么时候？",
    "Within 3 days": "3 天内",
    "4–7 days ago": "4–7 天前",
    "1–2 weeks ago": "1–2 周前",
    "More than 2 weeks ago": "2 周以上",
    "Not applicable": "不适用",
    "Was it during your ovulation window?": "是否处于排卵期内？",
    "Yes": "是",
    "Possibly": "可能",
    "No": "否",
    "I don't know": "不确定",
    "Ovulation typically occurs 10-16 days before your next period": "排卵通常发生在下次月经前 10-16 天",
    "Did you use contraception?": "是否采取了避孕措施？",
    "No protection": "未采取防护",
    "Condom used": "使用避孕套",
    "Birth control pill": "服用避孕药",
    "Emergency contraception": "紧急避孕",
    "I'm not sure": "不确定",
    "Has your period been missed?": "月经是否推迟？",
    "Too early to know": "现在还无法判断",
    "Have you noticed any symptoms?": "是否出现以下症状？",
    "Nausea": "恶心",
    "Fatigue": "疲劳",
    "Breast tenderness": "乳房胀痛",
    "Cramping": "痉挛/腹痛",
    "None": "无",
    "⚠️ Symptoms alone do not confirm pregnancy": "⚠️ 仅靠症状无法确认是否怀孕",
    "This self-check provides educational guidance based on your answers.\n\nIt does not diagnose pregnancy.": "本自测基于你的回答提供教育性建议。\n\n不用于医学诊断。",
    "If your exposure was recent, testing may be too early for accurate results.\n\nConsider retesting on the suggested date for more reliable results.": "如果近期才发生暴露，当前测试可能过早而影响准确性。\n\n建议在推荐日期复测以获得更可靠结果。",
    "This assessment is for informational purposes only. It does not diagnose pregnancy or replace medical testing. Only certified pregnancy tests can determine pregnancy status. Please consult a healthcare professional for medical advice.": "本评估仅用于信息参考，不用于诊断，也不能替代医学检测。是否怀孕需以正规妊娠检测为准，如有疑问请咨询专业医生。",
    "I missed my period": "我月经推迟了",
    "Before my period is due": "在预计月经日前",
    "After unprotected sex": "无保护性行为后",
    "I have irregular cycles": "我的周期不规律",
    "My period is late": "月经迟到了",
    "Want to test early": "想提前测试",
    "Recent exposure": "近期有暴露",
    "Unpredictable timing": "时间不规律",
    "Test Now": "现在测试",
    "Wait a Few Days": "再等几天",
    "Wait 2-3 Weeks": "等待 2-3 周",
    "Test Regularly": "定期测试",
    "Anytime now": "现在即可",
    "1-2 days before period": "月经前 1-2 天",
    "2-3 weeks after": "2-3 周后",
    "Every 2-3 weeks": "每 2-3 周",
    "First morning urine": "晨尿",
    "99% accurate": "约 99% 准确",
    "Variable (60-90%)": "波动较大（60%-90%）",
    "99% after 3 weeks": "3 周后约 99%",
    "99% when positive": "阳性时约 99%",
    "See Result": "查看结果",
    "Track your menstrual cycle": "追踪你的月经周期",
    "How Pregnancy Happens": "怀孕是如何发生的",
    "What Is hCG?": "什么是 hCG？",
    "Possible Early Signs": "可能的早期迹象",
    "What is Pregnancy?": "什么是怀孕？",
    "A natural process where a fertilized egg develops into a baby inside the uterus.": "受精卵在子宫内发育成胎儿的自然过程。",
    "Why Learn?": "为什么要了解？",
    "Understanding the basics helps you make informed decisions about your health.": "了解基础知识有助于你对健康做出更明智决定。",
    "The ovary releases an egg, usually 10–16 days before your next period.": "卵巢释放卵子，通常发生在下次月经前 10-16 天。",
    "Sperm meets the egg in the fallopian tube.": "精子在输卵管与卵子结合。",
    "The fertilized egg attaches to the uterine wall, starting pregnancy.": "受精卵附着在子宫壁后，怀孕开始。",
    "Rises in Early Pregnancy": "早孕期上升",
    "hCG levels increase rapidly in the first weeks.": "hCG 水平在最初几周快速上升。",
    "Timing Matters": "时机很重要",
    "Testing too early may not detect hCG levels.": "测试过早可能检测不到足够 hCG。",
    "Levels Increase Over Time": "数值会随时间升高",
    "hCG doubles roughly every 48–72 hours in early pregnancy.": "早孕期 hCG 大约每 48-72 小时翻倍。",
    "Missed Period": "月经推迟",
    "Often the first noticeable sign.": "通常是最早可察觉的迹象。",
    "Fatigue & Nausea": "疲劳和恶心",
    "Feeling unusually tired or experiencing morning sickness.": "感觉异常疲惫或出现晨吐。",
    "Other Changes": "其他变化",
    "Breast tenderness, mild cramping, frequent urination.": "乳房胀痛、轻微腹痛、尿频。",
    "Symptoms alone cannot confirm pregnancy. Testing is required.": "仅靠症状无法确认怀孕，仍需检测。",
    "Choose the Right Time": "选择合适测试时间",
    "Timing is crucial for accurate results. Test at the right moment for best accuracy.": "时机对结果准确性很关键，请在合适时间检测。",
    "Wait until the first day of your missed period for most accurate results": "最好等到月经推迟第一天再测，结果更准确。",
    "Use first morning urine - it has the highest concentration of hCG": "使用晨尿，hCG 浓度通常更高。",
    "If testing early, use a sensitive test (10-25 mIU/mL)": "若提前测试，建议使用高敏试纸（10-25 mIU/mL）。",
    "Avoid drinking too much liquid before testing": "测试前避免大量饮水。",
    "Set a reminder for the best testing day": "为最佳测试日设置提醒。",
    "Keep the test at room temperature before use": "使用前将试纸置于室温。",
    "Check the expiration date on the package": "检查包装上的有效期。",
    "Collect Your Sample": "采集样本",
    "Proper sample collection ensures reliable test results.": "正确采样能提高结果可靠性。",
    "Use a clean, dry container if collecting urine": "留尿时请使用干净、干燥容器。",
    "Collect midstream urine for best results": "建议采集中段尿。",
    "Use the sample within 10 minutes of collection": "采样后 10 分钟内使用。",
    "Make sure the test stick doesn't touch anything else": "确保试纸吸收端不要接触其他物体。",
    "Wash hands before handling the test": "操作前先洗手。",
    "Read all instructions before starting": "开始前先完整阅读说明。",
    "Have a timer ready to track waiting time": "准备计时器以准确计时。",
    "Perform the Test": "进行测试",
    "Follow the test instructions carefully for accurate results.": "请严格按说明操作以保证准确。",
    "Remove the test from its wrapper just before use": "使用前再拆开包装。",
    "Hold the absorbent tip in urine stream for 5-10 seconds": "将吸收端置于尿流中 5-10 秒。",
    "Or dip the tip in collected urine for the time specified": "或按说明将吸收端浸入留取尿液指定时间。",
    "Lay the test flat on a clean, dry surface": "将试纸平放在干净干燥表面。",
    "Don't shake excess urine off the test": "不要甩动试纸去除多余尿液。",
    "Keep the test horizontal while waiting": "等待期间保持试纸水平。",
    "Set a timer for the exact waiting time": "设置计时器以控制等待时长。",
    "Read Your Results": "读取结果",
    "Understanding your results correctly is important.": "正确理解结果非常重要。",
    "Wait the exact time specified (usually 3-5 minutes)": "按说明等待准确时间（通常 3-5 分钟）。",
    "Two lines = Positive (even if one is faint)": "两条线 = 阳性（即使一条很浅）。",
    "One line = Negative": "一条线 = 阴性。",
    "No lines or unclear = Invalid test, repeat with new test": "无线或结果不清晰 = 无效，请更换新试纸复测。",
    "Read results within the time window specified": "请在说明规定时窗内读取结果。",
    "A faint line is still a positive result": "浅色线仍可视为阳性。",
    "If unsure, take another test in 2-3 days": "如不确定，可在 2-3 天后复测。",
    "Consult a healthcare provider to confirm": "建议咨询医疗专业人员进行确认。",
    "Your answers suggest a low likelihood of pregnancy.": "你的回答提示怀孕可能性较低。",
    "There is some possibility.": "存在一定可能性。",
    "Pregnancy may be possible.": "有怀孕可能。",
    "If your period is late, pregnancy hormone (hCG) levels should be high enough to detect. Testing with first morning urine provides the most concentrated sample for best results.": "如果月经推迟，hCG 通常已达到可检测水平。使用晨尿检测更有利于提高准确性。",
    "Early testing is possible but less reliable. hCG levels may not be high enough yet. For best accuracy, wait until the day your period is expected or after.": "提前测试可行但可靠性较低，hCG 可能尚不足。建议至少等到预计月经日再测。",
    "It takes about 2-3 weeks after conception for hCG levels to be detectable. Testing too early may give a false negative. Wait at least 2 weeks, ideally 3 weeks for most accurate results.": "受孕后约 2-3 周 hCG 才更容易检出。过早测试可能出现假阴性，建议至少等 2 周，最好 3 周。",
    "With irregular cycles, it's hard to know when to test. Test every 2-3 weeks if you've had unprotected sex, or wait for pregnancy symptoms before testing.": "周期不规律时难以判断测试时机。若有无保护性行为，可每 2-3 周测一次，或出现相关症状后再测。",
    "Use first morning urine for most concentrated hCG": "使用晨尿可获得更高 hCG 浓度。",
    "Read results within the time frame specified": "在说明规定时间内读取结果。",
    "If negative but still no period, retest in 3-5 days": "若阴性但月经仍未来，3-5 天后复测。",
    "Early tests are less reliable - be prepared for false negatives": "提前测试可靠性较低，需警惕假阴性。",
    "Use a sensitive test (10-25 mIU/mL)": "建议使用高敏试纸（10-25 mIU/mL）。",
    "Retest on the day your period is due if negative": "若结果为阴性，可在预计月经日当天复测。",
    "Mark your calendar for 2-3 weeks after exposure": "在日历上标记暴露后 2-3 周的复测时间。",
    "Don't test too early to avoid false negatives": "避免过早测试以减少假阴性。",
    "Consider emergency contraception if within 72 hours": "若在 72 小时内，可考虑紧急避孕。",
    "Keep track of when you have unprotected sex": "记录无保护性行为发生时间。",
    "Test regularly if trying to conceive": "若正在备孕，可规律测试。",
    "Consider tracking ovulation with other methods": "可结合其他排卵追踪方式。",
    "It's normal to feel anxious while waiting for results.": "等待结果时感到焦虑很正常。",
    "Deep breathing": "深呼吸",
    "Gentle distractions": "温和分散注意力",
    "Avoid overanalyzing symptoms": "避免过度解读症状",
    "Mixed feelings are normal.": "出现复杂情绪是正常的。",
    "Relief": "如释重负",
    "Disappointment": "失落",
    "Uncertainty": "不确定",
    "Take a moment to breathe.": "先停下来深呼吸一下。",
    "Confirm with healthcare provider": "与医疗专业人员确认",
    "Discuss options": "讨论可选方案",
    "Seek support": "寻求支持",
    "A simple exercise to help you feel calm.": "一个帮助你平静下来的简单练习。",
    "STEP": "步骤"
]

private let zhLocale = Locale(identifier: "zh-Hans")
private let enLocale = Locale(identifier: "en_US")

func effectiveLanguage(for module: LocalizedModule) -> LocalizedLanguage {
    #if DEBUG
    let overrideRaw = UserDefaults.standard.string(forKey: "moduleLanguageOverride") ?? "Auto"
    switch overrideRaw {
    case "English":
        return .english
    case "Chinese":
        return .chinese
    default:
        break
    }
    #endif

    let preferred = Locale.preferredLanguages.first?.lowercased() ?? "en"
    if preferred.hasPrefix("zh") {
        return .chinese
    }
    return .english
}

func pregnancyText(_ key: PregnancyL10nKey) -> String {
    switch effectiveLanguage(for: .pregnancy) {
    case .english:
        return pregnancyEnglishByKey[key] ?? key.rawValue
    case .chinese:
        return pregnancyChineseByKey[key] ?? pregnancyEnglishByKey[key] ?? key.rawValue
    }
}

func pregnancyFormat(_ key: PregnancyL10nKey, _ arguments: CVarArg...) -> String {
    let format = pregnancyText(key)
    let locale = effectiveLanguage(for: .pregnancy) == .chinese ? zhLocale : enLocale
    return String(format: format, locale: locale, arguments: arguments)
}

func pregnancyRawText(_ text: String) -> String {
    guard effectiveLanguage(for: .pregnancy) == .chinese else {
        return text
    }
    return pregnancyRawChinese[text] ?? text
}
