//
//  LNExtensionExecutor.h
//
//  Created by Leo Natan on 2015-03-02.
//

@import Foundation;

extern NSString* __nonnull const LNActivityExecutorErrorDomain;
extern NSInteger const LNExtensionNotFoundErrorCode;

NS_ASSUME_NONNULL_BEGIN

@interface LNExtensionExecutor : NSObject

+ (nullable instancetype)executorWithExtensionBundleIdentifier:(NSString*)bundleIdentifier;

- (void)executeWithInputItems:(NSArray *)inputItems completionHandler:(void (^ __nonnull)(BOOL completed, NSArray * __nullable returnedItems, NSError* __nullable activityError))handler;

@end

NS_ASSUME_NONNULL_END
