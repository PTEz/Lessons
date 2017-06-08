//
//  TimelineMiniView.h
//  Lessons
//
//  Created by 利辺羅 on 10/04/05.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EventTreeView.h"

#define kCurrentMarkR 237.0/255.0
#define kCurrentMarkG 72.0/255.0
#define kCurrentMarkB 13.0/255.0
#define kCurrentMarkA 0.6
#define kFocusR 206.0/255.0
#define kFocusG 206.0/255.0
#define kFocusB 206.0/255.0
#define kFocusA 1.0
#define kDurationR 160.0/255.0
#define kDurationG 160.0/255.0
#define kDurationB 160.0/255.0
#define kDurationA 1.0
#define kElapsedR 0.0/255.0
#define kElapsedG 0.0/255.0
#define kElapsedB 0.0/255.0
#define kElapsedA 0.2
#define kWidthBar 10.0
#define kWidthEventBar 10.0

@interface TimelineMiniView : EventTreeView
{
	// Internal variables
	UIView * scrollFocus, * durationBar, * elapsedBar, * currentMark;
	float factor;
}

@end


@interface ComponentView : EventView
{
}

@end


@interface BarView : ComponentView
{
}

- (id)initWithFrame:(CGRect)frame R:(float)red G:(float)green B:(float)blue A:(float)alpha;

@end


@interface CurrentMarkView : ComponentView
{
	BOOL inverted;
}

- (id)initWithFrame:(CGRect)frame inverted:(BOOL)yesOrNo;

@end


@interface ScrollFocusView : ComponentView
{
}

@end


