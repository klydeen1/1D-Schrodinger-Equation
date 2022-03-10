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
    @Published var validPsiArrays: [[Double]] = []
    @Published var validEnergyArray: [Double] = []
    @Published var enableButton = true
    @Published var dataPoints :[plotDataType] =  []
    
    var xArray = [Double]() // Array holding x-values for the potential
    var VArray = [Double]() // Array holding the potentials V(x)
    var xStep = 0.0
    var calculatedPsiArray = [Double]()
    var calculatedPsiPrimeArray = [Double]()
    var calculatedPsiDoublePrimeArray = [Double]()
    var calculatedValidEnergies = [Double]()
    var calculatedValidPsi = [[Double]]()
    var newDataPoints: [plotDataType] =  []
    var allValidPsiPlotData: [[plotDataType]] = []
    var plotDataModel: PlotDataClass? = nil
    let hBarSquaredOverM = 7.61996423107385308868
    
    /// getWavefunction
    /// Runs functions to calculate the wavefunction and update the wavefunction array and data point array on the main thread
    func getWavefunction() async {
        await calculateValidWavefunctions()
        await updateValidEnergies(energyArray: calculatedValidEnergies)
        await updatePsiArrays(psiArray: calculatedValidPsi)
        // await updateDataPoints(dataPoints: newDataPoints)
    }
    
    // Function to find solutions for all valid energies
    func calculateValidWavefunctions() async {
        allValidPsiPlotData = []
        let psiPrecision = 1e-5 // How close the wavefunction must be to 0 for us to be satisfied
        let intervalPrecision = 1e-5 // How small the energy interval can be before we quit
        let minEnergy = 10.0
        await solveSchrodingerWithEuler(E: 37.603)
        print(calculatedPsiArray[calculatedPsiArray.count - 1])
        await solveSchrodingerWithEuler(E: minEnergy)
        var leftFinalPsi = calculatedPsiArray[calculatedPsiArray.count - 1]
        var leftEnergy = minEnergy
        
        let finalBoundaryPoints = await calculatePossibleWavefunctions(eMin: 10.0, eMax: 500.0, eStep: 5.0)
        
        for finalBoundaryPoint in finalBoundaryPoints {
            let newFinalPsi = finalBoundaryPoint.psi
            var rightFinalPsi = newFinalPsi
            let newEnergyVal = finalBoundaryPoint.energy
            // Find regions where the value of finalPsi has crossed through 0
            if (leftFinalPsi.sign != rightFinalPsi.sign) {
                var rightEnergy = newEnergyVal
                var possibleZero: Double
                var testEnergy: Double
                var count = 1
                // Find the zero using the false position bracketing method
                repeat {
                    testEnergy = leftEnergy - leftFinalPsi * (rightEnergy - leftEnergy) / (rightFinalPsi - leftFinalPsi)
                    await solveSchrodingerWithEuler(E: testEnergy)
                    possibleZero = calculatedPsiArray[calculatedPsiArray.count - 1]
                    if (possibleZero * leftFinalPsi < 0) {
                        // The zero is in the lower subinterval
                        rightEnergy = testEnergy // Shift the right barrier to get the new boundary
                        rightFinalPsi = possibleZero // Shift the psi value at the right barrier
                    }
                    else if (possibleZero * leftFinalPsi > 0) {
                        // The zero is in the upper subinterval
                        leftEnergy = testEnergy // Shift the left barrier
                        leftFinalPsi = possibleZero // Shift the psi value at the
                    }
                    else {
                        // possibleZero is the exact zero (highly unlikely)
                        break;
                    }
                    count+=1
                    if count > 2000 {
                        break;
                    }
                } while(abs(possibleZero) > psiPrecision && abs(leftEnergy - rightEnergy) > intervalPrecision)
                // We've now obtained our best guess for the zero
                
                // To look for future zeroes, we only want to look to the right of the zero we just found
                leftEnergy = testEnergy
                
                // We might have duplicate values so we'll filter those out
                var similarEnergyAlreadyFound = false
                if !(calculatedValidEnergies.isEmpty) {
                    let energyPrecision = 1e-1
                    for prevEnergy in calculatedValidEnergies {
                        if abs(prevEnergy - testEnergy) < energyPrecision {
                            similarEnergyAlreadyFound = true
                        }
                    }
                }
                if similarEnergyAlreadyFound == false {
                    print("Unique energy \(testEnergy)")
                    calculatedValidEnergies.append(testEnergy)
                    calculatedValidPsi.append(calculatedPsiArray)
                    allValidPsiPlotData.append(newDataPoints)
                }
            }
            else { // No zeros found in the interval
                leftEnergy = newEnergyVal // Shift the left barrier to the current energy value
                leftFinalPsi = newFinalPsi // Adjust the psi value at the left barrier
            }
        }
    }
    
    // Function to find a solution for all energies within a specified energy range
    func calculatePossibleWavefunctions(eMin: Double, eMax: Double, eStep: Double) async -> [(energy: Double, psi: Double)] {
        // var possiblePsi: [[Double]] = []
        // var possibleEnergies: [Double] = []
        var finalPointsForBC: [(energy: Double, psi: Double)] = []
        
        for energyVal in stride(from: eMin, through: eMax, by: eStep) {
            await solveSchrodingerWithEuler(E: energyVal)
            // possiblePsi.append(calculatedPsiArray)
            // possibleEnergies.append(energyVal)
            let finalPsi = calculatedPsiArray[calculatedPsiArray.count - 1]
            finalPointsForBC.append((energy: energyVal, psi: finalPsi))
        }
        
        return finalPointsForBC
    }
    
    func solveSchrodingerWithRK4(E: Double) async {
        let h = xStep
        let schrodingerConstant = hBarSquaredOverM/2.0
        await setSchrodingerInitialPoints(E: E) // Set points at index 0
        
        // Add subsequent points to the arrays using Runge-Kutta 4th Order
        for i in 1..<VArray.count {
            let k1 = h*calculatedPsiPrimeArray[i-1]
            let j1 = h * 1/schrodingerConstant * (VArray[i-1] - E) * (calculatedPsiArray[i-1])
            
            let k2 = h*(calculatedPsiPrimeArray[i-1] + j1/2.0)
            let j2 = h * 1/schrodingerConstant * (VArray[i-1] - E) * (calculatedPsiArray[i-1]+k1/2.0)
            
            let k3 = h*(calculatedPsiPrimeArray[i-1] + j2/2.0)
            let j3 = h * 1/schrodingerConstant * (VArray[i-1] - E) * (calculatedPsiArray[i-1]+k2/2.0)
            
            let k4 = h*(calculatedPsiPrimeArray[i-1] + j3)
            let j4 = h * 1/schrodingerConstant * (VArray[i-1] - E) * (calculatedPsiArray[i-1]+k3)
            
            calculatedPsiArray.append(calculatedPsiArray[i-1] + ((k1 + 2.0*k2 + 2.0*k3 + k4)/6.0))
            calculatedPsiPrimeArray.append(calculatedPsiPrimeArray[i-1] + ((j1 + 2.0*j2 + 2.0*j3 + j4)/6.0))
            
            let dataPoint: plotDataType = [.X: xArray[i], .Y: calculatedPsiArray[i]]
            newDataPoints.append(dataPoint)
        }
    }
    
    /// solveShrodingerWithEuler
    /// Calculates the wavefunction values vs. x and sets calculatedPsiArray and dataPoints at a given energy using the Euler method
    /// - Parameters:
    ///   - E: the energy value to solve the equation for
    /// - Returns: the value of the wave equation at the right boundary
    func solveSchrodingerWithEuler(E: Double) async {
        let schrodingerConstant = hBarSquaredOverM/2.0
        await setSchrodingerInitialPoints(E: E) // Set points at index 0
        
        // Add subsequent points to the arrays using Euler's method
        for i in 1..<VArray.count {
            calculatedPsiArray.append(calculatedPsiArray[i-1] + xStep * calculatedPsiPrimeArray[i-1])
            calculatedPsiPrimeArray.append(calculatedPsiPrimeArray[i-1] + xStep*calculatedPsiDoublePrimeArray[i-1])
            calculatedPsiDoublePrimeArray.append((VArray[i] - E) * 1/schrodingerConstant * calculatedPsiArray[i])
            let dataPoint: plotDataType = [.X: xArray[i], .Y: calculatedPsiArray[i]]
            newDataPoints.append(dataPoint)
        }
    }
    
    func setSchrodingerInitialPoints(E: Double) async {
        let schrodingerConstant = hBarSquaredOverM/2.0
        
        // Reset the arrays to empty
        calculatedPsiArray = []
        calculatedPsiPrimeArray = []
        calculatedPsiDoublePrimeArray = []
        newDataPoints = []
        
        // Add the first point (x=0) to the arrays
        calculatedPsiArray.append(0.0)
        calculatedPsiPrimeArray.append(1.0)
        calculatedPsiDoublePrimeArray.append(((VArray[0] - E) * 1/schrodingerConstant) * calculatedPsiArray[0])
        let dataPoint: plotDataType = [.X: xArray[0], .Y: calculatedPsiArray[0]]
        newDataPoints.append(dataPoint)
    }
    
    /// updatePsiArray
    /// The function runs on the main thread so it can update the GUI
    /// - Parameter psiArray: contains the array of wavefunction values
    @MainActor func updatePsiArrays(psiArray: [[Double]]) async {
        self.validPsiArrays = psiArray
    }
    
    /// updatePsiArray
    /// The function runs on the main thread so it can update the GUI
    /// - Parameter psiArray: contains the array of wavefunction values
    @MainActor func updateValidEnergies(energyArray: [Double]) async {
        self.validEnergyArray = energyArray
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
    
    func getPlotDataFromPsiArray(index: Int) async {
        if (index > -1 && index < allValidPsiPlotData.count) { // This is a valid index
            // Plot the data at the given index
            await updateDataPoints(dataPoints: allValidPsiPlotData[index])
            await getPlotData()
        }
        else if !(allValidPsiPlotData.isEmpty) { // The index isn't valid but the data array isn't empty
            // Plot the data at index 0
            await updateDataPoints(dataPoints: allValidPsiPlotData[0])
            await getPlotData()
        }
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
