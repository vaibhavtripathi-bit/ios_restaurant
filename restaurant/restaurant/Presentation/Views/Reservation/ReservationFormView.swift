import SwiftUI

struct ReservationFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: ReservationViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    dateSection
                    partySizeSection
                    timeSlotsSection
                    contactSection
                    specialRequestsSection
                }
                .padding()
            }
            .safeAreaInset(edge: .bottom) {
                confirmButton
            }
            .navigationTitle("Book a Table")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .overlay {
                LoadingOverlay(isLoading: viewModel.isSubmitting, message: "Booking...")
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                Text(viewModel.error ?? "")
            }
            .onChange(of: viewModel.showingConfirmation) { _, showing in
                if showing {
                    dismiss()
                }
            }
        }
    }
    
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Date")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            
            DatePicker(
                "Date",
                selection: $viewModel.selectedDate,
                in: viewModel.minDate...viewModel.maxDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .tint(AppColors.primary)
            .onChange(of: viewModel.selectedDate) { _, _ in
                Task {
                    await viewModel.loadAvailableSlots()
                }
            }
        }
    }
    
    private var partySizeSection: some View {
        LargeQuantitySelector(
            quantity: $viewModel.partySize,
            minValue: AppConstants.Reservation.minPartySize,
            maxValue: AppConstants.Reservation.maxPartySize,
            label: "Party Size"
        )
        .onChange(of: viewModel.partySize) { _, _ in
            Task {
                await viewModel.loadAvailableSlots()
            }
        }
    }
    
    private var timeSlotsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Select Time")
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            if viewModel.availableSlots.isEmpty {
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(AppColors.textTertiary)
                    Text("Select a date to see available times")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.surface)
                .cornerRadius(AppConstants.Layout.cornerRadius)
            } else {
                TimeSlotPicker(
                    slots: viewModel.availableSlots,
                    selectedTime: $viewModel.selectedTime
                )
            }
        }
    }
    
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Contact Information")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: 12) {
                FormTextField(
                    label: "Name",
                    placeholder: "Your full name",
                    text: $viewModel.customerName,
                    icon: "person"
                )
                
                FormTextField(
                    label: "Phone",
                    placeholder: "Phone number",
                    text: $viewModel.customerPhone,
                    icon: "phone",
                    keyboardType: .phonePad
                )
                
                FormTextField(
                    label: "Email (Optional)",
                    placeholder: "Email address",
                    text: $viewModel.customerEmail,
                    icon: "envelope",
                    keyboardType: .emailAddress
                )
            }
        }
    }
    
    private var specialRequestsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Special Requests (Optional)")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            
            TextField("e.g., High chair needed, birthday celebration...", text: $viewModel.specialRequests, axis: .vertical)
                .textFieldStyle(.plain)
                .padding()
                .background(AppColors.surface)
                .cornerRadius(AppConstants.Layout.cornerRadius)
                .lineLimit(3...5)
        }
    }
    
    private var confirmButton: some View {
        VStack(spacing: 0) {
            Divider()
            
            PrimaryButton(
                title: "Confirm Reservation",
                icon: "checkmark.circle",
                isLoading: viewModel.isSubmitting,
                isDisabled: !viewModel.canMakeReservation
            ) {
                Task {
                    await viewModel.makeReservation()
                }
            }
            .padding()
            .background(AppColors.background)
        }
    }
}

struct FormTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
            
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(AppColors.textTertiary)
                        .frame(width: 20)
                }
                
                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .keyboardType(keyboardType)
            }
            .padding()
            .background(AppColors.surface)
            .cornerRadius(AppConstants.Layout.cornerRadius)
        }
    }
}

struct ReservationConfirmationView: View {
    let reservation: Reservation
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(AppColors.success)
            
            VStack(spacing: 8) {
                Text("Reservation Confirmed!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("We look forward to seeing you!")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            VStack(spacing: 16) {
                infoRow(label: "Date", value: reservation.formattedDate)
                infoRow(label: "Time", value: reservation.time)
                infoRow(label: "Party Size", value: reservation.partySizeText)
                infoRow(label: "Confirmation Code", value: reservation.confirmationCode)
            }
            .padding()
            .background(AppColors.surface)
            .cornerRadius(AppConstants.Layout.cornerRadius)
            
            Spacer()
            
            PrimaryButton(title: "Done", action: onDismiss)
        }
        .padding()
    }
    
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
        }
    }
}

#Preview {
    ReservationFormView(viewModel: ReservationViewModel(
        getAvailableSlotsUseCase: GetAvailableSlotsUseCase(repository: ReservationRepository()),
        makeReservationUseCase: MakeReservationUseCase(repository: ReservationRepository()),
        getReservationsUseCase: GetReservationsUseCase(repository: ReservationRepository()),
        cancelReservationUseCase: CancelReservationUseCase(repository: ReservationRepository())
    ))
}
