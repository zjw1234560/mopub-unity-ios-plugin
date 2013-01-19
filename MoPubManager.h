//
//  MopubManager.h
//  MoPubTest
//
//  Created by Mike DeSaro on 10/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPAdView.h"
#import "MPInterstitialAdController.h"


typedef enum
{
	MoPubBannerType_320x50,
	MoPubBannerType_300x250,
	MoPubBannerType_728x90,
	MoPubBannerType_160x600
} MoPubBannerType;

typedef enum
{
	MoPubAdPositionTopLeft,
	MoPubAdPositionTopCenter,
	MoPubAdPositionTopRight,
	MoPubAdPositionCentered,
	MoPubAdPositionBottomLeft,
	MoPubAdPositionBottomCenter,
	MoPubAdPositionBottomRight
} MoPubAdPosition;


@interface MoPubManager : NSObject <MPAdViewDelegate, MPInterstitialAdControllerDelegate, CLLocationManagerDelegate>
{
@private
	BOOL _locationEnabled;
}
@property (nonatomic, retain) MPAdView *adView;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *lastKnownLocation;
@property (nonatomic) MoPubAdPosition bannerPosition;


+ (MoPubManager*)sharedManager;



- (void)enableLocationSupport:(BOOL)shouldEnable;

- (void)reportApplicationOpen:(NSString*)iTunesId;

- (void)createBanner:(MoPubBannerType)bannerType atPosition:(MoPubAdPosition)position adUnitId:(NSString*)adUnitId;

- (void)destroyBanner;

- (void)showBanner;

- (void)hideBanner:(BOOL)shouldDestroy;

- (void)refreshAd:(NSString*)keywords;

- (void)requestInterstitialAd:(NSString*)adUnitId keywords:(NSString*)keywords;

- (void)showInterstitialAd:(NSString*)adUnitId;



@end
