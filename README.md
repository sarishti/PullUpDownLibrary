# PullUpDownLibrary
===========
      Swift 3.0
      Protcol Oriented Progarmming (Extension) 

## Summary

PullUpDownLibrary is the customizion of ICSPullToRefresh Library.It provide the falicity to add a label with text "No More Record" at the end of infinite scroller.


## Use

 -> Provide pull to refresh and infinite scroll view functionality.

 -> In inifite scroll user can stop implementation on basis of particular scenerio.  

 -> User can select the color and font for label "No More Record"


## Implementation

**Pull to refresh :**

  tableView.addPullToRefreshHandler {

         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in

        print("Pull to refresh action")

      })
}

**Set the Color of Label :**

        UIFont(name: "HelveticaNeue-Bold", size: 15) ?? UIFont.boldSystemFontOfSize(17)

/**
Has no more data false will show "No more record" Label 
*/

        self.tableView.infiniteScrollingView?.hasMoreData = false

**Add infinite Scroller :**

self.tableView.addInfiniteScrollingWithHandler(fontForInfiniteScrolling, fontColor: UIColor.redColor(), actionHandler: {

          //condition to stop calling function
         if self.tableView.infiniteScrollingView!.hasMoreData {   
         
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                
                print("Infinite scroller action")
            })
        }
}

**Remove Loader :**

        self.pullToRefreshView?.stopAnimating()
        self.infiniteScrollingView?.stopAnimating()



## License
PullUpDownLibrary is available under the MIT License

If you use it and like it, let me know: 
[@sarishti](sarishti09@gmail.com)

