//
//  File.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 02.03.20.
//  Copyright © 2020 Michael Rojkov. All rights reserved.
//

import Foundation


enum ObservationType: CaseIterable {
    case Anamnesis
    case MedicalLetter
    case Haemodynamics
    case Respiration
    case BloodGasAnalysis
    case Perfusors
    case InfectiousDisease
    case Radeology
    case Lab
    case Others
    case NONE
}

public extension CaseIterable where Self: Equatable {

    func ordinal() -> Self.AllCases.Index {
        return Self.allCases.firstIndex(of: self)!
    }

}
