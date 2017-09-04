//
//  EventTreeView.h
//  Lessons
//
//  Created by Ernesto Rivera on 10/04/08.
//  Copyright PTEz 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "Event.h"

#define kEventR 114.0/255.0
#define kEventG 178.0/255.0
#define kEventB 247.0/255.0
#define kEventA 1.0
#define kHighlightedEventR 247.0/255.0
#define kHighlightedEventG 118.0/255.0
#define kHighlightedEventB 26.0/255.0
#define kHighlightedEventA 1.0

@class MainViewController, EventView;

@interface EventTreeView : UIView
{
	// Outlets
	MainViewController * mainViewController;
	
	// Variables
	NSMutableDictionary * eventViews;
}

@property (nonatomic, retain) IBOutlet MainViewController * mainViewController;
@property (nonatomic, retain) NSMutableDictionary * eventViews;

- (void)loadNewMovie;
- (EventView *)addViewForEvent:(Event *)event; // To be implemented by subclasses
- (void)addEvent:(Event *)event;
- (void)addEvents:(NSArray *)events;
- (void)removeEventWithKey:(NSObject *)key;
- (void)removeEventsWithKeys:(NSArray *)keys;
- (void)removeAllEvents;
- (void)displayEventsWithKeys:(NSArray *)keys;
- (void)displayAllEvents;
- (void)displayNone;
- (void)enableEditing:(BOOL)yesOrNo;

- (void)setHighlight:(BOOL)yesOrNo forEventWithKey:(NSObject *)key;

- (void)singleTapped:(UIGestureRecognizer *)recognizer;
- (void)singleTappedKey:(NSObject *)key withRecognizer:(UIGestureRecognizer *)recognizer;
- (void)singleTappedKeys:(NSArray *)keys withRecognizer:(UIGestureRecognizer *)recognizer;
- (void)singleTappedWithNoEvent:(UIGestureRecognizer *)recognizer;
- (NSArray *)touchedEventKeys:(CGPoint)location;
- (NSObject *)selectTopKey:(NSArray *)keys;
- (BOOL)shouldTouchHidden;
- (void)setCurrentPosition:(int)time;

@end

@interface EventView : UIView
{
	NSObject * key;
	UIColor * color;
}

@property (nonatomic, retain) NSObject * key;
- (void)setHighlighted:(BOOL)yesOrNo;

@end
