//
//  SchrodingerSolver.swift
//  1D-Schrodinger-Equation
//
//  Created by Katelyn Lydeen on 2/18/22.
//

import Foundation
import SwiftUI
import CorePlot

class SchrodingerSolver: NSObject, ObservableObject {
    @Published var psiArray = [Double]()
    @Published var enableButton = true
    @Published var dataPoints :[plotDataType] =  []
    
    var xArray = [Double]() // Array holding x-values for the potential
    var VArray = [Double]() // Array holding the potentials V(x)
    var xStep = 0.0
    var calculatedPsiArray = [Double]()
    var calculatedPsiPrimeArray = [Double]()
    var calculatedPsiDoublePrimeArray = [Double]()
    var newDataPoints: [plotDataType] =  []
    var plotDataModel: PlotDataClass? = nil
    let hBarSquaredOverM = 7.62
    
    
    
    /// getWavefunction
    /// Runs functions to calculate the wavefunction and update the wavefunction array and data point array on the main thread
    func getWavefunction() async {
        await solveShrodingerWithEuler(E: 3.67)
        await updatePsiArray(psiArray: calculatedPsiArray)
        await updateDataPoints(dataPoints: newDataPoints)
    }
    
    /// solveShrodingerWithEuler
    /// Calculates the wavefunction values vs. x and sets calculatedPsiArray and dataPoints at a given energy
    /// - Parameters:
    ///   - E: the energy value to solve the equation for
    func solveShrodingerWithEuler (E: Double) async {
        let schrodingerConstant = hBarSquaredOverM/2.0
        
        calculatedPsiArray.append(0.0)
        calculatedPsiPrimeArray.append(1.0)
        calculatedPsiDoublePrimeArray.append((VArray[0] - E) * 1/schrodingerConstant * calculatedPsiArray[0])
        let dataPoint: plotDataType = [.X: xArray[0], .Y: calculatedPsiArray[0]]
        newDataPoints.append(dataPoint)
        
        for i in 1..<VArray.count {
            calculatedPsiArray.append(calculatedPsiArray[i-1] + xStep * calculatedPsiPrimeArray[i-1])
            calculatedPsiPrimeArray.append(calculatedPsiPrimeArray[i-1] + xStep*calculatedPsiDoublePrimeArray[i-1])
            calculatedPsiDoublePrimeArray.append((VArray[i] - E) * 1/schrodingerConstant * calculatedPsiArray[i])
            let dataPoint: plotDataType = [.X: xArray[i], .Y: calculatedPsiArray[i]]
            newDataPoints.append(dataPoint)
            print(xArray[i])
        }
    }
    
    /// updatePsiArray
    /// The function runs on the main thread so it can update the GUI
    /// - Parameter psiArray: contains the array of wavefunction values
    @MainActor func updatePsiArray(psiArray: [Double]) async {
        self.psiArray = psiArray
    }
    
    /// updateDataPoints
    /// The function runs on the main thread so it can update the GUI
    /// - Parameter xArray: contains the array of plot data points for the potential vs. x
    @MainActor func updateDataPoints(dataPoints: [plotDataType]) async {
        self.dataPoints = dataPoints
    }
    
    /// getPlotData
    /// Sets plot properties and appends the current value of dataPoints to the plot data model
    /// Note: This does NOT recalculate the potential. calculatePotential must be used before calling this function in order to get the correct data
    func getPlotData() async {
        // Clear any existing plot data
        await plotDataModel!.zeroData()
        
        let xMin = xArray[0]
        let xMax = xArray[xArray.count - 1]
        
        // Set x-axis limits
        await plotDataModel!.changingPlotParameters.xMax = xMax + 0.5
        await plotDataModel!.changingPlotParameters.xMin = xMin - 0.5
        // Set y-axis limits
        await plotDataModel!.changingPlotParameters.yMax = 5.0
        await plotDataModel!.changingPlotParameters.yMin = -5.0
            
        // Set title and other attributes
        await plotDataModel!.changingPlotParameters.title = "Wavefunction Solution"
        await plotDataModel!.changingPlotParameters.xLabel = "Position"
        await plotDataModel!.changingPlotParameters.yLabel = "Psi"
        await plotDataModel!.changingPlotParameters.lineColor = .red()
            
        // Get plot data
        await plotDataModel!.appendData(dataPoint: dataPoints)
    }
    
    /// setButton Enable
    /// Toggles the state of the Enable Button on the Main Thread
    /// - Parameter state: Boolean describing whether the button should be enabled.
    @MainActor func setButtonEnable(state: Bool) {
        if state {
            Task.init {
                await MainActor.run {
                    self.enableButton = true
                }
            }
        }
        else{
            Task.init {
                await MainActor.run {
                    self.enableButton = false
                }
            }
        }
    }
}
