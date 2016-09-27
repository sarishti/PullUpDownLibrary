//
//  ICSPullToRefresh.swift
//  ICSPullToRefresh
//
//  Created by LEI on 3/15/15.
//  Copyright (c) 2015 TouchingAPP. All rights reserved.
//

import UIKit

private var pullToRefreshViewKey: Void?
/// Observer keys
private let observeKeyContentOffset = "contentOffset"
private let observeKeyFrame = "frame"
/// Default  Height of PUll to refresh View
private let ICSPullToRefreshViewHeight: CGFloat = 40

public typealias ActionHandler = () -> ()

public extension UIScrollView {

    /// Get and set the value of object (PullToRefreshView)
    public var pullToRefreshView: PullToRefreshView? {
        get {
            return objc_getAssociatedObject(self, &pullToRefreshViewKey) as? PullToRefreshView
        }
        set(newValue) {
            self.willChangeValue(forKey: "ICSPullToRefreshView")
            objc_setAssociatedObject(self, &pullToRefreshViewKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            self.didChangeValue(forKey: "ICSPullToRefreshView")
        }
    }

    /// Show Pull to refresh true/false
    public var showsPullToRefresh: Bool {
        return pullToRefreshView != nil ? pullToRefreshView!.isHidden : false
    }

    /**
     Add the pull to refresh Handler

     - parameter actionHandler: actionHandler Add refresh View at end of the table View
     */
    public func addPullToRefreshHandler(_ actionHandler: @escaping ActionHandler) {
        if pullToRefreshView == nil {
            pullToRefreshView = PullToRefreshView(frame: CGRect(x: CGFloat(0), y: -ICSPullToRefreshViewHeight, width: self.bounds.width, height: ICSPullToRefreshViewHeight))
            addSubview(pullToRefreshView!)
            pullToRefreshView?.scrollViewOriginContentTopInset = contentInset.top
        }
        pullToRefreshView?.actionHandler = actionHandler
        setShowsPullToRefresh(true)
    }

    /**
     For trigger the pull to refresh
     */
    public func triggerPullToRefresh() {
        pullToRefreshView?.state = .triggered
        pullToRefreshView?.startAnimating()
    }
    /**
     Ser Pul to refresh

     - parameter showsPullToRefresh: true/false
     */

    public func setShowsPullToRefresh(_ showsPullToRefresh: Bool) {
        if pullToRefreshView == nil {
            return
        }
        pullToRefreshView!.isHidden = !showsPullToRefresh
        if showsPullToRefresh {
            addPullToRefreshObservers()
        } else {
            removePullToRefreshObservers()
        }
    }

    // MARK: Observer

    /**
     Add Observer on pull to refresh View
     */

    func addPullToRefreshObservers() {
        if pullToRefreshView?.isObserving != nil && !pullToRefreshView!.isObserving {
            addObserver(pullToRefreshView!, forKeyPath: observeKeyContentOffset, options:.new, context: nil)
            addObserver(pullToRefreshView!, forKeyPath: observeKeyFrame, options:.new, context: nil)
            pullToRefreshView!.isObserving = true
        }
    }
    /**
     Remove Observer from View
     */

    func removePullToRefreshObservers() {
        if pullToRefreshView?.isObserving != nil && pullToRefreshView!.isObserving {
            removeObserver(pullToRefreshView!, forKeyPath: observeKeyContentOffset)
            removeObserver(pullToRefreshView!, forKeyPath: observeKeyFrame)
            pullToRefreshView!.isObserving = false
        }
    }


}
// MARK: PullToRefreshView Class

open class PullToRefreshView: UIView {
    /// Handler
    open var actionHandler: ActionHandler?
    /// Bool values
    open var isObserving: Bool = false
    var triggeredByUser: Bool = false
    /// scrollView
    open var scrollView: UIScrollView? {
        return self.superview as? UIScrollView
    }

    open var scrollViewOriginContentTopInset: CGFloat = 0
    /**
     enum

     - Stopped:   To stop infinite scrolling
     - Triggered: To trigger the infinte scrolling on
     - Loading:   Load the data
     - All: Default Case
     */
    public enum State {
        case stopped
        case triggered
        case loading
        case all
    }

