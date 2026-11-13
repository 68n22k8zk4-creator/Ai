import Foundation

public enum FlamioShared {
    public static let appGroup = "group.com.flamio.app"
    public static let widgetSnapshotKey = "flamio.widget.snapshot"
}

public struct WidgetSnapshot: Codable {
    public var petName: String
    public var streak: Int
    public var shiftHours: Double
    public var monthIncome: Double
    public var monthSpending: Double
    public var currency: String
    public var weatherCity: String
    public var weatherTemperature: Int
    public var weatherSymbol: String
    public var updatedAt: Date

    public init(petName: String = "Флами", streak: Int = 1, shiftHours: Double = 0, monthIncome: Double = 0, monthSpending: Double = 0, currency: String = "€", weatherCity: String = "Прага", weatherTemperature: Int = 5, weatherSymbol: String = "cloud.sun.fill", updatedAt: Date = .now) {
        self.petName = petName; self.streak = streak; self.shiftHours = shiftHours; self.monthIncome = monthIncome; self.monthSpending = monthSpending; self.currency = currency; self.weatherCity = weatherCity; self.weatherTemperature = weatherTemperature; self.weatherSymbol = weatherSymbol; self.updatedAt = updatedAt
    }
}
