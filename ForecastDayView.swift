
import SwiftUI

struct ForecastDayView: View {

    @State private var expanded = false
    
    private let borderColor = Color(red: 0.66, green: 0.66, blue: 0.66)

    private let dayDatum:ForecastDayDatum
    
    private let cUWidth:CGFloat
    
    private let isToday:Bool
    
    static private let qwarterNames:[String] = ["Утром","Днём","Вечером","Ночью"]
    
    init(cUWidth: CGFloat, dayDatum: ForecastDayDatum, isToday: Bool) {
        self.cUWidth = cUWidth
        self.dayDatum = dayDatum
        self.isToday = isToday
    }
    
    var body: some View {
        LazyVStack(spacing: 0, content: {
            
            Rectangle()
                .fill(.white)
                .opacity(0.2)
                .frame(width: cUWidth * 0.8,height: cUWidth * 0.003)
            forecastDayDataBlock()
            
            if(expanded){
                LazyVStack( content: {
                    
                    ForEach(0..<4){i in
                        if (dayDatum.ditailData.qwarters[i].maxTemp != "N/A")  {
                            
                            Rectangle()
                                .fill(.white)
                                .opacity(0.2)
                                .frame(width: cUWidth * 0.8 ,height: cUWidth * 0.003)
                            
                            qwarterBlock(index: i)
                                .padding(cUWidth * 0.01)
                        }
                    }
                })
            }
        })
        .background(.clear)
        .onTapGesture {
            withAnimation(.linear(duration: 0.2)){
                expanded.toggle()
            }
        }
    }
    //MARK: - forecastDayDataBlock
    func forecastDayDataBlock() -> HStack<some View>{
        HStack(spacing: 0, content: {
            
            dateBlock()
            
            windNWeatherBlock()
            
            sunDataBlock()
            
            VStack(spacing: 0, content: {
                
                Text(dayDatum.minTemp)
                    .font(.system(size: 17).weight(.medium))
                    .foregroundStyle(.white)
                
                Text(dayDatum.avrgTemp)
                    .font(.system(size: 30).weight(.medium))
                    .foregroundStyle(.white)
                
            })
            .frame(width: cUWidth * 0.17,alignment: .trailing)
        })
    }
    //MARK: - sunDataBlock
    func sunDataBlock() -> VStack<some View>{
        VStack(alignment: .leading,spacing: 0, content: {
            ForEach(0..<2){i in
                HStack(spacing: 0, content: {
                    
                    Image(i == 0 ? .sunrise : .sunset)
                        .resizable()
                        .colorMultiply(.yellow)
                        .frame(width: cUWidth * 0.05, height: cUWidth * 0.05)
                    
                    Text(i == 0 ? dayDatum.sunData.sunrise : dayDatum.sunData.sunset)
                        .foregroundStyle(.white)
                        .font(.system(size: 9))
                })
            }
            Text(dayDatum.sunData.dayLength)
                .foregroundStyle(.white)
        })
    }
    //MARK: - windNWeatherBlock
    func windNWeatherBlock() -> VStack<some View>{
        VStack(spacing: 0, content:{
            let fontSize: CGFloat = 12
            
            AsyncImage(url: URL(string: "https:\(dayDatum.weatherIcon)"))
                .frame(width: cUWidth * 0.12, height: cUWidth * 0.12)
                .frame(width: cUWidth * 0.15, height: cUWidth * 0.09)
            
            VStack(spacing: 0, content: {
                
                Text(dayDatum.windData.direction)
                    .foregroundStyle(.white)
                    .font(.system(size: fontSize))
                
                Text(dayDatum.windData.speed)
                    .foregroundStyle(.white)
                    .font(.system(size: fontSize))
            })
        })
    }
    //MARK: - dateBlock
    func dateBlock() -> VStack<some View>{
        VStack(spacing: 0, content: {
            
            Text(isToday ? "Сегодня" : dayDatum.date.weekDay)
                .font(.system(size: 21).weight(.medium))
                .minimumScaleFactor(0.9)
                .foregroundStyle(.white)
                .frame(width: cUWidth * 0.35, height: cUWidth * 0.09,alignment: .bottomLeading)
            
            Text(dayDatum.date.date)
                .font(.system(size: 15).weight(.medium))
                .foregroundStyle(.white)
                .opacity(0.8)
                .frame(width: cUWidth * 0.35, height: cUWidth * 0.05,alignment: .topLeading)
        })
    }
    //MARK: - qwarterBlock
    private func qwarterBlock(index:Int) -> HStack<some View>{
        
        HStack(spacing: 0, content: {
            
            let selfWidth = cUWidth * 0.8
            
            Text(ForecastDayView.qwarterNames[index])
                .foregroundStyle(Color(red: 0.9, green: 0.9, blue: 0.9))
                .frame(width: selfWidth * 0.35,alignment: .leading)
            
            Text(dayDatum.ditailData.qwarters[index].windSpeed)
                .foregroundStyle(.white)
                .frame(width: selfWidth * 0.2,alignment: .leading)
            
            weatherNTempBlock(index: index)
                .frame(width: selfWidth * 0.45, alignment: .trailing)
        })
    }
    //MARK: - weatherNTempBlock
    private func weatherNTempBlock(index:Int) -> HStack<some View>{
        HStack(spacing: cUWidth * 0.02, content: {
            
            AsyncImage(url: URL(string: "https:\(dayDatum.ditailData.qwarters[index].conditionIcon)"))
                .frame(width: cUWidth * 0.1, height: cUWidth * 0.1)
                .frame(width: cUWidth * 0.09, height: cUWidth * 0.09)
            
            Text(dayDatum.ditailData.qwarters[index].minTemp)
                .foregroundStyle(Color(red: 0, green: 0, blue: 0.45))
                .font(.system(size: 18,weight: .bold))
                .frame(width: cUWidth * 0.1)
            
            Text(dayDatum.ditailData.qwarters[index].maxTemp)
                .foregroundStyle(Color(red: 0.45, green: 0, blue: 0))
                .font(.system(size: 18,weight: .bold))
                .frame(width: cUWidth * 0.1)
        })
    }
}


