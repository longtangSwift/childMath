//
//  LinearCongruentialGenerator.swift
//  Psychologist
//
//  Created by CT MacBook Pro on 6/30/15.
//  Copyright © 2015 CT MacBook Pro. All rights reserved.
//

import Foundation

protocol RandomNumberGenerator {
    func random() -> Double
}
//This protocol, RandomNumberGenerator, requires any conforming type to have an instance method called random, which returns a Double value whenever it is called. Although it is not specified as part of the protocol, it is assumed that this value will be a number from 0.0 up to (but not including) 1.0.
//
//The RandomNumberGenerator protocol does not make any assumptions about how each random number will be generated—it simply requires the generator to provide a standard way to generate a new random number.
//
//Here’s an implementation of a class that adopts and conforms to the RandomNumberGenerator protocol. This class implements a pseudorandom number generator algorithm known as a linear congruential generator:

class LinearCongruentialGenerator: RandomNumberGenerator {
    private var lastRandom = 42.0 + (NSDate(timeIntervalSince1970: 4597865)).timeIntervalSinceReferenceDate
    private let m = 34359738367.0
    private var a = 3877.02 + abs((NSDate(timeIntervalSince1970: 14234).timeIntervalSinceReferenceDate - NSDate(timeIntervalSinceNow: 1).timeIntervalSinceReferenceDate - 2 * NSDate(timeIntervalSince1970: 14234).timeIntervalSinceReferenceDate)){didSet{print("in LCG, a is: \(a)")}}
    private let c = 29573.07 + abs(sin(NSDate(timeIntervalSince1970: 14234).timeIntervalSinceReferenceDate - NSDate(timeIntervalSinceNow: 1).timeIntervalSinceReferenceDate))
    private var d = 1.0
    private var e = 1.0
    
    func random() -> Double {
        d = abs( ((1.0731 * a + m + tan(m)) % c) / c ) + 0.0842385718481  //    //returns a double 0.XXXXXXX + 0.08
        e = abs( d * 3313.13 * tan(sqrt(d+7)) * sin(Double(m)+11) / tan(a+13) + M_2_PI*c )
        lastRandom = abs((lastRandom * a + c + 0.913 / e / d) % m)
        return lastRandom / m
    }
    func random(range: Int)->Int
    {
        let x = random()
        return (Int(Double(range) * x))
    }
}
