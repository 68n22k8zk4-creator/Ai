import Foundation
import SwiftUI

struct AppSettings: Codable {
    var theme: AppTheme = .dark
    var accent: AccentTheme = .violet
    var language: AppLanguage = .russian
    var currency: String = "€"
    var reduceMotion = false
    var notifications = true
    var hourlyRate: Double = 12
    var monthlyBonus: Double = 0
}
enum AppTheme: String, Codable, CaseIterable { case system, light, dark }
enum AccentTheme: String, Codable, CaseIterable { case violet, orange, blue, mint
    var colors: [Color] { switch self { case .violet: return [.purple, .indigo]; case .orange: return [.orange, .pink]; case .blue: return [.blue, .cyan]; case .mint: return [.mint, .teal] } }
}
enum AppLanguage: String, Codable, CaseIterable { case russian, english
    var code: String { self == .russian ? "ru" : "en" }
}

enum AppTab: String, CaseIterable { case weather, shifts, pet, finance
    var title: String { switch self { case .weather: return "Погода"; case .shifts: return "Смены"; case .pet: return "Огонёк"; case .finance: return "Финансы" } }
    var icon: String { switch self { case .weather: return "cloud.sun.fill"; case .shifts: return "calendar"; case .pet: return "flame.fill"; case .finance: return "wallet.pass.fill" } }
}

struct WorkShift: Identifiable, Codable { var id = UUID(); var name: String; var emoji: String; var date: Date; var start: Date; var end: Date; var breakMinutes: Int; var lunchMinutes: Int; var isManual = false; var note = ""
    var duration: TimeInterval { max(0, end.timeIntervalSince(start) - Double((breakMinutes + lunchMinutes) * 60)) }
}
enum ShiftFilter: String, CaseIterable { case day, week, month, all }

struct MoneyEntry: Identifiable, Codable { var id = UUID(); var title: String; var amount: Double; var date: Date = .now; var emoji: String = "🛒"; var isIncome: Bool; var note: String = "" }
enum MoneyFilter: String, CaseIterable { case all, income, spending; var title: String { switch self { case .all: return "Всё"; case .income: return "Доходы"; case .spending: return "Траты" } } }

enum FoodKind: String, CaseIterable, Codable { case fish, broccoli, apple, burger, chocolate
    var emoji: String { switch self { case .fish: return "🐟"; case .broccoli: return "🥦"; case .apple: return "🍎"; case .burger: return "🍔"; case .chocolate: return "🍫" } }
    var title: String { switch self { case .fish: return "Рыба"; case .broccoli: return "Брокколи"; case .apple: return "Яблоко"; case .burger: return "Бургер"; case .chocolate: return "Шоколад" } }
    var quality: Int { switch self { case .fish: return 3; case .broccoli: return 3; case .apple: return 2; case .burger: return 1; case .chocolate: return 0 } }
}
struct PetFeed: Identifiable, Codable { var id = UUID(); var food: FoodKind; var date: Date = .now }
struct PetState: Codable { var name = "Флами"; var streak = 1; var lastCare: Date?; var feeds: [PetFeed] = []; var playMinutes = 0; var hat = "✨"; var jacket = "🧥"; var accessory = "🔥" }

struct WeatherDay: Identifiable { var id = UUID(); var date: Date; var min: Int; var max: Int; var symbol: String; var summary: String; var hours: [(String, Int, String)] }
struct WeatherCity: Identifiable, Codable, Hashable { var id = UUID(); var name: String; var country: String; var latitude: Double; var longitude: Double }
struct WeatherSnapshot { var city: WeatherCity; var current: Int; var feels: Int; var symbol: String; var humidity: Int; var wind: Int; var pressure: Int; var days: [WeatherDay]; var fetchedAt = Date.now }

extension Date { var shortDay: String { formatted(.dateTime.weekday(.abbreviated)) }; var shortDate: String { formatted(.dateTime.day().month(.abbreviated)) }; var monthYear: String { formatted(.dateTime.month(.wide).year()) } }
