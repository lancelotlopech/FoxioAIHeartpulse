//
//  HIVEducation.swift
//  HeartRateSenior
//
//  HIV Education Content Model
//

import Foundation

// MARK: - HIV Education Section
struct HIVSection: Identifiable {
    let id: Int
    let title: String
    let content: String
    let bulletPoints: [String]?
    let keyPoints: [HIVKeyPoint]?
    let transmissionInfo: HIVTransmissionInfo?
    let symptoms: [String]?
    let importantNote: String?
    let testingInfo: HIVTestingInfo?
    let windowPeriod: HIVWindowPeriod?
    let whenToTest: [String]?
    let testingMethods: [HIVTestingMethod]?
    let timingGuidance: [HIVTimingGuidance]?
    let testExpectations: HIVTestExpectation?
}

// MARK: - HIV Key Point
struct HIVKeyPoint: Identifiable {
    let id = UUID()
    let icon: String
    let text: String
}

// MARK: - HIV Transmission Info
struct HIVTransmissionInfo {
    let transmittedThrough: [String]
    let notTransmittedThrough: [String]
}

// MARK: - HIV Testing Info
struct HIVTestingInfo {
    let detects: [String]
    let note: String
}

// MARK: - HIV Window Period
struct HIVWindowPeriod {
    let description: String
    let testTypes: [HIVTestType]
    let tip: String
}

struct HIVTestType: Identifiable {
    let id = UUID()
    let name: String
    let detectableAfter: String
}

// MARK: - HIV Testing Method
struct HIVTestingMethod: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let pros: [String]
    let cons: [String]
    let details: [String]
}

// MARK: - HIV Timing Guidance
struct HIVTimingGuidance: Identifiable {
    let id = UUID()
    let daysRange: String
    let status: TimingStatus
    let guidance: String
    let icon: String
    let color: String
}

enum TimingStatus {
    case tooEarly
    case earlyTest
    case reliable
}

// MARK: - HIV Test Expectation
struct HIVTestExpectation {
    let title: String
    let items: [String]
    let reminders: [String]
    let tipCard: String
}

