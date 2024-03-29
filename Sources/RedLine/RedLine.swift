//
//  RedLine.swift
//  RedLine
//
//  Created by kin on 2022/08/04.
//

import Foundation
import UIKit
precedencegroup PriorityPrecedence {
    associativity: left
    lowerThan: AdditionPrecedence
}

infix operator ^ : PriorityPrecedence
public typealias RedlineBlock = (RedLine) -> ()
extension UIView {
    public var rl:RedLine {
        return .init(this: self)
    }
    public var allConstraints:[NSLayoutConstraint] {
        var views = [self]

        var view = self
        while let superview = view.superview {
            views.append(superview)
            view = superview
        }
        return views.flatMap({ $0.constraints }).filter { constraint in
            return constraint.firstItem as? UIView == self ||
                constraint.secondItem as? UIView == self
        }
    }
    public func addSubview(_ view: UIView, redlineBlock:RedlineBlock) {
        addSubview(view)
        view.rl.do(redlineBlock: redlineBlock)
    }
    public func insertSubview(
        _ view: UIView,
        at index: Int,
        redlineBlock:RedlineBlock
    ) {
        insertSubview(view, at: index)
        view.rl.do(redlineBlock: redlineBlock)
    }
    public func insertSubview(
        _ view: UIView,
        aboveSubview siblingSubview: UIView,
        redlineBlock:RedlineBlock
    ) {
        view.insertSubview(view, aboveSubview: siblingSubview)
        view.rl.do(redlineBlock: redlineBlock)
    }
    public func insertSubview(
        _ view: UIView,
        belowSubview siblingSubview: UIView,
        redlineBlock:RedlineBlock
    ) {
        view.insertSubview(view, belowSubview: siblingSubview)
        view.rl.do(redlineBlock: redlineBlock)
    }
}
extension UILayoutGuide {
    public var rl:RedLine {
        return .init(this: self)
    }
}
public class RedLine  {
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
            DispatchQueue.main.async {
                layout.isActive = true
            }
            list.append(layout)
        }
        
        return list
    }
    
    public func `do`(redlineBlock:RedlineBlock) {
        redlineBlock(self)
    }
    public func doWithAnimate(duration:Double,parentView:UIView, _ closer:@escaping(RedLine) -> (),completion:((Bool)->Void)?) {
        UIView.animate(withDuration: duration, animations: {
            closer(self)
            parentView.layoutIfNeeded()
        }, completion: completion)
    }
    public func clear() {
        guard let this = self.this as? UIView else {
            return
        }
        this.allConstraints.forEach {
            $0.isActive = false
        }
    }
    
    @discardableResult
    public static func ==(lhs:RedLine, rhs:RedLine) -> [NSLayoutConstraint] {
        lhs.other = rhs.this
        lhs.otherAttr = rhs.thisAttrs
        lhs.relatedBy = .equal
        lhs.multiplier = rhs.multiplier ?? lhs.multiplier
        lhs.priority = rhs.priority ?? rhs.priority
        lhs.constant = rhs.constant
        return lhs.active()
    }
    @discardableResult
    public static func ==(lhs:RedLine, rhs:CGFloat) -> [NSLayoutConstraint] {
        lhs.relatedBy = .equal
        lhs.constant = rhs
        lhs.other = nil
        return lhs.active()
    }
    @discardableResult
    public static func >=(lhs:RedLine, rhs:RedLine) -> [NSLayoutConstraint] {
        lhs.other = rhs.this
        lhs.otherAttr = rhs.thisAttrs
        lhs.relatedBy = .greaterThanOrEqual
        lhs.multiplier = rhs.multiplier ?? lhs.multiplier
        lhs.priority = rhs.priority ?? rhs.priority
        lhs.constant = rhs.constant
        return lhs.active()
    }
    @discardableResult
    public static func >=(lhs:RedLine, rhs:CGFloat) -> [NSLayoutConstraint] {
        lhs.relatedBy = .greaterThanOrEqual
        lhs.constant = rhs
        lhs.other = nil
        return lhs.active()
    }
    @discardableResult
    public static func <=(lhs:RedLine, rhs:RedLine) -> [NSLayoutConstraint] {
        lhs.other = rhs.this
        lhs.otherAttr = rhs.thisAttrs
        lhs.relatedBy = .lessThanOrEqual
        lhs.multiplier = rhs.multiplier ?? lhs.multiplier
        lhs.priority = rhs.priority ?? rhs.priority
        lhs.constant = rhs.constant
        return lhs.active()
    }
    @discardableResult
    public static func <=(lhs:RedLine, rhs:CGFloat) -> [NSLayoutConstraint] {
        lhs.relatedBy = .lessThanOrEqual
        lhs.constant = rhs
        lhs.other = nil
        return lhs.active()
    }
    public static func * (lhs:CGFloat,rhs:RedLine) -> RedLine {
        rhs.multiplier = lhs
        return rhs
    }
    public static func * (lhs:RedLine, rhs:CGFloat) -> RedLine {
        lhs.multiplier = rhs
        return lhs
    }
    public static func + (lhs:RedLine, rhs:CGFloat) -> RedLine {
        lhs.constant = rhs
        return lhs
    }
    public static func + (lhs:CGFloat, rhs:RedLine) -> RedLine {
        rhs.constant = lhs
        return rhs
    }
    public static func - (lhs:RedLine, rhs:CGFloat) -> RedLine {
        lhs.constant = -rhs
        return lhs
    }
    public static func - (lhs:CGFloat, rhs:RedLine) -> RedLine {
        rhs.constant = -lhs
        return rhs
    }
    public static func ^ (lhs:RedLine, rhs:Float) -> RedLine {
        lhs.priority = rhs
        return lhs
    }
}

