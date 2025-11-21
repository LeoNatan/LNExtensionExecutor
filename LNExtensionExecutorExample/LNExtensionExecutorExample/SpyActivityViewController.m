//
//  SpyActivityViewController.m
//  LNExtensionExecutorExample
//
//  Created by Léo Natan on 21/11/25.
//

#import "SpyActivityViewController.h"

@interface SpyActivityViewController ()

@end

@implementation SpyActivityViewController

- (void)_performActivity:(UIActivity *)activity
{
	[super _performActivity:activity];

	@try
	{
		NSString* bundle = [activity valueForKeyPath:@"applicationExtension.identifier"];

		if(bundle != nil)
		{
			NSLog(@"🔵 Last selected activity type: %@", bundle);
			[NSNotificationCenter.defaultCenter postNotificationName:@"lastSelectedActivityType" object:bundle];

			return;
		}
	}
	@catch (NSException *exception)
	{}

	NSLog(@"🔵 Last selected activity type: %@", activity.activityType);
	[NSNotificationCenter.defaultCenter postNotificationName:@"lastSelectedActivityType" object:activity.activityType];
}

@end
