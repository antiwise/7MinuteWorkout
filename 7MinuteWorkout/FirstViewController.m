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

#define kExerciseDuration 30.0
#define kRestDuration 10.0

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

    [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        // We must add a delay here, otherwise we'll swap in the new view
        // too quickly and we'll get an animation glitch
        [self performSelector:@selector(updateLandscapeView) withObject:nil afterDelay:0];
    }];
}

- (void) updateLandscapeView
{
        //>     isShowingLandscapeView is declared in AppDelegate, so you won't need to declare it in each ViewController
        UIDeviceOrientation deviceOrientation       = [UIDevice currentDevice].orientation;
        if (UIDeviceOrientationIsLandscape(deviceOrientation) )
        {
            //UIStoryboard *storyboard                = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone_Landscape" bundle:[NSBundle mainBundle]];
            //MDBLogin *loginVC_landscape             =  [storyboard instantiateViewControllerWithIdentifier:@"MDBLogin"];
            //[UIView transitionWithView:loginVC_landscape.view duration:0 options:UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationCurveEaseIn animations:^{
            //    //>     Setup self.view to be the landscape view
            //    self.view = loginVC_landscape.view;
            //} completion:NULL];
        }
        else if (UIDeviceOrientationIsPortrait(deviceOrientation) )
        {
            //UIStoryboard *storyboard                = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:[NSBundle mainBundle]];
            //MDBLogin *loginVC                       = [storyboard instantiateViewControllerWithIdentifier:@"MDBLogin"];
//[UIView transitionWithView:loginVC.view duration:0 options:UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationCurveEaseIn animations:^{
                //>     Setup self.view to be now the previous portrait view
               // self.view = loginVC.view;
          //  } completion:NULL];
        //}
        }
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

/*
- (void) viewWillLayoutSubviews
{
    CGSize result = [[UIScreen mainScreen] bounds].size;
    CGFloat layoutRightGutterWidth = result.height - 310;
    
    //NSLog(@"screen dimensions: width: %f, height: %f",result.width, result.height);
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	if(orientation == UIInterfaceOrientationPortrait)
    {
        // show the title
        self.maintitle.hidden = NO;
        
        // locate the button, text, and progress view
        self.startButton.frame = CGRectMake(100,310,120,44);
        self.timeRemainingLabel1.frame = CGRectMake(71,357,129,21);
        self.timeRemainingLabel.frame = CGRectMake(208,357,19,21);
        self.timeRemainingProgress.frame = CGRectMake(76,386,169,9);
        self.currentExerciseImageView.frame = CGRectMake(36,54,248,248);
        self.allExercisesImageView.frame = CGRectMake(10,54,300,248);

        // show the tab bar
        
    }
    else if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
    {
        // hide the title
        self.maintitle.hidden = YES;
                
        // locate the button, text, and progress view
        self.startButton.frame = CGRectMake(layoutRightGutterWidth + (layoutRightGutterWidth - 120) / 2,100,120,44);
        self.timeRemainingLabel1.frame = CGRectMake(71,357,129,21);
        self.timeRemainingLabel.frame = CGRectMake(208,357,19,21);
        self.timeRemainingProgress.frame = CGRectMake(76,386,169,9);
        self.currentExerciseImageView.frame = CGRectMake(36,10,248,248);
        self.allExercisesImageView.frame = CGRectMake(10,10,300,248);

        
        
        
        // hide the tab bar

    }
}
*/
@end
