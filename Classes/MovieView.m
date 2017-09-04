//
//  MovieView.m
//  Lessons
//
//  Created by Ernesto Rivera on 10/03/31.
//  Copyright PTEz 2010. All rights reserved.
//

#import "MovieView.h"

@implementation MovieView

#pragma mark Init

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	// Add Pan recognizer
	panRecognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self
															 action:@selector(Panning:)] autorelease];
	panRecognizer.enabled = NO;
	[self addGestureRecognizer:panRecognizer];
	
	// Prepare mask and annotation views
	maskView = [[[MaskView alloc] initWithFrame:self.bounds] autorelease];
	[self addSubview:maskView];
	annotationView = [[AnnotationView alloc] initWithFrame:self.bounds];
	[self addSubview:annotationView];
}

#pragma mark Events

- (void)loadNewMovie
{
	[super loadNewMovie];
	
	// Size calculations
	CGSize originalSize = mainViewController.originalSize;
	CGSize actualSize = self.bounds.size;
	factor = MIN(actualSize.height / originalSize.height,
				 actualSize.width / originalSize.width);
	blackbar = CGSizeMake((actualSize.width - originalSize.width	* factor)/2.0,
						  (actualSize.height - originalSize.height * factor)/2.0);
}

- (EventView *)addViewForEvent:(Event *)event
{
	CGRect rect = CGRectMake(event.roi.origin.x * factor + blackbar.width,
							 // Adjust to iOS' inverted Y coordinates
							 //(event.originalSize.height - event.roi.origin.y - event.roi.size.height) * factor + blackbar.height,
							 event.roi.origin.y * factor + blackbar.height,
							 event.roi.size.width * factor,
							 event.roi.size.height * factor);
	EventView * view = [[[RoiView alloc] initWithFrame:rect] autorelease];
	view.hidden = YES;
	view.contentMode = UIViewContentModeRedraw;
	[self addSubview:view];
	return view;
}

- (void)displayNone
{
	[super displayNone];
	maskView.hidden = YES;
}

- (void)enableEditing:(BOOL)yesOrNo
{
	[super enableEditing:yesOrNo];
	panRecognizer.enabled = yesOrNo;
}

- (void)setHighlight:(BOOL)yesOrNo forEventWithKey:(NSObject *)key
{
	EventView * view = [eventViews objectForKey:key];
	[view setHighlighted:yesOrNo];
	if (yesOrNo)
		[self bringSubviewToFront:view];
}

#pragma mark Touch

//- (void)singleTapped:(UIGestureRecognizer *)recognizer
//{
//	// For now disable spatial navigation
//	return;
//}

- (void)singleTappedKeys:(NSArray *)keys withRecognizer:(UIGestureRecognizer *)recognizer
{
	if (maskView.hidden)
	{
		[mainViewController displayEventsWithKeys:keys];
		[maskView displayWithViews:[eventViews objectsForKeys:keys notFoundMarker:[NSArray array]]];
	}
	else
		[super singleTappedKeys:keys withRecognizer:recognizer];
}

- (void)singleTappedWithNoEvent:(UIGestureRecognizer *)recognizer
{
	[super singleTappedWithNoEvent:recognizer];
	
	if (maskView.hidden)
	{
		// Display all
		[self displayAllEvents];
		[maskView displayWithViews:[eventViews allValues]];
	}
	else
	{
		// Hide all
		[self displayNone];
		maskView.hidden = YES;
	}
}

- (NSObject *)selectTopKey:(NSArray *)keys
{
	if ([keys count] == 1)
		return [keys lastObject];
	
	// Select the view with the smaller area
	NSObject * key = nil;
	EventView * view;
	CGFloat area;
	CGFloat minArea = CGFLOAT_MAX;
	for (NSObject * k in keys)
	{
		view = (EventView *)[eventViews objectForKey:k];
		area = view.frame.size.width * view.frame.size.height;
		if (area < minArea)
		{
			key = k;
			minArea = area;
		}
	}
	return key;
}

- (BOOL)shouldTouchHidden
{
	return maskView.hidden;
}

