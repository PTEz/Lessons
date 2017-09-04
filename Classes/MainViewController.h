//
//  ViewViewController.h
//  View
//
//  Created by Ernesto Rivera on 10/02/02.
//  Copyright PTEz 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#define kUpdateInterval 0.2
#define kUserEventTimeBefore 10
#define kUserEventTimeAfter 5
#define kHighlightTolerance 10

@class MovieView, TimelineMiniView, TimelineScrollView;
@class PlayButton, Event;

@interface MainViewController : UIViewController
{
	// Outlets
	MovieView * movieView;
	TimelineMiniView * miniView;
	TimelineScrollView * scrollView;
	UIViewController * modalController;
	PlayButton * playButton;
	UIButton * openButton;
	UILabel * filenameLabel, * currentTimeLabel, * remainingTimeLabel;
	
	// Variables
	MPMoviePlayerController * moviePlayerController;
	NSString * moviePath, * plistPath;
	CGSize originalSize;
	BOOL autosave;
	
	// Internal variables
	NSMutableDictionary * events;
	NSMutableArray * highlightedEvents;
	NSTimer * timer;
	int currentTime, remainingTime, movieDuration;
	BOOL wasPlaying;
}

@property (nonatomic, retain) IBOutlet MovieView * movieView;
@property (nonatomic, retain) IBOutlet TimelineMiniView * miniView;
@property (nonatomic, retain) IBOutlet TimelineScrollView * scrollView;
@property (nonatomic, retain) IBOutlet UIViewController * modalController;
@property (nonatomic, retain) IBOutlet UIButton * playButton, * openButton;
@property (nonatomic, retain) IBOutlet UILabel * filenameLabel, * currentTimeLabel, * remainingTimeLabel;
@property (nonatomic, retain) MPMoviePlayerController * moviePlayerController;
@property (nonatomic, retain) NSString * moviePath, * plistPath;
@property CGSize originalSize;
@property BOOL autosave;


- (IBAction)togglePlay:(id)sender;
- (IBAction)suspend:(id)sender;
- (IBAction)resume:(id)sender;
- (IBAction)goTo30SecBefore:(id)sender;
- (IBAction)goTo30SecAfter:(id)sender;
- (IBAction)presentModalView:(id)sender;
- (IBAction)dismissModalView:(id)sender;
- (IBAction)saveToImage:(id)sender;

- (void)loadMovie:(NSString	*)file plist:(NSString *)plist;
- (void)loadMovie:(NSString	*)file plist:(NSString *)plist originalSize:(CGSize)size;
- (void)currentPositionChanged;
- (void)goToTime:(int)time;
- (void)goToEventWithKey:(NSObject *)key;
- (Event *)eventForKey:(NSObject *)key;
- (void)addEvent:(Event *)event;
- (void)addEvent:(Event *)event save:(BOOL)yesOrNo;
- (void)addUserEventWithROI:(CGRect)roi;
- (void)removeEventWithKey:(NSObject *)key;
- (void)displayEventsWithKeys:(NSArray *)keys;
- (void)displayAllEvents;
- (void)updateHighlights:(int)time;
- (void)enableEditing:(BOOL)yesOrNo;
- (void)saveTimelineToImage:(NSString *)path;

- (void)setHighlight:(BOOL)yesOrNo forEvent:(Event *)event;
- (BOOL)isHighlightingEvent:(Event *)event;

- (void)savePlist;

@end


@interface PlayButton : UIButton
{
	BOOL playing;
}

@property (nonatomic, getter=isPlaying) BOOL playing;

@end
