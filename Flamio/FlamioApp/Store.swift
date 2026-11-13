import Foundation
import SwiftUI
import UserNotifications

@MainActor final class AppStore: ObservableObject {
    @Published var settings: AppSettings { didSet { save(settings, key: "settings") } }
    @Published var shifts: [WorkShift] { didSet { save(shifts, key: "shifts"); syncWidget() } }
    @Published var money: [MoneyEntry] { didSet { save(money, key: "money"); syncWidget() } }
    @Published var pet: PetState { didSet { save(pet, key: "pet"); syncWidget() } }
    @Published var savedCities: [WeatherCity] { didSet { save(savedCities, key: "cities") } }
    @Published var selectedCityID: UUID { didSet { UserDefaults.standard.set(selectedCityID.uuidString, forKey: "selectedCity") } }
    @Published var weather: WeatherSnapshot?
    @Published var weatherLoading = false
    @Published var notice: String?

    init() {
        let d = UserDefaults.standard
        settings = load(AppSettings.self, key: "settings") ?? AppSettings()
        shifts = load([WorkShift].self, key: "shifts") ?? []
        money = load([MoneyEntry].self, key: "money") ?? []
        pet = load(PetState.self, key: "pet") ?? PetState()
        savedCities = load([WeatherCity].self, key: "cities") ?? [WeatherCity(name: "Прага", country: "Чехия", latitude: 50.0755, longitude: 14.4378), WeatherCity(name: "Киев", country: "Украина", latitude: 50.4501, longitude: 30.5234)]
        let savedID = UUID(uuidString: d.string(forKey: "selectedCity") ?? "")
        selectedCityID = savedID ?? savedCities[0].id
        Task { await refreshWeather() }
        syncWidget()
    }
    func load<T: Decodable>(_ type: T.Type, key: String) -> T? { guard let data = UserDefaults.standard.data(forKey: key) else { return nil }; return try? JSONDecoder().decode(type, from: data) }
    func save<T: Encodable>(_ value: T, key: String) { if let data = try? JSONEncoder().encode(value) { UserDefaults.standard.set(data, forKey: key) } }
    var selectedCity: WeatherCity { savedCities.first(where: { $0.id == selectedCityID }) ?? savedCities[0] }
    var monthlyIncome: Double { let entries = money.filter { $0.isIncome && Calendar.current.isDate($0.date, equalTo: .now, toGranularity: .month) }.reduce(0) { $0 + $1.amount }; return entries + monthlyHours * settings.hourlyRate + settings.monthlyBonus }
    var monthlySpending: Double { money.filter { !$0.isIncome && Calendar.current.isDate($0.date, equalTo: .now, toGranularity: .month) }.reduce(0) { $0 + $1.amount } }
    var monthlyHours: Double { shifts.filter { Calendar.current.isDate($0.date, equalTo: .now, toGranularity: .month) }.reduce(0) { $0 + $1.duration / 3600 } }
    func addCare(_ food: FoodKind) { pet.feeds.insert(PetFeed(food: food), at: 0); pet.lastCare = .now; if let last = pet.lastCare, Calendar.current.isDateInToday(last) { pet.streak = max(1, pet.streak) }; notice = "Флами доволен! +1 к заботе" }
    func play(_ minutes: Int = 10) { pet.playMinutes += minutes; pet.lastCare = .now; notice = "Флами отлично поиграл!" }
    func syncWidget() { let snap = WidgetSnapshot(petName: pet.name, streak: pet.streak, shiftHours: monthlyHours, monthIncome: monthlyIncome, monthSpending: monthlySpending, currency: settings.currency, weatherCity: selectedCity.name, weatherTemperature: weather?.current ?? 5, weatherSymbol: weather?.symbol ?? "cloud.sun.fill"); if let data = try? JSONEncoder().encode(snap), let defaults = UserDefaults(suiteName: FlamioShared.appGroup) { defaults.set(data, forKey: FlamioShared.widgetSnapshotKey); defaults.synchronize() }; NotificationCenter.default.post(name: .flamioWidgetUpdate, object: nil) }
    func requestNotifications() async { let center = UNUserNotificationCenter.current(); if settings.notifications { _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge]); scheduleReminders() } else { center.removeAllPendingNotificationRequests() } }
    func scheduleReminders() { let center = UNUserNotificationCenter.current(); center.removeAllPendingNotificationRequests(); var comps = DateComponents(); comps.hour = 19; let request = UNNotificationRequest(identifier: "pet-care", content: { let c = UNMutableNotificationContent(); c.title = "Флами ждёт тебя"; c.body = "Покорми или поиграй — огонёк не должен погаснуть"; c.sound = .default; return c }(), trigger: UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)); center.add(request) }
    func refreshWeather() async { weatherLoading = true; defer { weatherLoading = false }; do { weather = try await WeatherService.fetch(for: selectedCity) } catch { notice = "Не удалось обновить погоду — показан сохранённый прогноз" }; syncWidget() }
}
extension Notification.Name { static let flamioWidgetUpdate = Notification.Name("flamioWidgetUpdate") }
