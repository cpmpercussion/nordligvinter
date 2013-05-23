//
//  NordligVinterAppDelegate.m
//  NordligVinter
//
//  Created by Charles Martin on 9/05/12.
//  Copyright (c) 2012 Charles Martin Percussion. All rights reserved.
//

#import "NordligVinterAppDelegate.h"
#import "NordligVinterViewController.h"

#import "PGMidi.h"
#import "PGArc.h"

@implementation NordligVinterAppDelegate

@synthesize window = _window;
@synthesize viewController = viewController_;
@synthesize audioController = _audioController;

extern void bonk_tilde_setup(void);


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjects:@[@"160",@"240",@"120"] forKeys:@[@"IceDrumLength",@"SnowBellsLength",@"ClustersLength"]];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    
    
    // Override point for customization after application launch.
    application.idleTimerDisabled = YES; // we don't want the screen to sleep.
    self.viewController = (NordligVinterViewController *) self.window.rootViewController;
    
    _audioController = [[PdAudioController alloc] init];
    if ([self.audioController configurePlaybackWithSampleRate:22050 numberChannels:2 inputEnabled:YES mixingEnabled:NO] != PdAudioOK) {
        NSLog(@"failed to initialise audio components");
    }
    bonk_tilde_setup();
    
    // set AppDelegate as PdRecieverDelegate to recieve messages from pd
    [PdBase setDelegate:self];
    
    // recieve messages from pd
    [PdBase subscribe:@"snowbackground"];
	[PdBase subscribe:@"icedrumcomp"];
    [PdBase subscribe:@"clustercomp"];
    [PdBase subscribe:@"snowbellcomp"];
    [PdBase subscribe:@"inputvolume"];
    
    //[self.audioController configureTicksPerBuffer:128];
	[PdBase openFile:@"nordligvinter_main.pd" path:[[NSBundle mainBundle] resourcePath]];
	[self.audioController setActive:YES];
	[self.audioController print];
    
    //Configure MIDI
    midi = [[PGMidi alloc] init];
    [midi enableNetwork:YES];
    self.viewController.midi = midi;
    
    
    // Send Length Preferences to Pd
    [[NSUserDefaults standardUserDefaults] synchronize]; 
    [PdBase sendFloat:[[[NSUserDefaults standardUserDefaults] stringForKey:@"IceDrumLength"] intValue] toReceiver:@"icedrumlength"];

    [PdBase sendFloat:[[[NSUserDefaults standardUserDefaults] stringForKey:@"SnowBellsLength"] intValue] toReceiver:@"snowbellslength"];

    [PdBase sendFloat:[[[NSUserDefaults standardUserDefaults] stringForKey:@"ClustersLength"] intValue] toReceiver:@"clusterslength"];

    return YES;
}

#pragma mark - PdReceiverDelegate

-(void)receivePrint:(NSString *)message {
    //NSLog(@"Pd Console:%@", message);
}

-(void)receiveFloat:(float)received fromSource:(NSString *)source {
    
    //NSLog(@"Pd Message:%@ , %f", source, received);
    
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
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    self.audioController.active = NO;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    
    self.audioController.active = YES;
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    [PdBase sendFloat:[[[NSUserDefaults standardUserDefaults] stringForKey:@"IceDrumLength"] intValue] toReceiver:@"icedrumlength"];
    
    [PdBase sendFloat:[[[NSUserDefaults standardUserDefaults] stringForKey:@"SnowBellsLength"] intValue] toReceiver:@"snowbellslength"];
    
    [PdBase sendFloat:[[[NSUserDefaults standardUserDefaults] stringForKey:@"ClustersLength"] intValue] toReceiver:@"clusterslength"];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
