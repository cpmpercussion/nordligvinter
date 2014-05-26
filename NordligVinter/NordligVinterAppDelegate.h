//
//  NordligVinterAppDelegate.h
//  NordligVinter
//
//  Created by Charles Martin on 9/05/12.
//  Copyright (c) 2012 Charles Martin Percussion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PdAudioController.h"
#import "NordligVinterViewController.h"
#import "PdBase.h"

@interface NordligVinterAppDelegate : UIResponder <UIApplicationDelegate, PdReceiverDelegate> {}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NordligVinterViewController *viewController;
@property (strong, nonatomic, readonly) PdAudioController *audioController;
@end
