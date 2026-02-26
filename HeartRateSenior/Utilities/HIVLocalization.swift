//
//  HIVLocalization.swift
//  HeartRateSenior
//
//  Module-scoped localization for HIV.
//

import Foundation

enum HIVL10nKey: String, CaseIterable {
    case next
    case back
    case previousQuestion = "previous_question"
    case startAssessment = "start_assessment"
    case beforeYouStart = "before_you_start"
    case questionProgressFormat = "question_progress_format"
    case scoreFormat = "score_format"
    case smartRetestSuggestion = "smart_retest_suggestion"
    case days
    case repeatTestingImprovesAccuracy = "repeat_testing_improves_accuracy"
    case retakeAssessment = "retake_assessment"
    case complianceDisclaimer = "compliance_disclaimer"
    case advantages
    case considerations
    case process
    case testType = "test_type"
    case detectableAfter = "detectable_after"
    case testingTimelineAfterExposure = "testing_timeline_after_exposure"
    case checkYourRiskLevel = "check_your_risk_level"
}

private let hivEnglishByKey: [HIVL10nKey: String] = [
    .next: "Next",
    .back: "Back",
    .previousQuestion: "Previous Question",
    .startAssessment: "Start Assessment",
    .beforeYouStart: "Before You Start",
    .questionProgressFormat: "Question %d of %d",
    .scoreFormat: "Score: %d / 30",
    .smartRetestSuggestion: "Smart Retest Suggestion",
    .days: "days",
    .repeatTestingImprovesAccuracy: "Repeat testing improves accuracy.",
    .retakeAssessment: "Retake Assessment",
    .complianceDisclaimer: "Compliance Disclaimer",
    .advantages: "Advantages",
    .considerations: "Considerations",
    .process: "Process",
    .testType: "Test Type",
    .detectableAfter: "Detectable After",
    .testingTimelineAfterExposure: "Testing Timeline After Exposure",
    .checkYourRiskLevel: "Check Your Risk Level"
]

private let hivChineseByKey: [HIVL10nKey: String] = [
    .next: "下一步",
    .back: "返回",
    .previousQuestion: "上一题",
    .startAssessment: "开始评估",
    .beforeYouStart: "开始前须知",
    .questionProgressFormat: "第 %d 题 / 共 %d 题",
    .scoreFormat: "得分：%d / 30",
    .smartRetestSuggestion: "智能复测建议",
    .days: "天",
    .repeatTestingImprovesAccuracy: "复测可提高准确性。",
    .retakeAssessment: "重新自测",
    .complianceDisclaimer: "合规说明",
    .advantages: "优点",
    .considerations: "注意事项",
    .process: "流程",
    .testType: "测试类型",
    .detectableAfter: "可检测时间",
    .testingTimelineAfterExposure: "暴露后检测时间线",
    .checkYourRiskLevel: "查看你的风险水平"
]

