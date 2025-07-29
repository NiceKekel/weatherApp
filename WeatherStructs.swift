
import Foundation

struct WeatherData{
    let hourlyData:[ForecastHourDatum]
    
    let daylyData:[ForecastDayDatum]
    
    let cityName:String
    
    let current:WeatherForecastData.Hour
    
    init(data:WeatherForecastData.Data) {
        self.hourlyData = ForecastHourDatum.initForecastHourDatums(data: data, startTs: data.current.timeEpoch)
        self.daylyData = ForecastDayDatum.initForecastData(data: data)
        self.cityName = data.location.name
        self.current = data.current
    }
}

//MARK: - DayDatum
struct ForecastDayDatum{
    let date:FormatedDate
    
    let ditailData:DitailData
    
    let sunData:SunData
    
    let windData:WindData
    
    let weatherIcon:String
    let minTemp:String
    let avrgTemp:String
    
    private init(date: FormatedDate, ditailData: DitailData, sunData: SunData, hourlyData:[WeatherForecastData.Hour], weatherIcon: String, temp: Double, minTemp:Double) {
        self.date = date
        self.ditailData = ditailData
        self.sunData = sunData
        self.windData = WindData.init(data: hourlyData)
        self.weatherIcon = weatherIcon
        self.avrgTemp = "\(Int(round(temp)))°"
        self.minTemp = "(\(Int(round(minTemp)))°)"
    }
    static func initForecastData(data:WeatherForecastData.Data) -> [ForecastDayDatum]{
        let ditailData = DitailData.initDitailDates(data: data)
        var result:[ForecastDayDatum] = []
        var i:Int = 0
        for forecastDay in data.forecast.forecastday{
            
            let day = forecastDay.day
            result.append(
                ForecastDayDatum(date: FormatedDate(date: forecastDay.dateEpoch),
                                 ditailData: i < ditailData.count ?  ditailData[i] : DitailData.empty(),
                                 sunData: SunData.convertFromAstro(data: forecastDay.astro),
                                 hourlyData: forecastDay.hour,
                                 weatherIcon: day.condition.icon,
                                 temp: day.avgtempC,
                                 minTemp: day.mintempC))
            i += 1
        }
        return result
    }
}
//MARK: - HourDatum
struct ForecastHourDatum{
    let hour:String
  //  let ts:Int
    let weatherIcon:String
//TODO: - RENAME ALL BULL SHIT
    let temp:String
    let ts:Int
    private init(datum:WeatherForecastData.Hour) {
        self.hour = Date(timeIntervalSince1970: TimeInterval(datum.timeEpoch ?? 0)).formatted(date: .omitted, time: .shortened)
        self.weatherIcon = datum.condition.icon
        self.temp = "\(Int(round(datum.tempC)))°"
        self.ts = datum.timeEpoch ?? 0
    }
    static func initForecastHourDatums(data:WeatherForecastData.Data, startTs:Int?) -> [ForecastHourDatum]{
        var result:[ForecastHourDatum] = []
        for forecastDay in data.forecast.forecastday {
            for hour in forecastDay.hour {
                guard hour.timeEpoch ?? 0 >= startTs ?? 0 else { continue }
                result.append(ForecastHourDatum(datum: hour))
            }
            
        }
        return result
    }
}
//MARK: - DitailData

struct DitailData{
    struct QwarterData{
        let maxTemp:String
        let minTemp:String
        let conditionIcon:String
        let windSpeed:String
        
