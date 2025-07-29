
import SwiftUI
import OpenMeteoSdk
import CoreData
import Foundation

fileprivate struct SumOfActTempMark{
    
    var sumOfActTemp:String
    var name:String
    
    var date:Date
    
    init(name: String, date: Date, sumOfActTemp:String) {
        self.name = name
        self.date = date
        self.sumOfActTemp = sumOfActTemp
    }
    
    init(coreDataMark:FetchedResults<Mark>.Element, sumOfActTemp:String){
        self.name = coreDataMark.name ?? "Error"
        self.date = coreDataMark.date ?? Date()
        self.sumOfActTemp = sumOfActTemp
    }
}
struct SumOfActTempView: View {
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.date),
        SortDescriptor(\.name)
    ]) var marks: FetchedResults<Mark>
    
    private let maxMarksCount: Int = 5
    
    private let minCountingTemp: Float
    
    private let latitude:Double
    private let longitude:Double
    
    private let firstDayOfYear: Date
    
    private let cUWidth: CGFloat
    private let cUHeight: CGFloat
    
    
    @State private var selectedDate: Date
    
    @State private var showRedactor:Bool = false
    
    @State private var currentMarkIndex: Int? = nil
    
    @State private var sumOfActTempString: String = ""
    
    @State private var sumOfActTempMarks: [SumOfActTempMark] = []
    
    @State private var markToRedact:SumOfActTempMark = SumOfActTempMark(name: "", date: Date(), sumOfActTemp: "")
    
    init(cUHeigh:CGFloat, cUWidth: CGFloat, minCountingTemp: Float, latitude: Double, longitude: Double){
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let firstDayOfYear = DateComponents(calendar: calendar, year: currentYear).date
        self.firstDayOfYear = firstDayOfYear!
        self.selectedDate = firstDayOfYear!
        self.cUWidth = cUWidth
        self.latitude = latitude
        self.longitude = longitude
        self.minCountingTemp = minCountingTemp
        self.cUHeight = cUHeigh
    }
    
    var body: some View {
        VStack(alignment: .center,spacing: nil, content: {
            VStack(spacing: 0, content: {
                
                Text("Сумма активных температур")
                    .frame(height: cUWidth * 0.1, alignment: .bottom)
                
                Text(sumOfActTempString)
                    .font(.system(size: 25, weight: .bold))
                    .onAppear {
                        sumOfActTempMarks.removeAll()
                        calculateSumOfActTemp(since: selectedDate){ summ in
                            sumOfActTempString = summ
                        }
                        for mark in marks{
                            calculateSumOfActTemp(since: mark.date ?? Date()){ summ in
                                sumOfActTempMarks.append(SumOfActTempMark(coreDataMark: mark, sumOfActTemp: summ))
                            }
                        }
                    }
                    .onChange(of: selectedDate, {
                        calculateSumOfActTemp(since: selectedDate){ summ in
                            sumOfActTempString = summ
                        }
                    })
                    .onChange(of: currentMarkIndex, {
                        withAnimation(.linear(duration: 0.3), {
                            if let i = currentMarkIndex{
                                markToRedact = sumOfActTempMarks[i]
                                showRedactor = true
                            }
                            else{
                                showRedactor = false
                            }
                        })
                    })
                
                DatePicker(
                    "",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .frame(width: cUWidth * 0.9)
            })
            .background(
                RoundedRectangle(cornerRadius: Default.cornerRadius)
                    .fill(.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Default.cornerRadius)
                    .stroke(Default.borderColor, lineWidth: Default.borderWidth)
            )
            ForEach(0..<sumOfActTempMarks.count, id: \.self) { mark in
                markBlock(width: cUWidth * 0.9, index: mark)
            }
            addButton(width: cUWidth * 0.1)
                .disabled(maxMarksCount < sumOfActTempMarks.count)
                .opacity(maxMarksCount < sumOfActTempMarks.count ? 0 : 1)
        })
        .frame(height: cUHeight, alignment: .top)
        .overlay(content: {
            
        if showRedactor {
            Rectangle()
                .fill(.black.opacity(0.8))
                .frame(width: 1000, height: 1000)
                .onTapGesture {
                    guard let i = currentMarkIndex else { return }
                    sumOfActTempMarks[i] = markToRedact
                    calculateSumOfActTemp(since: sumOfActTempMarks[i].date){ summ in
                        sumOfActTempMarks[i].sumOfActTemp = summ
                    }
                    saveMarks()
                    self.currentMarkIndex = nil
                }
                .overlay(content: {
                    MarkRedactor(cUWidth: cUWidth, mark: $markToRedact)
                })
            }
        })
    }
    //MARK: - addButton
    private func addButton(width:CGFloat) -> HStack<some View>{
        
        return HStack(content: {
            
            Button(action: {
                sumOfActTempMarks.append(SumOfActTempMark(name: "", date: selectedDate, sumOfActTemp: sumOfActTempString))
                
                newMark(mark: sumOfActTempMarks.last!)
            
                currentMarkIndex = sumOfActTempMarks.count - 1
                
            }, label: {
                Text("+")
                    .frame(width: width, height: width)
                    .background(
                        RoundedRectangle(cornerRadius: Default.cornerRadius)
                            .fill(.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Default.cornerRadius)
                            .stroke(Default.borderColor, lineWidth: Default.borderWidth)
                    )
            })
        })
    }
    //MARK: - markBlock
    private func markBlock(width:CGFloat, index:Int) -> HStack<some View>{
        
        let sumOfActTempMark: SumOfActTempMark = sumOfActTempMarks[index]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        return HStack{
            HStack(spacing: 0, content: {
                
                redactorButton(index: index)
                
                Text(dateFormatter.string(from: sumOfActTempMark.date))
                    .frame(width: width * 0.2,alignment: .leading)
                
                Text(sumOfActTempMark.name)
                    .frame(width: width * 0.3, height: cUWidth * 0.1,alignment: .leading)
                
                Text(sumOfActTempMark.sumOfActTemp)
                    .frame(width: width * 0.2, height: cUWidth * 0.1)
                
                deleteButton(index: index)
            })
            .frame(width: width, height: cUWidth * 0.1)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: Default.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Default.cornerRadius)
                    .stroke(Default.borderColor, lineWidth: Default.borderWidth)
            )
            .shadow(radius: 10)
        }
    }
    //MARK: - redactorButton
    private func redactorButton(index:Int) -> some View{
        Button(action: {
            currentMarkIndex = index
        }, label: {
            Image(systemName: "pencil")
                .foregroundColor(.gray)
                .frame(width: cUWidth * 0.05, height: cUWidth * 0.05)
                .frame(width: cUWidth * 0.1, height: cUWidth * 0.1)
                .background(.clear)
        })
    }
    //MARK: - deleteButton
    private func deleteButton(index:Int) -> some View {
        Button(action: {
            deleteMark(index: index)
            sumOfActTempMarks.remove(at: index)
        }) {
            Image(systemName: "trash")
                .resizable()
                .foregroundColor(.gray)
                .frame(width: cUWidth * 0.05, height: cUWidth * 0.05)
                .frame(width: cUWidth * 0.1, height: cUWidth * 0.1)
                .background(.clear)
        }
    }
    //MARK: - calculateSumOfActTemp
    private func calculateSumOfActTemp(since:Date, summ:@escaping (_ summ: String)->Void){
        
        var sumOfActTemp: Float = 0
        var tempForForecast: Float = 0
        
        getTempHistory(since: since) { weatherHistory in
            for temp in weatherHistory where temp >= minCountingTemp {
                sumOfActTemp += temp
            }
            summ("\(Int(sumOfActTemp))°")
            for i in (weatherHistory.count - 3)..<weatherHistory.count {
                tempForForecast += weatherHistory[i]
            }
            tempForForecast /= 3
            if tempForForecast >= minCountingTemp{
                sumOfActTemp += tempForForecast * 3
            }
        }
        
    }
    //MARK: - getTempHistory
    private func getTempHistory(since: Date, daylyTemp:@escaping (_ daylyTemps: [Float])->Void) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        Task{
            do{
                let url = URL(string: "https://archive-api.open-meteo.com/v1/archive?latitude=\(latitude)&longitude=\(longitude)&start_date=\(dateFormatter.string(from: since))&end_date=\(dateFormatter.string(from: Date()))&daily=temperature_2m_mean&timezone=Europe%2FMoscow&format=flatbuffers")!
                let responses = try await WeatherApiResponse.fetch(url: url)
                let response = responses[0]
                let daily = response.daily!
                
                struct WeatherData {
                    let daily: Daily
                    
                    struct Daily {
                        let temperature2mMean: [Float]
                    }
                }
                let data = WeatherData(
                    daily: .init(
                        temperature2mMean: daily.variables(at: 0)!.values
                    )
                )
                daylyTemp(data.daily.temperature2mMean)
            }
            catch{}
        }
    }
    //MARK: - newMark
    private func newMark(mark:SumOfActTempMark){
        let newMark = Mark(context: self.moc)
        newMark.date = mark.date
        newMark.name = mark.name
        do {
            try self.moc.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    //MARK: - saveMarks
    private func saveMarks(){
        deleteAllMarks()
        for i in 0..<sumOfActTempMarks.count{
            let mark = sumOfActTempMarks[i]
            
            let newMark = Mark(context: self.moc)
            newMark.date = mark.date
            newMark.name = mark.name
        }
        
        do {
            try self.moc.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    //MARK: - deleteAllMarks
    private func deleteAllMarks() {
        for mark in marks{
            moc.delete(mark)
        }
        do {
            try self.moc.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    //MARK: - deleteMark
    private func deleteMark(index:Int) {
        
        moc.delete(marks[index])
        
        do {
            try self.moc.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    //MARK: - MarkRedactor
    private struct MarkRedactor: View {
        
        private let bindingMark: Binding<SumOfActTempMark>
        
        let monthDateFormatter:DateFormatter
        let dayDateFormatter:DateFormatter
        
        let dayAmountInMonths: [String: Int]
        
        let avalibleMonths: [String]
        
        let calendar = Calendar.current
        
        let cUWidth: CGFloat
        
        @State var month: String = "января"
        
        @State var dayAmount: Int = 31
        @State var day: Int = 1
        
        @State var mark: SumOfActTempMark = .init(name: "", date: Date(timeIntervalSince1970: 0), sumOfActTemp: "")
        
        fileprivate init(cUWidth: CGFloat, mark: Binding<SumOfActTempMark>) {
            let monthSymbols = Calendar.current.monthSymbols
            
            let dayDateFormatter = DateFormatter()
            dayDateFormatter.dateFormat = "M"
            
            let monthDateFormatter = DateFormatter()
            monthDateFormatter.locale = Locale(identifier: "ru_RU")
            monthDateFormatter.dateFormat = "MMMM"
            
            var avalibleMonths:[String] = []
            for i in 0..<Int(dayDateFormatter.string(from: Date()))!{
                avalibleMonths.append(monthSymbols[i])
            }
            
            let yearDateFormatter = DateFormatter()
            yearDateFormatter.dateFormat = "yyyy"
            
            var dayAmountInMonths: [String: Int] = [:]
            for i in 0..<monthSymbols.count{
                let dateComponents = DateComponents(year: Int(yearDateFormatter.string(from: Date()))!, month: i + 1)
                let date = calendar.date(from: dateComponents)!
                
                let range = calendar.range(of: .day, in: .month, for: date)!
                let numDays = range.count
                dayAmountInMonths[monthSymbols[i]] = numDays
            }
            
            self.cUWidth = cUWidth
            self.bindingMark = mark
            self.avalibleMonths = avalibleMonths
            self.dayAmountInMonths = dayAmountInMonths
            self.dayDateFormatter = dayDateFormatter
            self.monthDateFormatter = monthDateFormatter
        }
        var body: some View {
            
            LazyVStack(spacing: cUWidth * 0.1,content: {
                
                HStack(spacing: cUWidth * 0.2, content: {
                    
                    DropdownMenu(width: cUWidth * 0.2, height: cUWidth * 0.1,
                                 expandedMenuHeight: cUWidth * 0.6,
                                 array: Array(1...dayAmount), picked: $day)
                    
                    DropdownMenu(width: cUWidth * 0.4, height: cUWidth * 0.1,
                                 expandedMenuHeight: cUWidth * 0.6,
                                 array: avalibleMonths, picked: $month)
                })
                .onChange(of: month, {
                    dayAmount = dayAmountInMonths[month]!
                    if dayAmount > calendar.component(.day, from: Date()){
                        dayAmount = calendar.component(.day, from: Date())
                    }
                    if day > dayAmount {
                        day = dayAmount
                    }
                    mark.date = convertStringsToDate()
                })
                .onChange(of: day, {
                    mark.date = convertStringsToDate()
                })
                .zIndex(5)
                TextField(
                    "Название",
                    text: bindingMark.name
                )
                .frame(width: cUWidth * 0.75)
                .frame(width: cUWidth * 0.8,height: cUWidth * 0.1)
                .overlay(
                    RoundedRectangle(cornerRadius: Default.cornerRadius)
                        .stroke(.gray, lineWidth: 1)
                )
            })
            .frame(width: cUWidth * 0.8)
            .padding(cUWidth * 0.05)
            .background(content: {
                Color.white.clipShape(RoundedRectangle(cornerRadius: Default.cornerRadius))
            })
            .ignoresSafeArea()
            .onAppear(){
                mark = bindingMark.wrappedValue
                day = calendar.component(.day, from: mark.date)
                month = calendar.monthSymbols[(calendar.component(.month, from: mark.date)) - 1]
            }
            .onChange(of: mark.date, {
                bindingMark.wrappedValue.date = mark.date
            })
            
            .shadow(radius: 10)
        }
        private func convertStringsToDate() -> Date {
            let yearDateFormatter = DateFormatter()
            yearDateFormatter.dateFormat = "yyyy"
            let string = "\(day)" + month + yearDateFormatter.string(from: Date())
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "ddMMMMyyyy"
            return dateFormatter.date(from: string)!
        }
    }
}