private let hivRawChinese: [String: String] = [
    "HIV": "HIV",
    "Awareness": "认知",
    "HIV Awareness": "HIV 认知",
    "PREVENTION & EARLY CARE": "预防与早期关怀",
    "FEATURED": "精选",
    "Learn About\nHIV": "了解\nHIV",
    "Learn About HIV": "了解 HIV",
    "Basics & transmission routes": "基础知识与传播途径",
    "Understanding HIV": "了解 HIV",
    "Prevention, testing & early care": "预防、检测与早期关怀",
    "Prevention, testing & early care steps": "预防、检测与早期关怀",
    "Risk Assessment": "风险评估",
    "Check your risk level with a quick quiz": "通过简短问答了解风险水平",
    "Symptoms": "症状",
    "Identify": "识别",
    "Testing": "检测",
    "Methods": "方法",
    "Timeline": "时间线",
    "When Test": "何时检测",
    "Overview": "概览",
    "All Info": "全部信息",
    "Symptoms & Signs": "症状与体征",
    "Recognize early indicators": "了解早期迹象",
    "Key Takeaway": "关键提示",
    "Timeline & Testing": "时间线与检测",
    "Window period & when to get tested": "窗口期与检测时机",
    "Remember": "温馨提示",
    "Learn about prevention & testing": "了解预防与检测",
    "Regular testing is a responsible step for anyone who is sexually active.": "规律检测是性活跃人群负责任的做法。",
    "Too Early": "过早",
    "Early Test": "可提前检测",
    "Reliable": "可靠",
    "Testing Guide": "检测指南",
    "Methods, process & what to expect": "方法、流程与须知",
    "Can be transmitted:": "可通过以下方式传播：",
    "NOT transmitted:": "不会通过以下方式传播：",
    "Tests detect:": "检测内容：",
    "Now you understand HIV basics.\nReady to check your potential risk?": "你已了解 HIV 基础知识。\n现在来评估你的潜在风险吗？",
    "Start Risk Assessment": "开始风险评估",
    "Medical Disclaimer": "医疗免责声明",
    "Advantages": "优点",
    "Considerations": "注意事项",
    "Process": "流程",
    "What Is HIV?": "什么是 HIV？",
    "How HIV Is Transmitted": "HIV 如何传播",
    "Possible Early Signs": "可能的早期迹象",
    "How HIV Is Tested": "HIV 如何检测",
    "Understanding the Window Period": "了解窗口期",
    "When to Get Tested": "何时检测",
    "Choose a Testing Method": "选择检测方式",
    "Prepare Yourself": "做好准备",
    "HIV (Human Immunodeficiency Virus) is a virus that attacks the immune system, specifically CD4 cells (T cells), which help the body fight infections.\n\nIf HIV is not detected and treated, it can weaken the immune system over time and increase the risk of other infections.\n\nWith early testing and proper medical care, people living with HIV can live long, healthy lives.": "HIV（人类免疫缺陷病毒）是一种攻击免疫系统的病毒，主要影响 CD4 细胞（T 细胞），这些细胞帮助身体抵抗感染。\n\n如果未及时发现和治疗，HIV 会逐渐削弱免疫系统，增加其他感染的风险。\n\n通过早期检测和规范医疗，感染 HIV 的人也可以长期健康生活。",
    "HIV affects the immune system": "HIV 会影响免疫系统",
    "It does not spread through daily contact": "不会通过日常接触传播",
    "Early awareness makes a big difference": "及早了解影响很大",
    "HIV is transmitted through specific bodily fluids from a person who has HIV.\n\nThese fluids include:\n• Blood\n• Semen and pre-seminal fluid\n• Vaginal fluids\n• Rectal fluids\n• Breast milk\n\nHIV can enter the body through mucous membranes, damaged tissue, or direct injection into the bloodstream.": "HIV 通过感染者的特定体液传播。\n\n包括：\n• 血液\n• 精液及射前液\n• 阴道分泌物\n• 直肠分泌物\n• 母乳\n\nHIV 可通过黏膜、破损组织，或直接进入血液而感染。",
    "Unprotected vaginal or anal sex": "无保护的阴道或肛交",
    "Sharing needles or syringes": "共用针具或注射器",
    "From mother to child during pregnancy, birth, or breastfeeding": "母婴传播（孕期、分娩或哺乳）",
    "Hugging or touching": "拥抱或接触",
    "Sharing food or drinks": "共享食物或饮料",
    "Using the same toilet": "共用马桶",
    "Mosquito bites": "蚊虫叮咬",
    "Some people may experience flu-like symptoms within 2–4 weeks after HIV exposure. Others may have no symptoms at all.": "部分人在暴露后 2–4 周内可能出现类似流感的症状，另一些人可能完全无症状。",
    "Fever": "发热",
    "Fatigue": "乏力",
    "Sore throat": "咽喉痛",
    "Swollen lymph nodes": "淋巴结肿大",
    "Muscle or joint pain": "肌肉或关节疼痛",
    "Rash": "皮疹",
    "Having symptoms does NOT mean you have HIV.\nNot having symptoms does NOT mean you are HIV-negative.\n\nTesting is the only way to know your HIV status.": "有症状并不代表感染 HIV。\n没有症状也不代表 HIV 阴性。\n\n检测是了解 HIV 状态的唯一方式。",
    "HIV testing detects either antibodies produced by the body, antigens from the virus, or both.\n\nDifferent tests detect HIV at different times after exposure. This period is called the \"window period.\"": "HIV 检测可检测机体产生的抗体、病毒抗原，或二者同时检测。\n\n不同检测在暴露后可检出的时间不同，这个时间段称为“窗口期”。",
    "Antibodies produced by the body": "机体产生的抗体",
    "Antigens from the virus": "病毒抗原",
    "Or both": "或二者",
    "Different tests detect HIV at different times after exposure.": "不同检测在暴露后可检出的时间不同。",
    "Clinic/Lab Testing": "诊所/实验室检测",
    "Most accurate and comprehensive": "最准确且最全面",
    "Highly accurate results": "结果高度准确",
    "Professional guidance available": "可获得专业指导",
    "Can detect HIV earlier": "可更早检测",
    "Requires appointment": "需要预约",
    "Results may take days": "结果可能需要数天",
    "Blood sample taken by healthcare professional": "由医疗人员采血",
    "Sent to laboratory for analysis": "送实验室分析",
    "Results typically in 1-3 days": "结果通常 1-3 天",
    "Rapid Tests": "快速检测",
    "Quick results at clinics or testing centers": "在诊所或检测点快速出结果",
    "Results in 20-30 minutes": "20-30 分钟出结果",
    "No lab required": "无需实验室",
    "Professional support on-site": "现场提供专业支持",
    "May need confirmation test": "可能需要确认检测",
    "Slightly longer window period": "窗口期略长",
    "Blood from finger prick or oral fluid": "指尖血或口腔液",
    "Results while you wait": "现场等待结果",
    "Positive results should be confirmed": "阳性结果应确认",
    "Home Test Kits": "家用测试盒",
    "Private testing at home": "在家私密检测",
    "Complete privacy": "完全隐私",
    "Convenient timing": "时间方便",
    "No appointment needed": "无需预约",
    "Must follow instructions carefully": "需严格按说明操作",
    "Limited support available": "支持有限",
    "Positive results need confirmation": "阳性结果需确认",
    "Oral fluid or blood sample": "口腔液或血样",
    "Results in 20-40 minutes": "20-40 分钟出结果",
    "Follow-up testing recommended": "建议后续复测",
    "The window period is the time between potential HIV exposure and when a test can reliably detect HIV.\n\nDuring this time, a person may test negative even if HIV is present.": "窗口期是指可能暴露与检测能可靠检出之间的时间。\n\n在此期间，即便感染也可能出现阴性结果。",
    "Time until test can detect HIV:": "检测可检出 HIV 的时间：",
    "Antibody test": "抗体检测",
    "3–12 weeks": "3–12 周",
    "Antigen/antibody test": "抗原/抗体检测",
    "2–6 weeks": "2–6 周",
    "Nucleic acid test (NAT)": "核酸检测（NAT）",
    "1–4 weeks": "1–4 周",
    "For the most accurate results, repeat testing may be recommended after the window period has passed.": "为获得更准确结果，可能建议在窗口期后复测。",
    "0-7 days": "0-7 天",
    "Too early for reliable testing": "过早，检测不可靠",
    "14-28 days": "14-28 天",
    "Early testing possible, retest recommended": "可提前检测，建议复测",
    "45+ days": "45+ 天",
    "Most reliable testing window": "最可靠的检测窗口",
    "You may consider HIV testing if:": "以下情况可考虑检测 HIV：",
    "You had unprotected sex": "曾有无保护性行为",
    "You are unsure of a partner's HIV status": "不确定伴侣的 HIV 状态",
    "You shared needles or injection equipment": "共用针具或注射器",
    "You want peace of mind": "希望获得安心",
    "There are three main ways to get tested for HIV. Each has its own advantages depending on your needs and situation.": "HIV 检测主要有三种方式，可根据需求选择。",
    "Confirmatory testing included": "包含确认性检测",
    "Results may take 1-3 days": "结果可能需要 1-3 天",
    "Less privacy": "隐私性较弱",
    "Follow-up consultation available": "可提供后续咨询",
    "Best for definitive results": "适合获得明确结果",
    "Same-day peace of mind": "当天安心",
    "May need confirmation test if positive": "阳性可能需确认",
    "Knowing what to expect can help you feel more comfortable and confident about getting tested.": "了解流程可让你更安心地去检测。",
    "What to Expect During Testing": "检测时你可以期待什么",
    "You may feel nervous — this is completely normal": "感到紧张是正常的",
    "Blood or oral fluid may be used depending on the test": "可能采集血液或口腔液",
    "Rapid test results are usually available in minutes": "快速检测通常几分钟出结果",
    "Lab-based results may take several days": "实验室结果可能需数天",
    "Testing is safe, confidential, and widely available": "检测安全、保密且获取方便",
    "Remember: testing is a responsible and empowering step": "记住：检测是负责任且积极的一步",
    "Early retesting may be recommended for recent exposures": "近期暴露可能建议早期复测",
    "Routine testing helps maintain long-term health": "常规检测有助于长期健康",
    "If your first test was during the window period, consider retesting after 14–45 days based on your exposure risk.": "若首次检测处于窗口期，可根据风险在 14–45 天后复测。",
    "This app provides educational and informational content only. It does not provide medical advice, diagnosis, or treatment. HIV testing results should always be confirmed by certified medical tests. Please consult a healthcare professional for medical guidance.": "本应用仅提供教育与信息内容，不提供医疗建议、诊断或治疗。HIV 检测结果应由正规医疗检测确认。如需医疗建议，请咨询专业医护人员。",
    "Understanding HIV is the first step.\nNext, you can answer a few questions to better understand your potential risk.": "了解 HIV 是第一步。\n接下来可以通过几个问题了解潜在风险。",
    "HIV Risk Self-Assessment": "HIV 风险自测",
    "This self-assessment is designed to help you understand your potential HIV risk.\n\n• It is not a medical test\n• It does not provide a diagnosis\n• Results are based on your answers\n\nAnswer honestly to get the most accurate result.": "此自测旨在帮助你了解潜在 HIV 风险。\n\n• 这不是医学检测\n• 不提供诊断\n• 结果基于你的回答\n\n请如实作答，以获得更准确的结果。",
    "This assessment is for informational purposes only.\nIt does not diagnose HIV or replace laboratory testing.\n\nOnly certified medical tests can determine HIV status.\nPlease consult a healthcare professional for medical advice.": "本评估仅供参考。\n不用于诊断，也不能替代实验室检测。\n\n只有正规医疗检测才能确定 HIV 状态。\n如需医疗建议，请咨询专业医护人员。",
    "Because HIV tests may not detect infection immediately after exposure, you may consider testing again in:": "由于 HIV 检测在暴露后可能无法立即检出感染，建议在以下时间复测：",
    "Section A: Time Since Possible Exposure": "A 部分：距离可能暴露的时间",
    "When was your most recent possible exposure?": "你最近一次可能的暴露是什么时候？",
    "Within the last 7 days": "过去 7 天内",
    "8–28 days ago": "8–28 天前",
    "1–3 months ago": "1–3 个月前",
    "More than 3 months ago": "超过 3 个月",
    "I'm not sure": "不确定",
    "Recent exposure = higher uncertainty + window period risk": "近期暴露 = 不确定性更高 + 窗口期风险",
    "Section B: Sexual Activity": "B 部分：性行为情况",
    "Have you had sexual contact that may carry HIV risk?": "是否有可能存在 HIV 风险的性接触？",
    "Yes, unprotected anal sex": "是，无保护肛交",
    "Yes, unprotected vaginal sex": "是，无保护阴道性交",
    "Yes, but condom was used": "是，使用了安全套",
    "Oral sex only": "仅口交",
    "No sexual contact": "无性接触",
    "Do you know your partner's HIV status?": "你了解伴侣的 HIV 状态吗？",
    "Partner is HIV-positive or unknown": "伴侣 HIV 阳性或未知",
    "Partner's status unclear": "伴侣状态不清楚",
    "Partner tested HIV-negative recently": "伴侣近期检测为阴性",
    "I have only one long-term partner": "只有一位长期伴侣",
    "Section C: Other Exposure Risks": "C 部分：其他暴露风险",
    "Have you ever shared needles or injection equipment?": "是否共用过针具或注射器？",
    "Yes": "是",
    "Not sure": "不确定",
    "No": "否",
    "Have you had a blood exposure or medical procedure with uncertain safety?": "是否接触过血液或进行过安全性不确定的医疗操作？",
    "Section D: Symptoms Awareness (Non-Diagnostic)": "D 部分：症状了解（非诊断）",
    "Have you experienced any of the following in the past 2–6 weeks?": "过去 2–6 周内是否出现以下情况？",
    "None of the above": "以上均无",
    "⚠️ Symptoms alone do not indicate HIV": "⚠️ 仅靠症状无法判断 HIV",
    "Section E: Testing History": "E 部分：检测情况",
    "Have you been tested for HIV after this exposure?": "在这次暴露后是否进行过 HIV 检测？",
    "No, I have not been tested": "没有，尚未检测",
    "Yes, but within the window period": "有，但在窗口期内",
    "Yes, after the window period": "有，在窗口期之后",
    "I don't remember": "不记得",
    "Low Risk": "低风险",
    "Moderate Risk": "中等风险",
    "Higher Risk": "较高风险",
    "Your answers suggest a low level of HIV exposure risk.": "你的回答提示 HIV 暴露风险较低。",
    "Your answers indicate a moderate potential risk.": "你的回答提示存在中等风险。",
    "Your answers suggest a higher potential exposure risk.": "你的回答提示存在较高风险。",
    "Risk appears minimal": "风险较低",
    "Routine testing is still recommended if sexually active": "若有性行为，仍建议常规检测",
    "Continue practicing safer behaviors": "继续保持更安全的行为",
    "Consider HIV testing for reassurance": "建议进行 HIV 检测以获得安心",
    "If exposure was recent, testing again after the window period may be helpful": "如近期暴露，建议在窗口期后复测",
    "Safer sex practices can reduce future risk": "更安全的性行为可降低未来风险",
    "HIV testing is strongly recommended": "强烈建议进行 HIV 检测",
    "If exposure was recent, results may change after the window period": "如近期暴露，窗口期后结果可能改变",
    "Professional medical advice can provide clarity and support": "专业医疗建议可提供清晰指导与支持",
    "Learn About Prevention": "了解预防",
    "Retake Assessment Later": "稍后再测",
    "Find Testing Information": "查找检测信息",
    "Set a Reminder to Retest": "设置复测提醒",
    "Testing Guidance": "检测指导",
    "Emotional Support Resources": "情绪支持资源",
    "With modern treatment, people living with HIV can lead long, healthy lives. Early detection and consistent treatment are key to managing HIV effectively.": "在现代治疗下，感染 HIV 的人可以长期健康生活。早期发现与持续治疗是有效管理 HIV 的关键。"
]

private let zhLocale = Locale(identifier: "zh-Hans")
private let enLocale = Locale(identifier: "en_US")

func hivText(_ key: HIVL10nKey) -> String {
    switch effectiveLanguage(for: .hiv) {
    case .english:
        return hivEnglishByKey[key] ?? key.rawValue
    case .chinese:
        return hivChineseByKey[key] ?? hivEnglishByKey[key] ?? key.rawValue
    }
}

func hivFormat(_ key: HIVL10nKey, _ arguments: CVarArg...) -> String {
    let format = hivText(key)
    let locale = effectiveLanguage(for: .hiv) == .chinese ? zhLocale : enLocale
    return String(format: format, locale: locale, arguments: arguments)
}

func hivRawText(_ text: String) -> String {
    guard effectiveLanguage(for: .hiv) == .chinese else {
        return text
    }
    return hivRawChinese[text] ?? text
}
