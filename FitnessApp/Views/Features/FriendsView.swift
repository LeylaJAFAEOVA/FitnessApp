//
//  FriendsView.swift
//  FitnessApp
//
//  Created by Leyla Jafarova on 26/04/2026.
//

import SwiftUI
import MapKit
import CoreLocation
import Combine

// MARK: — Friend Model

struct Friend: Identifiable {
    let id: String
    let name: String
    let initials: String
    let color: Color
    var coordinate: CLLocationCoordinate2D
    var lastWorkout: String
    var workoutsThisWeek: Int
    var isOnline: Bool
    var distanceMeters: Double
}

// MARK: — FriendsViewModel

class FriendsViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.4093, longitude: 49.8671),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var authStatus: CLAuthorizationStatus = .notDetermined

    private let locationManager = CLLocationManager()

    @Published var friends: [Friend] = [
        Friend(id: "1", name: "Amir",   initials: "AM", color: Color(hex: "#5DCAA5"),
               coordinate: CLLocationCoordinate2D(latitude: 40.4120, longitude: 49.8700),
               lastWorkout: NSLocalizedString("workout.morning_ex", comment: ""),
               workoutsThisWeek: 4, isOnline: true,  distanceMeters: 340),
        Friend(id: "2", name: "Sara",   initials: "SA", color: Color(hex: "#FF6B6B"),
               coordinate: CLLocationCoordinate2D(latitude: 40.4070, longitude: 49.8640),
               lastWorkout: NSLocalizedString("workout.type.hiit", comment: ""),
               workoutsThisWeek: 2, isOnline: true,  distanceMeters: 820),
        Friend(id: "3", name: "Kamran", initials: "KA", color: Color(hex: "#A855F7"),
               coordinate: CLLocationCoordinate2D(latitude: 40.4050, longitude: 49.8720),
               lastWorkout: NSLocalizedString("workout.type.strength", comment: ""),
               workoutsThisWeek: 5, isOnline: false, distanceMeters: 1200),
        Friend(id: "4", name: "Nigar",  initials: "NI", color: Color(hex: "#4D9FFF"),
               coordinate: CLLocationCoordinate2D(latitude: 40.4140, longitude: 49.8660),
               lastWorkout: NSLocalizedString("workout.type.yoga", comment: ""),
               workoutsThisWeek: 3, isOnline: false, distanceMeters: 2100),
    ]

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authStatus = manager.authorizationStatus
        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        userLocation = loc.coordinate
        region.center = loc.coordinate
        locationManager.stopUpdatingLocation()
    }

    func formattedDistance(_ meters: Double) -> String {
        meters < 1000
            ? String(format: NSLocalizedString("friends.distance_m", comment: ""), Int(meters))
            : String(format: NSLocalizedString("friends.distance_km", comment: ""), meters / 1000)
    }
}

// MARK: — FriendsView

struct FriendsView: View {
    @StateObject private var vm = FriendsViewModel()
    @State private var filter: FriendFilter = .all
    @State private var selectedFriend: Friend? = nil
    @State private var showInvite = false

    enum FriendFilter { case all, online, nearby }

