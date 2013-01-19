//
//  MopubManager.m
//  MoPubTest
//
//  Created by Mike DeSaro on 10/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MoPubManager.h"
#import "MPAdConversionTracker.h"


void UnityPause( bool pause );

void UnitySendMessage( const char * className, const char * methodName, const char * param );

UIViewController *UnityGetGLViewController();


@implementation MoPubManager

@synthesize adView = _adView, locationManager = _locationManager, lastKnownLocation = _lastKnownLocation, bannerPosition;

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSObject

+ (MoPubManager*)sharedManager
{
	static MoPubManager *sharedManager = nil;
	
	if( !sharedManager )
		sharedManager = [[MoPubManager alloc] init];
	
	return sharedManager;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private

- (void)adjustAdViewFrameToShowAdView
{
	// fetch screen dimensions and useful values
	CGRect origFrame = _adView.frame;
	
	CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
	CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
	
	if( UIInterfaceOrientationIsLandscape( UnityGetGLViewController().interfaceOrientation ) )
	{
		screenWidth = screenHeight;
		screenHeight = [UIScreen mainScreen].bounds.size.width;
	}
	
	
	switch( bannerPosition )
	{
		case MoPubAdPositionTopLeft:
			origFrame.origin.x = 0;
			origFrame.origin.y = 0;
			_adView.autoresizingMask = ( UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin );
			break;
		case MoPubAdPositionTopCenter:
			origFrame.origin.x = ( screenWidth / 2 ) - ( origFrame.size.width / 2 );
			origFrame.origin.y = 0;
			_adView.autoresizingMask = ( UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin );
			break;
		case MoPubAdPositionTopRight:
			origFrame.origin.x = screenWidth - origFrame.size.width;
			origFrame.origin.y = 0;
			_adView.autoresizingMask = ( UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin );
			break;
		case MoPubAdPositionCentered:
			origFrame.origin.x = ( screenWidth / 2 ) - ( origFrame.size.width / 2 );
			origFrame.origin.y = ( screenHeight / 2 ) - ( origFrame.size.height / 2 );
			_adView.autoresizingMask = ( UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin );
			break;
		case MoPubAdPositionBottomLeft:
			origFrame.origin.x = 0;
			origFrame.origin.y = screenHeight - origFrame.size.height;
			_adView.autoresizingMask = ( UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin );
			break;
		case MoPubAdPositionBottomCenter:
			origFrame.origin.x = ( screenWidth / 2 ) - ( origFrame.size.width / 2 );
			origFrame.origin.y = screenHeight - origFrame.size.height;
			_adView.autoresizingMask = ( UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin );
			break;
		case MoPubAdPositionBottomRight:
			origFrame.origin.x = screenWidth - _adView.frame.size.width;
			origFrame.origin.y = screenHeight - origFrame.size.height;
			_adView.autoresizingMask = ( UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin );
			break;
	}
	
	_adView.frame = origFrame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public

- (void)enableLocationSupport:(BOOL)shouldEnable
{
	if( _locationEnabled == shouldEnable )
		return;
	
	_locationEnabled = shouldEnable;
	
	// are we stopping or starting location use?
	if( _locationEnabled )
	{
		// autorelease and retain just in case we have an old one to avoid leaking
		self.locationManager = [[[CLLocationManager alloc] init] autorelease];
		_locationManager.delegate = self;
		_locationManager.distanceFilter = 100;
		_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		
		// Make sure the user has location on in settings
		if( _locationManager.locationServicesEnabled )
		{
			// Only start updating if we can get location information
			[_locationManager startUpdatingLocation];
		}
		else
		{
			_locationEnabled = NO;
			self.locationManager = nil;
		}
	}
	else // turning off
	{
		[_locationManager stopUpdatingLocation];
		_locationManager.delegate = nil;
		self.locationManager = nil;
	}
}


- (void)reportApplicationOpen:(NSString*)iTunesId
{
	[[MPAdConversionTracker sharedConversionTracker] reportApplicationOpenForApplicationID:iTunesId];
}


- (void)createBanner:(MoPubBannerType)bannerType atPosition:(MoPubAdPosition)position adUnitId:(NSString*)adUnitId
{
	// kill the current adView if we have one
	if( _adView )
		[self hideBanner:YES];
	
	bannerPosition = position;
	
	switch( bannerType )
	{
		case MoPubBannerType_320x50:
		{
			_adView = [[MPAdView alloc] initWithAdUnitId:adUnitId size:MOPUB_BANNER_SIZE];
			[_adView lockNativeAdsToOrientation:MPNativeAdOrientationPortrait];
			break;
		}
		case MoPubBannerType_728x90:
		{
			_adView = [[MPAdView alloc] initWithAdUnitId:adUnitId size:MOPUB_LEADERBOARD_SIZE];
			[_adView lockNativeAdsToOrientation:MPNativeAdOrientationPortrait];
			break;
		}
		case MoPubBannerType_160x600:
		{
			_adView = [[MPAdView alloc] initWithAdUnitId:adUnitId size:MOPUB_WIDE_SKYSCRAPER_SIZE];
			break;
		}
		case MoPubBannerType_300x250:
		{
			_adView = [[MPAdView alloc] initWithAdUnitId:adUnitId size:MOPUB_MEDIUM_RECT_SIZE];
			break;
		}
	}
	
	// do we have location enabled?
	if( _locationEnabled && _lastKnownLocation )
		_adView.location = _lastKnownLocation;
	
	_adView.delegate = self;
	[UnityGetGLViewController().view addSubview:_adView];
	[_adView loadAd];
}


- (void)destroyBanner
{
	[_adView removeFromSuperview];
	_adView.delegate = nil;
	self.adView = nil;
}


- (void)showBanner
{
	if( !_adView )
		return;
	
	_adView.hidden = NO;
	_adView.ignoresAutorefresh = NO;
}


- (void)hideBanner:(BOOL)shouldDestroy
{
	_adView.hidden = YES;
	_adView.ignoresAutorefresh = YES;
	
	if( shouldDestroy )
		[self destroyBanner];
}


- (void)refreshAd:(NSString*)keywords
{
	if( !_adView )
		return;
	
	if( keywords )
		_adView.keywords = keywords;
	[_adView refreshAd];
}


- (void)requestInterstitialAd:(NSString*)adUnitId keywords:(NSString*)keywords
{
	// this will return nil if there is already a load in progress
	MPInterstitialAdController *interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:adUnitId];
	
	if( _locationEnabled && _lastKnownLocation )
		interstitial.location = _lastKnownLocation;
	
	interstitial.keywords = keywords;
	interstitial.delegate = self;
	[interstitial loadAd];
}


- (void)showInterstitialAd:(NSString*)adUnitId
{
	MPInterstitialAdController *interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:adUnitId];
	if( !interstitial.ready )
	{
		NSLog( @"interstitial ad is not yet loaded" );
		return;
	}
	
	[interstitial showFromViewController:UnityGetGLViewController()];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - MPAdViewDelegate

- (UIViewController*)viewControllerForPresentingModalView 
{
    return UnityGetGLViewController();
}


/*
 * These callbacks notify you regarding whether the ad view (un)successfully
 * loaded an ad.
 */
- (void)adViewDidFailToLoadAd:(MPAdView*)view
{
	_adView.hidden = YES;
	UnitySendMessage( "MoPubManager", "adViewDidFailToLoadAd", "" );
}


- (void)adViewDidLoadAd:(MPAdView*)view
{
	[self adjustAdViewFrameToShowAdView];
	_adView.hidden = NO;
	
	UnitySendMessage( "MoPubManager", "adViewDidLoadAd", "" );
}


/*
 * These callbacks are triggered when the ad view is about to present/dismiss a
 * modal view. If your application may be disrupted by these actions, you can
 * use these notifications to handle them (for example, a game might need to
 * pause/unpause).
 */
- (void)willPresentModalViewForAd:(MPAdView*)view
{
	UnityPause( true );
}


- (void)didDismissModalViewForAd:(MPAdView*)view
{
	UnityPause( false );
}


/*
 * This callback is triggered when the ad view has retrieved ad parameters
 * (headers) from the MoPub server. See MPInterstitialAdController for an
 * example of how this should be used.
- (void)adView:(MPAdView*)view didReceiveResponseParams:(NSDictionary*)params
{
	
}
*/


/*
 * This method is called when a mopub://close link is activated. Your implementation of this
 * method should remove the ad view from the screen (see MPInterstitialAdController for an example).
 */
- (void)adViewShouldClose:(MPAdView*)view
{
	[self hideBanner:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - MPInterstitialAdControllerDelegate

- (void)interstitialDidLoadAd:(MPInterstitialAdController*)interstitial
{
	UnitySendMessage( "MoPubManager", "interstitialDidLoadAd", interstitial.adUnitId.UTF8String );
}


- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController*)interstitial
{
	UnitySendMessage( "MoPubManager", "interstitialDidFailToLoadAd", interstitial.adUnitId.UTF8String );
}


- (void)interstitialDidExpire:(MPInterstitialAdController*)interstitial
{
	UnitySendMessage( "MoPubManager", "interstitialDidExpire", interstitial.adUnitId.UTF8String );
}


/*
 * This callback notifies you that the interstitial is about to appear. This is a good time to
 * handle potential app interruptions (e.g. pause a game).
 */
- (void)interstitialWillAppear:(MPInterstitialAdController*)interstitial
{
	UnityPause( true );
}


- (void)interstitialWillDisappear:(MPInterstitialAdController*)interstitial
{
	UnityPause( false );
}


- (void)interstitialDidDisappear:(MPInterstitialAdController*)interstitial
{
	UnitySendMessage( "MoPubManager", "interstitialDidDismiss", interstitial.adUnitId.UTF8String );
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager*)manager didUpdateToLocation:(CLLocation*)newLocation fromLocation:(CLLocation*)oldLocation
{
	// update our locations
	if( _adView )
		_adView.location = newLocation;
	
	self.lastKnownLocation = newLocation;
}



@end