// MARK: - HIV Education Data
struct HIVEducationData {
    static let sections: [HIVSection] = [
        // Section 1: What is HIV?
        HIVSection(
            id: 1,
            title: "What Is HIV?",
            content: """
            HIV (Human Immunodeficiency Virus) is a virus that attacks the immune system, specifically CD4 cells (T cells), which help the body fight infections.
            
            If HIV is not detected and treated, it can weaken the immune system over time and increase the risk of other infections.
            
            With early testing and proper medical care, people living with HIV can live long, healthy lives.
            """,
            bulletPoints: nil,
            keyPoints: [
                HIVKeyPoint(icon: "shield.lefthalf.filled", text: "HIV affects the immune system"),
                HIVKeyPoint(icon: "hand.raised.fill", text: "It does not spread through daily contact"),
                HIVKeyPoint(icon: "lightbulb.fill", text: "Early awareness makes a big difference")
            ],
            transmissionInfo: nil,
            symptoms: nil,
            importantNote: nil,
            testingInfo: nil,
            windowPeriod: nil,
            whenToTest: nil,
            testingMethods: nil,
            timingGuidance: nil,
            testExpectations: nil
        ),
        
        // Section 2: How is HIV Transmitted?
        HIVSection(
            id: 2,
            title: "How HIV Is Transmitted",
            content: """
            HIV is transmitted through specific bodily fluids from a person who has HIV.
            
            These fluids include:
            • Blood
            • Semen and pre-seminal fluid
            • Vaginal fluids
            • Rectal fluids
            • Breast milk
            
            HIV can enter the body through mucous membranes, damaged tissue, or direct injection into the bloodstream.
            """,
            bulletPoints: nil,
            keyPoints: nil,
            transmissionInfo: HIVTransmissionInfo(
                transmittedThrough: [
                    "Unprotected vaginal or anal sex",
                    "Sharing needles or syringes",
                    "From mother to child during pregnancy, birth, or breastfeeding"
                ],
                notTransmittedThrough: [
                    "Hugging or touching",
                    "Sharing food or drinks",
                    "Using the same toilet",
                    "Mosquito bites"
                ]
            ),
            symptoms: nil,
            importantNote: nil,
            testingInfo: nil,
            windowPeriod: nil,
            whenToTest: nil,
            testingMethods: nil,
            timingGuidance: nil,
            testExpectations: nil
        ),
        
        // Section 3: Early Symptoms
        HIVSection(
            id: 3,
            title: "Possible Early Signs",
            content: "Some people may experience flu-like symptoms within 2–4 weeks after HIV exposure. Others may have no symptoms at all.",
            bulletPoints: nil,
            keyPoints: nil,
            transmissionInfo: nil,
            symptoms: [
                "Fever",
                "Fatigue",
                "Sore throat",
                "Swollen lymph nodes",
                "Muscle or joint pain",
                "Rash"
            ],
            importantNote: """
            Having symptoms does NOT mean you have HIV.
            Not having symptoms does NOT mean you are HIV-negative.
            
            Testing is the only way to know your HIV status.
            """,
            testingInfo: nil,
            windowPeriod: nil,
            whenToTest: nil,
            testingMethods: nil,
            timingGuidance: nil,
            testExpectations: nil
        ),
        
        // Section 4: How HIV Testing Works
        HIVSection(
            id: 4,
            title: "How HIV Is Tested",
            content: "HIV testing detects either antibodies produced by the body, antigens from the virus, or both.\n\nDifferent tests detect HIV at different times after exposure. This period is called the \"window period.\"",
            bulletPoints: nil,
            keyPoints: nil,
            transmissionInfo: nil,
            symptoms: nil,
            importantNote: nil,
            testingInfo: HIVTestingInfo(
                detects: [
                    "Antibodies produced by the body",
                    "Antigens from the virus",
                    "Or both"
                ],
                note: "Different tests detect HIV at different times after exposure."
            ),
            windowPeriod: nil,
            whenToTest: nil,
            testingMethods: [
                HIVTestingMethod(
                    icon: "cross.case.fill",
                    title: "Clinic/Lab Testing",
                    description: "Most accurate and comprehensive",
                    pros: [
                        "Highly accurate results",
                        "Professional guidance available",
                        "Can detect HIV earlier"
                    ],
                    cons: [
                        "Requires appointment",
                        "Results may take days"
                    ],
                    details: [
                        "Blood sample taken by healthcare professional",
                        "Sent to laboratory for analysis",
                        "Results typically in 1-3 days"
                    ]
                ),
                HIVTestingMethod(
                    icon: "timer",
                    title: "Rapid Tests",
                    description: "Quick results at clinics or testing centers",
                    pros: [
                        "Results in 20-30 minutes",
                        "No lab required",
                        "Professional support on-site"
                    ],
                    cons: [
                        "May need confirmation test",
                        "Slightly longer window period"
                    ],
                    details: [
                        "Blood from finger prick or oral fluid",
                        "Results while you wait",
                        "Positive results should be confirmed"
                    ]
                ),
                HIVTestingMethod(
                    icon: "house.fill",
                    title: "Home Test Kits",
                    description: "Private testing at home",
                    pros: [
                        "Complete privacy",
                        "Convenient timing",
                        "No appointment needed"
                    ],
                    cons: [
                        "Must follow instructions carefully",
                        "Limited support available",
                        "Positive results need confirmation"
                    ],
                    details: [
                        "Oral fluid or blood sample",
                        "Results in 20-40 minutes",
                        "Follow-up testing recommended"
                    ]
                )
            ],
            timingGuidance: nil,
            testExpectations: nil
        ),
        
        // Section 5: Window Period
        HIVSection(
            id: 5,
            title: "Understanding the Window Period",
            content: "The window period is the time between potential HIV exposure and when a test can reliably detect HIV.\n\nDuring this time, a person may test negative even if HIV is present.",
            bulletPoints: nil,
            keyPoints: nil,
            transmissionInfo: nil,
            symptoms: nil,
            importantNote: nil,
            testingInfo: nil,
            windowPeriod: HIVWindowPeriod(
                description: "Time until test can detect HIV:",
                testTypes: [
                    HIVTestType(name: "Antibody test", detectableAfter: "3–12 weeks"),
                    HIVTestType(name: "Antigen/antibody test", detectableAfter: "2–6 weeks"),
                    HIVTestType(name: "Nucleic acid test (NAT)", detectableAfter: "1–4 weeks")
                ],
                tip: "For the most accurate results, repeat testing may be recommended after the window period has passed."
            ),
            whenToTest: nil,
            testingMethods: nil,
            timingGuidance: [
                HIVTimingGuidance(
                    daysRange: "0-7 days",
                    status: .tooEarly,
                    guidance: "Too early for reliable testing",
                    icon: "exclamationmark.triangle.fill",
                    color: "red"
                ),
                HIVTimingGuidance(
                    daysRange: "14-28 days",
                    status: .earlyTest,
                    guidance: "Early testing possible, retest recommended",
                    icon: "clock.fill",
                    color: "orange"
                ),
                HIVTimingGuidance(
                    daysRange: "45+ days",
                    status: .reliable,
                    guidance: "Most reliable testing window",
                    icon: "checkmark.circle.fill",
                    color: "green"
                )
            ],
            testExpectations: nil
        ),
        
        // Section 6: When to Test
        HIVSection(
            id: 6,
            title: "When to Get Tested",
            content: "You may consider HIV testing if:",
            bulletPoints: nil,
            keyPoints: nil,
            transmissionInfo: nil,
            symptoms: nil,
            importantNote: nil,
            testingInfo: nil,
            windowPeriod: nil,
            whenToTest: [
                "You had unprotected sex",
                "You are unsure of a partner's HIV status",
                "You shared needles or injection equipment",
                "You want peace of mind"
            ],
            testingMethods: nil,
            timingGuidance: nil,
            testExpectations: nil
        ),
        
        // Section 7: How to Test
        HIVSection(
            id: 7,
            title: "Choose a Testing Method",
            content: "There are three main ways to get tested for HIV. Each has its own advantages depending on your needs and situation.",
            bulletPoints: nil,
            keyPoints: nil,
            transmissionInfo: nil,
            symptoms: nil,
            importantNote: nil,
            testingInfo: nil,
            windowPeriod: nil,
            whenToTest: nil,
            testingMethods: [
                HIVTestingMethod(
                    icon: "cross.case.fill",
                    title: "Clinic/Lab Testing",
                    description: "Most accurate and comprehensive",
                    pros: [
                        "Highly accurate results",
                        "Professional guidance available",
                        "Can detect HIV earlier",
                        "Confirmatory testing included"
                    ],
                    cons: [
                        "Requires appointment",
                        "Results may take 1-3 days",
                        "Less privacy"
                    ],
                    details: [
                        "Blood sample taken by healthcare professional",
                        "Sent to laboratory for analysis",
                        "Follow-up consultation available",
                        "Best for definitive results"
                    ]
                ),
                HIVTestingMethod(
                    icon: "timer",
                    title: "Rapid Tests",
                    description: "Quick results at clinics or testing centers",
                    pros: [
                        "Results in 20-30 minutes",
                        "No lab required",
                        "Professional support on-site",
                        "Same-day peace of mind"
                    ],
                    cons: [
                        "May need confirmation test if positive",
                        "Slightly longer window period"
                    ],
                    details: [
                        "Blood from finger prick or oral fluid",
                        "Results while you wait",
                        "Positive results should be confirmed"
                    ]
                ),
                HIVTestingMethod(
                    icon: "house.fill",
                    title: "Home Test Kits",
                    description: "Private testing at home",
                    pros: [
                        "Complete privacy",
                        "Convenient timing",
                        "No appointment needed"
                    ],
                    cons: [
                        "Must follow instructions carefully",
                        "Limited support available",
                        "Positive results need confirmation"
                    ],
                    details: [
                        "Oral fluid or blood sample",
                        "Results in 20-40 minutes",
                        "Follow-up testing recommended"
                    ]
                )
            ],
            timingGuidance: nil,
            testExpectations: nil
        ),
        
        // Section 8: What to Expect
        HIVSection(
            id: 8,
            title: "Prepare Yourself",
            content: "Knowing what to expect can help you feel more comfortable and confident about getting tested.",
            bulletPoints: nil,
            keyPoints: nil,
            transmissionInfo: nil,
            symptoms: nil,
            importantNote: nil,
            testingInfo: nil,
            windowPeriod: nil,
            whenToTest: nil,
            testingMethods: nil,
            timingGuidance: nil,
            testExpectations: HIVTestExpectation(
                title: "What to Expect During Testing",
                items: [
                    "You may feel nervous — this is completely normal",
                    "Blood or oral fluid may be used depending on the test",
                    "Rapid test results are usually available in minutes",
                    "Lab-based results may take several days",
                    "Testing is safe, confidential, and widely available"
                ],
                reminders: [
                    "Remember: testing is a responsible and empowering step",
                    "Early retesting may be recommended for recent exposures",
                    "Routine testing helps maintain long-term health"
                ],
                tipCard: "If your first test was during the window period, consider retesting after 14–45 days based on your exposure risk."
            )
        )
    ]
    
