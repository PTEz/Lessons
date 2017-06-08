//
//  TimelineScrollView.m
//  Lessons
//
//  Created by 利辺羅 on 10/04/08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TimelineScrollView.h"

@implementation TimelineScrollView

@synthesize scrollView;

#pragma mark Init

- (void)awakeFromNib
{
	[super awakeFromNib];
	viewCount = 0;
	editing = NO;
	
	// Current mark
	CGRect rect = self.bounds;
	rect.size.width = kWidthBar;
	//rect.origin.x = -kWidthBar / 2.0;
	currentMark = [[[CurrentMarkView alloc] initWithFrame:rect inverted:YES] autorelease];
	[scrollView addSubview:currentMark];
}

#pragma mark Events

- (void)loadNewMovie
{
	[super loadNewMovie];
	
	// Difference between analyzed movie and playback movie
	factor = mainViewController.moviePlayerController.naturalSize.width / mainViewController.originalSize.width;
}

- (UIImage *)thumbnailAtTime:(NSTimeInterval)time roi:(CGRect)region imageSize:(CGSize)size
{
	UIGraphicsBeginImageContext(size);
	UIImage * image = [mainViewController.moviePlayerController thumbnailImageAtTime:time
																	  timeOption:MPMovieTimeOptionNearestKeyFrame];
	// Magnification factor
	CGFloat magnification = MIN(MIN(size.width/region.size.width, size.height/region.size.height),
								kMagnificationFactorMax);
	// Zoom and center roi
	CGRect rect = CGRectMake(-region.origin.x * magnification + (size.width - region.size.width * magnification)/2.0,
							 -region.origin.y * magnification + (size.height - region.size.height * magnification)/2.0,
							 image.size.width * magnification,
							 image.size.height * magnification);
	
	// Make sure that the image fills the whole area
	rect.origin.x = MAX(MIN(0.0, rect.origin.x),
						size.width - rect.size.width);
	rect.origin.y = MAX(MIN(0.0, rect.origin.y),
						size.height - rect.size.height);
	
	[image drawInRect:rect];
	image = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	return image;
}

- (EventView *)addViewForEvent:(Event *)event
{
	TimelineEventView *  view = [[[NSBundle mainBundle] loadNibNamed:@"TimelineEventView" owner:self options:nil] objectAtIndex:0];
	
	// Adjust label
	if (event.startFrame >= 3600) // Display hours?
		[view.label setText:[NSString stringWithFormat:@"%d:%02d:%02d",
							 event.startFrame/3600, (event.startFrame%3600)/60, event.startFrame%60]];
	else
		[view.label setText:[NSString stringWithFormat:@"%d:%02d",
							 (event.startFrame%3600)/60, event.startFrame%60]];
	
	// Adjust width enlarging if necessary, but not beyond 16:9 aspect ratio
	float widthDiff = MIN(MAX(event.roi.size.width * view.thumbnail.frame.size.height/event.roi.size.height,
							  view.thumbnail.frame.size.width),
						  view.thumbnail.frame.size.height * 16.0/9.0) - view.thumbnail.frame.size.width;
	CGRect rect = view.frame;
	rect.size.width += round(widthDiff);
	view.frame = rect;
	
	// Prepare thumbnail
	[view.thumbnail setImage:[self thumbnailAtTime:event.thumbFrame
											   roi:CGRectMake(event.roi.origin.x * factor,
															  event.roi.origin.y * factor,
															  event.roi.size.width * factor,
															  event.roi.size.height * factor)
										 imageSize:view.thumbnail.frame.size]];
	
	// Show/hide delete button
	view.deleteButton.hidden = !editing;
	
	// Set tag and add view
	[view setTag:event.startFrame * 10000 + viewCount++]; // Make sure to have different and ordered tags
	[scrollView insertSubview:view atIndex:0];
	return view;
}

- (void)displayAllEvents
{
	[super displayAllEvents];
	[scrollView setNeedsLayout];
}

- (void)displayEventsWithKeys:(NSArray *)keys
{
	[super displayEventsWithKeys:keys];
	[scrollView setNeedsLayout];
}

- (void)setHighlight:(BOOL)yesOrNo forEventWithKey:(NSObject *)key
{
	[super setHighlight:yesOrNo forEventWithKey:key];
	
	// Refresh the current key if needed
	if (!yesOrNo && currentKey == key)
		currentKey = nil;
	if (yesOrNo &&
		(!currentKey || ![mainViewController isHighlightingEvent:[mainViewController eventForKey:currentKey]]))
		currentKey = key;
}

