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

@interface _LNExecutorRootViewController : UIViewController

@end

@implementation _LNExecutorRootViewController

- (BOOL)prefersStatusBarHidden
{
	return [UIApplication sharedApplication].statusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
	return UIStatusBarAnimationFade;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return [[UIApplication sharedApplication] statusBarStyle];
}

@end

@interface _LNExecutorActivityViewController : UIActivityViewController

@end

@implementation _LNExecutorActivityViewController

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
	viewControllerToPresent.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[super presentViewController:viewControllerToPresent animated:flag completion:completion];
}

@end

@implementation LNExtensionExecutor
{
	NSString* _identifier;
	UIWindow* _extensionPresentationWindow;
	
	id _extension;
}

+ (nullable instancetype)executorWithExtensionBundleIdentifier:(nonnull NSString*)bundleId
{
	return [[self alloc] _initWithExtensionBundleIdentifier:bundleId];
}

- (nullable instancetype)init
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

- (void)executeWithInputItems:(nonnull NSArray *)inputItems completionHandler:(void (^ __nonnull)(BOOL completed, NSArray * __nullable returnedItems, NSError* __nullable activityError))handler
{
	NSMutableArray* items = [NSMutableArray new];
	
	[inputItems enumerateObjectsUsingBlock:^(id item, NSUInteger idx, BOOL *stop) {
		NSItemProvider* itemProvider = [[NSItemProvider alloc] initWithItem:item typeIdentifier:(NSString *)kUTTypeItem];
		
		NSExtensionItem* extensionItem = [NSExtensionItem new];
		extensionItem.attachments = @[itemProvider];
		
		[items addObject:extensionItem];
	}];
	
	[self _executeWithInputItems:items retriesCount:3 completionHandler:^ (BOOL completed, NSArray * __nullable returnedExtensionItems, NSError * __nullable activityError) {

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
					 void (^providerLoadHandler)() = ^
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

- (void)_executeWithInputItems:(nonnull NSArray *)inputItems retriesCount:(NSUInteger)retriesCount completionHandler:(void (^ __nullable)(BOOL completed, NSArray* __nullable returnedItems, NSError* __nullable activityError))handler
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
	
	NSMutableString* extClsName = [NSStringFromClass([LNExtensionExecutor class]) mutableCopy];
	[extClsName deleteCharactersInRange:NSMakeRange(11, 8)];
	[extClsName replaceCharactersInRange:NSMakeRange(0, 2) withString:@"NS"];
	
	NSMutableString* extActClsName = [NSStringFromClass([UIApplication class]) mutableCopy];
	[extActClsName appendString:[extClsName substringFromIndex:2]];
	[extActClsName appendString:[NSStringFromClass([UIActivityViewController class]) substringWithRange:NSMakeRange(2, 8)]];
	
	NSString* slName = [NSMutableString stringWithFormat:@"initWith%@:", [extActClsName substringWithRange:NSMakeRange(2, 20)]];
	
	id x = msgsend2([NSClassFromString(extActClsName) alloc], NSSelectorFromString(slName), _extension);
	
	_extensionPresentationWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_extensionPresentationWindow.windowLevel = UIWindowLevelStatusBar - 1;
	_extensionPresentationWindow.rootViewController = [_LNExecutorRootViewController new];
	_extensionPresentationWindow.rootViewController.view.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.0];
	[_extensionPresentationWindow makeKeyAndVisible];
	
	_LNExecutorActivityViewController* vc = [[_LNExecutorActivityViewController alloc] initWithActivityItems:inputItems applicationActivities:@[x]];
	
	vc.completionWithItemsHandler = ^ (NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError)
	{
		_extensionPresentationWindow.hidden = YES;
		_extensionPresentationWindow = nil;
		
		if(handler)
		{
			handler(completed, returnedItems, activityError);
		}
	};
	
	NSMutableString* alsEmbd = [NSStringFromSelector(@selector(allowsEditing)) mutableCopy];
	[alsEmbd replaceCharactersInRange:NSMakeRange(6, 7) withString:@"Embedding"];
	
	[vc setValue:@YES forKey:alsEmbd];

	[_extensionPresentationWindow.rootViewController addChildViewController:vc];
	
	UIView* wrapperView = [[UIView alloc] initWithFrame:_extensionPresentationWindow.rootViewController.view.bounds];
	[wrapperView setAlpha:0.0];
	[wrapperView addSubview:vc.view];
	
	[_extensionPresentationWindow.rootViewController.view addSubview:wrapperView];
	[vc didMoveToParentViewController:_extensionPresentationWindow.rootViewController];
	
	NSMutableString* prfmAct = [NSMutableString stringWithFormat:@"_%@%@:", @"perform", [NSStringFromClass([UIActivityViewController class]) substringWithRange:NSMakeRange(2, 8)]];
	
	msgsend3(vc, NSSelectorFromString(prfmAct), x);
}

@end
