
import Foundation
import SwiftUI

struct WeatherView: View {
    
    private let daylyScrollLength:Int = 10
    private let hourlyScrollLength:Int = 48
    
    private let barColor = Color(red: 0.61, green: 0.67, blue: 0.79,opacity: 0.8)
    
    private let cUWidth:CGFloat
    
    private let latitude:Double
    private let longitude:Double
    
    private let isDay:Binding<Bool>
    
    @State var weatherData:WeatherData? = nil
    init(cUWidth: CGFloat, latitude: Double, longitude: Double, isDay:Binding<Bool>) {
        self.cUWidth = cUWidth
        self.latitude = latitude
        self.longitude = longitude
        self.isDay = isDay
    }
    var body: some View {
        GeometryReader(){_ in
            
            VStack(spacing: 0,content: {
                
                dayInfo()
                    .frame(height: cUWidth * 0.6,alignment: .top)
                
                VStack(spacing: 0,content: {
                    
                    hourlyTemperatureBar()
                        .frame(width: cUWidth)
                    
                    ScrollView(.vertical, content: {
                        VStack(spacing: 0, content: {
                            forgecastScroll()
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
    //MARK: - dayInfo
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

                    Text(weatherData.current.condition.text)
                        .padding(10)
                        .font(.system(size: 30).weight(.medium))
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 5)
                })
            }
        })
    }
    //MARK: - hourlyTemperatureBar
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
                                    .frame(width: cUWidth * 0.12, height: cUWidth * 0.12)
                                    .frame(width: cUWidth * 0.1, height: cUWidth * 0.1)
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
    //MARK: - forgecastScroll
    func forgecastScroll() -> VStack<some View>{
        VStack(spacing: 0, content: {
            ForEach(0..<daylyScrollLength, id: \.self){i in
                if let dayDatum = weatherData?.daylyData[i]{
                    ForecastDayView(cUWidth: cUWidth, dayDatum: dayDatum, isToday: i == 0)
                }
            }
            
        })
        
    }
    //MARK: - DataFuncs
    private func getData(){
            getWeatherData(weatherData: { weatherData in
                self.weatherData = WeatherData(data: weatherData)
                isDay.wrappedValue = weatherData.current.isDay == 1
            })
    
    }
    
    private func getWeatherData(weatherData:@escaping (_ weatherData: WeatherForecastData.Data) -> Void){
        let headers = [
            "x-rapidapi-key": "myKey",
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
                weatherData(weather)
            }
        })

        dataTask.resume()
    }
}