- (void)scrollToEventWithKey:(NSObject *)key
{
	if (key)
		[scrollView scrollRectToVisible:[(EventView *)[eventViews objectForKey:key] frame]
							   animated:YES];
}

#pragma mark Touch

- (void)singleTappedKey:(NSObject *)key withRecognizer:(UIGestureRecognizer *)recognizer
{
	// Delete?
	TimelineEventView * view = [eventViews objectForKey:key];
	if (!view.deleteButton.hidden &&
		[view.deleteButton pointInside:[recognizer locationInView:view.deleteButton] withEvent:nil])
		[mainViewController removeEventWithKey:key];
	else
		[super singleTappedKey:key withRecognizer:recognizer];
}

#pragma mark Actions

- (void)refreshCurrentPosition
{
	currentKey = nil;
	[self setCurrentPosition:mainViewController.moviePlayerController.currentPlaybackTime];
}

- (void)setCurrentPosition:(int)time
{
	CGRect rect = currentMark.frame;
	Event * event = nil;
	
	// Find the current key if needed
	if (!currentKey)
		for (NSObject * key in scrollView.orderedEventKeys)
		{
			event = [mainViewController eventForKey:key];
			if (time <= event.endFrame) // Found
			{
				currentKey = key;
				break;
			}
		}
	else
		event = [mainViewController eventForKey:currentKey];
	
	// Position before the current view
	if (currentKey)
	{
		EventView * view = [eventViews objectForKey:currentKey];
		rect.origin.x = view.frame.origin.x - currentMark.frame.size.width/2.0 + 1.0;
		
		// Move inside if needed
		event = [mainViewController eventForKey:currentKey];
		if ([mainViewController isHighlightingEvent:event])
			rect.origin.x += MIN(MAX(time - event.startFrame, 0.0) / (event.endFrame - event.startFrame) * view.frame.size.width,
								 view.frame.size.width - 1.0);
	}
	// Else just move it to the origin of the scroll view
	else
		rect.origin.x = scrollView.contentSize.width - currentMark.frame.size.width/2.0 + 1.0;
	
	[currentMark setFrame:rect];
}

# pragma mark Editing

- (IBAction)toggleEdit:(id)sender
{
	UIButton * button = (UIButton *)sender;
	button.selected = !button.selected;
	[self enableEditing:button.selected];
}

- (void)enableEditing:(BOOL)yesOrNo
{
	[super enableEditing:yesOrNo];
	for (TimelineEventView * view in [eventViews allValues])
		view.deleteButton.hidden = !yesOrNo;
	editing = yesOrNo;
}

@end

#pragma mark -

@implementation ScrollView

@synthesize timelineView;
@synthesize orderedEventKeys;

- (void)awakeFromNib
{
	[super awakeFromNib];
	orderedEventKeys = [[NSMutableArray alloc] init];
}

- (void)dealloc
{
	[orderedEventKeys release];
	[super dealloc];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
	
	// Sort subviews
	[orderedEventKeys removeAllObjects];
	NSMutableDictionary * eventDict = [NSMutableDictionary dictionary];
	for (UIView * view in self.subviews)
		if ([view class] == [TimelineEventView class])
			[eventDict setObject:view forKey:[NSNumber numberWithInteger:view.tag]];
	NSArray * sortedTags = [[eventDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
	
	// Position subviews
	CGRect rect;
	float x = 0;
	EventView * view;
	for (NSObject * key in sortedTags)
	{
		view = [eventDict objectForKey:key];
		rect = view.frame;
		rect.origin.x = x;
		view.frame = rect;
		
		if (!view.hidden)
		{
			x += rect.size.width - 1; // Overlap frames
			[orderedEventKeys addObject:view.key];
		}
	}
	
	// Adjust timeline size and center if needed
	self.contentSize = CGSizeMake(x, rect.size.height);
	if (x < self.frame.size.width)
		self.contentOffset = CGPointMake((x-self.frame.size.width)/2.0, 0.0);
	
	// Refresh current position
	[timelineView refreshCurrentPosition];
}

@end


@implementation TimelineEventView

@synthesize thumbnail;
@synthesize label;
@synthesize deleteButton;

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	// Add Pan recognizer
	UISwipeGestureRecognizer * recognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self
																					   action:@selector(swiped)] autorelease];
	recognizer.direction = UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionDown;
	[self addGestureRecognizer:recognizer];
}

- (void)swiped
{
	deleteButton.hidden = NO;
}

- (void)setNeedsDisplay
{
	[self setBackgroundColor:[UIColor colorWithRed:kFocusR green:kFocusG blue:kFocusB alpha:kFocusA]];
	[label setTextColor:[color colorWithAlphaComponent:1.0]];
	[super setNeedsDisplay];
}

@end
