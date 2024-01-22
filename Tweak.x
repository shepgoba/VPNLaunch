#import <substrate.h>
#import "Tweak.h"
#import <stdint.h>

// thanks stackoverflow
static BOOL isVPNConnected()
{
    NSDictionary *dict = CFBridgingRelease(CFNetworkCopySystemProxySettings());
	NSArray *keys = [dict[@"__SCOPED__"]allKeys];
	for (NSString *key in keys) {
		if ([key rangeOfString:@"tap"].location != NSNotFound ||
			[key rangeOfString:@"tun"].location != NSNotFound ||
			[key rangeOfString:@"ppp"].location != NSNotFound ||
			[key rangeOfString:@"ipsec"].location != NSNotFound) {
			return YES;
		}
	}
	return NO;
}



static void (*_handleTapOrig)(id, SEL);
static void _handleTapNew(SBIconView *self, SEL selector) 
{
	if ([self.icon.applicationBundleID isEqual:@"com.czzhao.binance"]) {
		BOOL hasVPN = isVPNConnected();
		if (hasVPN) {
			_handleTapOrig(self, selector);
		} else {
			UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"A VPN is not connected."
				message:@"Open anyway?"
				preferredStyle:UIAlertControllerStyleAlert];

			void (^launchAction)(UIAlertAction *) = ^void(UIAlertAction *action) {
				_handleTapOrig(self, selector);
			};

			void (^openApp)(UIAlertAction *) = ^void(UIAlertAction *action) {
				[[UIApplication sharedApplication] launchApplicationWithIdentifier:@"com.nordvpn.NordVPN" suspended:NO];
			};

			UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:nil];
			UIAlertAction *openVPNAction = [UIAlertAction actionWithTitle:@"Open VPN" style:UIAlertActionStyleDefault handler:openApp];
			UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:launchAction];


			[alert addAction:cancelAction];
			[alert addAction:openVPNAction];
			[alert addAction:yesAction];
			[[self _viewControllerForAncestor] presentViewController:alert animated:YES completion:nil];
		}
	} else {
		_handleTapOrig(self, selector);
	}
}


__attribute__((constructor))
static void setup()
{
	MSHookMessageEx(objc_getClass("SBIconView"), @selector(_handleTap), (IMP)&_handleTapNew, (IMP *)&_handleTapOrig);
}
