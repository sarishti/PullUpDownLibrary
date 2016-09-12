//
//  ICSInfiniteScrolling.swift
//  ICSPullToRefresh
//
//  Created by LEI on 3/17/15.
//  Copyright (c) 2015 TouchingAPP. All rights reserved.
//

import UIKit

private var infiniteScrollingViewKey: Void?
/// Observer keys
private let observeKeyContentOffset = "contentOffset"
private let observeKeyContentSize = "contentSize"
private let observeKeyContentInset = "contentInset"

/// Default  Height of infinite Scroll View

private let ICSInfiniteScrollingViewHeight: CGFloat = 40

public extension UIScrollView {

    /// Get and set the value of object (InfiniteScrollingView)
	public var infiniteScrollingView: InfiniteScrollingView? {
		get {
			return objc_getAssociatedObject(self, &infiniteScrollingViewKey) as? InfiniteScrollingView
		}
		set(newValue) {
			self.willChangeValueForKey("ICSInfiniteScrollingView")
			objc_setAssociatedObject(self, &infiniteScrollingViewKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
			self.didChangeValueForKey("ICSInfiniteScrollingView")
		}
	}

    /// Show Infinite scrolling true/false
    
	public var showsInfiniteScrolling: Bool {
		return infiniteScrollingView != nil ? infiniteScrollingView!.hidden : false
	}
    
    /// Set has more data to represent "No More Records" after infinite scroll

	public var hasMoreData: Bool {
		get {
			return infiniteScrollingView!.hasMoreData
		}
		set(newValue) {
			infiniteScrollingView!.hasMoreData = newValue
		}
	}
    
    /// Set the font of "No more record" label

	public var font: UIFont {
		get {
			return infiniteScrollingView!.font
		}
		set(newValue) {
			infiniteScrollingView!.labelNoMoreRecord.font = newValue
		}
	}
    
    /// Set teh Font color of No More Record label

	public var fontColor: UIColor {
		get {
			return infiniteScrollingView!.fontColor
		}
		set(newValue) {
			infiniteScrollingView!.labelNoMoreRecord.textColor = fontColor
		}
	}
    /**
     Add the infinite Scroll Handler
     
     - parameter actionHandler: actionHandler Add Infinite scroll View at end of the table View
     */

	public func addInfiniteScrollingWithHandler(actionHandler: ActionHandler) {
		if infiniteScrollingView == nil {
			infiniteScrollingView = InfiniteScrollingView(frame: CGRect(x: CGFloat(0), y: contentSize.height, width: self.bounds.width, height: ICSInfiniteScrollingViewHeight))
			infiniteScrollingView?.backgroundColor = UIColor.clearColor()
			addSubview(infiniteScrollingView!)
			infiniteScrollingView?.scrollViewOriginContentBottomInset = contentInset.bottom
		}
		infiniteScrollingView?.actionHandler = actionHandler
		setShowsInfiniteScrolling(true)
	}
    
    /**
      Add the infinite Scroll Handler  with font and color of Label No Record
     
     - parameter font:          Font of label
     - parameter fontColor:     font color of label
     - parameter actionHandler: action handler
     */

	public func addInfiniteScrollingWithHandler(font: UIFont, fontColor: UIColor, actionHandler: ActionHandler) {
		if infiniteScrollingView == nil {
			infiniteScrollingView = InfiniteScrollingView(frame: CGRect(x: CGFloat(0), y: contentSize.height, width: self.bounds.width, height: ICSInfiniteScrollingViewHeight))
			addSubview(infiniteScrollingView!)
			infiniteScrollingView?.scrollViewOriginContentBottomInset = contentInset.bottom

			infiniteScrollingView?.font = font
			infiniteScrollingView?.fontColor = fontColor

			infiniteScrollingView?.labelNoMoreRecord.font = font
			infiniteScrollingView?.labelNoMoreRecord.textColor = fontColor

		}
		infiniteScrollingView?.actionHandler = actionHandler
		setShowsInfiniteScrolling(true)
	}

    /**
     For trigger the infinite scrolling
     */
	public func triggerInfiniteScrolling() {
		infiniteScrollingView?.state = .Triggered
		infiniteScrollingView?.startAnimating()
	}

    /**
     Set the infinite scrolling 
     
     - parameter showsInfiniteScrolling:  true/false
     */
	public func setShowsInfiniteScrolling(showsInfiniteScrolling: Bool) {
		if infiniteScrollingView == nil {
			return
		}
		infiniteScrollingView!.hidden = !showsInfiniteScrolling
		if showsInfiniteScrolling {
			addInfiniteScrollingViewObservers()
		} else {
			removeInfiniteScrollingViewObservers()
			infiniteScrollingView!.setNeedsLayout()
			infiniteScrollingView!.frame = CGRect(x: CGFloat(0), y: contentSize.height, width: infiniteScrollingView!.bounds.width, height: ICSInfiniteScrollingViewHeight)
		}
	}
    //MARK:- Observer
    
    /**
     Add Observer on infinite scrolling View
     */

	func addInfiniteScrollingViewObservers() {
		if infiniteScrollingView != nil && !infiniteScrollingView!.isObserving {
			addObserver(infiniteScrollingView!, forKeyPath: observeKeyContentOffset, options: .New, context: nil)
			addObserver(infiniteScrollingView!, forKeyPath: observeKeyContentSize, options: .New, context: nil)
			infiniteScrollingView!.isObserving = true
		}
	}

    /**
     Remove observer on Infinite scroll view
     */
    
	func removeInfiniteScrollingViewObservers() {
		if infiniteScrollingView != nil && infiniteScrollingView!.isObserving {
			removeObserver(infiniteScrollingView!, forKeyPath: observeKeyContentOffset)
			removeObserver(infiniteScrollingView!, forKeyPath: observeKeyContentSize)
			infiniteScrollingView!.isObserving = false
		}
	}

}

//MARK: InfiniteScrollingView Class

public class InfiniteScrollingView: UIView {
    /// Handler
	public var actionHandler: ActionHandler?
    /// Bool values
	public var isObserving: Bool = false
    
