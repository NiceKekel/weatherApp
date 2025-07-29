
import Foundation

struct WeatherForecastData{
    struct Data: Codable {
        let location: Location
        let current: Hour
        let forecast: Forecast
    }

    // MARK: - Current
    struct Hour: Codable {
        let lastUpdatedEpoch: Int?
        let lastUpdated: String?
        let tempC, tempF: Double
        let feelslikeC, feelslikeF: Double
        let windchillC, windchillF: Double
        let heatindexC, heatindexF: Double
        let dewpointC, dewpointF: Double
        let isDay: Int
        let condition: Condition
        let windMph, windKph: Double
        let windDegree: Int
        let windDir: String
        let pressureIn, pressureMB: Double
        let precipMm, precipIn: Double
        let humidity, cloud: Int
        let visKM, visMiles: Double
        let gustMph, gustKph: Double
        let uv: Double
        let timeEpoch: Int?
        let time: String?
        let snowCM: Double?
        let willItRain, willItSnow: Int?
        let chanceOfRain, chanceOfSnow: Int?

        enum CodingKeys: String, CodingKey {
            case lastUpdatedEpoch = "last_updated_epoch"
            case lastUpdated = "last_updated"
            case tempC = "temp_c"
            case tempF = "temp_f"
            case isDay = "is_day"
            case condition
            case windMph = "wind_mph"
            case windKph = "wind_kph"
            case windDegree = "wind_degree"
            case windDir = "wind_dir"
            case pressureMB = "pressure_mb"
            case pressureIn = "pressure_in"
            case precipMm = "precip_mm"
            case precipIn = "precip_in"
            case humidity, cloud
            case feelslikeC = "feelslike_c"
            case feelslikeF = "feelslike_f"
            case windchillC = "windchill_c"
            case windchillF = "windchill_f"
            case heatindexC = "heatindex_c"
            case heatindexF = "heatindex_f"
            case dewpointC = "dewpoint_c"
            case dewpointF = "dewpoint_f"
            case visKM = "vis_km"
            case visMiles = "vis_miles"
            case uv
            case gustMph = "gust_mph"
            case gustKph = "gust_kph"
            case timeEpoch = "time_epoch"
            case time
            case snowCM = "snow_cm"
            case willItRain = "will_it_rain"
            case chanceOfRain = "chance_of_rain"
            case willItSnow = "will_it_snow"
            case chanceOfSnow = "chance_of_snow"
        }
    }

    // MARK: - Condition
    struct Condition: Codable {
        let text: String
        let icon: String
        let code: Int
    }


    // MARK: - Forecast
    struct Forecast: Codable {
        let forecastday: [Forecastday]
    }

    // MARK: - Forecastday
    struct Forecastday: Codable {
        let date: String
        let dateEpoch: Int
        let day: Day
        let astro: Astro
        let hour: [Hour]

        enum CodingKeys: String, CodingKey {
            case date
            case dateEpoch = "date_epoch"
            case day, astro, hour
        }
    }

    // MARK: - Astro
    struct Astro: Codable {
        let sunrise, sunset, moonrise, moonset: String
        let moonPhase: String
        let isMoonUp, isSunUp: Int
        let moonIllumination: Double
        enum CodingKeys: String, CodingKey {
            case sunrise, sunset, moonrise, moonset
            case moonPhase = "moon_phase"
            case moonIllumination = "moon_illumination"
            case isMoonUp = "is_moon_up"
            case isSunUp = "is_sun_up"
        }
    }

    // MARK: - Day
    struct Day: Codable {
        let maxtempC, maxtempF: Double
        let mintempC, mintempF: Double
        let avgtempC, avgtempF: Double
        let maxwindMph, maxwindKph: Double
        let totalprecipMm, totalprecipIn: Double
        let totalsnowCM: Double
        let avgVisKM, avgVisMiles: Double
        let avghumidity: Int
        let dailyWillItRain, dailyWillItSnow: Int
        let dailyChanceOfSnow, dailyChanceOfRain: Int
        let condition: Condition
        let uv: Double

        enum CodingKeys: String, CodingKey {
            case maxtempC = "maxtemp_c"
            case maxtempF = "maxtemp_f"
            case mintempC = "mintemp_c"
            case mintempF = "mintemp_f"
            case avgtempC = "avgtemp_c"
            case avgtempF = "avgtemp_f"
            case maxwindMph = "maxwind_mph"
            case maxwindKph = "maxwind_kph"
            case totalprecipMm = "totalprecip_mm"
            case totalprecipIn = "totalprecip_in"
            case totalsnowCM = "totalsnow_cm"
            case avgVisKM = "avgvis_km"
            case avgVisMiles = "avgvis_miles"
            case avghumidity
            case dailyWillItRain = "daily_will_it_rain"
            case dailyChanceOfRain = "daily_chance_of_rain"
            case dailyWillItSnow = "daily_will_it_snow"
            case dailyChanceOfSnow = "daily_chance_of_snow"
            case condition, uv
        }
    }

    // MARK: - Location
    struct Location: Codable {
        let name, region, country: String
        let lat: Double
        let lon: Double
        let tzID: String
        let localtimeEpoch: Int
        let localtime: String

        enum CodingKeys: String, CodingKey {
            case name, region, country, lat, lon
            case tzID = "tz_id"
            case localtimeEpoch = "localtime_epoch"
            case localtime
        }
    }
}
