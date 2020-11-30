//
//  FacebookAdPlugin.m
//  TestAdMobCombo
//
//  Created by Xie Liming on 14-11-8.
//
//

#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import "UITapGestureRecognizer+Spec.h"
#import "FacebookAdPlugin.h"

#define TEST_BANNER_ID           @"726719434140206_777151452430337"
#define TEST_INERSTITIAL_ID      @"726719434140206_777151589096990"
#define TEST_NATIVE_ID           @"726719434140206_777151705763645"

#define OPT_DEVICE_HASH          @"deviceHash"

@interface FacebookAdPlugin()<FBAdViewDelegate, FBInterstitialAdDelegate, FBNativeAdDelegate, UIGestureRecognizerDelegate>

@property (assign) FBAdSize adSize;

@end


// ------------------------------------------------------------------

@implementation FacebookAdPlugin

- (void)pluginInitialize
{
    [super pluginInitialize];
    
    self.adSize = [self __AdSizeFromString:@"SMART_BANNER"];
}

- (NSString*) __getProductShortName{
    return @"FacebookAds";
}

- (NSString*) __getTestBannerId;
{
    return TEST_BANNER_ID;
}

- (NSString*) __getTestInterstitialId
{
    return TEST_INERSTITIAL_ID;
}

- (FBAdSize) __AdSizeFromString:(NSString*)str
{
    FBAdSize sz;
    if ([str isEqualToString:@"BANNER"]) {
        sz = kFBAdSize320x50;
    // other size not supported by facebook audience network: FULL_BANNER, MEDIUM_RECTANGLE, LEADERBOARD, SKYSCRAPER
    //} else if ([str isEqualToString:@"SMART_BANNER"]) {
    } else {
        BOOL isIPAD = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
        sz = isIPAD ? kFBAdSizeHeight90Banner : kFBAdSizeHeight50Banner;
    }
    
    return sz;
}

- (void) parseOptions:(NSDictionary *)options
{
    [super parseOptions:options];
    
    NSString* str = [options objectForKey:OPT_AD_SIZE];
    if(str) {
        self.adSize = [self __AdSizeFromString:str];
    }
    
    if(self.isTesting) {
        self.testTraffic = true;
        
        str = [options objectForKey:OPT_DEVICE_HASH];
        if(str && [str length]>0) {
            NSLog(@"set device hash: %@", str);
            [FBAdSettings addTestDevice:str];
        }
        
        // TODO: add device hash, but know how to get the FB hash id on ios ...
    }
}


- (UIView*) __createAdView:(NSString*)adId
{
    FBAdView* ad = [[FBAdView alloc] initWithPlacementID:adId
                                                  adSize:self.adSize
                                      rootViewController:[self getViewController]];
    ad.delegate= self;
    
    if(self.adSize.size.height == 50 || self.adSize.size.height == 90) {
        ad.autoresizingMask =
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleLeftMargin|
        UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleTopMargin;
    }
    
    return ad;
}

- (int) __getAdViewWidth:(UIView*)view
{
    return view.frame.size.width;
}

- (int) __getAdViewHeight:(UIView*)view
{
    return view.frame.size.height;
}

- (void) __loadAdView:(UIView*)view
{
    if([view isKindOfClass:[FBAdView class]]) {
        FBAdView* ad = (FBAdView*) view;
        [ad loadAd];
    }
}

- (void) __pauseAdView:(UIView*)view
{
    if([view isKindOfClass:[FBAdView class]]) {
        //FBAdView* ad = (FBAdView*) view;
        // [ad pause];
    }
}

- (void) __resumeAdView:(UIView*)view
{
    if([view isKindOfClass:[FBAdView class]]) {
        //FBAdView* ad = (FBAdView*) view;
        // [ad resume];
    }
}

- (void) __destroyAdView:(UIView*)view
{
    if([view isKindOfClass:[FBAdView class]]) {
        FBAdView* ad = (FBAdView*) view;
        ad.delegate = nil;
    }
}

#pragma mark FBAdViewDelegate implementation

/**
 * document.addEventListener('onAdLoaded', function(data));
 * document.addEventListener('onAdFailLoad', function(data));
 * document.addEventListener('onAdPresent', function(data));
 * document.addEventListener('onAdDismiss', function(data));
 * document.addEventListener('onAdLeaveApp', function(data));
 */
- (void)adViewDidClick:(FBAdView *)adView
{
    [self fireAdEvent:EVENT_AD_LEAVEAPP withType:ADTYPE_BANNER];
}

- (void)adViewDidFinishHandlingClick:(FBAdView *)adView
{
    [self fireAdEvent:EVENT_AD_DISMISS withType:ADTYPE_BANNER];
}

- (void)adViewDidLoad:(FBAdView *)adView
{
    if((! self.bannerVisible) && self.autoShowBanner) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self __showBanner:self.adPosition atX:self.posX atY:self.posY];
        });
    }
    
    [self fireEvent:[self __getProductShortName] event:@"onBannerReceive" withData:NULL];
    
    [self fireAdEvent:EVENT_AD_LOADED withType:ADTYPE_BANNER];
}

- (void)adView:(FBAdView *)adView didFailWithError:(NSError *)error
{
    [self fireAdErrorEvent:EVENT_AD_FAILLOAD withCode:(int)error.code withMsg:[error localizedDescription] withType:ADTYPE_BANNER];
}

- (void)adViewWillLogImpression:(FBAdView *)adView
{
    [self fireAdEvent:EVENT_AD_PRESENT withType:ADTYPE_BANNER];
}

@end
