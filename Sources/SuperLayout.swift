//
//  SuperLayout.swift
//  Pods
//
//  Created by Daniel Loewenherz on 1/13/17.
//
//

import UIKit

precedencegroup ConstraintPrecedence {
    lowerThan: AdditionPrecedence
    higherThan: AssignmentPrecedence
    associativity: left
    assignment: false
}

infix operator ~~: ConstraintPrecedence
infix operator ≥≥: ConstraintPrecedence
infix operator ≤≤: ConstraintPrecedence

public protocol Anchoring {
    associatedtype AnchorType

    var multiplier: CGFloat { get }
    var constant: CGFloat { get }
    var anchor: AnchorType { get }
}

public protocol AxisAnchoring: Anchoring {
    func constraint(equalTo: AnchorType, constant: CGFloat) -> NSLayoutConstraint
    func constraint(lessThanOrEqualTo: AnchorType, constant: CGFloat) -> NSLayoutConstraint
    func constraint(greaterThanOrEqualTo: AnchorType, constant: CGFloat) -> NSLayoutConstraint
}

public protocol DimensionAnchoring: Anchoring {
    func constraint(equalToConstant: CGFloat) -> NSLayoutConstraint
    func constraint(lessThanOrEqualToConstant: CGFloat) -> NSLayoutConstraint
    func constraint(greaterThanOrEqualToConstant: CGFloat) -> NSLayoutConstraint

    func constraint(equalTo: AnchorType, multiplier: CGFloat, constant: CGFloat) -> NSLayoutConstraint
    func constraint(lessThanOrEqualTo: AnchorType, multiplier: CGFloat, constant: CGFloat) -> NSLayoutConstraint
    func constraint(greaterThanOrEqualTo: AnchorType, multiplier: CGFloat, constant: CGFloat) -> NSLayoutConstraint
}

public struct LayoutContainer<U>: Anchoring {
    public typealias AnchorType = U

    public var multiplier: CGFloat
    public var constant: CGFloat
    public var anchor: AnchorType

    init<T: Anchoring>(anchor: T, constant: CGFloat) where T.AnchorType == AnchorType {
        self.constant = constant
        self.multiplier = anchor.multiplier
        self.anchor = anchor.anchor
    }

    init<T: DimensionAnchoring>(anchor: T, multiplier: CGFloat) where T.AnchorType == AnchorType {
        self.constant = anchor.constant
        self.multiplier = multiplier
        self.anchor = anchor.anchor
    }

    static func +(lhs: LayoutContainer<AnchorType>, rhs: CGFloat) -> LayoutContainer {
        return LayoutContainer(anchor: lhs, constant: rhs)
    }

    static func -(lhs: LayoutContainer<AnchorType>, rhs: CGFloat) -> LayoutContainer {
        return LayoutContainer(anchor: lhs, constant: -rhs)
    }
}

extension NSLayoutYAxisAnchor: AxisAnchoring {
    public typealias AnchorType = NSLayoutAnchor<NSLayoutYAxisAnchor>

    public var multiplier: CGFloat { return 1 }
    public var constant: CGFloat { return 0 }
    public var anchor: AnchorType { return self }
}

extension NSLayoutXAxisAnchor: AxisAnchoring {
    public typealias AnchorType = NSLayoutAnchor<NSLayoutXAxisAnchor>

    public var multiplier: CGFloat { return 1 }
    public var constant: CGFloat { return 0 }
    public var anchor: AnchorType { return self }
}

extension NSLayoutDimension: DimensionAnchoring {
    public typealias AnchorType = NSLayoutDimension

    public var multiplier: CGFloat { return 1 }
    public var constant: CGFloat { return 0 }
    public var anchor: AnchorType { return self }
}

public extension DimensionAnchoring {
    /// Returns a constraint that defines the anchor’s size attribute as equal to the specified size attribute multiplied by a constant plus an offset.
    ///
    /// - Parameters:
    ///   - lhs: A dimension anchor from a `UIView`, `NSView`, or `UILayoutGuide` object.
    ///   - rhs: See `lhs`.
    /// - Returns: An `NSLayoutConstraint` object that defines the attribute represented by this layout anchor as equal to the attribute represented by the anchor parameter multiplied by an optional m constant plus an optional constant c.
    @discardableResult
    static func ~~<T: Anchoring>(lhs: Self, rhs: T) -> NSLayoutConstraint where T.AnchorType == AnchorType {
        let constraint = lhs.constraint(equalTo: rhs.anchor, multiplier: rhs.multiplier, constant: rhs.constant)
        constraint.isActive = true
        return constraint
    }

    /// Returns a constraint that defines the anchor’s size attribute as greater than or equal to the specified anchor multiplied by the constant plus an offset.
    ///
    /// - Parameters:
    ///   - lhs: A dimension anchor from a `UIView`, `NSView`, or `UILayoutGuide` object.
    ///   - rhs: See `lhs`.
    /// - Returns: An `NSLayoutConstraint` object that defines the attribute represented by this layout anchor as less than or equal to the attribute represented by the anchor parameter multiplied by an optional m constant plus an optional constant c.
    @discardableResult
    static func ≤≤<T: Anchoring>(lhs: Self, rhs: T) -> NSLayoutConstraint where T.AnchorType == AnchorType {
        let constraint = lhs.constraint(lessThanOrEqualTo: rhs.anchor, multiplier: rhs.multiplier, constant: rhs.constant)
        constraint.isActive = true
        return constraint
    }

