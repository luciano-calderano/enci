//
//  ExtDictionary.swift
//  Lc
//
//  Created by Luciano Calderano on 2018
//  Copyright © 2018 Lc. All rights reserved.
//

import Foundation

public extension Dictionary {
    private typealias LcDict = Dictionary<Key, Value>
    func value<T>(_ keys: String) -> T? {
        let array = keys.components(separatedBy: "->")
        
        var dic = self as LcDict
        for key in array.dropLast() {
            guard let next = dic[key as! Key] else {
                return nil
            }
            guard next is LcDict else {
                return nil
            }
            
            dic = next as! LcDict
        }
        
        guard let value = dic[array.last! as! Key] else {
            return nil
        }
        return value as? T
    }
    
    func double (_ key: String) -> Double {
        return value(key) ?? 0
    }
    
    func int (_ key: String) -> Int {
        return value(key) ?? 0
    }
    
    func string (_ key: String) -> String {
        return value(key) ?? ""
    }
    
    func dictionary(_ key: String) -> Dictionary<Key, Value> {
        return value(key) ?? [:]
    }
    
    func array(_ key: String) -> Array<Any> {
        return value(key) ?? []
    }
    
    func bool (_ key: String) -> Bool {
        guard let ret:String = value(key) else {
            guard let boolRet:Bool = value(key) else {
                return false
            }
            return boolRet
        }
        return ret == "1" || ret.lowercased() == "true" || ret.lowercased().left(lenght: 1) == "y"
    }
    
    func date (_ key: String, fmt: String = "") -> Date? {
        if fmt.isEmpty {
            return value(key) ?? nil
        }
        
        if let ret:String = value(key) {
            return ret.isEmpty ? nil : ret.toDate(withFormat: fmt)
        }
        return nil
    }
}

