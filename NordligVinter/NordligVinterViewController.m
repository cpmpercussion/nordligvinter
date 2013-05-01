//
//  NordligVinterViewController.m
//  NordligVinter
//
//  Created by Charles Martin on 9/05/12.
//  Copyright (c) 2012 Charles Martin Percussion. All rights reserved.
//

#import "NordligVinterViewController.h"

#import "PGMidi.h"
#import <CoreMIDI/CoreMIDI.h>

@interface NordligVinterViewController () <PGMidiDelegate, PGMidiSourceDelegate>

@end

@implementation NordligVinterViewController
@synthesize iceDrumSwitch;
@synthesize iceDrumProgress;
@synthesize snowBellSwitch;
@synthesize snowBellProgress;
@synthesize clusterSwitch;
@synthesize reverbSwitch;
@synthesize clusterProgress;
@synthesize defaultProgress;
@synthesize inputLevel;
@synthesize inputLevelSlider;
@synthesize midiLabel;
@synthesize midiInterfaceLabel;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [iceDrumSwitch setOn:NO];
    [snowBellSwitch setOn:NO];
    [clusterSwitch setOn:NO];
    [iceDrumProgress setProgress:0];
    [snowBellProgress setProgress:0];
    [clusterProgress setProgress:0];
    [defaultProgress setProgress:0];
    
    [midiLabel setText: @""];
    [midiInterfaceLabel setText: @""];
}

- (void)viewDidUnload
{
    [PdBase setDelegate:nil];
    [self setIceDrumSwitch:nil];
    [self setIceDrumProgress:nil];
    [self setSnowBellSwitch:nil];
    [self setSnowBellProgress:nil];
    [self setClusterSwitch:nil];
    [self setClusterProgress:nil];
    [self setDefaultProgress:nil];
    [self setInputLevel:nil];
    [self setReverbSwitch:nil];
    [self setInputLevelSlider:nil];
    [self setMidiLabel:nil];
    [self setMidiInterfaceLabel:nil];
    [super viewDidUnload];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        // return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
        if (interfaceOrientation == UIInterfaceOrientationPortrait) {
            return YES;
        } else {
            return NO;
        }
    } else {
        if (interfaceOrientation == UIInterfaceOrientationPortrait) {
            return YES;
        } else {
            return NO;
        }
    }    
}

- (IBAction)iceDrumSwitched:(id)sender {
    if (iceDrumSwitch.on)
    {
        [PdBase sendFloat:1 toReceiver:@"icedrumswitchin"];
        NSLog(@"ice drum switched ON!");
    } else {
        [PdBase sendFloat:0 toReceiver:@"icedrumswitchin"];
        NSLog(@"ice drum switched OFF!");
    } 
}
- (IBAction)snowBellSwitched:(id)sender {
    if (snowBellSwitch.on) 
    {
        [PdBase sendFloat:1 toReceiver:@"snowbellswitchin"];
        NSLog(@"snow bells switched ON!");
    } else {
        [PdBase sendFloat:0 toReceiver:@"snowbellswitchin"];
        NSLog(@"snow bells switched OFF!");
    } 
}
- (IBAction)clusterSwitched:(id)sender {
    if (clusterSwitch.on) 
    {
        [PdBase sendFloat:1 toReceiver:@"clusterswitchin"];
        NSLog(@"clusters switched ON!");
    } else {
        [PdBase sendFloat:0 toReceiver:@"clusterswitchin"];
        NSLog(@"clusters switched OFF!");
    } 
}

- (IBAction)reverbSwitched:(id)sender {
    if (reverbSwitch.on)
    {
        [PdBase sendFloat:1 toReceiver:@"fxswitchin"];
        NSLog(@"Reverb switched ON!");
    } else {
        [PdBase sendFloat:0 toReceiver:@"fxswitchin"];
        NSLog(@"Reverb switched OFF!");
    }
}

- (IBAction)inLevelSliderMoved:(id)sender {
    float a = inputLevelSlider.value * 100;
    
    [PdBase sendFloat:a toReceiver:@"reverbsend"];
}


#pragma mark - Custom Accessors

// whenever loadPercentage is set, update the label
- (void)setClusterComp:(float)value {
    [clusterProgress setProgress:value animated:YES];
}
- (void)setIcedrumComp:(float)value {
    [iceDrumProgress setProgress:value animated:YES];
}
-(void)setSnowbellComp:(float)value {
    [snowBellProgress setProgress:value animated:YES];
}
-(void)setDefaultVol:(float)value {
    [defaultProgress setProgress:value animated:YES];
}
-(void)setInputVol:(float)inputVol {
    [inputLevel setProgress:inputVol animated:YES];
}


#pragma mark Midi

-(void) attachToAllExistingSources
{
    for (PGMidiSource *source in midi.sources)
    {
        source.delegate = self;
    }
}

-(void) setMidi:(PGMidi*)m
{
    midi.delegate = nil;
    midi = m;
    midi.delegate = self;
    
    [self attachToAllExistingSources];
}

-(void) midi:(PGMidi*)midi sourceAdded:(PGMidiSource *)source
{
    [midiLabel setText:@"MIDI:"];
    [midiInterfaceLabel setText:source.name];
    source.delegate = self;
}

-(void) midi:(PGMidi*)midi sourceRemoved:(PGMidiSource *)source
{
    [midiLabel setText:@""];
    [midiInterfaceLabel setText:@""];
    
}

-(void) midi:(PGMidi*)midi destinationAdded:(PGMidiDestination *)destination
{

}

-(void) midi:(PGMidi*)midi destinationRemoved:(PGMidiDestination *)destination
{
    
}


-(void) midiSource:(PGMidiSource *)input midiReceived:(const MIDIPacketList *)packetList
{    
    const MIDIPacket *packet = &packetList->packet[0];
    //
    // Cycle through midi packets and do the parsing.
    //
    for (int i = 0; i < packetList->numPackets; ++i)
    {
        if ((packet->length == 3) && ((packet->data[0] & 0xf0) == 0x90) && (packet->data[2] != 0)) {
            [PdBase sendNoteOn:1 pitch:packet->data[1] velocity:packet->data[2]];
        }
        packet = MIDIPacketNext(packet);
    }
}


@end
