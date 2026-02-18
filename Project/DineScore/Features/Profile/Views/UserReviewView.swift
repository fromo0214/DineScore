//
//  UserReviewView.swift
//  DineScore
//
//  Created by Fernando Romo on 7/28/25.
//

import SwiftUI

struct UserReviewView: View {
    
    //dismisses the current view, used for back button
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var vm: UserProfileViewModel
    
    init(vm: UserProfileViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        NavigationStack{
            ZStack{
                Color.backgroundColor
                    .ignoresSafeArea()
                VStack(alignment: .leading, spacing: 0) {
                    if vm.isLoading {
                        ProgressView("Loading reviews...")
                            .padding()
                    } else if sortedReviews.isEmpty {
                        Text("No reviews yet.")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        List {
                            ForEach(sortedReviews) { review in
                                HStack(spacing: 10) {
                                    Image(systemName: "star.bubble.fill")
                                        .foregroundColor(Color.accentColor)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(reviewSummary(review))
                                            .foregroundColor(Color.accentColor)
                                            .lineLimit(1)
                                        if let date = review.createdAt?.dateValue() {
                                            Text(formatDate(date))
                                                .foregroundColor(Color.accentColor)
                                                .font(.caption.bold())
                                        }
                                    }
                                }
                                .listRowBackground(Color.backgroundColor)
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.textColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar{
            
            //custom back button
            ToolbarItem(placement: .navigationBarLeading){
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }){
                    HStack{
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color.backgroundColor)
                        Text("Profile")
                            .foregroundColor(Color.backgroundColor)
                            .bold()
                    }
                }
            }
            
            //navigation title
            ToolbarItem(placement: .principal){
                Text("My Reviews")
                    .foregroundColor(Color.backgroundColor)
                    .bold()
            }
            
            //filtering button
            ToolbarItem(placement: .topBarTrailing){
                Button(action: {
                    //sorting func
                }){
                    HStack{
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(Color.backgroundColor)
                    }
                }
            }
        }
        .task {
            await vm.getAppUser()
            await vm.refreshMyReviews()
        }
    }
    
    private var sortedReviews: [Review] {
        vm.myReviews.sorted { lhs, rhs in
            let lhsDate = lhs.createdAt?.dateValue() ?? .distantPast
            let rhsDate = rhs.createdAt?.dateValue() ?? .distantPast
            if lhsDate != rhsDate {
                return lhsDate < rhsDate
            }
            return (lhs.id ?? "") < (rhs.id ?? "")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        Self.dateFormatter.string(from: date)
    }
    
    private func reviewSummary(_ review: Review) -> String {
        if let text = review.foodText?.trimmingCharacters(in: .whitespacesAndNewlines),
           !text.isEmpty {
            return text
        }
        if let text = review.serviceText?.trimmingCharacters(in: .whitespacesAndNewlines),
           !text.isEmpty {
            return text
        }
        return "Review"
    }
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()
}

#Preview {
    UserReviewView(vm: UserProfileViewModel())
}