extension RedLine {
    @discardableResult
    public func equal(_ to:RedLine) -> [NSLayoutConstraint] {
        return self == to
    }
    @discardableResult
    public func greaterThanOrEqual(_ to:RedLine) -> [NSLayoutConstraint] {
        return self >= to
    }
    @discardableResult
    public func lessThenOrEqual(_ to:RedLine) -> [NSLayoutConstraint] {
        return self <= to
    }
    @discardableResult
    public func setPriority(_ value:Float) -> RedLine {
        return self ^ value
    }
}

extension RedLine {
    //MARK: - typecasting
    @discardableResult
    public static func ==(lhs:RedLine, rhs:RedlineAnchor) -> [NSLayoutConstraint] {
        let rLine:RedLine = .init(this: rhs)
        return (lhs == rLine)
    }
    @discardableResult
    public static func ==(lhs:RedLine, rhs:Double) -> [NSLayoutConstraint] {
        return (lhs == CGFloat(rhs))
    }
    @discardableResult
    public static func ==(lhs:RedLine, rhs:Int) -> [NSLayoutConstraint] {
        return (lhs == CGFloat(rhs))
    }
    @discardableResult
    public static func >=(lhs:RedLine, rhs:RedlineAnchor) -> [NSLayoutConstraint] {
        let rLine:RedLine = .init(this: rhs)
        return (lhs >= rLine)
    }
    @discardableResult
    public static func >=(lhs:RedLine, rhs:Int) -> [NSLayoutConstraint] {
        return (lhs >= CGFloat(rhs))
    }
    @discardableResult
    public static func >=(lhs:RedLine, rhs:Double) -> [NSLayoutConstraint] {
        return (lhs >= CGFloat(rhs))
    }
    @discardableResult
    public static func <=(lhs:RedLine, rhs:RedlineAnchor) -> [NSLayoutConstraint] {
        let rLine:RedLine = .init(this: rhs)
        return (lhs <= rLine)
    }
    @discardableResult
    public static func <=(lhs:RedLine, rhs:Int) -> [NSLayoutConstraint] {
        return (lhs <= CGFloat(rhs))
    }
    @discardableResult
    public static func <=(lhs:RedLine, rhs:Double) -> [NSLayoutConstraint] {
        return (lhs <= CGFloat(rhs))
    }
    @discardableResult
    public func equal(_ to:RedlineAnchor) -> [NSLayoutConstraint] {
        return self == to
    }
    @discardableResult
    public func greaterThanOrEqual(_ to:RedlineAnchor) -> [NSLayoutConstraint] {
        return self >= to
    }
    @discardableResult
    public func lessThenOrEqual(_ to:RedlineAnchor) -> [NSLayoutConstraint] {
        return self <= to
    }
    public static func ^ (lhs:RedLine, rhs:Int) -> RedLine {
        return lhs ^ Float(rhs)
    }
}

extension RedLine {
    public var centerX:RedLine {
        self.thisAttrs.insert(.centerX)
        return self
    }
    public var centerY:RedLine {
        self.thisAttrs.insert(.centerY)
        return self
    }
    public var leading:RedLine {
        self.thisAttrs.insert(.leading)
        return self
    }
    public var trailing:RedLine {
        self.thisAttrs.insert(.trailing)
        return self
    }
    public var top:RedLine {
        self.thisAttrs.insert(.top)
        return self
    }
    public var bottom:RedLine {
        self.thisAttrs.insert(.bottom)
        return self
    }
    public var width:RedLine {
        self.thisAttrs.insert(.width)
        return self
    }
    public var height:RedLine {
        self.thisAttrs.insert(.height)
        return self
    }
    public var left:RedLine {
        self.thisAttrs.insert(.left)
        return self
    }
    public var right:RedLine {
        self.thisAttrs.insert(.right)
        return self
    }
    public var leftMargin:RedLine {
        self.thisAttrs.insert(.leftMargin)
        return self
    }
    public var rightMargin:RedLine {
        self.thisAttrs.insert(.rightMargin)
        return self
    }
    public var topMargin:RedLine {
        self.thisAttrs.insert(.topMargin)
        return self
    }
    public var bottomMargin:RedLine {
        self.thisAttrs.insert(.bottomMargin)
        return self
    }
    public var centerXWithinMargins:RedLine {
        self.thisAttrs.insert(.centerXWithinMargins)
        return self
    }
    public var centerYWithinMargins:RedLine {
        self.thisAttrs.insert(.centerYWithinMargins)
        return self
    }
    public var firstBaseline:RedLine {
        self.thisAttrs.insert(.firstBaseline)
        return self
    }
    public var lastBaseline:RedLine {
        self.thisAttrs.insert(.lastBaseline)
        return self
    }
    public var edge:RedLine {
        return self.top.leading.trailing.bottom
    }
}
extension NSLayoutConstraint {
    public static func ^ (lhs:NSLayoutConstraint, rhs:Float) {
        lhs.priority = .init(rawValue: rhs)
    }
    public static func ^ (lhs:NSLayoutConstraint, rhs:Int) {
        lhs ^ Float(rhs)
    }
}
extension Array where Element == NSLayoutConstraint {
    public static func ^ (lhs:[NSLayoutConstraint], rhs:Float) {
        lhs.forEach {
            $0.priority = .init(rawValue: rhs)
        }
    }
    public static func ^ (lhs:[NSLayoutConstraint], rhs:Int) {
        lhs ^ Float(rhs)
    }
}
public protocol RedlineAnchor {
    
}
extension UIView : RedlineAnchor{}
extension CALayer : RedlineAnchor{}
