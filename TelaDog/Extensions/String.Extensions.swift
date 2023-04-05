//
//  String.Extensions.swift
//  TelaDog
//
//  Created by Pierre BARTHELEMY on 04/04/2023.
//

import Foundation

extension String {
    public func indent(by level: Int = 0) -> String {
        String(repeating: "  ", count: level) + self
    }
}
