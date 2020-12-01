#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import <Cordova/CDVPlugin.h>
#import "FacebookAdPlugin.h"

@interface FacebookAdPlugin()<FBAdViewDelegate>

@end


// ------------------------------------------------------------------

@implementation FacebookAdPlugin

//- (void) setOptions:(CDVInvokedUrlCommand *)command
//{
//    NSDictionary* options = [command.arguments objectAtIndex:0];
//
//    bool isTesting = [options objectForKey:@"isTesting"];
//
//    if (isTesting) {
//        NSString* str = [options objectForKey:OPT_DEVICE_HASH];
//        if(str && [str length] > 0) {
//            NSLog(@"set device hash: %@", str);
//            [FBAdSettings addTestDevice:str];
//        }
//    }
//
//
//    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"] callbackId:command.callbackId];
//}

- (void) createBanner:(CDVInvokedUrlCommand *)command
{
  NSDictionary* options = [command.arguments objectAtIndex:0];
  
  NSString* adId = [options objectForKey:OPT_ADID];
  
  self.adView = [[FBAdView alloc] initWithPlacementID:adId
                                  adSize:kFBAdSizeHeight50Banner
                                  rootViewController:self.viewController];
  
  self.adView.delegate = self;
  
  self.adView.autoresizingMask =
  UIViewAutoresizingFlexibleRightMargin |
  UIViewAutoresizingFlexibleLeftMargin|
  UIViewAutoresizingFlexibleWidth |
  UIViewAutoresizingFlexibleTopMargin;
  
  [self.adView loadAd];
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
 * document.addEventListener('adViewDidLoad', function(data));
 * document.addEventListener('adViewDidClick', function(data));
 * document.addEventListener('adViewDidFinishHandlingClick', function(data));
 * document.addEventListener('didFailWithError', function(data));
 * document.addEventListener('adViewWillLogImpression', function(data));
 */

- (void)adViewDidLoad:(FBAdView *)adView
{
    [self fireEvent:NULL event:@"adViewDidLoad" withData:NULL];
}

- (void)adViewDidClick:(FBAdView *)adView
{
    [self fireEvent:NULL event:@"adViewDidClick" withData:NULL];
}

- (void)adViewDidFinishHandlingClick:(FBAdView *)adView
{
    [self fireEvent:NULL event:@"adViewDidFinishHandlingClick" withData:NULL];
}

- (void)adView:(FBAdView *)adView didFailWithError:(NSError *)error
{
  [self fireEvent:NULL event:@"didFailWithError" withData:NULL];
}

- (void)adViewWillLogImpression:(FBAdView *)adView
{
    [self fireEvent:NULL event:@"adViewWillLogImpression" withData:NULL];
}


- (void) fireEvent:(NSString *)obj event:(NSString *)eventName withData:(NSString *)jsonStr
{
    NSLog(@"%@, %@, %@", obj, eventName, jsonStr?jsonStr:@"");
    
    NSString* js;
    if(obj && [obj isEqualToString:@"window"]) {
        js = [NSString stringWithFormat:@"var evt=document.createEvent(\"UIEvents\");evt.initUIEvent(\"%@\",true,false,window,0);window.dispatchEvent(evt);", eventName];
    } else if(jsonStr && [jsonStr length]>0) {
        js = [NSString stringWithFormat:@"javascript:cordova.fireDocumentEvent('%@',%@);", eventName, jsonStr];
    } else {
        js = [NSString stringWithFormat:@"javascript:cordova.fireDocumentEvent('%@');", eventName];
    }
    [self.commandDelegate evalJs:js];
}
@end
