//
//  MoPubBinding.m
//  MoPubTest
//
//  Created by Mike DeSaro on 10/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MoPubManager.h"


// Converts C style string to NSString
#define GetStringParam( _x_ ) ( _x_ != NULL ) ? [NSString stringWithUTF8String:_x_] : [NSString stringWithUTF8String:""]


// Enables location support
void _moPubEnableLocationSupport( bool shouldUseLocation )
{
	[[MoPubManager sharedManager] enableLocationSupport:shouldUseLocation];
}


void _moPubCreateBanner( int bannerType, int bannerPosition, const char * adUnitId )
{
	MoPubBannerType type = (MoPubBannerType)bannerType;
	MoPubAdPosition position = (MoPubAdPosition)bannerPosition;
	
	[[MoPubManager sharedManager] createBanner:type atPosition:position adUnitId:GetStringParam( adUnitId )];
}


// Destroys the banner and removes it from view
void _moPubDestroyBanner()
{
	[[MoPubManager sharedManager] destroyBanner];
}


// Shows/hides the banner
void _moPubShowBanner( bool shouldShow )
{
	if( shouldShow )
		[[MoPubManager sharedManager] showBanner];
	else
		[[MoPubManager sharedManager] hideBanner:NO];
}


// Refreshes the ad banner with optional keywords
void _moPubRefreshAd( const char * keywords )
{
	NSString *keys = keys != NULL ? GetStringParam( keywords ) : nil;
	[[MoPubManager sharedManager] refreshAd:keys];
}


// Starts loading an interstitial ad
void _moPubRequestInterstitialAd( const char * adUnitId, const char * keywords )
{
	[[MoPubManager sharedManager] requestInterstitialAd:GetStringParam( adUnitId ) keywords:GetStringParam( keywords )];
}


// If an interstitial ad is loaded this will take over the screen and show the ad
void _moPubShowInterstitialAd( const char * adUnitId )
{
	[[MoPubManager sharedManager] showInterstitialAd:GetStringParam( adUnitId )];
}


// Reports an app download to MoPub
void _moPubReportApplicationOpen( const char * iTunesAppId )
{
	[[MoPubManager sharedManager] reportApplicationOpen:GetStringParam( iTunesAppId )];
}
