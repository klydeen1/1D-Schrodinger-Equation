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
    @Published var enableButton = true
    
    var plotDataModel: PlotDataClass? = nil
    
    
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