    /// Returns a constraint that defines the anchor’s size attribute as greater than or equal to the specified anchor multiplied by the constant plus an offset.
    ///
    /// - Parameters:
    ///   - lhs: A dimension anchor from a `UIView`, `NSView`, or `UILayoutGuide` object.
    ///   - rhs: See `lhs`.
    /// - Returns: An NSLayoutConstraint object that defines the attribute represented by this layout anchor as greater than or equal to the attribute represented by the anchor parameter multiplied by an optional m constant plus an optional constant c.
    @discardableResult
    static func ≥≥<T: Anchoring>(lhs: Self, rhs: T) -> NSLayoutConstraint where T.AnchorType == AnchorType {
        let constraint = lhs.constraint(greaterThanOrEqualTo: rhs.anchor, multiplier: rhs.multiplier, constant: rhs.constant)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    static func ~~(lhs: Self, rhs: CGFloat) -> NSLayoutConstraint {
        let constraint = lhs.constraint(equalToConstant: rhs)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    static func ≤≤(lhs: Self, rhs: CGFloat) -> NSLayoutConstraint {
        let constraint = lhs.constraint(lessThanOrEqualToConstant: rhs)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    static func ≥≥(lhs: Self, rhs: CGFloat) -> NSLayoutConstraint {
        let constraint = lhs.constraint(greaterThanOrEqualToConstant: rhs)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    static func *(lhs: Self, rhs: CGFloat) -> LayoutContainer<AnchorType> {
        return LayoutContainer(anchor: lhs, multiplier: rhs)
    }
}

public extension AxisAnchoring {
    /// Returns a constraint that defines one item’s attribute as equal to another item’s attribute plus an optional constant offset.
    ///
    /// - Parameters:
    ///   - lhs: A layout anchor from a `UIView`, `NSView`, or `UILayoutGuide` object. You must use a subclass of NSLayoutAnchor that matches the current anchor. For example, if you call this method on an `NSLayoutXAxisAnchor` object, this parameter must be another `NSLayoutXAxisAnchor`.
    ///   - rhs: See `lhs`.
    /// - Returns: An `NSLayoutConstraint` object that defines an equal relationship between the attributes represented by the two layout anchors plus a constant offset.
    @discardableResult
    static func ~~<T: Anchoring>(lhs: Self, rhs: T) -> NSLayoutConstraint where T.AnchorType == AnchorType {
        let constraint = lhs.constraint(equalTo: rhs.anchor, constant: rhs.constant)
        constraint.isActive = true
        return constraint
    }

    /// Returns a constraint that defines one item’s attribute as less than or equal to another item’s attribute plus an optional constant offset.
    ///
    /// - Parameters:
    ///   - lhs: A layout anchor from a `UIView`, `NSView`, or `UILayoutGuide` object. You must use a subclass of NSLayoutAnchor that matches the current anchor. For example, if you call this method on an `NSLayoutXAxisAnchor` object, this parameter must be another `NSLayoutXAxisAnchor`.
    ///   - rhs: See `lhs`.
    /// - Returns: An `NSLayoutConstraint` object that defines the attribute represented by this layout anchor as less than or equal to the attribute represented by the anchor parameter plus a constant offset.
    @discardableResult
    static func ≤≤<T: Anchoring>(lhs: Self, rhs: T) -> NSLayoutConstraint where T.AnchorType == AnchorType {
        let constraint = lhs.constraint(lessThanOrEqualTo: rhs.anchor, constant: rhs.constant)
        constraint.isActive = true
        return constraint
    }

    /// Returns a constraint that defines one item’s attribute as greater than or equal to another item’s attribute plus a constant offset.
    ///
    /// - Parameters:
    ///   - lhs: A layout anchor from a `UIView`, `NSView`, or `UILayoutGuide` object. You must use a subclass of NSLayoutAnchor that matches the current anchor. For example, if you call this method on an `NSLayoutXAxisAnchor` object, this parameter must be another `NSLayoutXAxisAnchor`.
    ///   - rhs: See `lhs`.
    /// - Returns: An `NSLayoutConstraint` object that defines the attribute represented by this layout anchor as greater than or equal to the attribute represented by the anchor parameter plus a constant offset.
    @discardableResult
    static func ≥≥<T: Anchoring>(lhs: Self, rhs: T) -> NSLayoutConstraint where T.AnchorType == AnchorType {
        let constraint = lhs.constraint(greaterThanOrEqualTo: rhs.anchor, constant: rhs.constant)
        constraint.isActive = true
        return constraint
    }

    static func +(lhs: Self, rhs: CGFloat) -> LayoutContainer<AnchorType> {
        return LayoutContainer(anchor: lhs, constant: rhs)
    }

    static func -(lhs: Self, rhs: CGFloat) -> LayoutContainer<AnchorType> {
        return LayoutContainer(anchor: lhs, constant: -rhs)
    }
}
