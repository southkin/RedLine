//
//  RedLine.swift
//  RedLine
//
//  Created by kin on 2022/08/04.
//

import Foundation
import UIKit
class RedLine  {
    fileprivate var this:Any
    fileprivate var thisAttr:NSLayoutConstraint.Attribute?
    fileprivate var other:Any?
    fileprivate var otherAttr:NSLayoutConstraint.Attribute?
    fileprivate var relatedBy:NSLayoutConstraint.Relation!
    fileprivate var multiplier:CGFloat?
    fileprivate var constant:CGFloat = 0
    init(this:Any) {
        self.this = this
    }
    @discardableResult
    func active() -> NSLayoutConstraint? {
        guard let thisAttr = thisAttr else {
            return nil
        }
        let layout = NSLayoutConstraint(item: this, attribute: thisAttr, relatedBy: relatedBy, toItem: other, attribute: otherAttr ?? thisAttr, multiplier: multiplier ?? 1, constant: constant)
        layout.isActive = true
        return layout
    }
    
    @discardableResult
    func equal(_ to:RedLine) -> NSLayoutConstraint? {
        return self == to
    }
    @discardableResult
    func greaterThanOrEqual(_ to:RedLine) -> NSLayoutConstraint? {
        return self >= to
    }
    @discardableResult
    func lessThenOrEqual(_ to:RedLine) -> NSLayoutConstraint? {
        return self <= to
    }
}

extension RedLine {
    @discardableResult
    static func ==(lhs:RedLine, rhs:RedLine) -> NSLayoutConstraint? {
        lhs.other = rhs.this
        lhs.otherAttr = rhs.thisAttr
        lhs.relatedBy = .equal
        lhs.multiplier = rhs.multiplier ?? lhs.multiplier
        return lhs.active()
    }
    @discardableResult
    static func ==(lhs:RedLine, rhs:Double) -> NSLayoutConstraint? {
        return (lhs == CGFloat(rhs))
    }
    @discardableResult
    static func ==(lhs:RedLine, rhs:Int) -> NSLayoutConstraint? {
        return (lhs == CGFloat(rhs))
    }
    @discardableResult
    static func ==(lhs:RedLine, rhs:CGFloat) -> NSLayoutConstraint? {
        lhs.relatedBy = .equal
        lhs.constant = rhs
        return lhs.active()
    }
    @discardableResult
    static func >=(lhs:RedLine, rhs:RedLine) -> NSLayoutConstraint? {
        lhs.other = rhs.this
        lhs.otherAttr = rhs.thisAttr
        lhs.relatedBy = .greaterThanOrEqual
        lhs.multiplier = rhs.multiplier ?? lhs.multiplier
        return lhs.active()
    }
    @discardableResult
    static func >=(lhs:RedLine, rhs:Int) -> NSLayoutConstraint? {
        return (lhs >= CGFloat(rhs))
    }
    @discardableResult
    static func >=(lhs:RedLine, rhs:Double) -> NSLayoutConstraint? {
        return (lhs >= CGFloat(rhs))
    }
    @discardableResult
    static func >=(lhs:RedLine, rhs:CGFloat) -> NSLayoutConstraint? {
        lhs.relatedBy = .greaterThanOrEqual
        lhs.constant = rhs
        return lhs.active()
    }
    @discardableResult
    static func <=(lhs:RedLine, rhs:RedLine) -> NSLayoutConstraint? {
        lhs.other = rhs.this
        lhs.otherAttr = rhs.thisAttr
        lhs.relatedBy = .lessThanOrEqual
        lhs.multiplier = rhs.multiplier ?? lhs.multiplier
        return lhs.active()
    }
    @discardableResult
    static func <=(lhs:RedLine, rhs:Int) -> NSLayoutConstraint? {
        return (lhs <= CGFloat(rhs))
    }
    @discardableResult
    static func <=(lhs:RedLine, rhs:Double) -> NSLayoutConstraint? {
        return (lhs <= CGFloat(rhs))
    }
    @discardableResult
    static func <=(lhs:RedLine, rhs:CGFloat) -> NSLayoutConstraint? {
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
}
extension UIView {
    var rl:RedLine {
        return .init(this: self)
    }
}

extension RedLine {
    var centerX:RedLine {
        self.thisAttr = .centerX
        return self
    }
    var centerY:RedLine {
        self.thisAttr = .centerY
        return self
    }
    var leading:RedLine {
        self.thisAttr = .leading
        return self
    }
    var trailing:RedLine {
        self.thisAttr = .trailing
        return self
    }
    var top:RedLine {
        self.thisAttr = .top
        return self
    }
    var bottom:RedLine {
        self.thisAttr = .bottom
        return self
    }
    var width:RedLine {
        self.thisAttr = .width
        return self
    }
    var height:RedLine {
        self.thisAttr = .height
        return self
    }
    var left:RedLine {
        self.thisAttr = .left
        return self
    }
    var right:RedLine {
        self.thisAttr = .right
        return self
    }
    var leftMargin:RedLine {
        self.thisAttr = .leftMargin
        return self
    }
    var rightMargin:RedLine {
        self.thisAttr = .rightMargin
        return self
    }
    var topMargin:RedLine {
        self.thisAttr = .topMargin
        return self
    }
    var bottomMargin:RedLine {
        self.thisAttr = .bottomMargin
        return self
    }
    var centerXWithinMargins:RedLine {
        self.thisAttr = .centerXWithinMargins
        return self
    }
    var centerYWithinMargins:RedLine {
        self.thisAttr = .centerYWithinMargins
        return self
    }
    var firstBaseline:RedLine {
        self.thisAttr = .firstBaseline
        return self
    }
    var lastBaseline:RedLine {
        self.thisAttr = .lastBaseline
        return self
    }
}
