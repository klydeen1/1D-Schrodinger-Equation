//
//  ContentView.swift
//  Shared
//
//  Created by Katelyn Lydeen on 2/18/22.
//

import SwiftUI
import CorePlot

typealias plotDataType = [CPTScatterPlotField : Double]

struct ContentView: View {
    @ObservedObject var potentialCalculator = OneDPotentials(withData: true)
    @ObservedObject var plotDataModel = PlotDataClass(fromLine: true)
    
    var body: some View {
        Text("Hello, world!")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