    static let disclaimer = """
    This app provides educational and informational content only. It does not provide medical advice, diagnosis, or treatment. HIV testing results should always be confirmed by certified medical tests. Please consult a healthcare professional for medical guidance.
    """
    
    static let ctaText = """
    Understanding HIV is the first step.
    Next, you can answer a few questions to better understand your potential risk.
    """

    static var localizedSections: [HIVSection] {
        sections.map { $0.localized() }
    }

    static var localizedDisclaimer: String {
        hivRawText(disclaimer)
    }

    static var localizedCtaText: String {
        hivRawText(ctaText)
    }
}

// MARK: - Localization Helpers
extension HIVSection {
    func localized() -> HIVSection {
        HIVSection(
            id: id,
            title: hivRawText(title),
            content: hivRawText(content),
            bulletPoints: bulletPoints?.map { hivRawText($0) },
            keyPoints: keyPoints?.map { $0.localized() },
            transmissionInfo: transmissionInfo?.localized(),
            symptoms: symptoms?.map { hivRawText($0) },
            importantNote: importantNote.map { hivRawText($0) },
            testingInfo: testingInfo?.localized(),
            windowPeriod: windowPeriod?.localized(),
            whenToTest: whenToTest?.map { hivRawText($0) },
            testingMethods: testingMethods?.map { $0.localized() },
            timingGuidance: timingGuidance?.map { $0.localized() },
            testExpectations: testExpectations?.localized()
        )
    }
}

