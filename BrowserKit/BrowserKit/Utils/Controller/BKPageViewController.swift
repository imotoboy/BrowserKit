//
//  BKPageViewController.swift
//  BrowserKit
//
//  Created by tramp on 2021/5/28.
//

import Foundation
import UIKit

/// BKPageViewControllerDelegate
protocol BKPageViewControllerDelegate: NSObjectProtocol {
    // Sent when a gesture-initiated transition begins.
    @available(iOS 6.0, *)
    func pageViewController(_ pageViewController: BKPageViewController, willTransitionTo pendingViewControllers: [UIViewController])
    
    // Sent when a gesture-initiated transition ends. The 'finished' parameter indicates whether the animation finished, while the 'completed' parameter indicates whether the transition completed or bailed out (if the user let go early).
    @available(iOS 5.0, *)
    func pageViewController(_ pageViewController: BKPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool)
    
    // Delegate may specify a different spine location for after the interface orientation change. Only sent for transition style 'UIPageViewControllerTransitionStylePageCurl'.
    // Delegate may set new view controllers or update double-sided state within this method's implementation as well.
    @available(iOS 5.0, *)
    func pageViewController(_ pageViewController: BKPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> BKPageViewController.SpineLocation
    
    @available(iOS 7.0, *)
    func pageViewControllerSupportedInterfaceOrientations(_ pageViewController: BKPageViewController) -> UIInterfaceOrientationMask
    
    @available(iOS 7.0, *)
    func pageViewControllerPreferredInterfaceOrientationForPresentation(_ pageViewController: BKPageViewController) -> UIInterfaceOrientation
    
}

extension BKPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: BKPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {}
    func pageViewController(_ pageViewController: BKPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {}
    func pageViewController(_ pageViewController: BKPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> BKPageViewController.SpineLocation {
        return pageViewController.transitionStyle == .pageCurl ? .min : .none
    }
    func pageViewControllerSupportedInterfaceOrientations(_ pageViewController: BKPageViewController) -> UIInterfaceOrientationMask {
        return .all
    }
    func pageViewControllerPreferredInterfaceOrientationForPresentation(_ pageViewController: BKPageViewController) -> UIInterfaceOrientation {
        return .portrait
    }
}

/// BKPageViewControllerDataSource
protocol BKPageViewControllerDataSource: NSObjectProtocol {
    
    // In terms of navigation direction. For example, for 'UIPageViewControllerNavigationOrientationHorizontal', view controllers coming 'before' would be to the left of the argument view controller, those coming 'after' would be to the right.
    // Return 'nil' to indicate that no more progress can be made in the given direction.
    // For gesture-initiated transitions, the page view controller obtains view controllers via these methods, so use of setViewControllers:direction:animated:completion: is not required.
    @available(iOS 5.0, *)
    func pageViewController(_ pageViewController: BKPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    
    @available(iOS 5.0, *)
    func pageViewController(_ pageViewController: BKPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    
    
    // A page indicator will be visible if both methods are implemented, transition style is 'UIPageViewControllerTransitionStyleScroll', and navigation orientation is 'UIPageViewControllerNavigationOrientationHorizontal'.
    // Both methods are called in response to a 'setViewControllers:...' call, but the presentation index is updated automatically in the case of gesture-driven navigation.
    @available(iOS 6.0, *)
    func presentationCount(for pageViewController: BKPageViewController) -> Int // The number of items reflected in the page indicator.
    
    @available(iOS 6.0, *)
    func presentationIndex(for pageViewController: BKPageViewController) -> Int // The selected item reflected in the page indicator.
}

extension BKPageViewControllerDataSource {
    
    internal func presentationCount(for pageViewController: BKPageViewController) -> Int { return 0 }
    internal func presentationIndex(for pageViewController: BKPageViewController) -> Int { return 0 }
}

/// BKPageViewController
class BKPageViewController: UIViewController {
    typealias TransitionStyle = UIPageViewController.TransitionStyle
    typealias NavigationOrientation = UIPageViewController.NavigationOrientation
    typealias OptionsKey = UIPageViewController.OptionsKey
    typealias SpineLocation = UIPageViewController.SpineLocation
    
    // MARK: - 公开属性
    
    /// BKPageViewControllerDelegate
    internal weak var delegate: BKPageViewControllerDelegate?
    /// BKPageViewControllerDataSource
    internal weak var dataSource: BKPageViewControllerDataSource? // If nil, user gesture-driven navigation will be disabled.
    /// TransitionStyle
    internal var transitionStyle: TransitionStyle {
        return pageViewController?.transitionStyle ?? .pageCurl
    }
    /// NavigationOrientation
    internal var navigationOrientation: NavigationOrientation {
        return pageViewController?.navigationOrientation ?? .horizontal
    }
    /// SpineLocation // If transition style is 'UIPageViewControllerTransitionStylePageCurl', default is 'UIPageViewControllerSpineLocationMin', otherwise 'UIPageViewControllerSpineLocationNone'.
    internal var spineLocation: SpineLocation {
        return pageViewController?.spineLocation ?? .min
    }
    // Whether client content appears on both sides of each page. If 'NO', content on page front will partially show through back.
    // If 'UIPageViewControllerSpineLocationMid' is set, 'doubleSided' is set to 'YES'. Setting 'NO' when spine location is mid results in an exception.
    // Default is 'NO'.
    internal var isDoubleSided: Bool {
        get { pageViewController?.isDoubleSided ?? false }
        set { pageViewController?.isDoubleSided = newValue }
    }
    
    // An array of UIGestureRecognizers pre-configured to handle user interaction. Initially attached to a view in the UIPageViewController's hierarchy, they can be placed on an arbitrary view to change the region in which the page view controller will respond to user gestures.
    // Only populated if transition style is 'UIPageViewControllerTransitionStylePageCurl'.
    internal var gestureRecognizers: [UIGestureRecognizer] {
        return pageViewController?.gestureRecognizers ?? []
    }
    /// [UIViewController]?
    internal var viewControllers: [UIViewController]? {
        return pageViewController?.viewControllers
    }
    /// [OptionsKey : Any]?
    internal private(set) var options: [OptionsKey : Any]?
    
    // MARK: - 私有属性
    
    /// UIPageViewController?
    private var pageViewController: UIPageViewController? {
        return children.first as? UIPageViewController
    }
    
    // MARK: - 生命周期
    
    /// 构建
    /// - Parameters:
    ///   - style: TransitionStyle
    ///   - navigationOrientation: NavigationOrientation
    ///   - options: [OptionsKey : Any]?
    internal init(transitionStyle style: TransitionStyle, navigationOrientation: NavigationOrientation, options: [OptionsKey : Any]? = nil) {
        self.options = options
        super.init(nibName: nil, bundle: nil)
        let controller: UIPageViewController = .init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
        controller.delegate = self
        controller.dataSource = self
        addChild(controller)
    }
    
    /// 构建
    /// - Parameter coder: NSCoder
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// viewDidLoad
    internal override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化
        initialze()
    }
    
}

// MARK: - 自定义
extension BKPageViewController {
    
    /// 初始化
    private func initialze() {
        // coding here ...
        
        // 布局
        if let controller = pageViewController {
            controller.view.frame = view.bounds
            view.addSubview(controller.view)
        }
    }
    
    /// change
    /// - Parameters:
    ///   - style: TransitionStyle
    ///   - navigationOrientation: NavigationOrientation
    ///   - options: [OptionsKey : Any]
    internal func change(transitionStyle style: TransitionStyle, navigationOrientation: NavigationOrientation, options: [OptionsKey : Any]? = nil) {
        guard let before = pageViewController else { return }
        let after: UIPageViewController = .init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
        after.delegate = self
        after.dataSource = self
        self.options = options
        addChild(after)
        after.view.frame = view.bounds
        view.addSubview(after.view)
        UIView.transition(from: before.view, to: after.view, duration: 0.25, options: .showHideTransitionViews) { _ in
            before.view.removeFromSuperview()
            before.removeFromParent()
        }
    }
}

// MARK: - UIPageViewControllerDelegate
extension BKPageViewController: UIPageViewControllerDelegate {
    
    /// willTransitionTo
    /// - Parameters:
    ///   - pageViewController: UIPageViewController
    ///   - pendingViewControllers: [UIViewController]
    internal func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        delegate?.pageViewController(self, willTransitionTo: pendingViewControllers)
    }
    
    /// didFinishAnimating
    /// - Parameters:
    ///   - pageViewController: UIPageViewController
    ///   - finished: Bool
    ///   - previousViewControllers: [UIViewController]
    ///   - completed: Bool
    internal func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        delegate?.pageViewController(self, didFinishAnimating: finished, previousViewControllers: previousViewControllers, transitionCompleted: completed)
    }
    
    /// spineLocationFor
    /// - Parameters:
    ///   - pageViewController: UIPageViewController
    ///   - orientation: UIInterfaceOrientation
    /// - Returns: UIPageViewController.SpineLocation
    internal func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewController.SpineLocation {
        return delegate?.pageViewController(self, spineLocationFor: orientation) ?? .min
    }
    
    /// pageViewControllerSupportedInterfaceOrientations
    /// - Parameter pageViewController: UIPageViewController
    /// - Returns: UIInterfaceOrientationMask
    internal func pageViewControllerSupportedInterfaceOrientations(_ pageViewController: UIPageViewController) -> UIInterfaceOrientationMask {
        return delegate?.pageViewControllerSupportedInterfaceOrientations(self) ?? .all
    }
    
    /// pageViewControllerPreferredInterfaceOrientationForPresentation
    /// - Parameter pageViewController: UIPageViewController
    /// - Returns: UIInterfaceOrientation
    internal func pageViewControllerPreferredInterfaceOrientationForPresentation(_ pageViewController: UIPageViewController) -> UIInterfaceOrientation {
        return delegate?.pageViewControllerPreferredInterfaceOrientationForPresentation(self) ?? .portrait
    }
}

// MARK: - UIPageViewControllerDataSource
extension BKPageViewController: UIPageViewControllerDataSource {
    
    /// viewControllerBefore
    /// - Parameters:
    ///   - pageViewController: UIPageViewController
    ///   - viewController: UIViewController
    /// - Returns: UIViewController
    internal func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return dataSource?.pageViewController(self, viewControllerBefore: viewController)
    }
    
    /// viewControllerAfter
    /// - Parameters:
    ///   - pageViewController: UIPageViewController
    ///   - viewController: UIViewController
    /// - Returns: UIViewController
    internal func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return dataSource?.pageViewController(self, viewControllerAfter: viewController)
    }
    
    /// presentationCount
    /// - Parameter pageViewController: UIPageViewController
    /// - Returns: Int
    internal func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return dataSource?.presentationCount(for: self) ?? 0
    }
    
    /// presentationIndex
    /// - Parameter pageViewController: UIPageViewController
    /// - Returns: Int
    internal func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return dataSource?.presentationIndex(for: self) ?? 0
    }
}
