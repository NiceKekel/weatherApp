
import Foundation
import SwiftUI

struct WeatherView: View {
    
    
 //   private let cornerRadius:CGFloat = 15
    private let daylyScrollLength:Int = 10
    private let hourlyScrollLength:Int = 48
    
   // private let borderColor = Color(red: 0.66, green: 0.66, blue: 0.66)
    private let barColor = Color(red: 0.61, green: 0.67, blue: 0.79,opacity: 0.8)
    
    private let cUWidth:CGFloat
    private let latitude:Double
    private let longitude:Double
    
//    @State var hourlyWeatherData:[ForecastHourDatum]? = nil
//    @State var daylyWeatherData:[ForecastDayDatum]? = nil
//    @State var weatherDescription:String? = nil
//    @State var cityName:String? = nil
    @State var weatherData:WeatherData? = nil
    let isDay:Binding<Bool>
    init(cUWidth: CGFloat, latitude: Double, longitude: Double, isDay:Binding<Bool>) {
        self.cUWidth = cUWidth
        self.latitude = latitude
        self.longitude = longitude
        self.isDay = isDay
    }
    var body: some View {
        GeometryReader(){_ in
            
            VStack(spacing: 0,content: {
             //   Text("\(latitude) \(longitude)")
                dayInfo()
                    .frame(height: cUWidth * 0.6,alignment: .top)
//                    .overlay(alignment: .bottomTrailing, content: {
//                        VStack(spacing: nil ,content: {
//                            Text("Сумма активных температур")
//                                .font(.system(size: 15, weight: .bold))
//                                .foregroundStyle(.white)
//                            S_A_T_View(minCountingTemp: 10)
//                        })
//                        .frame(width: cUWidth * 0.3,height: cUWidth * 0.25)
//                        .background(barColor)
//                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
//                        
//                    })
                VStack(spacing: 0,content: {
                    hourlyTemperatureBar()
                        .frame(width: cUWidth)
                    
                    ScrollView(.vertical, content: {
                        VStack(spacing: 0, content: {
                            weatherForgecastScroll()
                        })
                        .frame(width: cUWidth)
                    })
                    .scrollIndicators(.never)
                })
                .background(barColor)
                .clipShape(RoundedRectangle(cornerRadius: Default.cornerRadius))
                .ignoresSafeArea(.all)
            }).onAppear(perform: {
                getData()
            })
        }
    }
    func dayInfo() -> LazyVStack<some View>{
        
        LazyVStack(spacing: 0, content: {
            if let weatherData = weatherData{
                Rectangle()
                    .fill(.clear)
                    .frame(height: cUWidth * 0.1)
                
                Text(weatherData.cityName)
                    .font(.system(size: 50))
                    .foregroundStyle(.white)
                    .shadow(color: .black, radius: 5)
                
                LazyVStack(spacing: 0, content: {
                    Text("\(Int(weatherData.current.tempC))°")
                        .font(.system(size: 75).weight(.light))
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 5)
                        .frame(height: cUWidth * 0.2)
//                        .onTapGesture {
//                            getData()
//                       //     print("lol")
//                        }
                    
                    Text(weatherData.current.condition.text)
                        .padding(10)
                        .font(.system(size: 30).weight(.medium))
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 5)
                })
            }
                       
            
        })
    }
    func hourlyTemperatureBar() -> LazyVStack<some View>{
        LazyVStack(spacing: 0, content: {
            
            ScrollView(.horizontal){
                HStack{
                    ForEach(0..<hourlyScrollLength, id: \.self) { i in
                        VStack(spacing: 0, content: {
                            if let weatherData = weatherData{
                                Text(weatherData.hourlyData[i].hour)
                                    .font(.system(size: 15).weight(.medium))
                                    .foregroundStyle(.white)
                                AsyncImage(url: URL(string: "https:\(weatherData.hourlyData[i].weatherIcon)"))
                                    //.resizable()
                                    .frame(width: cUWidth * 0.12, height: cUWidth * 0.12)
                                    .frame(width: cUWidth * 0.1, height: cUWidth * 0.1)
                //                AsyncImage(url: URL(string: "https://example.com/icon.png"))
                                
    //                            { image in
    //                                image.resizable()
    //                            } placeholder: {
    //                                ProgressView()
    //                            }
                                .frame(width: 50, height: 50)
                                
                                Text(weatherData.hourlyData[i].temp)
                                    .font(.system(size: 27).weight(.medium))
                                    .minimumScaleFactor(0.5)
                                    .foregroundStyle(.white)
                            }
                            
                        })
                        .frame(width: cUWidth * 0.15, height: cUWidth * 0.28)
                    }
                }
            }
            .scrollIndicators(.never)
        })
    }
    func weatherForgecastScroll() -> VStack<some View>{
        VStack(spacing: 0, content: {
            ForEach(0..<daylyScrollLength, id: \.self){i in
                if let dayDatum = weatherData?.daylyData[i]{
                    ForecastDayView(cUWidth: cUWidth, dayDatum: dayDatum, isToday: i == 0)
                }
            }
            
        })
        
    }
    private func getData(){
            getWeatherData(weatherData: { weatherData in
                self.weatherData = WeatherData(data: weatherData)
                isDay.wrappedValue = weatherData.current.isDay == 1
//                daylyWeatherData = ForecastDayDatum.initForecastData(daylyData: daylyData.data, hourlyData: hourlyData)
//                hourlyWeatherData = ForecastHourDatum.initForecastHourDatums(data: hourlyData)
//                weatherDescription = weatherData.current.condition.text
//                cityName = weatherData.location.name
            })
    
    }
    
    private func getWeatherData(weatherData:@escaping (_ weatherData: WeatherForecastData.Data) -> Void){
        let headers = [
            "x-rapidapi-key": "e2f725c031msh397823778ff1755p13ad44jsna242075d5553",
            "x-rapidapi-host": "weatherapi-com.p.rapidapi.com"
        ]

        var request = URLRequest(url: URL(string: "https://weatherapi-com.p.rapidapi.com/forecast.json?q=\(latitude)%2C%20\(longitude)&days=\(daylyScrollLength)&lang=ru")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if let data, let weather = try? JSONDecoder().decode(WeatherForecastData.Data.self, from: data){
                //  print(weather.forecast.forecastday[2].hour[8].condition.text)
                weatherData(weather)
            }
        })

        dataTask.resume()
    }
