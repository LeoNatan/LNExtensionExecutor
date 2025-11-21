//
//  SpyActivityViewController.h
//  LNExtensionExecutorExample
//
//  Created by Léo Natan on 21/11/25.
//

#import <UIKit/UIKit.h>

@interface UIActivityViewController ()

- (void)_performActivity:(UIActivity*)activity;

@end

NS_ASSUME_NONNULL_BEGIN

@interface SpyActivityViewController : UIActivityViewController

@end

NS_ASSUME_NONNULL_END