    /// States to handle the Operations on scroll View
    open var state: State = .stopped {
        willSet {
            if state != newValue {
                self.setNeedsLayout()
                switch newValue {
                case .stopped:
                    resetScrollViewContentInset()
                case .loading:
                    setScrollViewContentInsetForLoading()
                    if state == .triggered {
                        actionHandler?()
                    }
                default:
                    break
                }
            }
        }
    }
    // MARK: Initialize methods
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViews()
    }
    /**
     On start animating state will become loading to load more data
     */
    open func startAnimating() {
        if scrollView == nil {
            return
        }
        scrollView?.setContentOffset(CGPoint(x: scrollView!.contentOffset.x, y: -(scrollView!.contentInset.top + bounds.height)), animated: true)
        triggeredByUser = true
        state = .loading
    }

    /**
     On stop animating state will become stopped to end loading
     */

    open func stopAnimating() {
        state = .stopped
        if triggeredByUser {
            scrollView?.setContentOffset(CGPoint(x: scrollView!.contentOffset.x, y: -scrollView!.contentInset.top), animated: true)
        }
    }

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == observeKeyContentOffset {
            srollViewDidScroll((change?[NSKeyValueChangeKey.newKey] as AnyObject).cgPointValue)
        } else if keyPath == observeKeyFrame {
            setNeedsLayout()
        }
    }

    // MARK: Scroll View Methods

    fileprivate func srollViewDidScroll(_ contentOffset: CGPoint?) {
        if scrollView == nil || contentOffset == nil {
            return
        }
        if state != .loading {
            let scrollOffsetThreshold = frame.origin.y - scrollViewOriginContentTopInset
            if !scrollView!.isDragging && state == .triggered {
                state = .loading
            } else if contentOffset!.y < scrollOffsetThreshold && scrollView!.isDragging && state == .stopped {
                state = .triggered
            } else if contentOffset!.y >= scrollOffsetThreshold && state != .stopped {
                state = .stopped
            }
        }
    }

    fileprivate func setScrollViewContentInset(_ contentInset: UIEdgeInsets) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: { () -> Void in
            self.scrollView?.contentInset = contentInset
            }, completion: nil)
    }
    /**
     Reset the content Inset of scroll View
     */

    fileprivate func resetScrollViewContentInset() {
        if scrollView == nil {
            return
        }
        var currentInset = scrollView!.contentInset
        currentInset.top = scrollViewOriginContentTopInset
        setScrollViewContentInset(currentInset)
    }

    /**
     Set the content Inset for loading indicator
     */
    fileprivate func setScrollViewContentInsetForLoading() {
        if scrollView == nil {
            return
        }
        let offset = max(scrollView!.contentOffset.y * -1, 0)
        var currentInset = scrollView!.contentInset
        currentInset.top = min(offset, scrollViewOriginContentTopInset + bounds.height)
        setScrollViewContentInset(currentInset)
    }

    // MARK: Set Layout
    /**
     Set the frames and states of scroll View
     */
    open override func layoutSubviews() {
        super.layoutSubviews()
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        activityIndicator.center = CGPoint.init(x: (screenWidth as CGFloat - activityIndicator.frame.size.width + 15)/2, y: 20)
        switch state {
        case .stopped:
            activityIndicator.stopAnimating()
        case .loading:
            activityIndicator.startAnimating()
        default:
            break
        }
    }

    open override func willMove(toSuperview newSuperview: UIView?) {
        if superview != nil && newSuperview == nil {
            if scrollView?.showsPullToRefresh != nil && scrollView!.showsPullToRefresh {
                scrollView?.removePullToRefreshObservers()
            }
        }
    }

    // MARK: Basic Views

    // Add activity indicator on scroll View
    func initViews() {
        addSubview(defaultView)
        defaultView.addSubview(activityIndicator)
    }

    /// Default View to take View's Bounds
    lazy var defaultView: UIView = {
        let view = UIView()
        return view
    }()

    /// Show the activity indicator when pull to refresh works
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicator.hidesWhenStopped = false
        return activityIndicator
    }()

}