//    private func getWether16DayForecastData(daylyData:@escaping (_ daylyData: Weather16DayForecast.WeatherData)->Void){
//        
//        let headers = [
//            "x-rapidapi-key": "e2f725c031msh397823778ff1755p13ad44jsna242075d5553",
//            "x-rapidapi-host": "weatherbit-v1-mashape.p.rapidapi.com"
//        ]
//        
//        let request = NSMutableURLRequest(url: NSURL(string: "https://weatherbit-v1-mashape.p.rapidapi.com/forecast/daily?lat=54.6&lon=26.0&units=metric&lang=ru")! as URL,
//                                          cachePolicy: .useProtocolCachePolicy,
//                                          timeoutInterval: 10.0)
//        request.httpMethod = "GET"
//        request.allHTTPHeaderFields = headers
//        
//        let session = URLSession.shared
//        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
//            if let data, let weather = try? JSONDecoder().decode(Weather16DayForecast.WeatherData.self, from: data){
//                daylyData(weather)
//            }
//            
//        })
//        
//        dataTask.resume()
//        
//    }
//    private func getWether120HoursForecastData(hourlyData:@escaping (_ hourlyData: Weather120HoursForecast.WeatherData)->Void){
//        let headers = [
//            "x-rapidapi-key": "e2f725c031msh397823778ff1755p13ad44jsna242075d5553",
//            "x-rapidapi-host": "weatherbit-v1-mashape.p.rapidapi.com"
//        ]
//        
//        let request = NSMutableURLRequest(url: NSURL(string: "https://weatherbit-v1-mashape.p.rapidapi.com/forecast/hourly?lat=54.6&lon=26.0&lang=ru&hours=120&units=metric")! as URL,
//                                          cachePolicy: .useProtocolCachePolicy,
//                                          timeoutInterval: 10.0)
//        request.httpMethod = "GET"
//        request.allHTTPHeaderFields = headers
//        
//        let session = URLSession.shared
//        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
//            if let data, let weather = try? JSONDecoder().decode(Weather120HoursForecast.WeatherData.self, from: data){
//                hourlyData(weather)
//            }
//            
//        })
//        
//        dataTask.resume()
//    }
}


