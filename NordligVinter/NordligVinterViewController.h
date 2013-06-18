//
//  NordligVinterViewController.h
//  NordligVinter
//
//  Created by Charles Martin on 9/05/12.
//  Copyright (c) 2012 Charles Martin Percussion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>


#import "PdDispatcher.h"

@class PGMidi;

@interface NordligVinterViewController : UIViewController {
    void *patch;
    
    PGMidi *midi;
    
    CMMotionManager *motionManager;
    NSOperationQueue *queue;
}


@property (nonatomic) BOOL continuousPerformance;
@property (strong, nonatomic) NSString *currentComposition;

@property (weak, nonatomic) IBOutlet UISwitch *iceDrumSwitch;
- (IBAction)iceDrumSwitched:(id)sender;
@property (weak, nonatomic) IBOutlet UIProgressView *iceDrumProgress;

@property (weak, nonatomic) IBOutlet UISwitch *snowBellSwitch;
- (IBAction)snowBellSwitched:(id)sender;
@property (weak, nonatomic) IBOutlet UIProgressView *snowBellProgress;

@property (weak, nonatomic) IBOutlet UISwitch *clusterSwitch;
- (IBAction)clusterSwitched:(id)sender;
@property (weak, nonatomic) IBOutlet UIProgressView *clusterProgress;

@property (nonatomic) float clusterComp;
@property (nonatomic) float icedrumComp;
@property (nonatomic) float snowbellComp;
@property (nonatomic) float defaultVol;
@property (nonatomic) float inputVol;





@property (weak, nonatomic) IBOutlet UIProgressView *defaultProgress;
@property (weak, nonatomic) IBOutlet UIProgressView *inputLevel;
@property (weak, nonatomic) IBOutlet UISwitch *reverbSwitch;
- (IBAction)reverbSwitched:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *inputLevelSlider;
- (IBAction)inLevelSliderMoved:(id)sender;

// MIDI
@property (weak, nonatomic) IBOutlet UILabel *midiLabel;
@property (weak, nonatomic) IBOutlet UILabel *midiInterfaceLabel;
@property (nonatomic, assign) PGMidi *midi;

// Continuous performance properties
- (IBAction)continuousPerformanceSwitched:(UISwitch *)sender;
- (void)cueNextComposition:(int) compositionNumber;
- (void)playNextComposition:(NSTimer *) cueTimer;
@property (nonatomic) int inBetweenPauseLength;

@end
