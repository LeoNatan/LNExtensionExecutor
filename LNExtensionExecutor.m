//
//  LNExtensionExecutor.m
//
//  Created by Leo Natan on 2015-03-02.
//

#import "LNExtensionExecutor.h"

@import UIKit;
@import MobileCoreServices;
@import ObjectiveC;

NSString* const LNExtensionExecutorErrorDomain = @"LNExtensionExecutorErrorDomain";
NSInteger const LNExtensionNotFoundErrorCode = 6001;

@interface _LNExecutorActivityViewController : UIActivityViewController @end

@implementation _LNExecutorActivityViewController

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
//	viewControllerToPresent.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[super presentViewController:viewControllerToPresent animated:flag completion:completion];
}

@end

@implementation LNExtensionExecutor
{
	NSString* _identifier;
	
	id _extension;
}

+ (nullable instancetype)executorWithExtensionBundleIdentifier:(nonnull NSString*)bundleId
{
	return [[self alloc] _initWithExtensionBundleIdentifier:bundleId];
}

- (instancetype)init
{
	[NSException raise:NSInternalInconsistencyException format:@"LNExtensionExecutor must not be initiazlied directly. Use +[LNExtensionExecutor extensionExecutorWithExtensionName:window:] to initilize."];
	
	return nil;
}

- (nullable instancetype)_initWithExtensionBundleIdentifier:(nonnull NSString*)bundleId
{
	if(bundleId == nil)
	{
		[NSException raise:NSInternalInconsistencyException format:@"Bundle identifier cannot be nil"];
		
		return nil;
	}
	
	self = [super init];
	
	if(self)
	{
		_identifier = bundleId;
		
		id (*msgsend1)(id, SEL, NSString*, NSError**) = (id (*)(id, SEL, NSString*, NSError**))objc_msgSend;
		
		NSMutableString* extClsName = [NSStringFromClass([LNExtensionExecutor class]) mutableCopy];
		[extClsName deleteCharactersInRange:NSMakeRange(11, 8)];
		[extClsName replaceCharactersInRange:NSMakeRange(0, 2) withString:@"NS"];
		
		NSMutableString* slName = [@"cellWithIdentifier:error:" mutableCopy];
		[slName replaceCharactersInRange:NSMakeRange(0, 4) withString:[[extClsName substringFromIndex:2] lowercaseString]];
		
		_extension = msgsend1(NSClassFromString(extClsName), NSSelectorFromString(slName), _identifier, NULL);
		
		if(_extension == nil)
		{
			NSLog(@"<CPSDK(ExtensionExecutor)> Extension with identifier \"%@\" not found", _identifier);
			
			return nil;
		}
	}
	
	return self;
}

- (nonnull NSString*)description
{
	return [NSString stringWithFormat:@"%@ Extension Bundle Identifier: %@", [super description], _identifier];
}

- (void)executeWithInputItems:(NSArray *)inputItems onViewController:(UIViewController*)vc completionHandler:(void (^ __nonnull)(BOOL completed, NSArray * __nullable returnedItems, NSError* __nullable activityError))handler
{
	[self _executeWithInputItems:inputItems viewController:vc completionHandler:^ (BOOL completed, NSArray * __nullable returnedExtensionItems, NSError * __nullable activityError) {

		__block NSUInteger loadCounter = 0;
		NSMutableArray* returnedItems = [NSMutableArray new];
		
		if(activityError)
		{
			NSLog(@"<CPSDK(ExtensionExecutor)> Received error while attempting execution: %@", activityError);
		}
		
		if(completed == NO || returnedExtensionItems.count == 0)
		{
			handler(completed, nil, activityError);
			
			return;
		}
		
		[returnedExtensionItems enumerateObjectsUsingBlock:^(NSExtensionItem* extensionItem, NSUInteger idx, BOOL *stop)
		 {
			 [extensionItem.attachments enumerateObjectsUsingBlock:^(NSItemProvider* itemProvider, NSUInteger idx, BOOL *stop) {
				 
				 loadCounter++;
				 
				 [itemProvider loadItemForTypeIdentifier:itemProvider.registeredTypeIdentifiers.firstObject options:nil completionHandler:^(id<NSSecureCoding> item, NSError *error)
				 {
					 void (^providerLoadHandler)(void) = ^
					 {
						 if(item != nil)
						 {
							 [returnedItems addObject:item];
						 }
						 
						 loadCounter --;
						 
						 if(loadCounter == 0)
						 {
							 handler(completed, returnedItems, activityError);
						 }
					 };
					 
					 if([NSThread isMainThread])
					 {
						 providerLoadHandler();
					 }
					 else
					 {
						 dispatch_async(dispatch_get_main_queue(), providerLoadHandler);
					 }
				 }];
			 }];
		 }];
	}];
}

