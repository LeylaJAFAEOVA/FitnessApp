//
//  NutritionView.swift
//  FitnessApp
//
//  Created by Leyla Jafarova on 26/04/2026.
//

import SwiftUI
import Combine

// MARK: — Models

struct Meal: Identifiable {
    let id = UUID()
    var name: String
    var items: [FoodItem]
    var icon: String
    var time: String
}

struct FoodItem: Identifiable {
    let id = UUID()
    var name: String
    var calories: Int
    var protein: Double
    var fat: Double
    var carbs: Double
    var grams: Int
}

// MARK: — NutritionViewModel

class NutritionViewModel: ObservableObject {
    @Published var targetCalories: Int = 2000
    @Published var meals: [Meal] = [
        Meal(
            name: NSLocalizedString("nutrition.meal.breakfast", comment: ""),
            items: [
                FoodItem(name: "Овсянка", calories: 150, protein: 5, fat: 3, carbs: 27, grams: 80),
                FoodItem(name: "Банан",   calories: 89,  protein: 1, fat: 0, carbs: 23, grams: 100),
            ],
            icon: "sun.horizon.fill",
            time: "08:00"
        ),
        Meal(
            name: NSLocalizedString("nutrition.meal.lunch", comment: ""),
            items: [
                FoodItem(name: "Куриная грудка", calories: 165, protein: 31, fat: 4, carbs: 0,  grams: 100),
                FoodItem(name: "Рис бурый",      calories: 112, protein: 2,  fat: 1, carbs: 24, grams: 100),
                FoodItem(name: "Огурец",         calories: 15,  protein: 1,  fat: 0, carbs: 3,  grams: 100),
            ],
            icon: "sun.max.fill",
            time: "13:00"
        ),
        Meal(
            name: NSLocalizedString("nutrition.meal.dinner", comment: ""),
            items: [
                FoodItem(name: "Лосось",   calories: 208, protein: 20, fat: 13, carbs: 0, grams: 100),
                FoodItem(name: "Брокколи", calories: 35,  protein: 2,  fat: 0,  carbs: 7, grams: 150),
            ],
            icon: "moon.stars.fill",
            time: "19:00"
        ),
    ]

    var consumedCalories: Int { meals.flatMap { $0.items }.reduce(0) { $0 + $1.calories } }
    var remainingCalories: Int { max(0, targetCalories - consumedCalories) }
    var progress: Double { min(Double(consumedCalories) / Double(targetCalories), 1.0) }

    var totalProtein: Double { meals.flatMap { $0.items }.reduce(0) { $0 + $1.protein } }
    var totalFat:     Double { meals.flatMap { $0.items }.reduce(0) { $0 + $1.fat } }
    var totalCarbs:   Double { meals.flatMap { $0.items }.reduce(0) { $0 + $1.carbs } }

    var targetProtein: Double { Double(targetCalories) * 0.30 / 4 }
    var targetFat:     Double { Double(targetCalories) * 0.25 / 9 }
    var targetCarbs:   Double { Double(targetCalories) * 0.45 / 4 }
}

// MARK: — NutritionView

