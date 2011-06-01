;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; COCOA

(defpackage :cocoa
  (:use :cl :ffi :util :eclffi)
  (:export
   :show-alert
   :dismiss-alert))

(in-package :cocoa)

(clines
 "#import <CoreGraphics/CoreGraphics.h>"
 "#import <Foundation/Foundation.h>"
 "#import <UIKit/UIKit.h>"
 "#import \"ecl_boot.h\""
 )

(defun show-alert (title &key message (dismiss-label "OK"))
  "Displays a simple alert to notify the user"
  (check-type title string)
  (check-type dismiss-label string)
  (c-fficall (((make-NSString title) :pointer-void)
              ((make-NSString message) :pointer-void)
              ((make-NSString dismiss-label) :pointer-void))
      :void
    "UIAlertView *alert = [[UIAlertView alloc] 
        initWithTitle: #0
        message: #1
        delegate: nil
        cancelButtonTitle: #2
        otherButtonTitles: nil];
      dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
        [alert release];
       });"))

(defun dismiss-alert (&key animated)
  (declare (ignore animated))
  (plusp
    (c-fficall ()
      :int
      "int count = 0;
       for (UIWindow* window in [UIApplication sharedApplication].windows) {
         NSArray* subviews = window.subviews;
         if ([subviews count] > 0) {
           UIView* view = [subviews objectAtIndex:0];
           if ([view isKindOfClass:[UIAlertView class]]) {
             dispatch_async(dispatch_get_main_queue(), ^{
               UIAlertView* alert = (UIAlertView *)view;
               [alert dismissWithClickedButtonIndex:[alert cancelButtonIndex] 
                      animated:NO];
             });
             count++;
            }
          }
        } 
        @(return) = count;")))