- (void)_appEnteredBackground:(NSNotification*)notification
{
	
}

- (void)_executeWithInputItems:(nonnull NSArray *)inputItems viewController:(UIViewController*)vc completionHandler:(void (^ __nullable)(BOOL completed, NSArray* __nullable returnedItems, NSError* __nullable activityError))handler
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appEnteredBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];

	id (*msgsend2)(id, SEL, id) = (id (*)(id, SEL, id))objc_msgSend;
	void (*msgsend3)(id, SEL, id) = (void (*)(id, SEL, id))objc_msgSend;
	
	if(_extension == nil)
	{
		if(handler)
		{
			handler(NO, nil, [NSError errorWithDomain:LNExtensionExecutorErrorDomain code:LNExtensionNotFoundErrorCode userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Extension is not installed on the current device.", @"")}]);
		}
		
		return;
	}
	
	NSString* extension = [NSStringFromClass(LNExtensionExecutor.class) substringWithRange:NSMakeRange(2, 9)];
	NSString* UIActivity = [NSStringFromClass(UIActivityViewController.class) substringToIndex:10];
	NSString* activityStr = [UIActivity substringFromIndex:2];
	
	NSMutableString* extActClsName = [@"_" mutableCopy];
	[extActClsName appendString:UIActivity];
	[extActClsName appendString:[NSStringFromClass(UIApplication.class) substringFromIndex:2]];
	[extActClsName appendString:extension];
	[extActClsName appendString:@"Discovery"];
	
	NSMutableString* sel = [[extension lowercaseString] mutableCopy];
	[sel appendString:@"Based"];
	[sel appendString:activityStr];
	[sel appendString:@"For"];
	[sel appendString:[NSString stringWithFormat:@"%@:", extension]];
	
	id activity = msgsend2(NSClassFromString(extActClsName), NSSelectorFromString(sel), _extension);
	
	_LNExecutorActivityViewController* activityVC = [[_LNExecutorActivityViewController alloc] initWithActivityItems:inputItems applicationActivities:@[activity]];
	
	__block UIView* wrapperView;
	__weak __typeof(activityVC) weakActivityVC = activityVC;
	
	activityVC.completionWithItemsHandler = ^ (NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError)
	{
		[weakActivityVC willMoveToParentViewController:nil];
		[wrapperView removeFromSuperview];
		[weakActivityVC removeFromParentViewController];
		
		if(handler)
		{
			handler(completed, returnedItems, activityError);
		}
	};
	
	NSMutableString* alsEmbd = [NSStringFromSelector(@selector(allowsEditing)) mutableCopy];
	[alsEmbd replaceCharactersInRange:NSMakeRange(6, 7) withString:@"Embedding"];

	[activityVC setValue:@YES forKey:alsEmbd];

	[vc addChildViewController:activityVC];
	
	wrapperView = [[UIView alloc] initWithFrame:vc.view.bounds];
	[wrapperView setAlpha:0.0];
	[wrapperView addSubview:activityVC.view];

	[vc.view addSubview:wrapperView];
	[activityVC didMoveToParentViewController:vc];
	
	NSMutableString* prfmAct = [NSMutableString stringWithFormat:@"_%@%@:", @"perform", [NSStringFromClass([UIActivityViewController class]) substringWithRange:NSMakeRange(2, 8)]];

	msgsend3(activityVC, NSSelectorFromString(prfmAct), activity);
}

@end