struct NutritionView: View {
    @StateObject private var vm = NutritionViewModel()
    @State private var showAddFood = false
    @State private var selectedMealIndex: Int = 0

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.dark.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        calorieRing
                        macrosRow
                        mealsSection
                        waterSection
                        Spacer(minLength: 40)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle(NSLocalizedString("nutrition.title", comment: ""))
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(AppTheme.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showAddFood = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(AppTheme.lime).font(.system(size: 22))
                    }
                }
            }
            .sheet(isPresented: $showAddFood) {
                AddFoodSheet(vm: vm, mealIndex: selectedMealIndex)
            }
        }
    }

    // MARK: — Calorie Ring

    private var calorieRing: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(AppTheme.card2, lineWidth: 18)
                    .frame(width: 160, height: 160)

                Circle()
                    .trim(from: 0, to: vm.progress)
                    .stroke(
                        vm.progress >= 1.0 ? Color.orange : AppTheme.lime,
                        style: StrokeStyle(lineWidth: 18, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.6), value: vm.progress)

                VStack(spacing: 2) {
                    Text("\(vm.consumedCalories)")
                        .font(.system(size: 32, weight: .bold)).foregroundColor(.white)
                    Text(String(format: NSLocalizedString("nutrition.calories_of", comment: ""), vm.targetCalories))
                        .font(.system(size: 11)).foregroundColor(AppTheme.muted)
                }
            }

            HStack(spacing: 24) {
                ringLegend(
                    color: AppTheme.lime,
                    label: NSLocalizedString("nutrition.consumed", comment: ""),
                    value: "\(vm.consumedCalories)"
                )
                ringLegend(
                    color: AppTheme.muted,
                    label: NSLocalizedString("nutrition.remaining", comment: ""),
                    value: "\(vm.remainingCalories)"
                )
                ringLegend(
                    color: .orange,
                    label: NSLocalizedString("nutrition.goal", comment: ""),
                    value: "\(vm.targetCalories)"
                )
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .background(AppTheme.card).cornerRadius(24)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(AppTheme.border, lineWidth: 1))
        .padding(.horizontal, 20)
        .padding(.top, 4)
    }

    private func ringLegend(color: Color, label: String, value: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Circle().fill(color).frame(width: 8, height: 8)
                Text(label).font(.system(size: 11)).foregroundColor(AppTheme.muted)
            }
            Text(value)
                .font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
        }
    }

    // MARK: — Macros Row

    private var macrosRow: some View {
        HStack(spacing: 12) {
            macroCard(
                NSLocalizedString("nutrition.protein", comment: ""),
                value: vm.totalProtein,
                target: vm.targetProtein,
                color: Color(hex: "#4D9FFF")
            )
            macroCard(
                NSLocalizedString("nutrition.fat", comment: ""),
                value: vm.totalFat,
                target: vm.targetFat,
                color: Color(hex: "#FF8C00")
            )
            macroCard(
                NSLocalizedString("nutrition.carbs", comment: ""),
                value: vm.totalCarbs,
                target: vm.targetCarbs,
                color: Color(hex: "#A855F7")
            )
        }
        .padding(.horizontal, 20)
    }

    private func macroCard(_ name: String, value: Double, target: Double, color: Color) -> some View {
        let prog = min(value / target, 1.0)
        return VStack(alignment: .leading, spacing: 8) {
            Text(name).font(.system(size: 11)).foregroundColor(AppTheme.muted)
            Text("\(Int(value)) \(NSLocalizedString("nutrition.gram_unit", comment: ""))")
                .font(.system(size: 18, weight: .bold)).foregroundColor(.white)
            Text(String(format: NSLocalizedString("nutrition.macro_of", comment: ""), Int(target)))
                .font(.system(size: 10)).foregroundColor(AppTheme.muted)

            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(AppTheme.border)
                    Capsule().fill(color)
                        .frame(width: g.size.width * prog)
                        .animation(.easeInOut(duration: 0.5), value: prog)
                }
            }
            .frame(height: 4)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.card).cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.border, lineWidth: 1))
    }

    // MARK: — Meals

    private var mealsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("nutrition.meals_section", comment: ""))
                .font(.system(size: 17, weight: .semibold)).foregroundColor(.white)
                .padding(.horizontal, 20)

            VStack(spacing: 12) {
                ForEach(Array(vm.meals.enumerated()), id: \.element.id) { idx, meal in
                    MealCard(meal: meal) {
                        selectedMealIndex = idx
                        showAddFood = true
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: — Water

    @State private var waterGlasses: Int = 4
    private let targetGlasses = 8

    private var waterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "drop.fill")
                    .foregroundColor(Color(hex: "#4D9FFF")).font(.system(size: 14))
                Text(NSLocalizedString("nutrition.water", comment: ""))
                    .font(.system(size: 17, weight: .semibold)).foregroundColor(.white)
            }
            .padding(.horizontal, 20)

            HStack(spacing: 10) {
                HStack(spacing: 6) {
                    ForEach(0..<targetGlasses, id: \.self) { i in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                waterGlasses = i < waterGlasses ? i : i + 1
                            }
                        } label: {
                            Image(systemName: i < waterGlasses ? "drop.fill" : "drop")
                                .font(.system(size: 18))
                                .foregroundColor(i < waterGlasses ? Color(hex: "#4D9FFF") : AppTheme.muted)
                                .animation(.spring(response: 0.3), value: waterGlasses)
                        }
                    }
                }
                Spacer()
                Text("\(waterGlasses) / \(targetGlasses)")
                    .font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                Text(NSLocalizedString("nutrition.glasses", comment: ""))
                    .font(.system(size: 12)).foregroundColor(AppTheme.muted)
            }
            .padding(16)
            .background(AppTheme.card).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.border, lineWidth: 1))
            .padding(.horizontal, 20)
        }
    }
}

