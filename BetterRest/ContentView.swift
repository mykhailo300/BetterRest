////
////  ContentView.swift
////  BetterRest
////
////  Created by Михайло Дмитрів on 22.12.2023.
////

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1

    @State private var alertTitle = ""
    @State private var alertMessage = ""
    

    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }

    var body: some View {
        NavigationStack {
            Form {
                VStack(alignment: .leading, spacing: 0) {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .onChange(of: wakeUp, calculateBedtime)
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                        .onChange(of: sleepAmount, calculateBedtime)

                }
                VStack(alignment: .leading, spacing: 0) {
                    Picker("Daily coffe intake", selection: $coffeeAmount) {
                        ForEach(1...20 , id: \.self) {
                            Text($0, format: .number)
                        }
                    }
                    .onAppear(perform: calculateBedtime)
                    .onChange(of: coffeeAmount, calculateBedtime)

//                  Text("Daily coffee intake")
//                      .font(.headline)
//
//                  Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 1...20)
                }
                
                VStack(alignment: .center) {
                    Spacer()
                    Spacer()
                    HStack{
                        Spacer()
                        Text(alertTitle)
                            .font(.headline.weight(.heavy))
                        Spacer()
                    }
                    HStack{
                        Spacer()
                        Text(alertMessage)
                            .font(.largeTitle.weight(.semibold))
                        Spacer()
                    }
                }
                .padding(20)
            }
            .navigationTitle("BetterRest")
        }
    }
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)

            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60

            let prediction = try model.prediction(wake: Int64(hour + minute), estimatedSleep: sleepAmount, coffee: Int64(coffeeAmount))

            let sleepTime = wakeUp - prediction.actualSleep

            alertTitle = "Your ideal bedtime is…"
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
    }
    
}

#Preview {
    ContentView()
}
