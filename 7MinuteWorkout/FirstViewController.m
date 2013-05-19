//
//  FirstViewController.m
//  7MinuteWorkout
//
//  Created by Dan Weston on 5/18/13.
//  Copyright (c) 2013 Dan Weston. All rights reserved.
//

#import "FirstViewController.h"
#import "FliteTTS.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

#define kExerciseDuration 5.0
#define kRestDuration 5.0

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    exerciseImageNames = [NSArray arrayWithObjects:@"jumping-jacks.png",
                          @"wall-sit.png",
                          @"push-up.png",
                          @"crunch.png",
                          @"step-up.png",
                          @"squat.png",
                          @"chair-dip.png",
                          @"plank.png",
                          @"high-knees.png",
                          @"lunge.png",
                          @"pushup-rotate.png",
                          @"side-plank.png",nil];
    
    exerciseNamesText = [NSArray arrayWithObjects:@"Jumping jacks",
                          @"wall sit",
                          @"push ups",
                          @"crunch",
                          @"chair step up",
                          @"squat",
                          @"chair arm dip",
                          @"plank",
                          @"high knees running",
                          @"lunge",
                          @"push up with rotatation",
                          @"side plank",nil];
    
    self.timeRemainingProgress.progress = 0.0;

    self.timeRemainingLabel.hidden = YES;
    self.timeRemainingLabel1.hidden = YES;
    self.timeRemainingProgress.hidden = YES;
    [self resetTimeRemaining];

    fliteEngine = [[FliteTTS alloc] init];
    //[fliteEngine setVoice:@"cmu_us_awb"];  // vaguely UK
    //[fliteEngine setVoice:@"cmu_us_kal"];  // strange computer
    //[fliteEngine setVoice:@"cmu_us_kal16"];  // strange computer
    //[fliteEngine setVoice:@"cmu_us_rms"];  // laid back
    [fliteEngine setVoice:@"cmu_us_slt"];  // female
    [fliteEngine setPitch:150.0 variance:50.0 speed:1.1];	// Change the voice properties


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) resetTimeRemaining
{
    timeRemainingInExercise = kExerciseDuration;
    timeRemainingInRest = kRestDuration;
}

- (void) countDownTimerForExcercise:(NSTimer *) timer
{
    timeRemainingInExercise--;
    [self updateTimeRemainingUI];

    if(timeRemainingInExercise > 1)
    {
        currentTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDownTimerForExcercise:) userInfo:nil repeats:NO];
    }
    else
    {
        currentTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(exerciseEnded:) userInfo:nil repeats:NO];
    }

}

- (void) countDownTimerForRest:(NSTimer *) timer
{
    timeRemainingInRest--;
    [self updateTimeRemainingUI];

    if(timeRemainingInRest > 1)
    {
        currentTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDownTimerForRest:) userInfo:nil repeats:NO];
    }
    else
    {
        currentTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(restEnded:) userInfo:nil repeats:NO];
    }
}

- (void) updateTimeRemainingUI
{
    if(exercisesInProcess && resting)
    {
        self.timeRemainingLabel.text = [NSString stringWithFormat:@"%d",timeRemainingInRest];
        self.timeRemainingProgress.progress = (kRestDuration - timeRemainingInRest) / kRestDuration;
    }
    else
    {
        self.timeRemainingLabel.text = [NSString stringWithFormat:@"%d",timeRemainingInExercise];
        self.timeRemainingProgress.progress = (kExerciseDuration - timeRemainingInExercise) / kExerciseDuration;

    }
    [self.view setNeedsDisplay];
}

- (void) restEnded:(NSTimer *) timer
{
    // cue
    resting = NO;
    
     // cue the next exercise
    [self resetTimeRemaining];
    [self updateTimeRemainingUI];
    [self startExerciseAtIndex:currentExcerciseIndex];

}

- (void) startExerciseAtIndex:(int) index
{
    self.currentExerciseImageView.image = [UIImage imageNamed:[exerciseImageNames objectAtIndex:index]];
    [fliteEngine speakText:[NSString stringWithFormat:@"%@",[exerciseNamesText objectAtIndex:index]]];

    currentTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDownTimerForExcercise:) userInfo:nil repeats:NO];
}

- (void) startResting
{
    self.currentExerciseImageView.image = [UIImage imageNamed:@"resting.png"];
    [fliteEngine speakText:@"Rest now"];
    currentTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDownTimerForRest:) userInfo:nil repeats:NO];
}

- (void) exerciseEnded:(NSTimer *) timer
{
    currentExcerciseIndex ++;
    if(currentExcerciseIndex >= [exerciseImageNames count])
    {
        // stop
        [fliteEngine speakText:@"You're done!"];
        [self startButton:nil];
        return;
    }
    else
    {
        resting = YES;
        [self resetTimeRemaining];
        [self updateTimeRemainingUI];
        [self startResting];
    }
}

- (IBAction) startButton:(id)sender
{
    if(exercisesInProcess)
    {
        // stop them
        [currentTimer invalidate];
        exercisesInProcess = NO;
        resting = YES;
        [self resetTimeRemaining];
        [self updateTimeRemainingUI];

        [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
        self.currentExerciseImageView.hidden = YES;
        self.allExercisesImageView.hidden = NO;
        self.timeRemainingLabel.hidden = YES;
        self.timeRemainingLabel1.hidden = YES;
        self.timeRemainingProgress.hidden = YES;
    }
    else
    {
        exercisesInProcess = YES;
        [self resetTimeRemaining];

        [self.startButton setTitle:@"Stop" forState:UIControlStateNormal];

        self.allExercisesImageView.hidden = YES;
        self.currentExerciseImageView.hidden = NO;
        self.timeRemainingLabel.hidden = NO;
        self.timeRemainingLabel1.hidden = NO;
        self.timeRemainingProgress.hidden = NO;

        // start the timer
        currentExcerciseIndex = 0;
        [self resetTimeRemaining];
        resting = NO;
        [self updateTimeRemainingUI];
        [self startExerciseAtIndex:currentExcerciseIndex];
    }
}


@end
