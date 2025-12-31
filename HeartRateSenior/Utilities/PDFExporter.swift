//
//  PDFExporter.swift
//  HeartRateSenior
//
//  PDF generation for heart rate reports
//

import UIKit
import PDFKit

class PDFExporter {
    
    /// Generate a PDF report from heart rate records
    static func generatePDF(from records: [HeartRateRecord]) -> Data? {
        let pageWidth: CGFloat = 612 // US Letter width in points
        let pageHeight: CGFloat = 792 // US Letter height in points
        let margin: CGFloat = 50
        
        let pdfMetaData = [
            kCGPDFContextCreator: "HeartRate Senior",
            kCGPDFContextAuthor: "HeartRate Senior App",
            kCGPDFContextTitle: "Heart Rate Report"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            var yPosition: CGFloat = margin
            
            // Title
            let titleFont = UIFont.systemFont(ofSize: 28, weight: .bold)
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: UIColor.systemRed
            ]
            
            let title = "Heart Rate Report"
            let titleSize = title.size(withAttributes: titleAttributes)
            let titleRect = CGRect(x: (pageWidth - titleSize.width) / 2, y: yPosition, width: titleSize.width, height: titleSize.height)
            title.draw(in: titleRect, withAttributes: titleAttributes)
            
            yPosition += titleSize.height + 10
            
            // Subtitle with date
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            let subtitle = "Generated on \(dateFormatter.string(from: Date()))"
            let subtitleFont = UIFont.systemFont(ofSize: 14, weight: .regular)
            let subtitleAttributes: [NSAttributedString.Key: Any] = [
                .font: subtitleFont,
                .foregroundColor: UIColor.gray
            ]
            let subtitleSize = subtitle.size(withAttributes: subtitleAttributes)
            let subtitleRect = CGRect(x: (pageWidth - subtitleSize.width) / 2, y: yPosition, width: subtitleSize.width, height: subtitleSize.height)
            subtitle.draw(in: subtitleRect, withAttributes: subtitleAttributes)
            
            yPosition += subtitleSize.height + 30
            
            // Summary Section
            yPosition = drawSummarySection(records: records, yPosition: yPosition, pageWidth: pageWidth, margin: margin)
            
            yPosition += 30
            
            // Divider
            let dividerPath = UIBezierPath()
            dividerPath.move(to: CGPoint(x: margin, y: yPosition))
            dividerPath.addLine(to: CGPoint(x: pageWidth - margin, y: yPosition))
            UIColor.lightGray.setStroke()
            dividerPath.lineWidth = 1
            dividerPath.stroke()
            
            yPosition += 20
            
            // Records Table Header
            yPosition = drawTableHeader(yPosition: yPosition, pageWidth: pageWidth, margin: margin)
            
            yPosition += 10
            
            // Records
            let sortedRecords = records.sorted { $0.timestamp > $1.timestamp }
            
            for record in sortedRecords {
                // Check if we need a new page
                if yPosition > pageHeight - 100 {
                    context.beginPage()
                    yPosition = margin
                    yPosition = drawTableHeader(yPosition: yPosition, pageWidth: pageWidth, margin: margin)
                    yPosition += 10
                }
                
                yPosition = drawRecordRow(record: record, yPosition: yPosition, pageWidth: pageWidth, margin: margin)
            }
            
            // Footer
            drawFooter(pageRect: pageRect, margin: margin)
        }
        