// MARK: — MealCard

struct MealCard: View {
    let meal: Meal
    let onAdd: () -> Void
    @State private var isExpanded = true

    private var mealCalories: Int { meal.items.reduce(0) { $0 + $1.calories } }

    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) { isExpanded.toggle() }
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(AppTheme.lime.opacity(0.15)).frame(width: 40, height: 40)
                        Image(systemName: meal.icon)
                            .font(.system(size: 16)).foregroundColor(AppTheme.lime)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(meal.name)
                            .font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                        Text(meal.time)
                            .font(.system(size: 11)).foregroundColor(AppTheme.muted)
                    }
                    Spacer()
                    Text("\(mealCalories) \(NSLocalizedString("workouts.kcal", comment: ""))")
                        .font(.system(size: 13, weight: .medium)).foregroundColor(AppTheme.lime)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11)).foregroundColor(AppTheme.muted)
                }
                .padding(14)
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider().background(AppTheme.border).padding(.horizontal, 14)

                VStack(spacing: 0) {
                    ForEach(meal.items) { item in
                        HStack(spacing: 10) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name)
                                    .font(.system(size: 13, weight: .medium)).foregroundColor(.white)
                                Text("\(item.grams) \(NSLocalizedString("nutrition.gram_unit", comment: ""))")
                                    .font(.system(size: 11)).foregroundColor(AppTheme.muted)
                            }
                            Spacer()
                            Text("\(item.calories) \(NSLocalizedString("workouts.kcal", comment: ""))")
                                .font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        if item.id != meal.items.last?.id {
                            Divider().background(AppTheme.border).padding(.leading, 14)
                        }
                    }

                    Button { onAdd() } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill").font(.system(size: 14))
                            Text(NSLocalizedString("nutrition.add_food", comment: ""))
                                .font(.system(size: 13))
                        }
                        .foregroundColor(AppTheme.lime)
                        .frame(maxWidth: .infinity).padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)
                    .background(AppTheme.lime.opacity(0.05))
                }
            }
        }
        .background(AppTheme.card).cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.border, lineWidth: 1))
    }
}

// MARK: — AddFoodSheet

struct AddFoodSheet: View {
    @ObservedObject var vm: NutritionViewModel
    let mealIndex: Int
    @Environment(\.dismiss) var dismiss

    @State private var searchText = ""
    @State private var grams = 100
    @State private var showNewProduct = false

    @State private var customFoods: [FoodItem] = []

    private let builtinDatabase: [FoodItem] = [
        FoodItem(name: "Яйцо",             calories: 155, protein: 13, fat: 11, carbs: 1,  grams: 100),
        FoodItem(name: "Творог 5%",        calories: 121, protein: 18, fat: 5,  carbs: 3,  grams: 100),
        FoodItem(name: "Греческий йогурт", calories: 59,  protein: 10, fat: 0,  carbs: 4,  grams: 100),
        FoodItem(name: "Гречка",           calories: 343, protein: 13, fat: 3,  carbs: 71, grams: 100),
        FoodItem(name: "Куриная грудка",   calories: 165, protein: 31, fat: 4,  carbs: 0,  grams: 100),
        FoodItem(name: "Говядина",         calories: 250, protein: 26, fat: 16, carbs: 0,  grams: 100),
        FoodItem(name: "Лосось",           calories: 208, protein: 20, fat: 13, carbs: 0,  grams: 100),
        FoodItem(name: "Банан",            calories: 89,  protein: 1,  fat: 0,  carbs: 23, grams: 100),
        FoodItem(name: "Яблоко",           calories: 52,  protein: 0,  fat: 0,  carbs: 14, grams: 100),
        FoodItem(name: "Овсянка",          calories: 150, protein: 5,  fat: 3,  carbs: 27, grams: 100),
        FoodItem(name: "Миндаль",          calories: 579, protein: 21, fat: 50, carbs: 22, grams: 100),
        FoodItem(name: "Авокадо",          calories: 160, protein: 2,  fat: 15, carbs: 9,  grams: 100),
    ]

