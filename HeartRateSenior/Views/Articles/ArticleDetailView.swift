//
//  ArticleDetailView.swift
//  HeartRateSenior
//
//  Detail view for displaying article content with Markdown rendering
//

import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    @Environment(\.dismiss) private var dismiss
    @State private var scrollOffset: CGFloat = 0
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Cover Image
                GeometryReader { geometry in
                    let minY = geometry.frame(in: .global).minY
                    let height = max(geometry.size.width, geometry.size.width + minY)
                    
                    ArticleCoverPlaceholder(article: article, title: article.shortTitle)
                        .frame(width: geometry.size.width, height: height)
                        .clipped()
                        .offset(y: minY > 0 ? -minY : 0)
                }
                .frame(height: UIScreen.main.bounds.width)
                
                // Content
                VStack(alignment: .leading, spacing: 20) {
                    // Category & Reading Time
                    HStack(spacing: 12) {
                        // Category Tag
                        Text(article.category.rawValue)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(article.category.color)
                            .clipShape(Capsule())
                        
                        // Reading Time
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 12))
                            Text("\(estimatedReadingTime) min read")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(AppColors.textSecondary)
                        Spacer()
                    }
                    // Title
                    Text(article.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(red: 0.118, green: 0.161, blue: 0.231))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(2)
                    Divider()
                        .padding(.vertical, 4)
                    
                    // Markdown Content
                    MarkdownContentView(content: article.content)
                    
                    // Footer
                    VStack(spacing: 16) {
                        Divider()
                        
                        // Related Articles Hint
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                            Text("Keep learning about heart health!")
                                .font(.system(size: 14, weight: .medium, design: .rounded)).foregroundColor(AppColors.textSecondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.yellow.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.top, 20)
                    Spacer(minLength: 60)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .background(AppColors.background)
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(AppColors.background)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                ShareLink(item: article.title) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
            }
        }
    }
    
    private var estimatedReadingTime: Int {
        let wordCount = article.content.split(separator: " ").count
        return max(1, wordCount / 200) // Average reading speed: 200 words/min
    }
}

// MARK: - Markdown Content View
struct MarkdownContentView: View {
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(parseContent(), id: \.self) { block in
                renderBlock(block)
            }
        }
    }
    
    private func parseContent() -> [String] {
        // Split content by double newlines to get paragraphs/blocks
        content.components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    @ViewBuilder
    private func renderBlock(_ block: String) -> some View {
        if block.hasPrefix("## ") {
            // H2 Header
            Text(block.replacingOccurrences(of: "## ", with: ""))
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .padding(.top, 8)
        } else if block.hasPrefix("### ") {
            // H3 Header
            Text(block.replacingOccurrences(of: "### ", with: ""))
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .padding(.top, 4)
        } else if block.hasPrefix("**Category:**") {
            // Category line - styled differently
            Text(block.replacingOccurrences(of: "**", with: ""))
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .italic()
        } else if block.hasPrefix("> ") {
            // Blockquote
            HStack(spacing: 12) {
                Rectangle()
                    .fill(AppColors.primaryRed.opacity(0.6))
                    .frame(width: 4)
                
                Text(block.replacingOccurrences(of: "> ", with: "").replacingOccurrences(of: "**", with: ""))
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .italic()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.gray.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        } else if block.hasPrefix("| ") {
            // Table - render as simple list
            TableView(content: block)
        } else if block.contains("*   **") || block.hasPrefix("*   ") {
            // Bullet list
            BulletListView(content: block)
        } else if block.contains("1.  ") || block.contains("2.  ") {
            // Numbered list
            NumberedListView(content: block)
        } else {
            // Regular paragraph
            Text(formatInlineStyles(block))
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private func formatInlineStyles(_ text: String) -> AttributedString {
        var result = AttributedString(text)
        
        // Remove markdown bold markers for display
        // In a production app, you'd want to properly parse and style these
        let cleanText = text
            .replacingOccurrences(of: "**", with: "")
            .replacingOccurrences(of: "*", with: "")
        
        result = AttributedString(cleanText)
        return result
    }
}

// MARK: - Bullet List View
struct BulletListView: View {
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(parseItems(), id: \.self) { item in
                HStack(alignment: .top, spacing: 12) {
                    Circle()
                        .fill(AppColors.primaryRed)
                        .frame(width: 6, height: 6)
                        .padding(.top, 8)
                    
                    Text(cleanItem(item))
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(.leading, 4)
    }
    
    private func parseItems() -> [String] {
        content.components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { $0.hasPrefix("*") }
    }
    
    private func cleanItem(_ item: String) -> String {
        item.replacingOccurrences(of: "*   ", with: "")
            .replacingOccurrences(of: "* ", with: "")
            .replacingOccurrences(of: "**", with: "")
            .trimmingCharacters(in: .whitespaces)
    }
}

// MARK: - Numbered List View
struct NumberedListView: View {
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(parseItems().enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1).")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.primaryRed)
                        .frame(width: 24, alignment: .trailing)
                    
                    Text(cleanItem(item))
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
    
    private func parseItems() -> [String] {
        let pattern = #"\d+\.\s+"#
        let items = content.components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { item in
                item.range(of: pattern, options: .regularExpression) != nil
            }
        return items
    }
    
    private func cleanItem(_ item: String) -> String {
        let pattern = #"^\d+\.\s+"#
        return item.replacingOccurrences(of: pattern, with: "", options: .regularExpression).replacingOccurrences(of: "**", with: "")
            .trimmingCharacters(in: .whitespaces)
    }
}

// MARK: - Table View
struct TableView: View {
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(parseRows().enumerated()), id: \.offset) { index, row in
                if index == 0 {
                    // Header row
                    HStack(spacing: 0) {
                        ForEach(row, id: \.self) { cell in
                            Text(cell)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 8)
                        }
                    }
                    .background(AppColors.primaryRed.opacity(0.1))
                } else if !row.allSatisfy({ $0.contains("---") || $0.contains(":") }) {
                    // Data row (skip separator row)
                    HStack(spacing: 0) {
                        ForEach(row, id: \.self) { cell in
                            Text(cell.replacingOccurrences(of: "**", with: ""))
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 8)
                        }
                    }
                    .background(index % 2 == 0 ? Color.gray.opacity(0.05) : Color.clear)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func parseRows() -> [[String]] {
        content.components(separatedBy: "\n")
            .filter { !$0.isEmpty }
            .map { row in
                row.components(separatedBy: "|")
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }
            }
    }
}

#Preview {
    NavigationStack {
        ArticleDetailView(article: ArticleData.articles[0])
    }
}

#Preview("Article 4 - Table") {
    NavigationStack {
        ArticleDetailView(article: ArticleData.articles[3])
    }
}
