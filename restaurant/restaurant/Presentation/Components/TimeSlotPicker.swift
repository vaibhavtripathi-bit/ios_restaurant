import SwiftUI

struct TimeSlotPicker: View {
    let slots: [TimeSlot]
    @Binding var selectedTime: String?
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(slots) { slot in
                TimeSlotButton(
                    time: slot.time,
                    isAvailable: slot.isAvailable,
                    isSelected: selectedTime == slot.time,
                    action: {
                        if slot.isAvailable {
                            selectedTime = slot.time
                        }
                    }
                )
            }
        }
    }
}

struct TimeSlotButton: View {
    let time: String
    let isAvailable: Bool
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(time)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .cornerRadius(AppConstants.Layout.smallCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.Layout.smallCornerRadius)
                        .stroke(borderColor, lineWidth: isSelected ? 2 : 1)
                )
        }
        .disabled(!isAvailable)
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return AppColors.primary
        } else if isAvailable {
            return AppColors.surface
        } else {
            return AppColors.surfaceSecondary.opacity(0.5)
        }
    }
    
    private var foregroundColor: Color {
        if isSelected {
            return .white
        } else if isAvailable {
            return AppColors.textPrimary
        } else {
            return AppColors.textTertiary
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return AppColors.primary
        } else if isAvailable {
            return AppColors.surfaceSecondary
        } else {
            return Color.clear
        }
    }
}

#Preview {
    TimeSlotPicker(
        slots: [
            TimeSlot(time: "11:00", isAvailable: true),
            TimeSlot(time: "11:30", isAvailable: true),
            TimeSlot(time: "12:00", isAvailable: false),
            TimeSlot(time: "12:30", isAvailable: true),
            TimeSlot(time: "13:00", isAvailable: true),
            TimeSlot(time: "13:30", isAvailable: false),
            TimeSlot(time: "14:00", isAvailable: true),
            TimeSlot(time: "14:30", isAvailable: true)
        ],
        selectedTime: .constant("11:30")
    )
    .padding()
}
