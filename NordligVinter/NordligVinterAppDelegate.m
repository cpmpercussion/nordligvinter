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
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjects:@[ICE_DRUM_DEFAULT,SNOWBELLS_DEFAULT,CLUSTERS_DEFAULT,PAUSE_DEFAULT] forKeys:@[ICE_DRUM_PREFERENCE,SNOWBELLS_PREFERENCE,CLUSTERS_PREFERENCE,PAUSE_PREFERENCE]];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    //[[NSUserDefaults standardUserDefaults] synchronize];
    
    if (![[NSUserDefaults standardUserDefaults] stringForKey:ICE_DRUM_PREFERENCE] &&
        ![[NSUserDefaults standardUserDefaults] stringForKey:CLUSTERS_PREFERENCE] &&
        ![[NSUserDefaults standardUserDefaults] stringForKey:SNOWBELLS_PREFERENCE] &&
        ![[NSUserDefaults standardUserDefaults] stringForKey:PAUSE_PREFERENCE]) {
        
    }

    
    
    // Override point for customization after application launch.
    application.idleTimerDisabled = YES; // we don't want the screen to sleep.
    self.viewController = (NordligVinterViewController *) self.window.rootViewController;
    
    _audioController = [[PdAudioController alloc] init];
    if ([self.audioController configurePlaybackWithSampleRate:44100 numberChannels:2 inputEnabled:YES mixingEnabled:NO] != PdAudioOK) {
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
    [PdBase sendFloat:[[[NSUserDefaults standardUserDefaults] stringForKey:ICE_DRUM_PREFERENCE] intValue] toReceiver:@"icedrumlength"];
    
    [PdBase sendFloat:[[[NSUserDefaults standardUserDefaults] stringForKey:SNOWBELLS_PREFERENCE] intValue] toReceiver:@"snowbellslength"];
    
    [PdBase sendFloat:[[[NSUserDefaults standardUserDefaults] stringForKey:CLUSTERS_PREFERENCE] intValue] toReceiver:@"clusterslength"];
    [self.viewController setInBetweenPauseLength:[[[NSUserDefaults standardUserDefaults] stringForKey:PAUSE_PREFERENCE] intValue]];
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
