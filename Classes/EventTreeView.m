//
//  EventTreeView.m
//  Lessons
//
//  Created by 利辺羅 on 10/04/08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EventTreeView.h"
#import "MovieView.h"

@implementation EventTreeView

@synthesize mainViewController;
@synthesize eventViews;

#pragma mark Init

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	self.eventViews = [[NSMutableDictionary alloc] init];
	
	// Add tap recognizer
	UITapGestureRecognizer * recognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self
																				   action:@selector(singleTapped:)] autorelease];
	recognizer.numberOfTapsRequired = 1;
	[self addGestureRecognizer:recognizer];
}

- (void)dealloc
{
    [eventViews removeAllObjects];
	[eventViews release];
	for (UIGestureRecognizer * recognizer in [self gestureRecognizers])
		[self removeGestureRecognizer:recognizer];
	[super dealloc];
}

#pragma mark Events

- (void)loadNewMovie
{
	[self removeAllEvents];
}

- (EventView *)addViewForEvent:(Event *)event
{
	// To be implemented by subclasses
	return nil;
}

- (void)addEvent:(Event *)event
{
	EventView * view = [self addViewForEvent:event];
	view.key = event.key;
	[eventViews setObject:view forKey:event.key];
}

- (void)addEvents:(NSArray *)events
{
	for (Event * event in events)
		[self addEvent:event];
}

- (void)removeEventWithKey:(NSObject *)key
{
	[[eventViews objectForKey:key] removeFromSuperview];
	[eventViews removeObjectForKey:key];
}

- (void)removeEventsWithKeys:(NSArray *)keys
{
	for (UIView * view in [eventViews objectsForKeys:keys notFoundMarker:nil])
		[view removeFromSuperview];
	[eventViews removeObjectsForKeys:keys];
}

- (void)removeAllEvents
{
	for (UIView * view in [eventViews allValues])
		[view removeFromSuperview];
	[eventViews removeAllObjects];
}

- (void)displayEventsWithKeys:(NSArray *)keys
{
	for (NSObject * key in [eventViews allKeys])
	{
		UIView * view = [eventViews objectForKey:key];
		view.hidden = ![keys containsObject:key];
	}
}

- (void)displayAllEvents
{
	for (UIView * view in [eventViews allValues])
		view.hidden = NO;
}

- (void)displayNone
{
	for (UIView * view in [eventViews allValues])
		view.hidden = YES;
}

- (void)enableEditing:(BOOL)yesOrNo
{
	// Implement in subclasses if needed
}

- (void)setHighlight:(BOOL)yesOrNo forEventWithKey:(NSObject *)key
{
	EventView * view = [eventViews objectForKey:key];
	[view setHighlighted:yesOrNo];
}

#pragma mark Touch

- (void)singleTapped:(UIGestureRecognizer *)recognizer
{
	NSArray * keys = [self touchedEventKeys:[recognizer locationInView:self]];

	if ([keys count])
		[self singleTappedKeys:keys withRecognizer:recognizer];
	else
		[self singleTappedWithNoEvent:recognizer];
}

- (void)singleTappedKey:(NSObject *)key withRecognizer:(UIGestureRecognizer *)recognizer
{
	[mainViewController goToEventWithKey:key];
}

- (void)singleTappedKeys:(NSArray *)keys withRecognizer:(UIGestureRecognizer *)recognizer
{
	// Default behaviour process only top key
	NSObject * key = [self selectTopKey:keys];
	[self singleTappedKey:key withRecognizer:recognizer];
}

- (void)singleTappedWithNoEvent:(UIGestureRecognizer *)recognizer
{
	[mainViewController displayAllEvents];
}

- (NSArray *)touchedEventKeys:(CGPoint)location
{
	NSMutableArray * keys = [NSMutableArray array];
	BOOL touchHidden = [self shouldTouchHidden];
	UIView * view;
	for (NSObject * key in [eventViews allKeys])
	{
		view = [eventViews objectForKey:key];
		if ([view pointInside:[self convertPoint:location toView:view] withEvent:nil])
			if (touchHidden || !view.hidden)
				[keys addObject:key];
	}
	return keys;
}

- (NSObject *)selectTopKey:(NSArray *)keys
{
	return [keys lastObject];
}

- (BOOL)shouldTouchHidden
{
	return NO;
}

#pragma mark Actions

- (void)setCurrentPosition:(int)time
{
	// Default implementation does nothing
}

@end


@implementation EventView

@synthesize key;

// For Nib views
- (void)awakeFromNib
{
	[super awakeFromNib];
	[self setHighlighted:NO];
}

// For programatic views
- (id)initWithFrame:(CGRect)rect
{
    self = [super initWithFrame:rect];
    if (self)
	{
        [self setHighlighted:NO];
    }
    return self;
}

- (void)dealloc
{
    if (color)
		[color release];
	[super dealloc];
}

- (void)setHighlighted:(BOOL)yesOrNo
{
	if (color)
		[color release];
	if (yesOrNo)
		color = [[UIColor alloc] initWithRed:kHighlightedEventR green:kHighlightedEventG blue:kHighlightedEventB alpha:kHighlightedEventA];
	else
		color = [[UIColor alloc] initWithRed:kEventR green:kEventG blue:kEventB alpha:kEventA];
	[self setNeedsDisplay];
}

@end
