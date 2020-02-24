//
//  CGPointExtension.swift
//  PegglePhysics
//
//  Created by Liu Zechu on 8/2/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import Foundation
import struct CoreGraphics.CGPoint

extension CGPoint {
    func toPosition() -> Position {
        return Position(xComponent: Double(self.x), yComponent: Double(self.y))
    }
}