        private init(maxTemp: String, minTemp: String, condition: String, windSpeed: String) {
            self.maxTemp = maxTemp
            self.minTemp = minTemp
            self.conditionIcon = condition
            self.windSpeed = windSpeed
        }
        fileprivate init(data:[WeatherForecastData.Hour]){
            
            var minTemp = 100.0
            var maxTemp = -100.0
            var windSpeed = 0.0
            for datum in data {
                if (maxTemp < datum.tempC){
                    maxTemp = datum.tempC
                }
                if (minTemp > datum.tempC){
                    minTemp = datum.tempC
                }
                windSpeed += datum.windKph
            }
            windSpeed /= Double(data.count)
            conditionIcon = Self.avrgConditionIcon(data: data)
            self.maxTemp = "\(Int(round(maxTemp)))°"
            self.minTemp = "\(Int(round(minTemp)))°"
            self.windSpeed = "\(Int(round(windSpeed * 0.278))) м/с"
        }
        static fileprivate func nullDatum() -> QwarterData{
            return QwarterData(maxTemp: "N/A", minTemp: "N/A", condition: "nullCondition", windSpeed: "N/A")
        }
        //TODO: TOTAL REWORK
        private static func avrgConditionIcon(data:[WeatherForecastData.Hour]) -> String{
            var conditions:[String] = []
            var topCondition = ("", -1)
            for datum in data{
                conditions.append(datum.condition.icon)
            }
            var conditionsCounts: [String: Int] = [:]
            for item in conditions{
                conditionsCounts[item] = (conditionsCounts[item] ?? 0) + 1
            }
            for (key, value) in conditionsCounts {
                guard value > topCondition.1 else{continue}
                topCondition = (key, value)
            }
            return topCondition.0
        }
//        private static func avrgDayCondition(data:[Weather120HoursForecast.Datum]) -> String{
//       //     guard data.count >= 6 else{return "nullCondition"}
//            var dayConditions:[(String, Int)] = []
//            var topCondition = ("", -1)
//            for datum in data{
//                dayConditions = checkWeather(conditions: dayConditions, data: datum)
//            }
//            for condition in dayConditions {
//                guard topCondition.1 < condition.1 else{continue}
//                topCondition = condition
//            }
//            return topCondition.0
//        }
//        private static func checkWeather(conditions:[(String, Int)], data:Weather120HoursForecast.Datum) -> [(String, Int)]{
//            var conditions = conditions
//            for condition in 0..<conditions.count{
//                guard conditions[condition].0 == data.weather.icon else{continue}
//                conditions[condition].1 += 1
//                return conditions
//            }
//            conditions.append((data.weather.icon,0))
//            return conditions
//        }
        
    }
    //   let date:FormatedDate
    let qwarters:[QwarterData]
    private init(qwarters:[QwarterData]) {
        self.qwarters = qwarters
    }
    private init(data:[WeatherForecastData.Hour]) {
        var qwarters:[QwarterData] = []
        qwarters.append(QwarterData(data: Array(data[0..<7])))
        for i in 1..<3{
            qwarters.append(QwarterData(data: Array(data[(i * 6)..<(i * 6 + 6)])))
        }
        qwarters.append(QwarterData(data: Array(data[18..<24])))
        
        self.qwarters = qwarters
    }
    static fileprivate func initWithDeficientDatum(data:[WeatherForecastData.Hour]) -> DitailData{
        var qwarters:[QwarterData] = []
        switch data.count {
        case 7:
            qwarters = Array(repeating: QwarterData.nullDatum(), count: 3)
            qwarters.append(QwarterData(data: Array(data[0..<7])))
        case 13:
            qwarters = Array(repeating: QwarterData.nullDatum(), count: 2)
            qwarters.append(QwarterData(data: Array(data[0..<7])))
            qwarters.append(QwarterData(data: Array(data[7..<13])))
        case 18:
            qwarters = [QwarterData.nullDatum()]
            qwarters.append(QwarterData(data: Array(data[0..<7])))
            for i in 1..<3{
                qwarters.append(QwarterData(data: Array(data[(i * 6)..<(i * 6 + 6)])))
            }
        case 24:
            return DitailData(data: data)
        default:
            return DitailData.empty()
        }
        return DitailData(qwarters: qwarters)
    }
    static fileprivate func empty() -> DitailData {
        return DitailData(qwarters: Array(repeating: QwarterData.nullDatum(), count: 4))
    }
    static fileprivate func initDitailDates(data:WeatherForecastData.Data) -> [DitailData] {
     //   guard data.data.count >= 120 else{return []}
        var hourlyData:[WeatherForecastData.Hour] = []
        for day in data.forecast.forecastday{
            for hour in day.hour{
                hourlyData.append(hour)
            }
        }
         
        var result:[DitailData] = []
        let currentDayData:ArraySlice<WeatherForecastData.Hour>
        while true{
            let date = Date(timeIntervalSince1970: TimeInterval(hourlyData[0].timeEpoch ?? 0)).formatted(date: .omitted, time: .shortened)
            guard date != "05:00" else{currentDayData = hourlyData[0..<24]; break}
            guard date != "12:00" else{currentDayData = hourlyData[0..<18]; break}
            guard date != "17:00" else{currentDayData = hourlyData[0..<13]; break}
            guard date != "22:00" else{currentDayData = hourlyData[0..<7]; break}
            guard date != "23:00" else{currentDayData = []; hourlyData.removeFirst(6); break}
            hourlyData.removeFirst()
        }
        
        
        result.append(DitailData.initWithDeficientDatum(data: Array(currentDayData)))
        hourlyData.removeFirst(currentDayData.count)
        
        for i in 0..<(hourlyData.count / 24){
            result.append(DitailData(data: Array(hourlyData[(i * 24)..<(i * 24 + 24)])))
        }
        
        return result
        
    }
}
//MARK: - WindData
struct WindData{
    let speed:String
    let direction:String
    fileprivate init(data:[WeatherForecastData.Hour]) {
        var totalWindSpeed:Double = 0
        
        for datum in data{
            totalWindSpeed += Double(datum.windKph)
        }
        let speed:Double = (totalWindSpeed / Double(data.count)) * 0.278
        let speedString = "\(Int(round(speed))) м/с"
        let direction = Self.translateWindDirection(Self.avrgWindDirection(data: data))
        
        self.speed = speedString
        self.direction = direction
    }
    private static func avrgWindDirection(data:[WeatherForecastData.Hour]) -> String{
        var windDirections:[String] = []
        var topWindDirection = ("", -1)
        for datum in data{
            windDirections.append(datum.windDir)
        }
        var directionCounts: [String: Int] = [:]
        for item in windDirections{
            directionCounts[item] = (directionCounts[item] ?? 0) + 1
        }
        for (key, value) in directionCounts {
            guard value > topWindDirection.1 else{continue}
            topWindDirection = (key, value)
        }
        return topWindDirection.0
    }
    static private func translateWindDirection(_ wind:String) -> String{
        var wind = wind
        wind = wind.replacingOccurrences(of: "S", with: "Ю")
        wind = wind.replacingOccurrences(of: "N", with: "С")
        wind = wind.replacingOccurrences(of: "W", with: "З")
        wind = wind.replacingOccurrences(of: "E", with: "В")
        return wind
    }
}
//MARK: SunData
struct SunData{
    let sunrise:String
    let sunset:String
    let dayLength:String
    let sunriseTs:Int
    let sunsetTs:Int
    fileprivate init(sunriseTs: Int, sunsetTs: Int) {
        let sunrise = Date(timeIntervalSince1970: TimeInterval(sunriseTs))
        let sunset = Date(timeIntervalSince1970: TimeInterval(sunsetTs))
        let dayLength = Date(timeIntervalSince1970: TimeInterval(sunsetTs - sunriseTs))
        
        self.sunriseTs = sunriseTs
        self.sunsetTs = sunsetTs
        self.sunrise = sunrise.formatted(date: .omitted, time: .shortened)
        self.sunset = sunset.formatted(date: .omitted, time: .shortened)
        self.dayLength = dayLength.formatted(date: .omitted, time: .shortened)
    }
    static fileprivate func convertFromAstro(data:WeatherForecastData.Astro) -> SunData{
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "hh:mm a"
        let sunriseTs = Int(dateformatter.date(from: data.sunrise)?.timeIntervalSince1970 ?? 0)
        let sunsetTs = Int(dateformatter.date(from: data.sunset)?.timeIntervalSince1970 ?? 0)
        return SunData(sunriseTs: sunriseTs, sunsetTs: sunsetTs)
    }
}
//MARK: - FormatedDate
struct FormatedDate{
    let date:String
    let weekDay:String
    init(date:Int) {
        let weekDayDateFormater = DateFormatter()
            weekDayDateFormater.locale = Locale(identifier: "ru_RU")
            weekDayDateFormater.dateFormat = "EEEE"
        let dateFormater = DateFormatter()
            dateFormater.locale = Locale(identifier: "ru_RU")
            dateFormater.dateFormat = "dd MMMM"
        weekDay = weekDayDateFormater.string(from: Date(timeIntervalSince1970: TimeInterval(date))).capitalized(with: Locale(identifier: "ru_RU"))
        self.date = dateFormater.string(from: Date(timeIntervalSince1970: TimeInterval(date))).capitalized(with: Locale(identifier: "ru_RU"))
        
    }
    static private func exstractDateOfMonth(_ date:String) -> String{
        var date = date
        var result = ""
        while true{
            guard date.first != " " else{result = result + " ";return result}
            result = result + String(date.first ?? "0")
            date.removeFirst()
        }
    }
}

