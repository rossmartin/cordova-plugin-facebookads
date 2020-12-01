#import <Cordova/CDVPlugin.h>

#define EVENT_AD_LOADED         @"onAdLoaded"
#define EVENT_AD_FAILLOAD       @"onAdFailLoad"
#define EVENT_AD_PRESENT        @"onAdPresent"
#define EVENT_AD_LEAVEAPP       @"onAdLeaveApp"
#define EVENT_AD_DISMISS        @"onAdDismiss"
#define EVENT_AD_WILLPRESENT    @"onAdWillPresent"
#define EVENT_AD_WILLDISMISS    @"onAdWillDismiss"
#define OPT_DEVICE_HASH         @"deviceHash"
#define OPT_ADID                @"adId"

@interface FacebookAdPlugin : CDVPlugin

- (void)createBanner:(CDVInvokedUrlCommand *)command;
- (void)showBanner:(CDVInvokedUrlCommand *)command;
- (void)hideBanner:(CDVInvokedUrlCommand *)command;
- (void)removeBanner:(CDVInvokedUrlCommand *)command;

@property (nonatomic, retain) FBAdView *adView;

@end
