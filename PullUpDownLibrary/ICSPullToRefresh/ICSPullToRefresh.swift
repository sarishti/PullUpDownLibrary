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
            self.willChangeValueForKey("ICSPullToRefreshView")
            objc_setAssociatedObject(self, &pullToRefreshViewKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            self.didChangeValueForKey("ICSPullToRefreshView")
        }
    }

     /// Show Pull to refresh true/false
    public var showsPullToRefresh: Bool {
        return pullToRefreshView != nil ? pullToRefreshView!.hidden : false
    }

    /**
     Add the pull to refresh Handler

     - parameter actionHandler: actionHandler Add refresh View at end of the table View
     */
    public func addPullToRefreshHandler(actionHandler: ActionHandler) {
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
        pullToRefreshView?.state = .Triggered
        pullToRefreshView?.startAnimating()
    }
    /**
     Ser Pul to refresh

     - parameter showsPullToRefresh: true/false
     */

    public func setShowsPullToRefresh(showsPullToRefresh: Bool) {
        if pullToRefreshView == nil {
            return
        }
        pullToRefreshView!.hidden = !showsPullToRefresh
        if showsPullToRefresh {
            addPullToRefreshObservers()
        } else {
            removePullToRefreshObservers()
        }
    }

    //MARK: Observer

    /**
     Add Observer on pull to refresh View
     */

    func addPullToRefreshObservers() {
        if pullToRefreshView?.isObserving != nil && !pullToRefreshView!.isObserving {
            addObserver(pullToRefreshView!, forKeyPath: observeKeyContentOffset, options:.New, context: nil)
            addObserver(pullToRefreshView!, forKeyPath: observeKeyFrame, options:.New, context: nil)
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
//MARK: PullToRefreshView Class

public class PullToRefreshView: UIView {
    /// Handler
    public var actionHandler: ActionHandler?
    /// Bool values
    public var isObserving: Bool = false
    var triggeredByUser: Bool = false
     /// scrollView
    public var scrollView: UIScrollView? {
        return self.superview as? UIScrollView
    }

    public var scrollViewOriginContentTopInset: CGFloat = 0
    /**
     enum

     - Stopped:   To stop infinite scrolling
     - Triggered: To trigger the infinte scrolling on
     - Loading:   Load the data
     - All: Default Case
     */
    public enum State {
        case Stopped
        case Triggered
        case Loading
        case All
    }

    /// States to handle the Operations on scroll View
    public var state: State = .Stopped {
        willSet {
            if state != newValue {
                self.setNeedsLayout()
                switch newValue {
                case .Stopped:
                    resetScrollViewContentInset()
                case .Loading:
                    setScrollViewContentInsetForLoading()
                    if state == .Triggered {
                        actionHandler?()
                    }
                default:
                    break
                }
            }
        }
    }

    //MARK: Initialize methods
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
    public func startAnimating() {
        if scrollView == nil {
            return
        }
        scrollView?.setContentOffset(CGPoint(x: scrollView!.contentOffset.x, y: -(scrollView!.contentInset.top + bounds.height)), animated: true)
        triggeredByUser = true
        state = .Loading
    }

    /**
     On stop animating state will become stopped to end loading
     */

    public func stopAnimating() {
        state = .Stopped
        if triggeredByUser {
            scrollView?.setContentOffset(CGPoint(x: scrollView!.contentOffset.x, y: -scrollView!.contentInset.top), animated: true)
        }
    }

    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == observeKeyContentOffset {
            srollViewDidScroll(change?[NSKeyValueChangeNewKey]?.CGPointValue)
        } else if keyPath == observeKeyFrame {
            setNeedsLayout()
        }
    }

    //MARK: Scroll View Methods

    private func srollViewDidScroll(contentOffset: CGPoint?) {
        if scrollView == nil || contentOffset == nil {
            return
        }
        if state != .Loading {
            let scrollOffsetThreshold = frame.origin.y - scrollViewOriginContentTopInset
            if !scrollView!.dragging && state == .Triggered {
                state = .Loading
            } else if contentOffset!.y < scrollOffsetThreshold && scrollView!.dragging && state == .Stopped {
                state = .Triggered
            } else if contentOffset!.y >= scrollOffsetThreshold && state != .Stopped {
                state == .Stopped
            }
        }
    }

    private func setScrollViewContentInset(contentInset: UIEdgeInsets) {
        UIView.animateWithDuration(0.3, delay: 0, options: [.AllowUserInteraction, .BeginFromCurrentState], animations: { () -> Void in
            self.scrollView?.contentInset = contentInset
        }, completion: nil)
    }
    /**
     Reset the content Inset of scroll View
     */

    private func resetScrollViewContentInset() {
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
    private func setScrollViewContentInsetForLoading() {
        if scrollView == nil {
            return
        }
        let offset = max(scrollView!.contentOffset.y * -1, 0)
        var currentInset = scrollView!.contentInset
        currentInset.top = min(offset, scrollViewOriginContentTopInset + bounds.height)
        setScrollViewContentInset(currentInset)
    }

    //MARK: Set Layout
    /**
     Set the frames and states of scroll View
     */
    public override func layoutSubviews() {
        super.layoutSubviews()
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        activityIndicator.center = CGPoint.init(x: (screenWidth as CGFloat - activityIndicator.frame.size.width + 15)/2, y: 20)
        switch state {
        case .Stopped:
            activityIndicator.stopAnimating()
        case .Loading:
            activityIndicator.startAnimating()
        default:
            break
        }
    }

    public override func willMoveToSuperview(newSuperview: UIView?) {
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
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityIndicator.hidesWhenStopped = false
        return activityIndicator
    }()

}