- (void)Panning:(UIGestureRecognizer *)recognizer
{
	switch (recognizer.state)
	{
		// Staring
		case UIGestureRecognizerStateBegan:
			
			// Clear the video player and suspend the player
			[self displayNone];
			[mainViewController suspend:self];
			
			// Reset the annotation
			[annotationView reset];
			annotationView.hidden = NO;
			annotationView.point = [recognizer locationInView:self];
			break;
			
		// Moving
		case UIGestureRecognizerStateChanged:
			
			// Add line
			annotationView.point = [recognizer locationInView:self];
			break;
			
		// End
		case UIGestureRecognizerStateEnded:
			
			// Hide annotation
			annotationView.hidden = YES;
			
			// Calculate ROI
			CGRect roi = [annotationView getBoundingBox];
			roi.origin.x = (roi.origin.x - blackbar.width) / factor;
			roi.origin.y = (self.bounds.size.height - roi.size.height - 2*blackbar.height - roi.origin.y) / factor; // With iOS > OS X conversion
			roi.size.width /= factor;
			roi.size.height /= factor;
			
			// Add event
			[mainViewController addUserEventWithROI:roi];
			
			// Resume playing
			[mainViewController resume:self];
			break;
        default:
            break;
	}
}

#pragma mark Actions

- (void)flashEventWithKey:(NSObject *)key
{
	[self displayNone];
	RoiView * view = [eventViews objectForKey:key];
	view.hidden = NO;
	
	[maskView displayWithViews:[NSArray arrayWithObject:view]];
	
	// Set timer to turn off
	[NSTimer scheduledTimerWithTimeInterval:kFlashDuration
									 target:self
								   selector:@selector(displayNone)
								   userInfo:nil
									repeats:NO];
}

@end


#pragma mark -

@implementation MaskView

@synthesize views;

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		self.opaque = NO;
		self.userInteractionEnabled = NO;
		[self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		self.hidden = YES;
	}
	return self;
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Clipping mask
	for (UIView * view in views)
	{
		CGContextAddRect(context, self.bounds);
		CGContextAddRect(context, view.frame);
		CGContextEOClip(context);
	}
	
	// Draw
	CGContextAddRect(context, self.bounds);
	CGContextSetRGBFillColor(context, 45.0/255.0, 48.0/255.0, 43.0/255.0, 0.6);
	
	CGContextFillPath(context);
}

- (void)displayWithViews:(NSArray *)theViews
{
	self.views = theViews;
	[self setNeedsDisplay];
	self.hidden = NO;
}

@end


@implementation AnnotationView

@synthesize point;

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		self.opaque = NO;
		self.userInteractionEnabled = NO;
		[self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		self.hidden = YES;
		path = CGPathCreateMutable();
	}
	return self;
}

- (void)viewDidUnload
{
	CGPathRelease(path);
}

- (void)setPoint:(CGPoint)aPoint
{
	point = aPoint;
	[self setNeedsDisplay];
}

- (void)reset
{
	CGPathRelease(path);
	path = CGPathCreateMutable();
	[self setNeedsDisplay];
}

- (CGRect)getBoundingBox
{
	CGRect rect = CGPathGetBoundingBox(path);
	rect.size = CGSizeMake(MAX(rect.size.width, kAnnotationWidth),
						   MAX(rect.size.height, kAnnotationWidth)); // At leat as thick as the annotation mark
	return rect;
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// First point
	if (CGPathIsEmpty(path))
		CGPathMoveToPoint(path, NULL, point.x, point.y);
	
	// Next points
	else
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
	
	// Draw
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetLineJoin(context, kCGLineJoinRound);
	CGContextSetLineWidth(context,kAnnotationWidth);
	CGContextSetRGBStrokeColor(context, kHighlightedEventR, kHighlightedEventG, kHighlightedEventB, kAnnotationA);
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
}

@end


@implementation RoiView

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		self.opaque = NO;
		self.userInteractionEnabled = NO;
	}
	return self;
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Drawing code
	[[color colorWithAlphaComponent:1.0] setStroke];
	CGContextStrokeRectWithWidth(context, self.bounds, 4.0);
}

@end