        return data
    }
    
    private static func drawSummarySection(records: [HeartRateRecord], yPosition: CGFloat, pageWidth: CGFloat, margin: CGFloat) -> CGFloat {
        var y = yPosition
        
        let headerFont = UIFont.systemFont(ofSize: 18, weight: .semibold)
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: headerFont,
            .foregroundColor: UIColor.black
        ]
        
        let valueFont = UIFont.systemFont(ofSize: 16, weight: .regular)
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: valueFont,
            .foregroundColor: UIColor.darkGray
        ]
        
        // Summary header
        let summaryTitle = "Summary"
        summaryTitle.draw(at: CGPoint(x: margin, y: y), withAttributes: headerAttributes)
        y += 30
        
        // Calculate statistics
        let bpmValues = records.map { $0.bpm }
        let avgBPM = bpmValues.isEmpty ? 0 : bpmValues.reduce(0, +) / bpmValues.count
        let minBPM = bpmValues.min() ?? 0
        let maxBPM = bpmValues.max() ?? 0
        
        // Date range
        let sortedRecords = records.sorted { $0.timestamp < $1.timestamp }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let dateRange: String
        if let first = sortedRecords.first, let last = sortedRecords.last {
            dateRange = "\(dateFormatter.string(from: first.timestamp)) - \(dateFormatter.string(from: last.timestamp))"
        } else {
            dateRange = "No records"
        }
        
        // Calculate HRV statistics
        let recordsWithHRV = records.filter { $0.hasHRVData }
        let hrvValues = recordsWithHRV.compactMap { $0.hrvRMSSD }
        let avgHRV = hrvValues.isEmpty ? nil : hrvValues.reduce(0, +) / Double(hrvValues.count)
        
        // Draw summary items
        var summaryItems = [
            ("Total Measurements:", "\(records.count)"),
            ("Date Range:", dateRange),
            ("Average Heart Rate:", "\(avgBPM) BPM"),
            ("Minimum Heart Rate:", "\(minBPM) BPM"),
            ("Maximum Heart Rate:", "\(maxBPM) BPM")
        ]
        
        // Add HRV summary if available
        if let avgHRV = avgHRV {
            summaryItems.append(("HRV Measurements:", "\(recordsWithHRV.count)"))
            summaryItems.append(("Average HRV (RMSSD):", String(format: "%.1f ms", avgHRV)))
        }
        
        for (label, value) in summaryItems {
            let labelWidth: CGFloat = 180
            label.draw(at: CGPoint(x: margin, y: y), withAttributes: valueAttributes)
            value.draw(at: CGPoint(x: margin + labelWidth, y: y), withAttributes: valueAttributes)
            y += 25
        }
        
        return y
    }
    
    private static func drawTableHeader(yPosition: CGFloat, pageWidth: CGFloat, margin: CGFloat) -> CGFloat {
        let headerFont = UIFont.systemFont(ofSize: 12, weight: .semibold)
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: headerFont,
            .foregroundColor: UIColor.black
        ]
        
        let columns: [(String, CGFloat)] = [
            ("Date & Time", margin),
            ("BPM", margin + 140),
            ("HRV", margin + 200),
            ("Activity", margin + 280),
            ("Synced", margin + 380)
        ]
        
        for (title, x) in columns {
            title.draw(at: CGPoint(x: x, y: yPosition), withAttributes: headerAttributes)
        }
        
        // Underline
        let underlinePath = UIBezierPath()
        underlinePath.move(to: CGPoint(x: margin, y: yPosition + 20))
        underlinePath.addLine(to: CGPoint(x: pageWidth - margin, y: yPosition + 20))
        UIColor.black.setStroke()
        underlinePath.lineWidth = 1
        underlinePath.stroke()
        
        return yPosition + 25
    }
    
    private static func drawRecordRow(record: HeartRateRecord, yPosition: CGFloat, pageWidth: CGFloat, margin: CGFloat) -> CGFloat {
        let rowFont = UIFont.systemFont(ofSize: 11, weight: .regular)
        let rowAttributes: [NSAttributedString.Key: Any] = [
            .font: rowFont,
            .foregroundColor: UIColor.darkGray
        ]
        
        let bpmFont = UIFont.systemFont(ofSize: 12, weight: .semibold)
        let bpmAttributes: [NSAttributedString.Key: Any] = [
            .font: bpmFont,
            .foregroundColor: UIColor.systemRed
        ]
        
        let hrvFont = UIFont.systemFont(ofSize: 11, weight: .medium)
        let hrvAttributes: [NSAttributedString.Key: Any] = [
            .font: hrvFont,
            .foregroundColor: UIColor.systemBlue
        ]
        
        // Date & Time
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        let dateString = dateFormatter.string(from: record.timestamp)
        dateString.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: rowAttributes)
        
        // Heart Rate (BPM)
        let bpmString = "\(record.bpm)"
        bpmString.draw(at: CGPoint(x: margin + 140, y: yPosition), withAttributes: bpmAttributes)
        
        // HRV (RMSSD)
        let hrvString = record.formattedHRV ?? "-"
        hrvString.draw(at: CGPoint(x: margin + 200, y: yPosition), withAttributes: hrvAttributes)
        
        // Activity
        record.measurementTag.rawValue.draw(at: CGPoint(x: margin + 280, y: yPosition), withAttributes: rowAttributes)
        
        // Synced status
        let syncedString = record.syncedToHealth ? "✓" : "-"
        syncedString.draw(at: CGPoint(x: margin + 380, y: yPosition), withAttributes: rowAttributes)
        
        return yPosition + 22
    }
    
    private static func drawFooter(pageRect: CGRect, margin: CGFloat) {
        let footerFont = UIFont.systemFont(ofSize: 10, weight: .regular)
        let footerAttributes: [NSAttributedString.Key: Any] = [
            .font: footerFont,
            .foregroundColor: UIColor.gray
        ]
        
        let disclaimer = "Disclaimer: This report is generated by HeartRate Senior app and is for informational purposes only. It is not a medical document. Please consult a healthcare professional for medical advice."
        
        let disclaimerRect = CGRect(x: margin, y: pageRect.height - 60, width: pageRect.width - (margin * 2), height: 40)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        var attributes = footerAttributes
        attributes[.paragraphStyle] = paragraphStyle
        
        disclaimer.draw(in: disclaimerRect, withAttributes: attributes)
    }
}
