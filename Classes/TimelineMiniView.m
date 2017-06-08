//
//  TimelineMiniView.m
//  Lessons
//
//  Created by 利辺羅 on 10/04/05.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TimelineMiniView.h"

@implementation TimelineMiniView

#pragma mark Init

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	// Scroll focus
	scrollFocus = [[[ScrollFocusView alloc] initWithFrame:self.bounds] autorelease];
	[self addSubview:scrollFocus];
	
	// Duration bar
	CGRect rect;
	rect = CGRectMake(0.0, (self.bounds.size.height - kWidthBar)/2.0, self.bounds.size.width, kWidthBar);
	durationBar = [[[BarView alloc] initWithFrame:rect R:kDurationR G:kDurationG B:kDurationB A:kDurationA] autorelease];
	[self addSubview:durationBar];
	
	// Elapsed bar
	rect = CGRectMake(0.0, (self.bounds.size.height - kWidthBar)/2.0, kWidthBar, kWidthBar);
	elapsedBar = [[[BarView alloc] initWithFrame:rect R:kElapsedR G:kElapsedG B:kElapsedB A:kElapsedA] autorelease];
	elapsedBar.contentMode = UIViewContentModeRedraw;
	[self addSubview:elapsedBar];
	
	// Current mark
	rect = CGRectMake(elapsedBar.frame.size.width - kWidthBar/2.0, 0.0, kWidthBar, self.bounds.size.height + 4.0);
	currentMark = [[[CurrentMarkView alloc] initWithFrame:rect] autorelease];
	[self addSubview:currentMark];
	
	// Add pan and long tap recognizer
	UILongPressGestureRecognizer * recognizer = [[[UILongPressGestureRecognizer alloc] initWithTarget:self
																							   action:@selector(singleTappedWithNoEvent:)] autorelease];
	recognizer.allowableMovement = self.frame.size.width;
	[self addGestureRecognizer:recognizer];
}

#pragma mark Events

- (void)loadNewMovie
{
	[super loadNewMovie];
	
	// Adjust factor
	factor = (self.frame.size.width - kWidthBar) / mainViewController.moviePlayerController.duration;
}

- (EventView *)addViewForEvent:(Event *)event
{
	CGRect rect = CGRectMake(event.startFrame * factor,
							 0.0,
							 (event.endFrame - event.startFrame) * factor,
							 kWidthEventBar);
	EventView * view = [[[BarView alloc] initWithFrame:rect] autorelease];
	[durationBar addSubview:view];
	return view;
}

- (void)setHighlight:(BOOL)yesOrNo forEventWithKey:(NSObject *)key
{
	EventView * view = [eventViews objectForKey:key];
	[view setHighlighted:yesOrNo];
	if (yesOrNo)
		[durationBar bringSubviewToFront:view];
	else
		[durationBar sendSubviewToBack:view];
}


#pragma mark Touch

- (void)singleTappedWithNoEvent:(UIGestureRecognizer *)recognizer
{
	CGPoint location = [recognizer locationInView:self];
	[mainViewController goToTime:location.x / factor];
}

#pragma mark Actions

- (void)setCurrentPosition:(int)time
{
	// Move elapsed and current marks
	CGRect rect;
	rect = elapsedBar.frame;
	rect.size.width = time * factor + kWidthBar/2.0;
	[elapsedBar setFrame:rect];
	rect = currentMark.frame;
	rect.origin.x = elapsedBar.frame.size.width - kWidthBar/2.0;
	[currentMark setFrame:rect];
}

@end


#pragma mark -

@implementation ComponentView

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
		self.opaque = NO;
		self.userInteractionEnabled = NO;
		self.clearsContextBeforeDrawing = NO;
    }
    return self;
}

@end

@implementation CurrentMarkView

#define kShadowDist 2.0

- (id)initWithFrame:(CGRect)frame inverted:(BOOL)yesOrNo
{
    CGRect rect = frame;
	rect.size.width += kShadowDist;
	if ((self = [super initWithFrame:rect]))
	{
		inverted = yesOrNo;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetRGBFillColor(context, kCurrentMarkR, kCurrentMarkG, kCurrentMarkB, 1.0);
	CGContextSetRGBStrokeColor(context, kCurrentMarkR, kCurrentMarkG, kCurrentMarkB, 1.0);
	CGContextSetShadow(context, CGSizeMake(kShadowDist, -kShadowDist), 1.0);
	CGContextBeginTransparencyLayer(context, NULL);
	
	CGFloat width = self.bounds.size.width - kShadowDist; // For the shadow
	
	CGContextSetLineWidth(context, 2.0);
	CGContextMoveToPoint(context, width/2.0, self.bounds.origin.y);
	CGContextAddLineToPoint(context, width/2.0, self.bounds.size.height);
	CGContextStrokePath(context);
	
	if (!inverted)
	{
		CGContextMoveToPoint(context, self.bounds.origin.x, self.bounds.origin.y);
		CGContextAddLineToPoint(context, width/2.0, width);
		CGContextAddLineToPoint(context, width, self.bounds.origin.y);
	}
	else
	{
		CGContextMoveToPoint(context, self.bounds.origin.x, self.bounds.size.height);
		CGContextAddLineToPoint(context, width/2.0, self.bounds.size.height - width);
		CGContextAddLineToPoint(context, width, self.bounds.size.height);
	}
	CGContextFillPath(context);
	
	CGContextEndTransparencyLayer(context);
}

@end

@implementation ScrollFocusView

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Drawing code
	CGFloat components[] = { kFocusR - 0.3, kFocusG - 0.3, kFocusB - 0.3, kFocusA, kFocusR, kFocusG, kFocusB, kFocusA };
	CGGradientRef gradient = CGGradientCreateWithColorComponents(CGColorSpaceCreateDeviceRGB(), components, NULL, 2);
	CGContextDrawLinearGradient(context, gradient,
								self.bounds.origin,
								CGPointMake(self.bounds.origin.x, self.bounds.origin.y + 10.0),
								kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(gradient);
	
	CGContextSetRGBStrokeColor(context, kFocusR, kFocusG, kFocusB, kFocusA);
	CGContextStrokeRectWithWidth(context, self.bounds, 1.0);
}

@end

@implementation BarView

- (id)initWithFrame:(CGRect)frame R:(float)red G:(float)green B:(float)blue A:(float)alpha
{
    if ((self = [super initWithFrame:frame]))
	{
		color = [[UIColor alloc] initWithRed:red green:green blue:blue alpha:alpha];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGRect bounds = self.bounds;
	
	// Path
	CGContextBeginPath(context);
	CGContextMoveToPoint(context,
						 bounds.origin.x + bounds.size.height/2.0,
						 bounds.origin.y + bounds.size.height/2.0);
	CGContextAddLineToPoint(context,
							bounds.origin.x + bounds.size.width - bounds.size.height/2.0,
							bounds.origin.y + bounds.size.height/2.0);
	
	// Draw
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetLineWidth(context, bounds.size.height);
	
	[color setStroke];
	CGContextStrokePath(context);
}



@end
