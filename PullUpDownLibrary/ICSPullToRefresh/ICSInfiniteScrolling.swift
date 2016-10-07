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

public typealias ActionHandler = () -> ()

private let ICSInfiniteScrollingViewHeight: CGFloat = 40

public extension UIScrollView {

    /// Get and set the value of object (InfiniteScrollingView)
	public var infiniteScrollingView: InfiniteScrollingView? {
		get {
			return objc_getAssociatedObject(self, &infiniteScrollingViewKey) as? InfiniteScrollingView
		}
		set(newValue) {
			self.willChangeValue(forKey: "ICSInfiniteScrollingView")
			objc_setAssociatedObject(self, &infiniteScrollingViewKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
			self.didChangeValue(forKey: "ICSInfiniteScrollingView")
		}
	}

    /// Show Infinite scrolling true/false

	public var showsInfiniteScrolling: Bool {
		return infiniteScrollingView != nil ? infiniteScrollingView!.isHidden : false
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

	public func addInfiniteScrollingWithHandler(_ actionHandler: @escaping ActionHandler) {
		if infiniteScrollingView == nil {
			infiniteScrollingView = InfiniteScrollingView(frame: CGRect(x: CGFloat(0), y: contentSize.height, width: self.bounds.width, height: ICSInfiniteScrollingViewHeight))
			infiniteScrollingView?.backgroundColor = UIColor.clear
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

	public func addInfiniteScrollingWithHandler(_ font: UIFont, fontColor: UIColor, actionHandler: @escaping ActionHandler) {
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
		infiniteScrollingView?.state = .triggered
		infiniteScrollingView?.startAnimating()
	}

    /**
     Set the infinite scrolling

     - parameter showsInfiniteScrolling:  true/false
     */
	public func setShowsInfiniteScrolling(_ showsInfiniteScrolling: Bool) {
		if infiniteScrollingView == nil {
			return
		}
		infiniteScrollingView!.isHidden = !showsInfiniteScrolling
		if showsInfiniteScrolling {
			addInfiniteScrollingViewObservers()
		} else {
			removeInfiniteScrollingViewObservers()
			infiniteScrollingView!.setNeedsLayout()
			infiniteScrollingView!.frame = CGRect(x: CGFloat(0), y: contentSize.height, width: infiniteScrollingView!.bounds.width, height: ICSInfiniteScrollingViewHeight)
		}
	}

    // MARK: Observer
    /**
     Add Observer on infinite scrolling View
     */
	func addInfiniteScrollingViewObservers() {
		if infiniteScrollingView != nil && !infiniteScrollingView!.isObserving {
			addObserver(infiniteScrollingView!, forKeyPath: observeKeyContentOffset, options: .new, context: nil)
			addObserver(infiniteScrollingView!, forKeyPath: observeKeyContentSize, options: .new, context: nil)
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

// MARK: InfiniteScrollingView Class

open class InfiniteScrollingView: UIView {
    /// Handler
	open var actionHandler: ActionHandler?
    /// Bool values
	open var isObserving: Bool = false

    /// scrollView
    	open var scrollView: UIScrollView? {
		return self.superview as? UIScrollView
	}
	open var scrollViewOriginContentBottomInset: CGFloat = 0
    /**
     enum

     - Stopped:   To stop infinite scrolling
     - Triggered: To trigger the infinte scrolling on
     - Loading:   Load the data
     - All: Default case
     */
	public enum State {
		case stopped
		case triggered
		case loading
        case all
	}

	/// If true then No more records will not display and if false then show no more records label
	open var hasMoreData: Bool = true {
		didSet {
			if hasMoreData {

				labelNoMoreRecord.isHidden = true
			}
		}
	}
    /// Default Font and font color
	open var font: UIFont = UIFont.systemFont(ofSize: 12.0)
	open var fontColor: UIColor = UIColor.black

    /// States to handle the Operations on scroll View
	open var state: State = .stopped {
		willSet {
			if state != newValue {
				self.setNeedsLayout()
				switch newValue {
				case .stopped:
					resetScrollViewContentInset()
				case .loading:
					setScrollViewContentInsetForInfiniteScrolling()
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
		state = .loading
	}

    /**
     On stop animating state will become stopped to end loading
     */
	open func stopAnimating() {
		state = .stopped
	}

	open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
		if keyPath == observeKeyContentOffset {
            var newContentOffsetPoint: CGPoint?
            if let newContentOffset = change?[NSKeyValueChangeKey.newKey] {
             newContentOffsetPoint = (newContentOffset as AnyObject).cgPointValue
            }
			srollViewDidScroll(newContentOffsetPoint)
		} else if keyPath == observeKeyContentSize {
			setNeedsLayout()
			if let _ = (change?[NSKeyValueChangeKey.newKey] as AnyObject).cgPointValue {
				self.frame = CGRect(x: CGFloat(0), y: scrollView!.contentSize.height, width: self.bounds.width, height: ICSInfiniteScrollingViewHeight)
			}
		}
	}

    // MARK: Scroll View Methods

	fileprivate func srollViewDidScroll(_ contentOffset: CGPoint?) {
		if scrollView == nil || contentOffset == nil {
			return
		}
		if state != .loading {
			let scrollViewContentHeight = scrollView!.contentSize.height
			var scrollOffsetThreshold = scrollViewContentHeight - scrollView!.bounds.height + 40
			if scrollViewContentHeight < self.scrollView!.bounds.height {
				scrollOffsetThreshold = 40 - self.scrollView!.contentInset.top
			}
			if !scrollView!.isDragging && state == .triggered {
				state = .loading
			} else if contentOffset!.y > scrollOffsetThreshold && state == .stopped && scrollView!.isDragging {
				state = .triggered
			} else if contentOffset!.y < scrollOffsetThreshold && state != .stopped {
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
		currentInset.bottom = scrollViewOriginContentBottomInset
		setScrollViewContentInset(currentInset)
	}

    /**
     Set the content Inset for infinte scroll so that Height Will increase when user reachs at end to represent the No More Record
     */
	fileprivate func setScrollViewContentInsetForInfiniteScrolling() {
		if scrollView == nil {
			return
		}
		var currentInset = scrollView!.contentInset
		currentInset.bottom = scrollViewOriginContentBottomInset + ICSInfiniteScrollingViewHeight
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
		activityIndicator.center = CGPoint.init(x: (screenWidth as CGFloat - activityIndicator.frame.size.width + 15) / 2, y: 20)

		var frame = labelNoMoreRecord.frame
		frame.size.width = screenWidth
        labelNoMoreRecord.superview?.superview?.frame = CGRect(x: CGFloat(0), y: (scrollView?.contentSize.height)!, width: screenWidth, height: ICSInfiniteScrollingViewHeight)
       		labelNoMoreRecord.frame = frame

		switch state {
		case .stopped:
			if !hasMoreData {
				labelNoMoreRecord.isHidden = false
			}
			activityIndicator.stopAnimating()
		case .loading:
			if !hasMoreData {
				labelNoMoreRecord.isHidden = false
			} else {
				activityIndicator.startAnimating()
			}
		default:
			break
		}
	}
	open override func willMove(toSuperview newSuperview: UIView?) {
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
        defaultView.clipsToBounds = true
	}

    /// Default View to take View's Bounds
	lazy var defaultView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor.clear
		view.frame = self.bounds

		return view
	}()

    /// Show the activity indicator when Infinite scroller works
	lazy var activityIndicator: UIActivityIndicatorView = {
		let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
		activityIndicator.hidesWhenStopped = true
		return activityIndicator
	}()

	/// Create label for "No more records" in infinite scroll
	lazy var labelNoMoreRecord: UILabel = {
		let labelNoMoreRecord = UILabel(frame: CGRect.init(x: 0, y: 0, width: self.bounds.width, height: ICSInfiniteScrollingViewHeight))
		labelNoMoreRecord.isHidden = true
		labelNoMoreRecord.text = "No More Records"
		labelNoMoreRecord.font = UIFont.systemFont(ofSize: 12.0)
		labelNoMoreRecord.textAlignment = .center
		labelNoMoreRecord.backgroundColor = UIColor.clear

		return labelNoMoreRecord
	}()
}
