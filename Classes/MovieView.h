//
//  MovieView.h
//  Lessons
//
//  Created by 利辺羅 on 10/03/31.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EventTreeView.h"

#define kFlashDuration 5.0
#define kAnnotationWidth 24.0
#define kAnnotationA 0.5

@class MaskView, AnnotationView;

@interface MovieView : EventTreeView
{
	// Internal variables
	UIPanGestureRecognizer * panRecognizer;
	MaskView * maskView;
	AnnotationView * annotationView;
	float factor;
	CGSize blackbar;
}

- (void)flashEventWithKey:(NSObject *)key;

@end


@interface MaskView : UIView
{
	// Variables
	NSArray * views;
}

@property (nonatomic, retain) NSArray * views;

- (void)displayWithViews:(NSArray *)views;

@end


@interface AnnotationView : UIView
{
	// Variables
	CGPoint point;
	
	// Internal variables
	CGMutablePathRef path;
}

@property (nonatomic) CGPoint point;
- (CGRect)getBoundingBox;
- (void)reset;

@end


@interface RoiView : EventView
{
}

@end
