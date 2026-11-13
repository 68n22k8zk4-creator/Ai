import Foundation

struct WeatherService {
    static func searchCity(_ query: String) async throws -> WeatherCity {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = URL(string: "https://geocoding-api.open-meteo.com/v1/search?name=\(encoded)&count=1&language=ru&format=json")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(GeocodingResponse.self, from: data)
        guard let first = response.results?.first else { throw URLError(.fileDoesNotExist) }
        return WeatherCity(name: first.name, country: first.country ?? "", latitude: first.latitude, longitude: first.longitude)
    }

    static func fetch(for city: WeatherCity) async throws -> WeatherSnapshot {
        let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(city.latitude)&longitude=\(city.longitude)&current=temperature_2m,relative_humidity_2m,apparent_temperature,pressure_msl,wind_speed_10m,weather_code&hourly=temperature_2m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min&forecast_days=7&timezone=auto")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
        let currentCode = decoded.current.weather_code
        let days = decoded.daily.time.enumerated().map { index, time in
            let date = ISO8601DateFormatter.withoutTime.date(from: time + "T00:00:00Z") ?? .now
            let hours = (0..<24).map { h in
                let i = min(index * 24 + h, decoded.hourly.time.count - 1)
                let t = ISO8601DateFormatter.withoutTime.date(from: String(decoded.hourly.time[i].prefix(13)) + ":00:00Z") ?? .now
                return (t.formatted(.dateTime.hour(.twoDigits(minimumLength: 2))), Int(decoded.hourly.temperature_2m[i].rounded()), symbol(for: decoded.hourly.weather_code[i]))
            }
            return WeatherDay(date: date, min: Int(decoded.daily.temperature_2m_min[index].rounded()), max: Int(decoded.daily.temperature_2m_max[index].rounded()), symbol: symbol(for: decoded.daily.weather_code[index]), summary: summary(for: decoded.daily.weather_code[index]), hours: hours)
        }
        return WeatherSnapshot(city: city, current: Int(decoded.current.temperature_2m.rounded()), feels: Int(decoded.current.apparent_temperature.rounded()), symbol: symbol(for: currentCode), humidity: Int(decoded.current.relative_humidity_2m), wind: Int(decoded.current.wind_speed_10m.rounded()), pressure: Int(decoded.current.pressure_msl.rounded()), days: days)
    }
    static func symbol(for code: Int) -> String { switch code { case 0: return "sun.max.fill"; case 1...3: return "cloud.sun.fill"; case 45...48: return "cloud.fog.fill"; case 51...67, 80...82: return "cloud.rain.fill"; case 71...77, 85...86: return "snowflake"; case 95...99: return "cloud.bolt.rain.fill"; default: return "cloud.fill" } }
    static func summary(for code: Int) -> String { switch code { case 0: return "Ясно"; case 1...3: return "Переменная облачность"; case 51...67, 80...82: return "Дождь"; case 71...86: return "Снег"; default: return "Облачно" } }
}
private struct OpenMeteoResponse: Codable { struct Current: Codable { var temperature_2m: Double; var relative_humidity_2m: Double; var apparent_temperature: Double; var pressure_msl: Double; var wind_speed_10m: Double; var weather_code: Int }; struct Hourly: Codable { var time: [String]; var temperature_2m: [Double]; var weather_code: [Int] }; struct Daily: Codable { var time: [String]; var weather_code: [Int]; var temperature_2m_max: [Double]; var temperature_2m_min: [Double] }; var current: Current; var hourly: Hourly; var daily: Daily }
private extension ISO8601DateFormatter { static let withoutTime: ISO8601DateFormatter = { let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]; return f }() }

private struct GeocodingResponse: Codable { struct Result: Codable { var name: String; var country: String?; var latitude: Double; var longitude: Double }; var results: [Result]? }
