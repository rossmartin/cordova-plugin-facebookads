#import <Cordova/CDVPlugin.h>

#define OPT_ADID                @"adId"

@interface FacebookAdPlugin : CDVPlugin

- (void)createBanner:(CDVInvokedUrlCommand *)command;
- (void)removeBanner:(CDVInvokedUrlCommand *)command;

@property (nonatomic, retain) FBAdView *adView;

@end
