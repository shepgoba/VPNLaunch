#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SBIconController : UIViewController
@end

@interface SBIcon : NSObject
-(NSString *)applicationBundleID;
@end

@interface SBIconView : UIView
-(SBIcon *)icon;
@end

@interface UIView (extra)
-(UIViewController *)_viewControllerForAncestor;
@end

@interface UIApplication (extra)
-(BOOL)launchApplicationWithIdentifier:(id)arg1 suspended:(BOOL)arg2;
@end