    private var filtered: [Friend] {
        switch filter {
        case .all:    return vm.friends
        case .online: return vm.friends.filter { $0.isOnline }
        case .nearby: return vm.friends.filter { $0.distanceMeters < 1000 }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.dark.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        filterChips
                        mapSection
                        friendsList
                        inviteSection
                        Spacer(minLength: 40)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle(NSLocalizedString("friends.title", comment: ""))
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(AppTheme.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showInvite = true } label: {
                        Image(systemName: "person.badge.plus")
                            .foregroundColor(AppTheme.lime)
                    }
                }
            }
            .sheet(isPresented: $showInvite) { InviteFriendSheet() }
            .sheet(item: $selectedFriend) { friend in FriendDetailSheet(friend: friend) }
            .onAppear { vm.requestLocation() }
        }
    }

    // MARK: — Filter chips

    private var filterChips: some View {
        HStack(spacing: 8) {
            filterChip(NSLocalizedString("friends.filter.all",    comment: ""), .all)
            filterChip(NSLocalizedString("friends.filter.online", comment: ""), .online)
            filterChip(NSLocalizedString("friends.filter.nearby", comment: ""), .nearby)
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
    }

    private func filterChip(_ label: String, _ value: FriendFilter) -> some View {
        let active = filter == value
        return Button { withAnimation { filter = value } } label: {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(active ? .black : AppTheme.muted)
                .padding(.horizontal, 18).padding(.vertical, 8)
                .background(active ? AppTheme.lime : AppTheme.card)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(active ? Color.clear : AppTheme.border, lineWidth: 1)
                )
        }
    }

    // MARK: — Map

    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "map.fill")
                    .foregroundColor(AppTheme.lime).font(.system(size: 14))
                Text(NSLocalizedString("friends.map", comment: ""))
                    .font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
            }
            .padding(.horizontal, 20)

            ZStack(alignment: .bottomTrailing) {
                Map(coordinateRegion: $vm.region,
                    showsUserLocation: true,
                    annotationItems: filtered) { friend in
                    MapAnnotation(coordinate: friend.coordinate) {
                        FriendMapPin(friend: friend)
                            .onTapGesture { selectedFriend = friend }
                    }
                }
                .frame(height: 220)
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.border, lineWidth: 1))

                Button {
                    withAnimation {
                        if let loc = vm.userLocation {
                            vm.region.center = loc
                        } else {
                            vm.requestLocation()
                        }
                    }
                } label: {
                    Image(systemName: "location.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(AppTheme.card)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.border, lineWidth: 1))
                }
                .padding(12)
            }
            .padding(.horizontal, 20)

            if vm.authStatus == .denied {
                HStack(spacing: 8) {
                    Image(systemName: "location.slash.fill")
                        .foregroundColor(.orange).font(.system(size: 13))
                    Text(NSLocalizedString("friends.location_denied", comment: ""))
                        .font(.system(size: 12)).foregroundColor(AppTheme.muted)
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: — Friends list

    private var friendsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(listTitle)
                    .font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                Spacer()
                Text("\(filtered.count)")
                    .font(.system(size: 13)).foregroundColor(AppTheme.muted)
            }
            .padding(.horizontal, 20)

            if filtered.isEmpty {
                emptyFriends
            } else {
                VStack(spacing: 10) {
                    ForEach(filtered) { friend in
                        FriendRow(friend: friend, distanceText: vm.formattedDistance(friend.distanceMeters))
                            .onTapGesture { selectedFriend = friend }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var listTitle: String {
        switch filter {
        case .all:    return NSLocalizedString("friends.all_friends",   comment: "")
        case .online: return NSLocalizedString("friends.filter.online", comment: "")
        case .nearby: return NSLocalizedString("friends.filter.nearby", comment: "")
        }
    }

    private var emptyFriends: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 36)).foregroundColor(AppTheme.lime.opacity(0.4))
            Text(NSLocalizedString("friends.empty_category", comment: ""))
                .font(.system(size: 14)).foregroundColor(AppTheme.muted)
        }
        .frame(maxWidth: .infinity).padding(30)
        .background(AppTheme.card).cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.border, lineWidth: 1))
        .padding(.horizontal, 20)
    }

    // MARK: — Invite section

    private var inviteSection: some View {
        Button { showInvite = true } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(AppTheme.lime.opacity(0.15)).frame(width: 44, height: 44)
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 18)).foregroundColor(AppTheme.lime)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(NSLocalizedString("friends.invite_title", comment: ""))
                        .font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                    Text(NSLocalizedString("friends.invite_subtitle", comment: ""))
                        .font(.system(size: 12)).foregroundColor(AppTheme.muted)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13)).foregroundColor(AppTheme.muted)
            }
            .padding(16)
            .background(AppTheme.card).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.border, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
    }
}

// MARK: — FriendMapPin

struct FriendMapPin: View {
    let friend: Friend
    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle().fill(friend.color).frame(width: 36, height: 36)
                    .overlay(Circle().stroke(friend.isOnline ? AppTheme.lime : Color.clear, lineWidth: 2.5))
                Text(friend.initials)
                    .font(.system(size: 11, weight: .bold)).foregroundColor(.white)
            }
            Triangle()
                .fill(friend.color)
                .frame(width: 8, height: 5)
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.closeSubpath()
        return p
    }
}

// MARK: — FriendRow

struct FriendRow: View {
    let friend: Friend
    let distanceText: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack(alignment: .bottomTrailing) {
                Circle().fill(friend.color).frame(width: 48, height: 48)
                Text(friend.initials)
                    .font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                Circle()
                    .fill(friend.isOnline ? AppTheme.lime : AppTheme.muted)
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(AppTheme.card, lineWidth: 2))
                    .offset(x: 2, y: 2)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(friend.name)
                    .font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 10)).foregroundColor(.orange)
                    Text(friend.lastWorkout)
                        .font(.system(size: 12)).foregroundColor(AppTheme.muted)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 10)).foregroundColor(AppTheme.lime)
                    Text(distanceText)
                        .font(.system(size: 12, weight: .medium)).foregroundColor(AppTheme.lime)
                }
                Text(String(format: NSLocalizedString("friends.workouts_week", comment: ""), friend.workoutsThisWeek))
                    .font(.system(size: 11)).foregroundColor(AppTheme.muted)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12)).foregroundColor(AppTheme.muted)
        }
        .padding(14)
        .background(AppTheme.card).cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.border, lineWidth: 1))
    }
}

// MARK: — FriendDetailSheet

struct FriendDetailSheet: View {
    let friend: Friend
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            AppTheme.dark.ignoresSafeArea()
            VStack(spacing: 0) {
                Capsule().fill(AppTheme.border).frame(width: 40, height: 4).padding(.top, 12)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Avatar
                        VStack(spacing: 10) {
                            ZStack {
                                Circle().fill(friend.color).frame(width: 80, height: 80)
                                Text(friend.initials)
                                    .font(.system(size: 26, weight: .bold)).foregroundColor(.white)
                            }
                            Text(friend.name)
                                .font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(friend.isOnline ? AppTheme.lime : AppTheme.muted)
                                    .frame(width: 8, height: 8)
                                Text(friend.isOnline
                                     ? NSLocalizedString("friend.online",  comment: "")
                                     : NSLocalizedString("friend.offline", comment: ""))
                                    .font(.system(size: 13))
                                    .foregroundColor(friend.isOnline ? AppTheme.lime : AppTheme.muted)
                            }
                        }
                        .padding(.top, 20)

