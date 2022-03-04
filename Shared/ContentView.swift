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
    @State var selectedPotential = ""
    @State var selectedPlot = ""
    
    var plots = ["Potential", "Wavefunction"]
    var potentials = ["Square Well", "Linear Well", "Parabolic Well", "Square + Linear Well", "Square Barrier", "Triangle Barrier", "Coupled Parabolic Well", "Coupled Square Well + Field", "Harmonic Oscillator", "Kronig - Penney"]
    
    var body: some View {
        HStack{
            VStack{
                // Text boxes to set xMin, xMax, and xStep for the potential
                // Drop down menu (picker) for setting the potential
                VStack {
                    Text("Potential Type")
                        .font(.callout)
                        .bold()
                    Picker("", selection: $selectedPotential) {
                        ForEach(potentials, id: \.self) {
                            Text($0)
                        }
                    }
                }
                
                VStack {
                    Text("Plot Type")
                        .font(.callout)
                        .bold()
                    Picker("", selection: $selectedPlot) {
                        ForEach(plots, id: \.self) {
                            Text($0)
                        }
                    }
                }
                
                HStack {
                    Button("Cycle Calculation", action: {Task.init{await self.calculateWavefunction()}})
                        .padding()
                        .disabled(psiCalculator.enableButton == false)
                    
                    Button("Clear", action: {self.clear()})
                        .padding()
                        .disabled(psiCalculator.enableButton == false)
                }
                
                /*
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
                 */
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
    
    /// calculateWavefunction
    /// Runs appropriate functions to calculate the potential and wavefunction
    /// Also runs generatePlots to get and display plot data
    func calculateWavefunction() async {
        // Tell potentialCalculator which potential the user chose
        potentialCalculator.potentialType = selectedPotential
        
        // Disable the calculate button
        psiCalculator.setButtonEnable(state: false)
        
        // Get the arrays for x and potential from potentialCalculator
        await potentialCalculator.setPotential()
        xArray = potentialCalculator.xArray
        VArray = potentialCalculator.VArray
        
        // Send the x and potential arrays to psiCalculator
        psiCalculator.xArray = xArray
        psiCalculator.VArray = VArray
        
        // Get the wavefunction result from psiCalculator
        await psiCalculator.getWavefunction()
        
        // Plot the results (either the wavefunction or the potential)
        await self.generatePlots()
        
        // Enable the calculate button
        psiCalculator.setButtonEnable(state: true)
    }
    
    /// setupPlotDataModel
    /// Tells psiCalculator and potentialCalculator which plot data model to use
    @MainActor func setupPlotDataModel() {
        psiCalculator.plotDataModel = self.plotDataModel
        potentialCalculator.plotDataModel = self.plotDataModel
    }
    
    /// generatePlots
    /// Runs the functions to plot either the wavefunction or the potential depending on user selection
    func generatePlots() async {
        setupPlotDataModel()
        if (selectedPlot == "Wavefunction") {
            // await psiCalculator.getPlotData()
            print("You haven't made this function yet...")
        }
        else if (selectedPlot == "Potential") {
            // Tell potentialCalculator which potential the user chose
            potentialCalculator.potentialType = selectedPotential
            
            // Plot the potential
            await potentialCalculator.getPlotData()
        }
    }
    
    /// clear
    /// Resets the potential arrays to all 0 and clears the plot display
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
