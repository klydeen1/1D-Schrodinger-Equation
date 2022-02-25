//
//  OneDPotentials.swift
//  1D-Schrodinger-Equation
//
//  Created by Katelyn Lydeen on 2/18/22.
//

import Foundation
import CorePlot

class OneDPotentials: NSObject, ObservableObject {
    @Published var xArray = [Double]() // Array holding x-values for the potential
    @Published var VArray = [Double]() // Array holding the potentials V(x)
    @Published var dataPoints :[plotDataType] =  []
    
    var plotDataModel: PlotDataClass? = nil
    
    @MainActor init(withData data: Bool) {
        super.init()
        xArray = []
        VArray = []
        dataPoints = []
    }
    
    func setPotential(potentialType: String, xMin: Double, xMax: Double, xStep: Double) {
        let hbar2overm = 1.0 // Change this later...
        var count = 0
        clearPotential()
        
        switch potentialType {
        case "Square Well":
            startPotential(xMin: xMin, xMax: xMax, xStep: xStep)
            for i in stride(from: xMin+xStep, through: xMax-xStep, by: xStep) {
                xArray.append(i)
                VArray.append(0.0)
                
                count = xArray.count
                let dataPoint: plotDataType = [.X: xArray[count-1], .Y: VArray[count-1]]
                dataPoints.append(dataPoint)
            }
            finishPotential(xMin: xMin, xMax: xMax, xStep: xStep)
            
        case "Linear Well":
            startPotential(xMin: xMin, xMax: xMax, xStep: xStep)
            for i in stride(from: xMin+xStep, through: xMax-xStep, by: xStep) {
                xArray.append(i)
                VArray.append((i-xMin)*4.0*1.3)
                
                count = xArray.count
                let dataPoint: plotDataType = [.X: xArray[count-1], .Y: VArray[count-1]]
                dataPoints.append(dataPoint)
            }
            finishPotential(xMin: xMin, xMax: xMax, xStep: xStep)
            
        case "Parabolic Well":
            startPotential(xMin: xMin, xMax: xMax, xStep: xStep)
            for i in stride(from: xMin+xStep, through: xMax-xStep, by: xStep) {
                xArray.append(i)
                VArray.append((pow((i-(xMax+xMin)/2.0), 2.0)/1.0))
                
                count = xArray.count
                let dataPoint: plotDataType = [.X: xArray[count-1], .Y: VArray[count-1]]
                dataPoints.append(dataPoint)
            }
            finishPotential(xMin: xMin, xMax: xMax, xStep: xStep)
            
        case "Square + Linear Well":
            startPotential(xMin: xMin, xMax: xMax, xStep: xStep)
            for i in stride(from: xMin+xStep, to: (xMax+xMin)/2.0, by: xStep) {
                xArray.append(i)
                VArray.append(0.0)
                
                count = xArray.count
                let dataPoint: plotDataType = [.X: xArray[count-1], .Y: VArray[count-1]]
                dataPoints.append(dataPoint)
            }
            for i in stride(from: (xMin+xMax)/2.0, through: xMax-xStep, by: xStep) {
                xArray.append(i)
                VArray.append(((i-(xMin+xMax)/2.0)*4.0*0.1))
                
                count = xArray.count
                let dataPoint: plotDataType = [.X: xArray[count-1], .Y: VArray[count-1]]
                dataPoints.append(dataPoint)
            }
            finishPotential(xMin: xMin, xMax: xMax, xStep: xStep)
            
        case "Square Barrier":
            startPotential(xMin: xMin, xMax: xMax, xStep: xStep)
            for i in stride(from: xMin+xStep, to: xMin + (xMax-xMin)*0.4, by: xStep) {
                xArray.append(i)
                VArray.append(0.0)
                
                count = xArray.count
                let dataPoint: plotDataType = [.X: xArray[count-1], .Y: VArray[count-1]]
                dataPoints.append(dataPoint)
            }
            for i in stride(from: xMin + (xMax-xMin)*0.4, to: xMin + (xMax-xMin)*0.6, by: xStep) {
                xArray.append(i)
                VArray.append(15.000000001)
                
                count = xArray.count
                let dataPoint: plotDataType = [.X: xArray[count-1], .Y: VArray[count-1]]
                dataPoints.append(dataPoint)
            }
            for i in stride(from: xMin + (xMax-xMin)*0.6, to: xMax, by: xStep) {
                xArray.append(i)
                VArray.append(0.0)
                
                count = xArray.count
                let dataPoint: plotDataType = [.X: xArray[count-1], .Y: VArray[count-1]]
                dataPoints.append(dataPoint)
            }
            finishPotential(xMin: xMin, xMax: xMax, xStep: xStep)
            
        case "Triangle Barrier":
            startPotential(xMin: xMin, xMax: xMax, xStep: xStep)
            for i in stride(from: xMin+xStep, to: xMin + (xMax-xMin)*0.4, by: xStep) {
                xArray.append(i)
                VArray.append(0.0)

                count = xArray.count
                let dataPoint: plotDataType = [.X: xArray[count-1], .Y: VArray[count-1]]
                dataPoints.append(dataPoint)
            }
            for i in stride(from: xMin + (xMax-xMin)*0.4, to: xMin + (xMax-xMin)*0.5, by: xStep) {
                xArray.append(i)
                VArray.append((abs(i-(xMin + (xMax-xMin)*0.4))*3.0))
                            
                count = xArray.count
                let dataPoint: plotDataType = [.X: xArray[count-1], .Y: VArray[count-1]]
                dataPoints.append(dataPoint)
            }
            for i in stride(from: xMin + (xMax-xMin)*0.5, to: xMin + (xMax-xMin)*0.6, by: xStep) {
                xArray.append(i)
                VArray.append((abs(i-(xMax - (xMax-xMin)*0.4))*3.0))
                            
                count = xArray.count
                let dataPoint: plotDataType = [.X: xArray[count-1], .Y: VArray[count-1]]
                dataPoints.append(dataPoint)
            }
            for i in stride(from: xMin + (xMax-xMin)*0.6, to: xMax, by: xStep) {
                xArray.append(i)
                VArray.append(0.0)
                            
                count = xArray.count
                let dataPoint: plotDataType = [.X: xArray[count-1], .Y: VArray[count-1]]
                dataPoints.append(dataPoint)
            }
            finishPotential(xMin: xMin, xMax: xMax, xStep: xStep)
            
        case "Coupled Parabolic Well":
            startPotential(xMin: xMin, xMax: xMax, xStep: xStep)
            for i in stride(from: xMin+xStep, to: xMin + (xMax-xMin)*0.5, by: xStep) {
                xArray.append(i)
                VArray.append((pow((i-(xMin+(xMax-xMin)/4.0)), 2.0)))
                     
                count = xArray.count
                let dataPoint: plotDataType = [.X: xArray[count-1], .Y: VArray[count-1]]
                dataPoints.append(dataPoint)
            }
                 
            for i in stride(from: xMin + (xMax-xMin)*0.5, through: xMax-xStep, by: xStep) {
                xArray.append(i)
                VArray.append((pow((i-(xMax-(xMax-xMin)/4.0)), 2.0)))
                     
                count = xArray.count
                let dataPoint: plotDataType = [.X: xArray[count-1], .Y: VArray[count-1]]
                dataPoints.append(dataPoint)
            }
            finishPotential(xMin: xMin, xMax: xMax, xStep: xStep)
            
        case "Coupled Square Well + Field":
            startPotential(xMin: xMin, xMax: xMax, xStep: xStep)
            for i in stride(from: xMin+xStep, to: xMin + (xMax-xMin)*0.4, by: xStep) {
                xArray.append(i)
                VArray.append(0.0)
            }
            for i in stride(from: xMin + (xMax-xMin)*0.4, to: xMin + (xMax-xMin)*0.6, by: xStep) {
                xArray.append(i)
                VArray.append(4.0)
            }
            for i in stride(from: xMin + (xMax-xMin)*0.6, to: xMax, by: xStep) {
                xArray.append(i)
                VArray.append(0.0)
            }
            for i in 1 ..< (xArray.count) {
                VArray[i] += ((xArray[i]-xMin)*4.0*0.1)
                let dataPoint: plotDataType = [.X: xArray[i], .Y: VArray[i]]
                dataPoints.append(dataPoint)
            }
            finishPotential(xMin: xMin, xMax: xMax, xStep: xStep)
            
        case "Harmonic Oscillator":
            let xMinHO = -20.0
            let xMaxHO = 20.0
            let xStepHO = 0.001
                    
            startPotential(xMin: xMinHO+xMaxHO, xMax: xMaxHO+xMaxHO, xStep: xStepHO)
            for i in stride(from: xMinHO+xStepHO, through: xMaxHO-xStepHO, by: xStepHO) {
                xArray.append(i+xMaxHO)
                VArray.append((pow((i-(xMaxHO+xMinHO)/2.0), 2.0)/15.0))
                        
                count = xArray.count
                let dataPoint: plotDataType = [.X: xArray[count-1], .Y: VArray[count-1]]
                dataPoints.append(dataPoint)
            }
            finishPotential(xMin: xMinHO+xMaxHO, xMax: xMaxHO+xMaxHO, xStep: xStepHO)
            
        case "Kronig - Penney":
            let xMinKP = 0.0
            let xStepKP = 0.001
                    
            let numberOfBarriers = 10.0
            let boxLength = 10.0
            let barrierPotential = 100.0*hbar2overm/2.0
            let latticeSpacing = boxLength/numberOfBarriers
            let barrierWidth = 1.0/6.0*latticeSpacing
            var barrierNumber = 1;
            var currentBarrierPosition = 0.0
            var inBarrier = false;
            let xMaxKP = boxLength
                    
            startPotential(xMin: xMinKP, xMax: xMaxKP, xStep: xStepKP)
                    
            for i in stride(from: xMinKP+xStepKP, through: xMaxKP-xStepKP, by: xStepKP) {
                currentBarrierPosition = -latticeSpacing/2.0 + Double(barrierNumber)*latticeSpacing
                if ((abs(i-currentBarrierPosition)) < (barrierWidth/2.0)) {
                    inBarrier = true
      
                    xArray.append(i)
                    VArray.append(barrierPotential)
                            
                    count = xArray.count
                    let dataPoint: plotDataType = [.X: xArray[count-1], .Y: VArray[count-1]]
                    dataPoints.append(dataPoint)
                }
                else {
                    if (inBarrier) {
                        inBarrier = false
                        barrierNumber += 1
                    }
                            
                    xArray.append(i)
                    VArray.append(0.0)
                            
                    count = xArray.count
                    let dataPoint: plotDataType = [.X: xArray[count-1], .Y: VArray[count-1]]
                    dataPoints.append(dataPoint)
                }
            }
                    
            xArray.append(xMax)
            VArray.append(5000000.0)
                    
            let dataPoint: plotDataType = [.X: xArray[count-1], .Y: VArray[count-1]]
            dataPoints.append(dataPoint)
                    
            /*
            /** Fixes Bug In Plotting Library not displaying the last point **/
            dataPoint = [.X: xMax+xStep, .Y: 5000000.0]
            contentArray.append(dataPoint)
                    
            let xMin = potential.minX(minArray: potential.oneDPotentialXArray)
            let xMax = potential.maxX(maxArray: potential.oneDPotentialXArray)
            let yMin = potential.minY(minArray: potential.oneDPotentialYArray)
            var yMax = potential.maxY(maxArray: potential.oneDPotentialYArray)
                    
            if yMax > 500 { yMax = 10}
                    
            makePlot(xLabel: "x Å", yLabel: "Potential V", xMin: (xMin - 1.0), xMax: (xMax + 1.0), yMin: yMin-1.2, yMax: yMax+0.2)
                    
            contentArray.removeAll()
            */
            
        default:
            // Default to the square well
            startPotential(xMin: xMin, xMax: xMax, xStep: xStep)
            for i in stride(from: xMin+xStep, through: xMax-xStep, by: xStep) {
                xArray.append(i)
                VArray.append(0.0)
                count = xArray.count
                let dataPoint: plotDataType = [.X: xArray[count-1], .Y: VArray[count-1]]
                dataPoints.append(dataPoint)
            }
            finishPotential(xMin: xMin, xMax: xMax, xStep: xStep)
        }
    }
    
    /// clearPotential
    /// Sets the arrays for the x values, potentials, and plot data points to empty arrays
    func clearPotential() {
        xArray = []
        VArray = []
        dataPoints = []
    }
    
    func startPotential(xMin: Double, xMax: Double, xStep: Double) {
        var count = 0
        xArray.append(xMin)
        VArray.append(0.0)
        
        count = xArray.count
        let dataPoint: plotDataType = [.X: xArray[count-1], .Y: VArray[count-1]]
        dataPoints.append(dataPoint)
    }
    
    func finishPotential(xMin: Double, xMax: Double, xStep: Double) {
        var count = 0
        xArray.append(xMax)
        VArray.append(0.0)
        
        count = xArray.count
        let dataPoint: plotDataType = [.X: xArray[count-1], .Y: VArray[count-1]]
        dataPoints.append(dataPoint)
    }
}