    private var allFoods: [FoodItem] { customFoods + builtinDatabase }

    private var filtered: [FoodItem] {
        searchText.isEmpty ? allFoods : allFoods.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack {
            AppTheme.dark.ignoresSafeArea()
            VStack(spacing: 0) {
                Capsule().fill(AppTheme.border).frame(width: 40, height: 4).padding(.top, 12)

                // Header
                HStack {
                    Button(NSLocalizedString("add.cancel", comment: "")) { dismiss() }
                        .foregroundColor(AppTheme.muted)
                    Spacer()
                    Text(NSLocalizedString("nutrition.add_food", comment: ""))
                        .font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                    Spacer()
                    Button {
                        showNewProduct = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(AppTheme.lime)
                    }
                }
                .padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 12)

                // Search
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass").foregroundColor(AppTheme.muted)
                    TextField("", text: $searchText)
                        .placeholder(when: searchText.isEmpty) {
                            Text(NSLocalizedString("nutrition.search_placeholder", comment: ""))
                                .foregroundColor(AppTheme.muted)
                        }
                        .foregroundColor(.white).font(.system(size: 14))
                }
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(AppTheme.card).cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.border, lineWidth: 1))
                .padding(.horizontal, 20).padding(.bottom, 12)

                Divider().background(AppTheme.border)

                // Food list
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(filtered) { item in
                            Button {
                                let scaled = FoodItem(
                                    name:     item.name,
                                    calories: Int(Double(item.calories) * Double(grams) / 100),
                                    protein:  item.protein * Double(grams) / 100,
                                    fat:      item.fat     * Double(grams) / 100,
                                    carbs:    item.carbs   * Double(grams) / 100,
                                    grams:    grams
                                )
                                if mealIndex < vm.meals.count {
                                    vm.meals[mealIndex].items.append(scaled)
                                }
                                dismiss()
                            } label: {
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(item.name)
                                            .font(.system(size: 15)).foregroundColor(.white)
                                        HStack(spacing: 8) {
                                            Text("\(NSLocalizedString("nutrition.macro.p", comment: "")): \(Int(item.protein))\(NSLocalizedString("nutrition.gram_unit", comment: ""))")
                                                .font(.system(size: 11)).foregroundColor(Color(hex: "#4D9FFF"))
                                            Text("\(NSLocalizedString("nutrition.macro.f", comment: "")): \(Int(item.fat))\(NSLocalizedString("nutrition.gram_unit", comment: ""))")
                                                .font(.system(size: 11)).foregroundColor(Color(hex: "#FF8C00"))
                                            Text("\(NSLocalizedString("nutrition.macro.c", comment: "")): \(Int(item.carbs))\(NSLocalizedString("nutrition.gram_unit", comment: ""))")
                                                .font(.system(size: 11)).foregroundColor(Color(hex: "#A855F7"))
                                        }
                                    }
                                    Spacer()
                                    Text("\(item.calories) \(NSLocalizedString("workouts.kcal", comment: ""))")
                                        .font(.system(size: 14, weight: .semibold)).foregroundColor(AppTheme.lime)
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 20)).foregroundColor(AppTheme.lime)
                                }
                                .padding(.horizontal, 20).padding(.vertical, 14)
                            }
                            .buttonStyle(.plain)
                            Divider().background(AppTheme.border).padding(.leading, 20)
                        }
                    }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .sheet(isPresented: $showNewProduct) {
            NewProductSheet { newItem in
                customFoods.insert(newItem, at: 0)
            }
        }
    }
}

