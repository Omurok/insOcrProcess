//
//  AIDetection.swift
//  APIPackageDescription
//
//  Created by Omurok Chien on 2018/12/19.
//

import Foundation
import CoreML
class AIDetection {
    var model: InsuranceTextClassifier!
    init() {
        model = InsuranceTextClassifier()
    }
}