                        // Stats
                        HStack(spacing: 12) {
                            miniStat(NSLocalizedString("friend.stat_workouts", comment: ""),
                                     value: "\(friend.workoutsThisWeek)",
                                     icon: "dumbbell.fill", color: AppTheme.lime)
                            miniStat(NSLocalizedString("friend.stat_distance", comment: ""),
                                     value: distanceString,
                                     icon: "location.fill", color: .orange)
                        }
                        .padding(.horizontal, 20)

                        // Last workout
                        VStack(alignment: .leading, spacing: 6) {
                            Text(NSLocalizedString("friend.last_workout", comment: ""))
                                .font(.system(size: 12, weight: .medium)).foregroundColor(AppTheme.muted)
                                .padding(.leading, 4)
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10).fill(AppTheme.lime.opacity(0.15))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "dumbbell.fill")
                                        .foregroundColor(AppTheme.lime).font(.system(size: 18))
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(friend.lastWorkout)
                                        .font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                                    Text(NSLocalizedString("friend.today", comment: ""))
                                        .font(.system(size: 12)).foregroundColor(AppTheme.muted)
                                }
                                Spacer()
                            }
                            .padding(14)
                            .background(AppTheme.card).cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.border, lineWidth: 1))
                        }
                        .padding(.horizontal, 20)

                        // Challenge button
                        Button {} label: {
                            HStack(spacing: 8) {
                                Image(systemName: "bolt.fill").font(.system(size: 15))
                                Text(NSLocalizedString("friend.challenge", comment: ""))
                                    .font(.system(size: 15, weight: .bold))
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(AppTheme.lime).cornerRadius(100)
                        }
                        .padding(.horizontal, 20)

                        Spacer(minLength: 40)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }

    private var distanceString: String {
        friend.distanceMeters < 1000
            ? String(format: NSLocalizedString("friends.distance_m",  comment: ""), Int(friend.distanceMeters))
            : String(format: NSLocalizedString("friends.distance_km", comment: ""), friend.distanceMeters / 1000)
    }

    private func miniStat(_ label: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(color.opacity(0.15)).frame(width: 40, height: 40)
                Image(systemName: icon).font(.system(size: 16)).foregroundColor(color)
            }
            Text(value).font(.system(size: 20, weight: .bold)).foregroundColor(.white)
            Text(label).font(.system(size: 11)).foregroundColor(AppTheme.muted)
        }
        .frame(maxWidth: .infinity).padding(16)
        .background(AppTheme.card).cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.border, lineWidth: 1))
    }
}

// MARK: — InviteFriendSheet

struct InviteFriendSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var copied = false

    private let inviteCode = "FIT-MA-2026"

    var body: some View {
        ZStack {
            AppTheme.dark.ignoresSafeArea()
            VStack(spacing: 0) {
                Capsule().fill(AppTheme.border).frame(width: 40, height: 4).padding(.top, 12)

                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle().fill(AppTheme.lime.opacity(0.15)).frame(width: 70, height: 70)
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 28)).foregroundColor(AppTheme.lime)
                        }
                        Text(NSLocalizedString("friends.invite_title", comment: ""))
                            .font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                        Text(NSLocalizedString("friends.invite_subtitle", comment: ""))
                            .font(.system(size: 14)).foregroundColor(AppTheme.muted)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)

                    // Invite code
                    VStack(spacing: 6) {
                        Text(NSLocalizedString("friends.invite_code_label", comment: ""))
                            .font(.system(size: 12, weight: .medium)).foregroundColor(AppTheme.muted)
                        HStack(spacing: 12) {
                            Text(inviteCode)
                                .font(.system(size: 22, weight: .bold, design: .monospaced))
                                .foregroundColor(AppTheme.lime)
                            Spacer()
                            Button {
                                UIPasteboard.general.string = inviteCode
                                withAnimation { copied = true }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation { copied = false }
                                }
                            } label: {
                                Image(systemName: copied ? "checkmark.circle.fill" : "doc.on.doc.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(copied ? AppTheme.lime : AppTheme.muted)
                            }
                        }
                        .padding(16)
                        .background(AppTheme.card2).cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.lime.opacity(0.3), lineWidth: 1))
                    }
                    .padding(.horizontal, 20)

                    // Share button
                    Button {
                        let text = String(format: NSLocalizedString("friends.share_text", comment: ""), inviteCode)
                        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                        UIApplication.shared.connectedScenes
                            .compactMap { $0 as? UIWindowScene }
                            .first?.windows.first?.rootViewController?
                            .present(av, animated: true)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up").font(.system(size: 15))
                            Text(NSLocalizedString("friends.share", comment: ""))
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(AppTheme.lime).cornerRadius(100)
                    }
                    .padding(.horizontal, 20)

                    Spacer()
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }
}
