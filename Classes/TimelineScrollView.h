//
//  TimelineScrollView.h
//  Lessons
//
//  Created by 利辺羅 on 10/04/08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TimelineMiniView.h"

#define kMagnificationFactorMax 2.0

@class ScrollView;

@interface TimelineScrollView : EventTreeView
{
	// Outlets
	ScrollView * scrollView;
	
	// Internal Variables
	BOOL editing;
	UIView * currentMark;
	NSObject * currentKey;
	int viewCount;
	float factor;
}

@property (nonatomic, retain) IBOutlet ScrollView * scrollView;

- (IBAction)toggleEdit:(id)sender;
- (void)refreshCurrentPosition;
- (void)scrollToEventWithKey:(NSObject *)key;

@end


@interface ScrollView : UIScrollView
{
	// Outlet
	TimelineScrollView * timelineView;
	
	// Variables
	NSMutableArray * orderedEventKeys;
}

@property (nonatomic, retain) IBOutlet TimelineScrollView * timelineView;
@property (nonatomic, readonly) NSArray * orderedEventKeys;

@end


@interface TimelineEventView : EventView
{
	// Outlets
	UIImageView * thumbnail;
	UILabel * label;
	UIButton * deleteButton;
}

@property (nonatomic, retain) IBOutlet UIImageView * thumbnail;
@property (nonatomic, retain) IBOutlet UILabel * label;
@property (nonatomic, retain) IBOutlet UIButton * deleteButton;

@end
