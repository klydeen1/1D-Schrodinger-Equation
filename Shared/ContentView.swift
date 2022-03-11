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
    
    @State var minEnergyString = "0.01"
    @State var maxEnergyString = "10.0"
    @State var selectedPotential = "Square Well"
    @State var selectedPlot = "Wavefunction"
    @State var firstTimeRunning = true
    @State var selectedEnergy = ""
    @State var selectedEnergyIndex = 0
    @State var energies = [""]
    
    var plots = ["Potential", "Wavefunction"]
    var potentials = ["Square Well", "Linear Well", "Parabolic Well", "Square + Linear Well", "Square Barrier", "Triangle Barrier", "Coupled Parabolic Well", "Coupled Square Well + Field", "Harmonic Oscillator", "Kronig - Penney", "KP2-a"]
    
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
                
                VStack {
                    Text("Energy Value")
                        .font(.callout)
                        .bold()
                    Picker("", selection: $selectedEnergy) {
                        ForEach(energies, id: \.self) {
                            Text($0)
                        }
                    }
                }
                
                HStack {
                    Button("Calculate Data", action: {Task.init{await self.calculateFunctions()}})
                        .padding()
                        .disabled(psiCalculator.enableButton == false)
                    
                    Button("Update Plot", action: {Task.init{await self.generatePlots()}})
                        .padding()
                        .disabled(psiCalculator.enableButton == false)
                    
                    Button("Clear", action: {self.clear()})
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
    
    /// calculateFunctions
    /// Runs appropriate functions to calculate the potential and wavefunction
    /// Also runs generatePlots to get and display plot data
    func calculateFunctions() async {
        let previousPotential = potentialCalculator.potentialType
        
        // Tell potentialCalculator which potential the user chose
        potentialCalculator.potentialType = selectedPotential
        
        // Disable the calculate button
        psiCalculator.setButtonEnable(state: false)
        
        // Get the arrays for x and potential from potentialCalculator
        // If the user has chosen a new potential, calculate that new potential. Otherwise keep the old values to save some computation time
        if (previousPotential != selectedPotential || firstTimeRunning) {
            await potentialCalculator.setPotential()
            firstTimeRunning = false
        }
        
        // Send the x and potential arrays as well as xStep to psiCalculator
        psiCalculator.xArray = potentialCalculator.xArray
        psiCalculator.VArray = potentialCalculator.VArray
        psiCalculator.xStep = potentialCalculator.xStep
        
        // Get the wavefunction result from psiCalculator
        await psiCalculator.getWavefunction()
        
        self.energies = []
        for energy in psiCalculator.validEnergyArray {
            self.energies.append(String(format: "%.3f", energy, " eV"))
        }
        
        await generatePlots()
        
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
        // Disable the calculate button
        psiCalculator.setButtonEnable(state: false)
        
        selectedEnergyIndex = energies.firstIndex(of: selectedEnergy) ?? 0
        
        setupPlotDataModel()
        if (selectedPlot == "Wavefunction") {
            await psiCalculator.getPlotDataFromPsiArray(index: selectedEnergyIndex)
        }
        else if (selectedPlot == "Potential") {
            await potentialCalculator.getPlotData()
        }
        
        // Enable the calculate button
        psiCalculator.setButtonEnable(state: true)
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