// MARK: — NewProductSheet

struct NewProductSheet: View {
    @Environment(\.dismiss) var dismiss
    let onSave: (FoodItem) -> Void

    @State private var name     = ""
    @State private var calories = ""
    @State private var protein  = ""
    @State private var fat      = ""
    @State private var carbs    = ""
    @State private var grams    = "100"

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        Int(calories) != nil
    }

    var body: some View {
        ZStack {
            AppTheme.dark.ignoresSafeArea()
            VStack(spacing: 0) {
                Capsule().fill(AppTheme.border).frame(width: 40, height: 4).padding(.top, 12)

                // Header
                HStack {
                    Button(NSLocalizedString("add.cancel", comment: "")) { dismiss() }
                        .foregroundColor(AppTheme.muted)
                    Spacer()
                    Text(NSLocalizedString("nutrition.new_product", comment: ""))
                        .font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                    Spacer()
                    Button(NSLocalizedString("add.save", comment: "")) {
                        let item = FoodItem(
                            name:     name.trimmingCharacters(in: .whitespaces),
                            calories: Int(calories) ?? 0,
                            protein:  Double(protein)  ?? 0,
                            fat:      Double(fat)      ?? 0,
                            carbs:    Double(carbs)    ?? 0,
                            grams:    Int(grams)       ?? 100
                        )
                        onSave(item)
                        dismiss()
                    }
                    .foregroundColor(isValid ? AppTheme.lime : AppTheme.muted)
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
                .padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {

                        // Name
                        fieldRow(
                            label: NSLocalizedString("nutrition.product_name", comment: ""),
                            placeholder: NSLocalizedString("nutrition.product_name_placeholder", comment: ""),
                            text: $name,
                            keyboard: .default
                        )

                        // Calories
                        fieldRow(
                            label: NSLocalizedString("nutrition.calories_field", comment: ""),
                            placeholder: "0",
                            text: $calories,
                            keyboard: .numberPad,
                            unit: NSLocalizedString("workouts.kcal", comment: "")
                        )

                        // Grams
                        fieldRow(
                            label: NSLocalizedString("nutrition.grams_field", comment: ""),
                            placeholder: "100",
                            text: $grams,
                            keyboard: .numberPad,
                            unit: NSLocalizedString("nutrition.gram_unit", comment: "")
                        )

                        // Macros
                        VStack(spacing: 1) {
                            macroRow(
                                label: NSLocalizedString("nutrition.protein", comment: ""),
                                color: Color(hex: "#4D9FFF"),
                                text: $protein
                            )
                            macroRow(
                                label: NSLocalizedString("nutrition.fat", comment: ""),
                                color: Color(hex: "#FF8C00"),
                                text: $fat
                            )
                            macroRow(
                                label: NSLocalizedString("nutrition.carbs", comment: ""),
                                color: Color(hex: "#A855F7"),
                                text: $carbs
                            )
                        }
                        .background(AppTheme.card).cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.border, lineWidth: 1))
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }

    private func fieldRow(label: String, placeholder: String, text: Binding<String>, keyboard: UIKeyboardType, unit: String? = nil) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14)).foregroundColor(AppTheme.muted)
                .frame(width: 110, alignment: .leading)
            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .foregroundColor(.white).font(.system(size: 15))
            if let unit {
                Text(unit).font(.system(size: 13)).foregroundColor(AppTheme.muted)
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 14)
        .background(AppTheme.card).cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.border, lineWidth: 1))
    }

    private func macroRow(label: String, color: Color, text: Binding<String>) -> some View {
        HStack {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label)
                .font(.system(size: 14)).foregroundColor(.white)
                .frame(width: 100, alignment: .leading)
            Spacer()
            TextField("0", text: text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .foregroundColor(.white).font(.system(size: 15))
                .frame(width: 60)
            Text(NSLocalizedString("nutrition.gram_unit", comment: ""))
                .font(.system(size: 13)).foregroundColor(AppTheme.muted)
        }
        .padding(.horizontal, 14).padding(.vertical, 13)
    }
}
