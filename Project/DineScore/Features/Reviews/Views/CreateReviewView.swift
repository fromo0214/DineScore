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
    
    // Track which text field is focused to control keyboard dismissal
    @FocusState private var focusedField: Field?
    private enum Field: Hashable {
        case foodText
        case serviceText
    }
    
    // Character limits
    private let foodMaxChars = 200
    private let serviceMaxChars = 200
    
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
    
    // Extracted bindings for ratings to simplify type inference
    private func foodRatingBinding() -> Binding<Double> {
        Binding<Double>(
            get: { vm.foodScore ?? 0 },
            set: { vm.foodScore = (( $0 * 2 ).rounded() / 2).clamped(to: 0...5) }
        )
    }
    private func serviceRatingBinding() -> Binding<Double> {
        Binding<Double>(
            get: { vm.serviceScore ?? 0 },
            set: { vm.serviceScore = (( $0 * 2 ).rounded() / 2).clamped(to: 0...5) }
        )
    }
    
    var body: some View {
        ZStack {
            Color.backgroundColor.ignoresSafeArea()
                .onTapGesture { focusedField = nil } // dismiss keyboard on background tap
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        headerView
                        restaurantSummaryView
                        photosSection
                        scoresSection(proxy: proxy)
                        tagsSection
                        segmentedPickersSection
                        errorMessageView
                        Spacer(minLength: 0)
                        postButton
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") { focusedField = nil }
                    }
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .task { await vm.load() }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focusedField = nil }
            }
        }
    }
}

// MARK: - Subviews

private extension CreateReviewView {
    @ViewBuilder
    var headerView: some View {
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
    }
    
    @ViewBuilder
    var restaurantSummaryView: some View {
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
                        
                        
                        let foodAvg = vm.avgFoodScore ?? restaurant.avgFoodScore
                        let serviceAvg = vm.avgServiceScore ?? restaurant.avgServiceScore

                        if foodAvg != nil || serviceAvg != nil {
                            HStack(spacing: 8) {
                                if let food = foodAvg {
                                    Text("🍴:")
                                    Text(String(format: "%.1f" + "⭐️", food))
                                        .font(.callout)
                                        .foregroundColor(.accentColor)
                                }
                                if foodAvg != nil && serviceAvg != nil {
                                    Text("·").foregroundColor(.accentColor).bold()
                                }
                                if let service = serviceAvg {
                                    Text("🤝:")
                                    Text(String(format: "%.1f" + "⭐️", service))
                                        .font(.callout)
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundColor(.textColor)
                    .opacity(0.3)
            }
        }
    }
    
    @ViewBuilder
    var photosSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                // Left column: label + picker
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
                
                // Right column: date picker
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
    }
    
