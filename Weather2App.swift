
import SwiftUI
import MapKit
import Foundation
//import SwiftUIGenericDialog
struct Default{
    static let cornerRadius:CGFloat = 15
    static let borderWidth:CGFloat = 0.5
    static let borderColor:Color = Color.gray
}
@main

struct Weather2App: App {
    @ObservedObject private var locationManager = LocationManager()
    let persistenceController = PersistenceController.shared
    @State var isDay:Bool = true
   // let persistenceController = PersistenceController.shared
    //TODO: СМЕНА ДНЯ И НОЧИ
    var body: some Scene {
        let coordinate = self.locationManager.location != nil ? self.locationManager.location!.coordinate: CLLocationCoordinate2D()
        WindowGroup {
            GeometryReader{ geo in
                TabView{
                    WeatherView(cUWidth: geo.size.width,latitude: coordinate.latitude,longitude: coordinate.longitude, isDay: $isDay)
                    SumOfActTempView(cUHeigh: geo.size.height,cUWidth: geo.size.width, minCountingTemp: 10,latitude: coordinate.latitude, longitude:coordinate.latitude)
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                }
                .background(content: {
                  //  if let weatherData = weatherData{
                    Image(isDay ? "day" : "night")
                        .resizable()
                        .ignoresSafeArea()
                        .frame(width: 1000 )
                 //   }
                })
                .ignoresSafeArea()
                .tabViewStyle(.page(indexDisplayMode: .never))
             //   .ignoresSafeArea()
            }
            
        }
    }
}

//extension Array{
//    func safeOpen<T>(index: Int) -> T? {
//        guard index >= 0 && index < self.count else {
//            return nil
//        }
//        return self[index] as? T
//    }
//}

struct dropdownMenu<T>: View {
    @State private var expanded:Bool = false
    let width:CGFloat
    let height:CGFloat
    let expandedMenuHeight:CGFloat
    var menuArray: [T]
    @Binding var picked:T
    init(width: CGFloat, height: CGFloat, expandedMenuHeight: CGFloat, array: [T], picked: Binding<T>) {
        self.width = width
        self.height = height
        self.expandedMenuHeight = expandedMenuHeight
        menuArray = array
        _picked = picked
    }
    var body: some View {
            VStack(spacing: 0, content: {
                Text("\(picked)")
                    .foregroundStyle(.black)
                    .minimumScaleFactor(0.5)
                    .frame(width: width,height: height)
                    .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                    .onTapGesture {
                        withAnimation(.smooth, {expanded.toggle()})
                    }
                ScrollView(content: {
                    VStack(spacing: 0, content:{
                        ForEach(0..<menuArray.count, id: \.self){ index in
                                VStack(spacing: 0,content:{
                                    Rectangle()
                                        .fill(.gray)
                                        .opacity(expanded ? 0.2  : -0.2)
                                        .frame(width: width,height: 5)
                                    ZStack{
                                        Text("\(menuArray[index])")
                                            .foregroundStyle(.black)
                                            .minimumScaleFactor(0.5)
                                        Rectangle()
                                            .fill(.clear)
                                            .frame(width: width,height: height)
                                    }
                                    .onTapGesture {
                                        picked = menuArray[index]
                                        withAnimation(.default, {expanded.toggle()})
                                    }
                                })
                            }
                            Rectangle().fill(.clear).frame(width: 0,height: height)
                    })
                })
                .scrollIndicators(.never)
                .frame(height: expanded ?  expandedMenuHeight : 0)
                .clipped()
                .background(.white)
            })
            .frame(width: width,height: expanded ?  expandedMenuHeight : height, alignment: .top)
            .clipShape(RoundedRectangle(cornerRadius: Default.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Default.cornerRadius)
                    .stroke(Default.borderColor, lineWidth: Default.borderWidth)
                )
            .frame(height: height,alignment: .top)
    }
}