    /// scrollView
    	public var scrollView: UIScrollView? {
		return self.superview as? UIScrollView
	}

	public var scrollViewOriginContentBottomInset: CGFloat = 0
    /**
     enum
     
     - Stopped:   To stop infinite scrolling
     - Triggered: To trigger the infinte scrolling on
     - Loading:   Load the data
     - All: Default case
     */
	public enum State {
		case Stopped
		case Triggered
		case Loading
        case All
	}

	/// If true then No more records will not display and if false then show no more records label
	public var hasMoreData: Bool = true {
		didSet {
			if hasMoreData {

				labelNoMoreRecord.hidden = true
			}
		}
	}
    /// Default Font and font color
	public var font: UIFont = UIFont.systemFontOfSize(12.0)
	public var fontColor: UIColor = UIColor.blackColor()

    /// States to handle the Operations on scroll View
	public var state: State = .Stopped {
		willSet {
			if state != newValue {
				self.setNeedsLayout()
				switch newValue {
				case .Stopped:
					resetScrollViewContentInset()
				case .Loading:
					setScrollViewContentInsetForInfiniteScrolling()
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
		state = .Loading
	}

    /**
     On stop animating state will become stopped to end loading
     */
	public func stopAnimating() {
		state = .Stopped
	}
    
	public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutablePointer<Void>) {
		if keyPath == observeKeyContentOffset {
			srollViewDidScroll(change?[NSKeyValueChangeNewKey]?.CGPointValue)
		} else if keyPath == observeKeyContentSize {
			setNeedsLayout()
			if let _ = change?[NSKeyValueChangeNewKey]?.CGPointValue {
				self.frame = CGRect(x: CGFloat(0), y: scrollView!.contentSize.height, width: self.bounds.width, height: ICSInfiniteScrollingViewHeight)
			}
		}
	}

    //MARK: Scroll View Methods
    
	private func srollViewDidScroll(contentOffset: CGPoint?) {
		if scrollView == nil || contentOffset == nil {
			return
		}
		if state != .Loading {
			let scrollViewContentHeight = scrollView!.contentSize.height
			var scrollOffsetThreshold = scrollViewContentHeight - scrollView!.bounds.height + 40
			if scrollViewContentHeight < self.scrollView!.bounds.height {
				scrollOffsetThreshold = 40 - self.scrollView!.contentInset.top
			}
			if !scrollView!.dragging && state == .Triggered {
				state = .Loading
			} else if contentOffset!.y > scrollOffsetThreshold && state == .Stopped && scrollView!.dragging {
				state = .Triggered
			} else if contentOffset!.y < scrollOffsetThreshold && state != .Stopped {
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
		currentInset.bottom = scrollViewOriginContentBottomInset
		setScrollViewContentInset(currentInset)
	}

    /**
     Set the content Inset for infinte scroll so that Height Will increase when user reachs at end to represent the No More Record
     */
	private func setScrollViewContentInsetForInfiniteScrolling() {
		if scrollView == nil {
			return
		}
		var currentInset = scrollView!.contentInset
		currentInset.bottom = scrollViewOriginContentBottomInset + ICSInfiniteScrollingViewHeight
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
		activityIndicator.center = CGPoint.init(x: (screenWidth as CGFloat - activityIndicator.frame.size.width + 15) / 2, y: 20)

		var frame = labelNoMoreRecord.frame
		frame.size.width = screenWidth
		labelNoMoreRecord.frame = frame

		switch state {
		case .Stopped:
			if !hasMoreData {
				labelNoMoreRecord.hidden = false
			}
			activityIndicator.stopAnimating()
		case .Loading:
			if !hasMoreData {
				labelNoMoreRecord.hidden = false
			} else {
				activityIndicator.startAnimating()
			}
		default:
			break
		}
	}

	public override func willMoveToSuperview(newSuperview: UIView?) {
		if superview != nil && newSuperview == nil {
			if scrollView?.showsInfiniteScrolling != nil && scrollView!.showsInfiniteScrolling {
				scrollView?.removeInfiniteScrollingViewObservers()
			}
		}
	}

	// MARK: Basic Views

   // Add Label,view on which add the scroller and activity indicator on scroll View
	func initViews() {
		addSubview(defaultView)
		defaultView.addSubview(activityIndicator)
		defaultView.addSubview(labelNoMoreRecord)
	}
    
    /// Default View to take View's Bounds
    
	lazy var defaultView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor.clearColor()
		view.frame = self.bounds
		return view
	}()

    /// Show the activity indicator when Infinite scroller works
    
	lazy var activityIndicator: UIActivityIndicatorView = {
		let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
		activityIndicator.hidesWhenStopped = true
		return activityIndicator
	}()

	/// Create label for "No more records" in infinite scroll

	lazy var labelNoMoreRecord: UILabel = {

		let labelNoMoreRecord = UILabel(frame: CGRect.init(x: 0, y: 0, width: self.bounds.width, height: ICSInfiniteScrollingViewHeight))
		labelNoMoreRecord.hidden = true
		labelNoMoreRecord.text = "No More Records"
		labelNoMoreRecord.font = UIFont.systemFontOfSize(12.0)
		labelNoMoreRecord.textAlignment = .Center
		labelNoMoreRecord.backgroundColor = UIColor.clearColor()

		return labelNoMoreRecord
	}()

}
