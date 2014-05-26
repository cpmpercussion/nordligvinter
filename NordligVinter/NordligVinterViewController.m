//
//  NordligVinterViewController.m
//  NordligVinter
//
//  Created by Charles Martin on 9/05/12.
//  Copyright (c) 2012 Charles Martin Percussion. All rights reserved.
//

#import "NordligVinterViewController.h"

#define PAUSE_LENGTH 30
#define COMPOSITION_NONE 0
#define COMPOSITION_ICEDRUM 1
#define COMPOSITION_CLUSTERS 2
#define COMPOSITION_SNOWBELLS 3

@implementation NordligVinterViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.iceDrumSwitch setOn:NO];
    [self.snowBellSwitch setOn:NO];
    [self.clusterSwitch setOn:NO];
    [self.iceDrumProgress setProgress:0];
    [self.snowBellProgress setProgress:0];
    [self.clusterProgress setProgress:0];
    [self.defaultProgress setProgress:0];
    [self.midiLabel setText: @""];
    [self.midiInterfaceLabel setText: @""];
    
    self.midi = [[PGMidi alloc] init];
    self.midi.delegate = self;
    [self.midi enableNetwork:YES];
    [self attachToAllExistingSources];
    
//    for (PGMidiSource *source in self.midi.sources)
//    {
//        NSLog(source.name);
//    }
}

- (IBAction)iceDrumSwitched:(UISwitch *)sender {
    if (sender.on)
    {
        [PdBase sendFloat:1 toReceiver:@"icedrumswitchin"];
        NSLog(@"ice drum switched ON!");
        self.currentComposition = @"icedrumswitchin";
    } else {
        [PdBase sendFloat:0 toReceiver:@"icedrumswitchin"];
        NSLog(@"ice drum switched OFF!");
    } 
}
- (IBAction)snowBellSwitched:(UISwitch *)sender {
    if (sender.on)
    {
        [PdBase sendFloat:1 toReceiver:@"snowbellswitchin"];
        NSLog(@"snow bells switched ON!");
        self.currentComposition = @"snowbellswitchin";
    } else {
        [PdBase sendFloat:0 toReceiver:@"snowbellswitchin"];
        NSLog(@"snow bells switched OFF!");
    } 
}
- (IBAction)clusterSwitched:(UISwitch *)sender {
    if (sender.on)
    {
        [PdBase sendFloat:1 toReceiver:@"clusterswitchin"];
        NSLog(@"clusters switched ON!");
        self.currentComposition = @"clusterswitchin";
    } else {
        [PdBase sendFloat:0 toReceiver:@"clusterswitchin"];
        NSLog(@"clusters switched OFF!");
    } 
}

- (IBAction)reverbSwitched:(UISwitch *)sender {
    if (sender.on)
    {
        [PdBase sendFloat:1 toReceiver:@"fxswitchin"];
        NSLog(@"Reverb switched ON!");
    } else {
        [PdBase sendFloat:0 toReceiver:@"fxswitchin"];
        NSLog(@"Reverb switched OFF!");
    }
}

- (IBAction)inLevelSliderMoved:(UISlider *)sender {
    [PdBase sendFloat:(sender.value * 100) toReceiver:@"reverbsend"];
}

- (IBAction)continuousPerformanceSwitched:(UISwitch *)sender {
    self.continuousPerformance = sender.on;
}


- (void)cueNextComposition:(int)compositionNumber {
    [NSTimer scheduledTimerWithTimeInterval:self.inBetweenPauseLength
                                     target:self
                                   selector:@selector(playNextComposition:)
                                   userInfo:[NSNumber numberWithInt:compositionNumber]
                                    repeats:NO];
}

- (void)playNextComposition:(NSTimer *)cueTimer {
    int compositionNumber = [(NSNumber *) cueTimer.userInfo intValue];
    
    if (compositionNumber == COMPOSITION_ICEDRUM) {
        [self.iceDrumSwitch setOn:YES animated:YES];
        [PdBase sendFloat:1 toReceiver:@"icedrumswitchin"];
    } else if (compositionNumber == COMPOSITION_CLUSTERS) {
        [self.clusterSwitch setOn:YES animated:YES];
        [PdBase sendFloat:1 toReceiver:@"clusterswitchin"];
    } else if (compositionNumber == COMPOSITION_SNOWBELLS) {
        [self.snowBellSwitch setOn:YES animated:YES];
        [PdBase sendFloat:1 toReceiver:@"snowbellswitchin"];
    } else if (compositionNumber == COMPOSITION_NONE) {
        // do nothing
    }
}


#pragma mark - Custom Accessors

// whenever loadPercentage is set, update the label
- (void)setClusterComp:(float)value {
    [self.clusterProgress setProgress:value animated:YES];
    if (value == 1.0 && self.continuousPerformance){
        [self cueNextComposition:COMPOSITION_SNOWBELLS];
        [self.clusterSwitch setOn:NO animated:YES];
        [PdBase sendFloat:0 toReceiver:@"clusterswitchin"];
        NSLog(@"Cue Snowbells...");
    }
}
- (void)setIcedrumComp:(float)value {
    [self.iceDrumProgress setProgress:value animated:YES];
    if (value == 1.0 && self.continuousPerformance){
        [self cueNextComposition:COMPOSITION_CLUSTERS];
        [self.iceDrumSwitch setOn:NO animated:YES];
        [PdBase sendFloat:0 toReceiver:@"icedrumswitchin"];
        NSLog(@"Cue Clusters...");
    }
}
-(void)setSnowbellComp:(float)value {
    [self.snowBellProgress setProgress:value animated:YES];
}
-(void)setDefaultVol:(float)value {
    [self.defaultProgress setProgress:value animated:YES];
}
-(void)setInputVol:(float)inputVol {
    [self.inputLevel setProgress:inputVol animated:YES];
}


#pragma mark Midi
-(void) attachToAllExistingSources
{
    for (PGMidiSource *source in self.midi.sources)
    {
        source.delegate = self;
        [self.midiLabel setText:@"MIDI:"];
        [self.midiInterfaceLabel setText:source.name];
    }
}

//-(void) setMidi:(PGMidi*)m
//{
//    if (m) {
//        self.midi.delegate = nil;
//        self.midi = m;
//        self.midi.delegate = self;
//        [self attachToAllExistingSources];
//    }
//}

-(void) midi:(PGMidi*)midi sourceAdded:(PGMidiSource *)source
{
    [self.midiLabel setText:@"MIDI:"];
    [self.midiInterfaceLabel setText:source.name];
    source.delegate = self;
}

-(void) midi:(PGMidi*)midi sourceRemoved:(PGMidiSource *)source
{
    [self.midiLabel setText:@""];
    [self.midiInterfaceLabel setText:@""];
}


-(void) midiSource:(PGMidiSource *)input midiReceived:(const MIDIPacketList *)packetList
{    
    const MIDIPacket *packet = &packetList->packet[0];
    for (int i = 0; i < packetList->numPackets; ++i)
    {
        if ((packet->length == 3) && ((packet->data[0] & 0xf0) == 0x90) && (packet->data[2] != 0)) {
            [PdBase sendNoteOn:1 pitch:packet->data[1] velocity:packet->data[2]];
        }
        packet = MIDIPacketNext(packet);
    }
}

- (void) midi:(PGMidi*)midi destinationAdded:(PGMidiDestination *)destination { }
- (void) midi:(PGMidi*)midi destinationRemoved:(PGMidiDestination *)destination { }

@end
