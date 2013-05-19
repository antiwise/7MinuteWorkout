//
//  FirstViewController.h
//  7MinuteWorkout
//
//  Created by Dan Weston on 5/18/13.
//  Copyright (c) 2013 Dan Weston. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FliteTTS;

@interface FirstViewController : UIViewController

{
    BOOL exercisesInProcess;
    BOOL resting;
    NSArray *exerciseImageNames;
    NSArray *exerciseNamesText;
    int     currentExcerciseIndex;
    NSTimer    *currentTimer;
    
    int timeRemainingInExercise;
    int timeRemainingInRest;
    FliteTTS *fliteEngine;
}
@property IBOutlet UIImageView  *allExercisesImageView;
@property IBOutlet UIImageView  *currentExerciseImageView;
@property IBOutlet UIButton     *startButton;
@property IBOutlet UILabel      *timeRemainingLabel1;
@property IBOutlet UILabel      *timeRemainingLabel;
@property IBOutlet UIProgressView     *timeRemainingProgress;

- (IBAction) startButton:(id)sender;

@end
