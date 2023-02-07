//
//  LNExtensionExecutor.h
//  LNExtensionExecutor
//
//  Created by Leo Natan on 2015-03-02.
//

@import UIKit;

extern NSErrorDomain __nonnull const LNActivityExecutorErrorDomain;
extern NSInteger const LNExtensionNotFoundErrorCode;

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_UI_ACTOR
__TVOS_PROHIBITED __WATCHOS_PROHIBITED
@interface LNExtensionExecutor : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (nullable instancetype)initWithExtensionBundleIdentifier:(NSString*)bundleId error:(NSError**)error NS_DESIGNATED_INITIALIZER;

+ (nullable instancetype)executorWithExtensionBundleIdentifier:(NSString*)bundleIdentifier NS_REFINED_FOR_SWIFT;
+ (nullable instancetype)executorWithExtensionBundleIdentifier:(NSString*)bundleIdentifier error:(NSError* __autoreleasing*)error NS_REFINED_FOR_SWIFT;

- (void)executeWithItemsConfiguration:(id<UIActivityItemsConfigurationReading>)activityItemsConfiguration onViewController:(UIViewController*)vc completionHandler:(void (^ __nonnull)(BOOL completed, NSArray* __nullable returnedItems, NSError* __nullable activityError))handler  API_AVAILABLE(ios(14.0)) API_UNAVAILABLE(watchos) API_UNAVAILABLE(tvos);
- (void)executeWithActivityItems:(NSArray*)activityItems onViewController:(UIViewController*)vc completionHandler:(void (^ __nonnull)(BOOL completed, NSArray* __nullable returnedItems, NSError* __nullable activityError))handler;

- (void)executeWithInputItems:(NSArray*)inputItems onViewController:(UIViewController*)vc completionHandler:(void (^ __nonnull)(BOOL completed, NSArray* __nullable returnedItems, NSError* __nullable activityError))handler __attribute__((deprecated("Use execute(withActivityItems:on:completionHandler:) or execute(withItemsConfiguration:on:completionHandler:) instead.")));

@end

NS_ASSUME_NONNULL_END
