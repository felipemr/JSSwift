//
//  Monster.swift
//  JSSwift
//
//  Created by Felipe Marques on 26/04/22.
//

import Foundation
import JavaScriptCore

@objc
protocol MonsterJS: JSExport {
    // JSExport exposes variables and functions to work on JSContext
    var name: String { get set}
    var hitPoints: Int { get set}
    var strength: Int { get set }

    static func create(_ name: String, _ hitPoints: Int, _ strength: Int) -> MonsterJS
    func printMonster() -> String
}

@objc
public class Monster : NSObject, MonsterJS {
    var name: String
    var hitPoints: Int
    var strength: Int

    init(name: String, hitPoints: Int, strength: Int) {
        self.name = name
        self.hitPoints = hitPoints
        self.strength = strength
        super.init()
    }

    class func create(_ name: String, _ hitPoints: Int, _ strength: Int) -> MonsterJS {
        return Monster(name: name, hitPoints: hitPoints, strength: strength)
    }

    func printMonster() -> String {
            return "Monster: \(name)(\(hitPoints))"
        }
}
