//
//  CreateReviewView.swift
//  DineScore
//
//  Created by Fernando Romo on 12/17/25.
//

import SwiftUI
import PhotosUI

struct CreateReviewView: View {
    @StateObject private var vm: CreateReviewViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Case 1: you only have an id (will fetch)
    init(restaurantId: String) {
        _vm = StateObject(wrappedValue: CreateReviewViewModel(restaurantId: restaurantId))
    }
    
    // Case 2: you already have the full RestaurantPublic (no fetch needed to show)
    init(restaurant: RestaurantPublic) {
        _vm = StateObject(wrappedValue: CreateReviewViewModel(restaurant: restaurant))
    }
    
    private var navTitle: String {
        if let restaurant = vm.restaurant {
            let combined = restaurant.name
            return combined.isEmpty ? "Restaurant" : combined
        } else {
            return "Restaurant"
        }
    }
    
    var body: some View {
        ZStack{
            Color.backgroundColor.ignoresSafeArea()
            VStack(spacing: 12){
                // Header
                VStack(spacing: 8) {
                    Text("Write a Review")
                        .foregroundColor(.accentColor)
                        .bold()
                        .padding(.top)
                        .font(.title2)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.textColor)
                        .opacity(0.3)
                }
                
                // Restaurant summary
                if let restaurant = vm.restaurant {
                    VStack(spacing: 6){
                        Text(restaurant.name)
                            .foregroundColor(.accentColor)
                            .font(.title3)
                            .bold()
                        HStack(spacing: 4){
                            Text("\(restaurant.city ?? "City"), \(restaurant.state ?? "State")")
                                .foregroundColor(.accentColor)
                                .font(.callout)
                            if let priceLevel = restaurant.priceLevel {
                                let clamped = max(0, min(priceLevel, 5))
                                let dollars = String(repeating: "$", count: clamped)
                                Text("·").foregroundColor(.accentColor).bold()
                                Text(verbatim: dollars)
                                    .font(.callout)
                                    .foregroundColor(.accentColor)
                                Text("·").foregroundColor(.accentColor).bold()
                                Text("🍴")
                                if let rating = restaurant.avgFoodScore {
                                    Text("\(String(format: "%.1f", rating))")
                                        .font(.callout)
                                        .foregroundColor(.accentColor)
                                }
                                Text("🛎️")
                                if let rating = restaurant.avgServiceScore {
                                    Text("\(String(format: "%.1f", rating))")
                                        .font(.callout)
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                        Rectangle()
                            .frame(width: 350, height: 1)
                            .foregroundColor(.textColor)
                            .opacity(0.3)
                    }
                }
                
                // Photos picker (multi-select up to 5) + Date visited
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        // Left column: label on first row, picker on second row
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Photos (up to 5):")
                                .foregroundColor(.accentColor)
                                .bold()
                            
                            PhotosPicker(
                                selection: $vm.selectedItems,
                                maxSelectionCount: 5,
                                matching: .images
                            ) {
                                Label("Add Photos", systemImage: "photo.on.rectangle.angled")
                                    .foregroundColor(.backgroundColor)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(
                                        Capsule().fill(Color.accentColor)
                                    )
                            }
                            .onChange(of: vm.selectedItems) { _, _ in
                                Task { await vm.loadPickedPhotos() }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Right column: label on first row, date picker on second row
                        VStack(alignment: .trailing, spacing: 6) {
                            HStack(spacing: 8) {
                                Text("Date visited:")
                                    .bold()
                                    .foregroundColor(.accentColor)
                                if vm.isUploading { ProgressView() }
                            }
                            
                            DatePicker(
                                "",
                                selection: $vm.visitDate,
                                in: ...Date(),
                                displayedComponents: .date
                            )
                            .labelsHidden()
                            .datePickerStyle(.compact)
                            .tint(.accentColor)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    
                    // Thumbnails grid
                    if !vm.pickedImages.isEmpty {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5), spacing: 8) {
                            ForEach(Array(vm.pickedImages.enumerated()), id: \.offset) { idx, img in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .clipped()
                                        .cornerRadius(8)
                                    
                                    Button {
                                        vm.removeImage(at: idx)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white)
                                            .background(Circle().fill(Color.black.opacity(0.6)))
                                    }
                                    .offset(x: 6, y: -6)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal)
                
                // Scores section: Food and Service with stars + sliders (0.5 steps)
                VStack(spacing: 14) {
                    RatingControl(
                        title: "Food score",
                        value: Binding(
                            get: { vm.foodScore ?? 0 },
                            set: { vm.foodScore = (( $0 * 2 ).rounded() / 2).clamped(to: 0...5) }
                        ),
                        range: 0...5,
                        step: 0.5
                    )
                    
                    TextField("What did you order? How was it?", text: $vm.foodText, axis: .vertical)
                        .lineLimit(1...4)
                        .textFieldStyle(.roundedBorder)
                        .tint(.accentColor)
                    
                    
                    RatingControl(
                        title: "Service score",
                        value: Binding(
                            get: { vm.serviceScore ?? 0 },
                            set: { vm.serviceScore = (( $0 * 2 ).rounded() / 2).clamped(to: 0...5) }
                        ),
                        range: 0...5,
                        step: 0.5
                    )
                    
                    TextField("How was the staff? Wait time? Vibe?", text: $vm.serviceText, axis: .vertical)
                        .lineLimit(1...4)
                        .textFieldStyle(.roundedBorder)
                        .tint(.accentColor)
                }
                .padding(.horizontal)
                
                // Optional: basic text fields for food/service notes
                    
                    
                   
                
                
                // Error message
                if !vm.errorMessage.isEmpty {
                    Text(vm.errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // Post button
                Button {
                    Task {
                        await vm.submitReview()
                        if vm.didPost { dismiss() }
                    }
                } label: {
                    HStack {
                        if vm.isUploading { ProgressView().tint(.backgroundColor) }
                        Text("Post Review")
                            .bold()
                    }
                    .foregroundColor(.backgroundColor)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10).fill(vm.canPost ? Color.accentColor : Color.gray)
                    )
                }
                .disabled(!vm.canPost)
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .task { await vm.load() }
    }
}

// MARK: - Rating control with stars + slider
private struct RatingControl: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .foregroundColor(.accentColor)
                    .bold()
                Spacer()
                Text(String(format: "%.1f / %.0f", value, range.upperBound))
                    .foregroundColor(.accentColor)
                    .font(.footnote).monospacedDigit()
                    .accessibilityHidden(true)
            }
            
            // Stars reflect current value (with halves) and accept tap to set whole stars
            StarsRow(rating: $value, max: Int(range.upperBound))
                .frame(height: 24)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(title)")
                .accessibilityValue("\(String(format: "%.1f", value)) out of \(Int(range.upperBound))")
            
            // Slider for fine control (0.5 steps)
            Slider(value: $value, in: range, step: step)
                .tint(.accentColor)
                .accessibilityLabel("\(title) slider")
        }
    }
}

private struct StarsRow: View {
    @Binding var rating: Double
    let max: Int // typically 5
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(1...max), id: \.self) { i in
                let systemImageName = starSystemImage(for: i)
                Image(systemName: systemImageName)
                    .foregroundColor(.accentColor)
                    .font(.title3)
                    .accessibilityHidden(true)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Tapping sets to the whole star; slider can fine-tune to halves
                        rating = Double(i)
                    }
            }
        }
    }
    
    private func starSystemImage(for index: Int) -> String {
        // Full star if rating >= index
        if rating >= Double(index) {
            return "star.fill"
        }
        // Half star if rating is within [index-0.5, index)
        else if rating >= Double(index) - 0.5 {
            return "star.leadinghalf.filled"
        }
        // Empty otherwise
        else {
            return "star"
        }
    }
}

private extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}

#Preview {
    CreateReviewView(restaurantId: "test-restaurant-123-address")
}
