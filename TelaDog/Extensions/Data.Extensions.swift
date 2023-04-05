//
//  Data.Extensions.swift
//  TelaDog
//
//  Created by Pierre BARTHELEMY on 04/04/2023.
//

import Foundation

extension Data {
    public func json(format pFormat:Bool = false, padding pPadding:String = "") -> String? {
        var lRet: String? = nil
        
        let lOptions: JSONSerialization.WritingOptions = pFormat ? .prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
        
        if let json = try? JSONSerialization.jsonObject(with: self, options: JSONSerialization.ReadingOptions.allowFragments),
           let lData = try? JSONSerialization.data(withJSONObject: json, options: lOptions) {
                lRet = String(data: lData, encoding: String.Encoding.utf8)
                
                if pPadding != "" {
                    lRet = lRet?.components(separatedBy: "\n").map({ "\(pPadding)\($0)"}).joined(separator: "\n")
                }
        }
        
        return lRet
    }
}
