//
//  NordligVinterAppDelegate.m
//  NordligVinter
//
//  Created by Charles Martin on 9/05/12.
//  Copyright (c) 2012 Charles Martin Percussion. All rights reserved.
//

#import "NordligVinterAppDelegate.h"
#import "NordligVinterViewController.h"

@implementation NordligVinterAppDelegate

extern void bonk_tilde_setup(void);

#define ICE_DRUM_PREFERENCE @"IceDrumLength"
#define SNOWBELLS_PREFERENCE @"SnowBellsLength"
#define CLUSTERS_PREFERENCE @"ClustersLength"
#define PAUSE_PREFERENCE @"PauseLength"

#define ICE_DRUM_DEFAULT @"160"
#define SNOWBELLS_DEFAULT @"240"
#define CLUSTERS_DEFAULT @"180"
#define PAUSE_DEFAULT @"30"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjects:@[ICE_DRUM_DEFAULT,SNOWBELLS_DEFAULT,CLUSTERS_DEFAULT,PAUSE_DEFAULT]
                                                            forKeys:@[ICE_DRUM_PREFERENCE,SNOWBELLS_PREFERENCE,CLUSTERS_PREFERENCE,PAUSE_PREFERENCE]];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    
    if (![[NSUserDefaults standardUserDefaults] stringForKey:ICE_DRUM_PREFERENCE] &&
        ![[NSUserDefaults standardUserDefaults] stringForKey:CLUSTERS_PREFERENCE] &&
        ![[NSUserDefaults standardUserDefaults] stringForKey:SNOWBELLS_PREFERENCE] &&
        ![[NSUserDefaults standardUserDefaults] stringForKey:PAUSE_PREFERENCE]) {
    }

    application.idleTimerDisabled = YES; // we don't want the screen to sleep.
    self.viewController = (NordligVinterViewController *) self.window.rootViewController;
    
    _audioController = [[PdAudioController alloc] init];
    if ([self.audioController configurePlaybackWithSampleRate:44100 numberChannels:2 inputEnabled:YES mixingEnabled:NO] != PdAudioOK) {
        NSLog(@"failed to initialise audio components");
    }
    
    bonk_tilde_setup();
    [PdBase setDelegate:self];
    [PdBase subscribe:@"snowbackground"];
	[PdBase subscribe:@"icedrumcomp"];
    [PdBase subscribe:@"clustercomp"];
    [PdBase subscribe:@"snowbellcomp"];
    [PdBase subscribe:@"inputvolume"];
    
    [PdBase openFile:@"nordligvinter_main.pd" path:[[NSBundle mainBundle] resourcePath]];
	[self.audioController setActive:YES];
	[self.audioController print];
    
    // Send Length Preferences to Pd
    [[NSUserDefaults standardUserDefaults] synchronize]; 
    [PdBase sendFloat:[[[NSUserDefaults standardUserDefaults] stringForKey:ICE_DRUM_PREFERENCE] intValue] toReceiver:@"icedrumlength"];
    [PdBase sendFloat:[[[NSUserDefaults standardUserDefaults] stringForKey:SNOWBELLS_PREFERENCE] intValue] toReceiver:@"snowbellslength"];
    [PdBase sendFloat:[[[NSUserDefaults standardUserDefaults] stringForKey:CLUSTERS_PREFERENCE] intValue] toReceiver:@"clusterslength"];
    [self.viewController setInBetweenPauseLength:[[[NSUserDefaults standardUserDefaults] stringForKey:PAUSE_PREFERENCE] intValue]];
    return YES;
}

#pragma mark - PdReceiverDelegate
-(void)receivePrint:(NSString *)message {
    //NSLog(@"Pd Console:%@", message);
}

-(void)receiveFloat:(float)received fromSource:(NSString *)source {
    if ([source isEqualToString:@"icedrumcomp"]) {
        received = received/100;
        self.viewController.icedrumComp = received;
    } else if ([source isEqualToString:@"clustercomp"]) {
        received = received/100;
        self.viewController.clusterComp = received;
    } else if ([source isEqualToString:@"snowbellcomp"]) {
        received = received/100;
        self.viewController.snowbellComp = received;
    } else if ([source isEqualToString:@"snowbackground"]) {
        received = received/100;
        self.viewController.defaultVol = received;
    } else if ([source isEqualToString:@"inputvolume"]) {
        self.viewController.inputVol = received;
    }
}

#pragma mark - UIApplicationDelegate
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    self.audioController.active = NO;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    self.audioController.active = YES;
    [[NSUserDefaults standardUserDefaults] synchronize];
    [PdBase sendFloat:[[[NSUserDefaults standardUserDefaults] stringForKey:ICE_DRUM_PREFERENCE] intValue] toReceiver:@"icedrumlength"];
    [PdBase sendFloat:[[[NSUserDefaults standardUserDefaults] stringForKey:SNOWBELLS_PREFERENCE] intValue] toReceiver:@"snowbellslength"];
    [PdBase sendFloat:[[[NSUserDefaults standardUserDefaults] stringForKey:CLUSTERS_PREFERENCE] intValue] toReceiver:@"clusterslength"];
    [self.viewController setInBetweenPauseLength:[[[NSUserDefaults standardUserDefaults] stringForKey:PAUSE_PREFERENCE] intValue]];
}

@end
