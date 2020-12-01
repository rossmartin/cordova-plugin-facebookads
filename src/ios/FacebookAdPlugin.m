#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import <Cordova/CDVPlugin.h>
#import "FacebookAdPlugin.h"

@interface FacebookAdPlugin()<FBAdViewDelegate>

@end


@implementation FacebookAdPlugin

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
  
  [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"] callbackId:command.callbackId];
}

- (void)removeBanner:(CDVInvokedUrlCommand *)command
{
  if (self.adView) {
    [self.adView removeFromSuperview];
    self.adView.delegate = nil;
    self.adView = nil;
    
    CGRect superViewBounds = self.webView.superview.bounds;
    CGRect window = CGRectMake(superViewBounds.origin.x, superViewBounds.origin.y, superViewBounds.size.width, superViewBounds.size.height);
    
    self.webView.bounds = window;
    self.webView.frame = window;
  }
  
  [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"] callbackId:command.callbackId];
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
    if (self.adView && self.adView.isAdValid) {
      CGRect webViewBounds = self.webView.bounds;
      NSLog(@"webViewBounds, %f by %f", webViewBounds.size.width, webViewBounds.size.height);
      
      CGFloat bottomPadding = 0;
      
      if (@available(iOS 11.0, *)) {
          UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
          bottomPadding = window.safeAreaInsets.bottom;
      }
      
      NSLog(@"bottomPadding = %f", bottomPadding);
      
      CGFloat adSizeWithPadding = bottomPadding + self.adView.frame.size.height;
      
      // move the ad to the bottom
      self.adView.frame = CGRectMake(0, webViewBounds.size.height - adSizeWithPadding, self.adView.frame.size.width, self.adView.frame.size.height);
      
      // resize the webview to accommodate for the ad
      CGRect window = CGRectMake(webViewBounds.origin.x, webViewBounds.origin.y, webViewBounds.size.width, webViewBounds.size.height - adSizeWithPadding);
      
      self.webView.bounds = window;
      self.webView.frame = window;
      
      [self.webView.superview addSubview:self.adView];
      
      [self fireEvent:NULL event:@"adViewDidLoad" withData:NULL];
    }
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
