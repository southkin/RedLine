//
//  RedLine.swift
//  RedLine
//
//  Created by kin on 2022/08/04.
//

import Foundation
#if !os(macOS)
import UIKit

import Foundation
import UIKit
infix operator ^
extension UIView {
    var rl:RedLine {
        return .init(this: self)
    }
}
extension UILayoutGuide {
    var rl:RedLine {
        return .init(this: self)
    }
}
class RedLine  {
    fileprivate var this:Any
    fileprivate var thisAttrs:Set<NSLayoutConstraint.Attribute> = .init()
    fileprivate var other:Any?
    fileprivate var otherAttr:Set<NSLayoutConstraint.Attribute> = .init()
    fileprivate var relatedBy:NSLayoutConstraint.Relation!
    fileprivate var multiplier:CGFloat?
    fileprivate var constant:CGFloat = 0
    fileprivate var priority:Float?
    init(this:Any) {
        self.this = this
    }
    @discardableResult
    func active() -> [NSLayoutConstraint] {
        defer {
            thisAttrs.removeAll()
            otherAttr.removeAll()
            multiplier = nil
            constant = 0
        }
        if let view = this as? UIView {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        var list = [NSLayoutConstraint]()
        thisAttrs.forEach { thisAttr in
            let layout = NSLayoutConstraint(item: this, attribute: thisAttr, relatedBy: relatedBy, toItem: other, attribute: otherAttr.first ?? thisAttr, multiplier: multiplier ?? 1, constant: constant)
            layout.priority = .init(rawValue: priority ?? 1000)
            layout.isActive = true
            list.append(layout)
        }
        
        return list
    }
    
    func `do`(_ closer:(RedLine)->()) {
        closer(self)
    }
    
    @discardableResult
    static func ==(lhs:RedLine, rhs:RedLine) -> [NSLayoutConstraint] {
        lhs.other = rhs.this
        lhs.otherAttr = rhs.thisAttrs
        lhs.relatedBy = .equal
        lhs.multiplier = rhs.multiplier ?? lhs.multiplier
        lhs.priority = rhs.priority ?? rhs.priority
        return lhs.active()
    }
    @discardableResult
    static func ==(lhs:RedLine, rhs:CGFloat) -> [NSLayoutConstraint] {
        lhs.relatedBy = .equal
        lhs.constant = rhs
        return lhs.active()
    }
    @discardableResult
    static func >=(lhs:RedLine, rhs:RedLine) -> [NSLayoutConstraint] {
        lhs.other = rhs.this
        lhs.otherAttr = rhs.thisAttrs
        lhs.relatedBy = .greaterThanOrEqual
        lhs.multiplier = rhs.multiplier ?? lhs.multiplier
        lhs.priority = rhs.priority ?? rhs.priority
        return lhs.active()
    }
    @discardableResult
    static func >=(lhs:RedLine, rhs:CGFloat) -> [NSLayoutConstraint] {
        lhs.relatedBy = .greaterThanOrEqual
        lhs.constant = rhs
        return lhs.active()
    }
    @discardableResult
    static func <=(lhs:RedLine, rhs:RedLine) -> [NSLayoutConstraint] {
        lhs.other = rhs.this
        lhs.otherAttr = rhs.thisAttrs
        lhs.relatedBy = .lessThanOrEqual
        lhs.multiplier = rhs.multiplier ?? lhs.multiplier
        return lhs.active()
    }
    @discardableResult
    static func <=(lhs:RedLine, rhs:CGFloat) -> [NSLayoutConstraint] {
        lhs.relatedBy = .lessThanOrEqual
        lhs.constant = rhs
        return lhs.active()
    }
    static func * (lhs:CGFloat,rhs:RedLine) -> RedLine {
        rhs.multiplier = lhs
        return rhs
    }
    static func * (lhs:RedLine, rhs:CGFloat) -> RedLine {
        lhs.multiplier = rhs
        return lhs
    }
    static func + (lhs:RedLine, rhs:CGFloat) -> RedLine {
        lhs.constant = rhs
        return lhs
    }
    static func + (lhs:CGFloat, rhs:RedLine) -> RedLine {
        rhs.constant = lhs
        return rhs
    }
    static func ^ (lhs:RedLine, rhs:Float) -> RedLine {
        lhs.priority = rhs
        return lhs
    }
}

extension RedLine {
    @discardableResult
    func equal(_ to:RedLine) -> [NSLayoutConstraint] {
        return self == to
    }
    @discardableResult
    func greaterThanOrEqual(_ to:RedLine) -> [NSLayoutConstraint] {
        return self >= to
    }
    @discardableResult
    func lessThenOrEqual(_ to:RedLine) -> [NSLayoutConstraint] {
        return self <= to
    }
}

extension RedLine {
    //MARK: - typecasting
    @discardableResult
    static func ==(lhs:RedLine, rhs:UIView) -> [NSLayoutConstraint] {
        return (lhs == rhs.rl)
    }
    @discardableResult
    static func ==(lhs:RedLine, rhs:Double) -> [NSLayoutConstraint] {
        return (lhs == CGFloat(rhs))
    }
    @discardableResult
    static func ==(lhs:RedLine, rhs:Int) -> [NSLayoutConstraint] {
        return (lhs == CGFloat(rhs))
    }
    @discardableResult
    static func >=(lhs:RedLine, rhs:UIView) -> [NSLayoutConstraint] {
        return (lhs >= rhs.rl)
    }
    @discardableResult
    static func >=(lhs:RedLine, rhs:Int) -> [NSLayoutConstraint] {
        return (lhs >= CGFloat(rhs))
    }
    @discardableResult
    static func >=(lhs:RedLine, rhs:Double) -> [NSLayoutConstraint] {
        return (lhs >= CGFloat(rhs))
    }
    @discardableResult
    static func <=(lhs:RedLine, rhs:UIView) -> [NSLayoutConstraint] {
        return (lhs <= rhs.rl)
    }
    @discardableResult
    static func <=(lhs:RedLine, rhs:Int) -> [NSLayoutConstraint] {
        return (lhs <= CGFloat(rhs))
    }
    @discardableResult
    static func <=(lhs:RedLine, rhs:Double) -> [NSLayoutConstraint] {
        return (lhs <= CGFloat(rhs))
    }
    @discardableResult
    func equal(_ to:UIView) -> [NSLayoutConstraint] {
        return self == to.rl
    }
    @discardableResult
    func greaterThanOrEqual(_ to:UIView) -> [NSLayoutConstraint] {
        return self >= to.rl
    }
    @discardableResult
    func lessThenOrEqual(_ to:UIView) -> [NSLayoutConstraint] {
        return self <= to.rl
    }
    static func ^ (lhs:RedLine, rhs:Int) -> RedLine {
        return lhs ^ Float(rhs)
    }
}

extension RedLine {
    var centerX:RedLine {
        self.thisAttrs.insert(.centerX)
        return self
    }
    var centerY:RedLine {
        self.thisAttrs.insert(.centerY)
        return self
    }
    var leading:RedLine {
        self.thisAttrs.insert(.leading)
        return self
    }
    var trailing:RedLine {
        self.thisAttrs.insert(.trailing)
        return self
    }
    var top:RedLine {
        self.thisAttrs.insert(.top)
        return self
    }
    var bottom:RedLine {
        self.thisAttrs.insert(.bottom)
        return self
    }
    var width:RedLine {
        self.thisAttrs.insert(.width)
        return self
    }
    var height:RedLine {
        self.thisAttrs.insert(.height)
        return self
    }
    var left:RedLine {
        self.thisAttrs.insert(.left)
        return self
    }
    var right:RedLine {
        self.thisAttrs.insert(.right)
        return self
    }
    var leftMargin:RedLine {
        self.thisAttrs.insert(.leftMargin)
        return self
    }
    var rightMargin:RedLine {
        self.thisAttrs.insert(.rightMargin)
        return self
    }
    var topMargin:RedLine {
        self.thisAttrs.insert(.topMargin)
        return self
    }
    var bottomMargin:RedLine {
        self.thisAttrs.insert(.bottomMargin)
        return self
    }
    var centerXWithinMargins:RedLine {
        self.thisAttrs.insert(.centerXWithinMargins)
        return self
    }
    var centerYWithinMargins:RedLine {
        self.thisAttrs.insert(.centerYWithinMargins)
        return self
    }
    var firstBaseline:RedLine {
        self.thisAttrs.insert(.firstBaseline)
        return self
    }
    var lastBaseline:RedLine {
        self.thisAttrs.insert(.lastBaseline)
        return self
    }
}
extension NSLayoutConstraint {
    static func ^ (lhs:NSLayoutConstraint, rhs:Float) {
        lhs.priority = .init(rawValue: rhs)
    }
    static func ^ (lhs:NSLayoutConstraint, rhs:Int) {
        lhs ^ Float(rhs)
    }
}
extension Array where Element == NSLayoutConstraint {
    static func ^ (lhs:[NSLayoutConstraint], rhs:Float) {
        lhs.forEach {
            $0.priority = .init(rawValue: rhs)
        }
    }
    static func ^ (lhs:[NSLayoutConstraint], rhs:Int) {
        lhs ^ Float(rhs)
    }
}

#endif
