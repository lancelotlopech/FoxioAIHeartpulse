//  ArticlesListView.swift
//  HeartRateSenior
//
//  Grid view displaying all health articles
//

import SwiftUI

struct ArticlesListView: View {
    @Environment(\.dismiss) private var dismiss
    let articles = ArticleData.articles
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Article")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("Expert insights for your heart health journey")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 20)
                    
                    // Articles Grid
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(articles) { article in
                            NavigationLink(destination: ArticleDetailView(article: article)) {
                                ArticleCardView(article: article)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    Spacer(minLength: 40)
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 32, height: 32).background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
}

// MARK: - Article Card View (标题居中显示在封面上)
struct ArticleCardView: View {
    let article: Article
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Cover Image (正方形)
                ArticleCoverPlaceholder(article: article, title: article.shortTitle)
                    .frame(width: geometry.size.width, height: geometry.size.width)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Article Cover Placeholder (使用实际图片 + 标题居中)
struct ArticleCoverPlaceholder: View {
    let article: Article
    let title: String
    
    var body: some View {
        ZStack {
            // 实际封面图片背景
            Image("\(article.id)")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipped()
            
            // 半透明遮罩层（让标题更清晰）
            Color.black.opacity(0.35)
            
            // 标题居中显示 - 允许自动换行和缩放
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .minimumScaleFactor(0.75)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Horizontal Article Card (for Dashboard - 标题居中显示)
struct HorizontalArticleCardView: View {
    let article: Article
    
    var body: some View {
        ZStack {
            // Cover Image (正方形)
            ArticleCoverPlaceholder(article: article, title: article.shortTitle)
                .frame(width: 140, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .frame(width: 140, height: 140)}
}

// MARK: - Dashboard Articles Section
struct DashboardArticlesSection: View {
    let articles = ArticleData.articles
    @State private var showingAllArticles = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "book.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppColors.primaryRed)
                    
                    Text("Article")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                }
                Spacer()
                
                Button(action: {
                    HapticManager.shared.selectionChanged()
                    showingAllArticles = true
                }) {
                    HStack(spacing: 4) {
                        Text("See All")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(AppColors.primaryRed)
                }
            }
            .padding(.horizontal, 20)
            
            // Horizontal Scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(articles.prefix(5)) { article in
                        NavigationLink(destination: ArticleDetailView(article: article)) {
                            HorizontalArticleCardView(article: article)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .fullScreenCover(isPresented: $showingAllArticles) {
            ArticlesListView()
        }
    }
}

#Preview {
    ArticlesListView()
}

#Preview("Dashboard Section") {
    NavigationStack {
        VStack {
            DashboardArticlesSection()
        }
        .background(AppColors.background)}
}
