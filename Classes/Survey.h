//
//  Survey.h
//  Lessons
//
//  Created by Ernesto Rivera on 10/10/28.
//  Copyright PTEz 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
@class SurveyContentView;

@interface SurveyViewController : UITabBarController
{
	// Outlets
	UIView * surveyView;
	UINavigationItem * itemTitle;
	UIView * contentPlaceholder;
	UILabel * surveyIDLabel;
	UIBarButtonItem * continueButton;
	UIButton * timeButton;
	SurveyContentView * currentContent, * lastContent;
	MainViewController * mainViewController;
	
	// Internal variables
	NSArray * tests;
	BOOL keyboardShown, testInProgress, contentShouldFinish;
	UIView * activeField;
	NSString * surveyID;
	NSMutableDictionary * surveyAnswers;
	NSString * surveyPath;
	NSTimer * timer;
	NSTimeInterval testShouldFinishTime;
	int selectedSection;
	NSMutableArray * plistPaths;
}

@property (nonatomic, retain) IBOutlet UIView * surveyView;
@property (nonatomic, retain) IBOutlet UINavigationItem * itemTitle;
@property (nonatomic, retain) IBOutlet UIView * contentPlaceholder;
@property (nonatomic, retain) IBOutlet UILabel * surveyIDLabel;
@property (nonatomic, retain) IBOutlet UIBarButtonItem * continueButton;
@property (nonatomic, retain) IBOutlet UIButton * timeButton;
@property (nonatomic, retain) IBOutlet SurveyContentView * currentContent, * lastContent;
@property (nonatomic, retain) IBOutlet MainViewController * mainViewController;

- (void)doCurrentContent;
- (IBAction)shouldFinishCurrentContent:(id)sender;
- (IBAction)generateTimelineImages:(id)sender;
- (IBAction)mergeSurveys:(id)sender;

@end


@interface SurveySectionViewController : UIViewController
{
	// Outlets
	SurveyContentView * nextContent;
}
@property (nonatomic, retain) IBOutlet SurveyContentView * nextContent;

@end


@interface SurveyContentView : UIScrollView
{
	// Outlets
	SurveyContentView * nextContent;
}
@property (nonatomic, retain) IBOutlet SurveyContentView * nextContent;

@end


@interface SurveyLabel : UITextView
{
	// Outlets
	UIView * target;
	
	// Variables
	UIColor * colorWhenValid;
}

@property (nonatomic, retain) IBOutlet UIView * target;
@property (nonatomic, retain) UIColor * colorWhenValid;

@end

