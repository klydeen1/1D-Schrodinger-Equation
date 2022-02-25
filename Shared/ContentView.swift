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
    @ObservedObject var psiCalculator = SchrodingerSolver()
    @ObservedObject var plotDataModel = PlotDataClass(fromLine: true)
    
    @State var selector = 0 // Select which type of plot to make. 0 is wavefunction, 1 is potential
    @State var xArray = [Double]() // Array holding x-values for the potential
    @State var VArray = [Double]() // Array holding the potentials V(x)
    
    var body: some View {
        HStack{
            VStack{
                // Text boxes to set xMin, xMax, and xStep for the potential
                // Drop down menu (picker) for setting the potential
                
                HStack {
                    Button("Cycle Calculation", action: {Task.init{await self.calculateWavefunction()}})
                        .padding()
                        .disabled(psiCalculator.enableButton == false)
                    
                    Button("Clear", action: {self.clear()})
                        .padding()
                        .disabled(psiCalculator.enableButton == false)
                }
                
                HStack {
                    Button("Plot wavefunction", action: {Task.init{
                        self.selector = 0 // 0 is the wavefunction
                        await self.generatePlots()
                        }})
                        .padding()
                        .disabled(psiCalculator.enableButton == false)
                           
                    Button("Plot potential", action: {Task.init {
                        self.selector = 1 // 1 is the potential
                        await self.generatePlots()
                        }})
                        .padding()
                        .disabled(psiCalculator.enableButton == false)
                }
                if (!psiCalculator.enableButton){
                    ProgressView()
                }
            }
        
            // Stop the window shrinking to zero.
            Spacer()
            CorePlot(dataForPlot: $plotDataModel.plotData, changingPlotParameters:  $plotDataModel.changingPlotParameters)
                .setPlotPadding(left: 10)
                .setPlotPadding(right: 10)
                .setPlotPadding(top: 10)
                .setPlotPadding(bottom: 10)
                .padding()
            Divider()
        }
    }
    
    func calculateWavefunction() async {
        // Get the arrays for x and potential from potentialCalculator
        await potentialCalculator.setPotential()
        xArray = potentialCalculator.xArray
        VArray = potentialCalculator.VArray
        // 
    }
    
    @MainActor func setupPlotDataModel() {
        psiCalculator.plotDataModel = self.plotDataModel
        potentialCalculator.plotDataModel = self.plotDataModel
    }
    
    func generatePlots() async {
        setupPlotDataModel()
        psiCalculator.setButtonEnable(state: false)
        if (selector == 0) {
            // await psiCalculator.getPlotData()
            print("You haven't made this function yet...")
        }
        else if (selector == 1) {
            // potentialCalculator.potentialType =
            // potentialCalculator.xMin =
            // etc
            await potentialCalculator.getPlotData()
        }
        psiCalculator.setButtonEnable(state: true)
    }
        
    func clear() {
        potentialCalculator.clearPotential()
        plotDataModel.zeroData()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