extension HIVKeyPoint {
    func localized() -> HIVKeyPoint {
        HIVKeyPoint(icon: icon, text: hivRawText(text))
    }
}

extension HIVTransmissionInfo {
    func localized() -> HIVTransmissionInfo {
        HIVTransmissionInfo(
            transmittedThrough: transmittedThrough.map { hivRawText($0) },
            notTransmittedThrough: notTransmittedThrough.map { hivRawText($0) }
        )
    }
}

extension HIVTestingInfo {
    func localized() -> HIVTestingInfo {
        HIVTestingInfo(
            detects: detects.map { hivRawText($0) },
            note: hivRawText(note)
        )
    }
}

extension HIVWindowPeriod {
    func localized() -> HIVWindowPeriod {
        HIVWindowPeriod(
            description: hivRawText(description),
            testTypes: testTypes.map { $0.localized() },
            tip: hivRawText(tip)
        )
    }
}

extension HIVTestType {
    func localized() -> HIVTestType {
        HIVTestType(name: hivRawText(name), detectableAfter: hivRawText(detectableAfter))
    }
}

extension HIVTestingMethod {
    func localized() -> HIVTestingMethod {
        HIVTestingMethod(
            icon: icon,
            title: hivRawText(title),
            description: hivRawText(description),
            pros: pros.map { hivRawText($0) },
            cons: cons.map { hivRawText($0) },
            details: details.map { hivRawText($0) }
        )
    }
}

extension HIVTimingGuidance {
    func localized() -> HIVTimingGuidance {
        HIVTimingGuidance(
            daysRange: hivRawText(daysRange),
            status: status,
            guidance: hivRawText(guidance),
            icon: icon,
            color: color
        )
    }
}

extension HIVTestExpectation {
    func localized() -> HIVTestExpectation {
        HIVTestExpectation(
            title: hivRawText(title),
            items: items.map { hivRawText($0) },
            reminders: reminders.map { hivRawText($0) },
            tipCard: hivRawText(tipCard)
        )
    }
}
