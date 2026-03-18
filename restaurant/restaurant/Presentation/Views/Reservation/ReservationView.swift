import SwiftUI

struct ReservationView: View {
    @EnvironmentObject private var container: DIContainer
    @State private var viewModel: ReservationViewModel?
    @State private var showingForm = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                if let viewModel = viewModel {
                    mainContent(viewModel: viewModel)
                } else {
                    LoadingView()
                }
            }
            .navigationTitle("Reservations")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingForm = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(AppColors.primary)
                    }
                }
            }
            .sheet(isPresented: $showingForm) {
                if let viewModel = viewModel {
                    ReservationFormView(viewModel: viewModel)
                }
            }
            .sheet(isPresented: Binding(
                get: { viewModel?.showingConfirmation ?? false },
                set: { if !$0 { viewModel?.dismissConfirmation() } }
            )) {
                if let reservation = viewModel?.lastCreatedReservation {
                    ReservationConfirmationView(reservation: reservation) {
                        viewModel?.dismissConfirmation()
                    }
                }
            }
        }
        .task {
            if viewModel == nil {
                viewModel = container.makeReservationViewModel()
            }
            await viewModel?.loadReservations()
        }
    }
    
    @ViewBuilder
    private func mainContent(viewModel: ReservationViewModel) -> some View {
        if viewModel.reservations.isEmpty && !viewModel.isLoading {
            EmptyStateView(
                icon: "calendar",
                title: "No Reservations",
                message: "You don't have any reservations yet. Book a table to get started!",
                buttonTitle: "Make Reservation",
                buttonAction: { showingForm = true }
            )
        } else {
            ScrollView {
                LazyVStack(spacing: 16) {
                    if !viewModel.upcomingReservations.isEmpty {
                        reservationSection(
                            title: "Upcoming",
                            reservations: viewModel.upcomingReservations,
                            viewModel: viewModel
                        )
                    }
                    
                    if !viewModel.pastReservations.isEmpty {
                        reservationSection(
                            title: "Past",
                            reservations: viewModel.pastReservations,
                            viewModel: viewModel
                        )
                    }
                }
                .padding()
            }
        }
    }
    
    private func reservationSection(title: String, reservations: [Reservation], viewModel: ReservationViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            
            ForEach(reservations) { reservation in
                ReservationCard(reservation: reservation) {
                    Task {
                        await viewModel.cancelReservation(reservation)
                    }
                }
            }
        }
    }
}

struct ReservationCard: View {
    let reservation: Reservation
    let onCancel: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(reservation.formattedDate)
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("at \(reservation.time)")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                StatusBadge(status: reservation.status)
            }
            
            Divider()
            
            HStack {
                Label(reservation.partySizeText, systemImage: "person.2")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                
                Spacer()
                
                Text("Code: \(reservation.confirmationCode)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.primary)
            }
            
            if reservation.status == .confirmed || reservation.status == .pending {
                Divider()
                
                Button(action: onCancel) {
                    HStack {
                        Image(systemName: "xmark.circle")
                        Text("Cancel Reservation")
                    }
                    .font(.subheadline)
                    .foregroundColor(AppColors.error)
                }
            }
        }
        .padding()
        .background(AppColors.surface)
        .cornerRadius(AppConstants.Layout.cornerRadius)
    }
}

struct StatusBadge: View {
    let status: Reservation.ReservationStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.iconName)
                .font(.caption2)
            Text(status.displayName)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(backgroundColor.opacity(0.15))
        .foregroundColor(backgroundColor)
        .cornerRadius(AppConstants.Layout.smallCornerRadius)
    }
    
    private var backgroundColor: Color {
        switch status {
        case .pending:
            return AppColors.warning
        case .confirmed:
            return AppColors.success
        case .seated:
            return AppColors.info
        case .completed:
            return AppColors.textSecondary
        case .cancelled, .noShow:
            return AppColors.error
        }
    }
}

#Preview {
    ReservationView()
        .environmentObject(DIContainer())
}