    @ViewBuilder
    func scoresSection(proxy: ScrollViewProxy) -> some View {
        VStack(spacing: 14) {
            RatingControl(
                title: "Food score:",
                value: foodRatingBinding(),
                range: 0...5,
                step: 0.5
            )
            
            // Food text field
            VStack(alignment: .trailing, spacing: 4) {
                HStack(alignment: .top, spacing: 8) {
                    TextField("What did you order? How was it?", text: $vm.foodText, axis: Axis.vertical)
                        .id(Field.foodText) // scroll target
                        .lineLimit(1...6)
                        .textFieldStyle(.roundedBorder)
                        .tint(.accentColor)
                        .focused($focusedField, equals: .foodText)
                        .onChange(of: vm.foodText) { _, _ in
                            if vm.foodText.count > foodMaxChars {
                                vm.foodText = String(vm.foodText.prefix(foodMaxChars))
                            }
                            if focusedField == .foodText {
                                withAnimation {
                                    proxy.scrollTo(Field.foodText, anchor: .bottom)
                                }
                            }
                        }
                        .onChange(of: focusedField) { _, newFocus in
                            if newFocus == .foodText {
                                withAnimation {
                                    proxy.scrollTo(Field.foodText, anchor: .bottom)
                                }
                            }
                        }
                    
                    if focusedField == .foodText {
                        Button("Done") { focusedField = nil }
                            .font(.footnote.bold())
                            .foregroundColor(.backgroundColor)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(Capsule().fill(Color.accentColor))
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                    }
                }
                
                Text("\(vm.foodText.count)/\(foodMaxChars)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            RatingControl(
                title: "Service score:",
                value: serviceRatingBinding(),
                range: 0...5,
                step: 0.5
            )
            
            // Service text field
            VStack(alignment: .trailing, spacing: 4) {
                HStack(alignment: .top, spacing: 8) {
                    TextField("How was the staff? Wait time? Vibe?", text: $vm.serviceText, axis: Axis.vertical)
                        .id(Field.serviceText) // scroll target
                        .lineLimit(1...6)
                        .textFieldStyle(.roundedBorder)
                        .tint(.accentColor)
                        .focused($focusedField, equals: .serviceText)
                        .onChange(of: vm.serviceText) { _, _ in
                            if vm.serviceText.count > serviceMaxChars {
                                vm.serviceText = String(vm.serviceText.prefix(serviceMaxChars))
                            }
                            if focusedField == .serviceText {
                                withAnimation {
                                    proxy.scrollTo(Field.serviceText, anchor: .bottom)
                                }
                            }
                        }
                        .onChange(of: focusedField) { _, newFocus in
                            if newFocus == .serviceText {
                                withAnimation {
                                    proxy.scrollTo(Field.serviceText, anchor: .bottom)
                                }
                            }
                        }
                    
                    if focusedField == .serviceText {
                        Button("Done") { focusedField = nil }
                            .font(.footnote.bold())
                            .foregroundColor(.backgroundColor)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(Capsule().fill(Color.accentColor))
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                    }
                }
                
                Text("\(vm.serviceText.count)/\(serviceMaxChars)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags")
                .foregroundColor(.accentColor)
                .bold()
            
            if !vm.suggestedTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(vm.suggestedTags, id: \.self) { tag in
                            let isSelected = vm.selectedTags.contains { $0.caseInsensitiveCompare(tag) == .orderedSame }
                            TagChip(
                                text: tag,
                                isSelected: isSelected,
                                removable: false
                            ) {
                                vm.toggleSuggestedTag(tag)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            
            if !vm.selectedTags.isEmpty {
                ReviewFlowLayout(spacing: 8, rowSpacing: 8) {
                    ForEach(vm.selectedTags, id: \.self) { tag in
                        TagChip(
                            text: tag,
                            isSelected: true,
                            removable: true
                        ) {
                            vm.removeTag(tag)
                        }
                        .fixedSize()
                    }
                }
                .padding(.vertical, 4)
            }
            
            HStack(spacing: 8) {
                TextField("Add a tag (e.g., 'Friendly')", text: $vm.newTagText)
                    .textFieldStyle(.roundedBorder)
                    .tint(.accentColor)
                    .onChange(of: vm.newTagText) { _, _ in
                        if vm.newTagText.count > vm.maxTagLength {
                            vm.newTagText = String(vm.newTagText.prefix(vm.maxTagLength))
                        }
                    }
                Button {
                    vm.addNewTag()
                } label: {
                    Text("Add")
                        .font(.footnote.bold())
                        .foregroundColor(.backgroundColor)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(Capsule().fill(vm.newTagText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.selectedTags.count >= vm.maxTags ? Color.gray : Color.accentColor))
                }
                .disabled(vm.newTagText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.selectedTags.count >= vm.maxTags)
            }
            
            Text("\(vm.selectedTags.count)/\(vm.maxTags) tags")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    var segmentedPickersSection: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Would you come back?")
                    .foregroundColor(.accentColor)
                    .bold()
                Picker("Would you come back?", selection: $vm.comeBack) {
                    ForEach(ComeBackOption.allCases) { opt in
                        Text(opt.title).tag(opt)
                    }
                }
                .pickerStyle(.segmented)
                .tint(.accentColor)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Price vs value")
                    .foregroundColor(.accentColor)
                    .bold()
                Picker("Price vs value", selection: $vm.priceValue) {
                    ForEach(PriceValueOption.allCases) { opt in
                        Text(opt.title).tag(opt)
                    }
                }
                .pickerStyle(.segmented)
                .tint(.accentColor)
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    var errorMessageView: some View {
        if !vm.errorMessage.isEmpty {
            Text(vm.errorMessage)
                .foregroundColor(.red)
                .font(.footnote)
                .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    var postButton: some View {
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
            
            StarsRow(rating: $value, max: Int(range.upperBound))
                .frame(height: 24)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(title)")
                .accessibilityValue("\(String(format: "%.1f", value)) out of \(Int(range.upperBound))")
            
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
                        rating = Double(i)
                    }
            }
        }
    }
    
    private func starSystemImage(for index: Int) -> String {
        if rating >= Double(index) {
            return "star.fill"
        } else if rating >= Double(index) - 0.5 {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
}

private extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}

// MARK: - Tag chip
private struct TagChip: View {
    let text: String
    let isSelected: Bool
    let removable: Bool
    var action: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Text(text)
                .font(.footnote.bold())
                .lineLimit(1)
            if removable {
                Image(systemName: "xmark")
                    .font(.caption2.bold())
            }
        }
        .foregroundColor(isSelected ? .backgroundColor : .accentColor)
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(
            Capsule().fill(isSelected ? Color.accentColor : Color.textColor.opacity(0.12))
        )
        .overlay(
            Capsule().stroke(Color.accentColor.opacity(isSelected ? 0 : 0.6), lineWidth: isSelected ? 0 : 1)
        )
        .contentShape(Capsule())
        .onTapGesture { action() }
    }
}

// MARK: - Flow layout for wrapping chips
private struct ReviewFlowLayout: Layout {
    var spacing: CGFloat = 8
    var rowSpacing: CGFloat = 8
    
    init(spacing: CGFloat = 8, rowSpacing: CGFloat = 8) {
        self.spacing = spacing
        self.rowSpacing = rowSpacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x > 0 && x + size.width > maxWidth {
                // wrap
                x = 0
                y += rowHeight + rowSpacing
                rowHeight = 0
            }
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        if subviews.isEmpty == false {
            y += rowHeight
        }
        return CGSize(width: maxWidth, height: y)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0
        
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x > bounds.minX && x + size.width > bounds.maxX {
                // wrap
                x = bounds.minX
                y += rowHeight + rowSpacing
                rowHeight = 0
            }
            sub.place(
                at: CGPoint(x: x, y: y),
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview {
    CreateReviewView(restaurantId: "test-restaurant-123-address")
}
