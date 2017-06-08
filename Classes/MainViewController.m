//
//  MainViewController.m
//  View
//
//  Created by 利辺羅 on 10/02/02.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "MainViewController.h"
#import "MovieView.h"
#import "TimelineMiniView.h"
#import "TimelineScrollView.h"
#import "Event.h"
#import <QuartzCore/QuartzCore.h>

@implementation MainViewController

@synthesize	movieView;
@synthesize miniView;
@synthesize scrollView;
@synthesize modalController;
@synthesize playButton, openButton;
@synthesize filenameLabel, currentTimeLabel, remainingTimeLabel;
@synthesize moviePlayerController;
@synthesize moviePath, plistPath;
@synthesize originalSize;
@synthesize autosave;

#pragma mark Init

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	events = [[NSMutableDictionary alloc] init];
	highlightedEvents = [[NSMutableArray alloc] init];
	
	// Prepare movie player
	moviePlayerController = [[MPMoviePlayerController alloc] init];
	moviePlayerController.controlStyle = MPMovieControlStyleNone;
	[moviePlayerController.view setFrame:movieView.bounds];
	[moviePlayerController.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[moviePlayerController.view setUserInteractionEnabled:NO];
	[movieView insertSubview:moviePlayerController.view atIndex:0];
	
	// Observe movie notifications
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(finishLoadingMovie)
												 name:MPMovieNaturalSizeAvailableNotification
											   object:moviePlayerController];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(playbackChanged:)
												 name:MPMoviePlayerPlaybackStateDidChangeNotification
											   object:moviePlayerController];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(togglePlay:)
												 name:MPMoviePlayerPlaybackDidFinishNotification
											   object:moviePlayerController];
	
	// Load movie
	//[self loadMovie:@"Screencast/Massive Web Design Tutorial in Photoshop (720p HD).mp4" plist:nil];
	
	//[self loadMovie:@"Radian Measure.mov" plist:nil];
	//[self loadMovie:@"Anatomy of a muscle cell.mp4" plist:@"Anatomy of a muscle cell.plist"];
	//[self loadMovie:@"Muscle cells and the lungs.m4v" plist:@"Muscle cells and the lungs.plist"];
	//[self loadMovie:@"MOV01C.m4v" plist:@"MOV01C.plist"];
	//[self loadMovie:@"Hydrogen part 3 Eigenfunctions.m4v" plist:@"Hydrogen part 3 Eigenfunctions.plist"];
	[self loadMovie:@"授業.m4v" plist:@"授業.plist" originalSize:CGSizeMake(1280, 720)];
	//[self loadMovie:@"授業.m4v" plist:@"授業nocrop.plist" originalSize:CGSizeMake(1280, 720)];
	//[self loadMovie:@"授業HD.m4v" plist:@"授業.plist" originalSize:CGSizeMake(1280, 720)];
	//[self loadMovie:@"15. iPhone Device APIs; Location, Accelerometer & Camera; Battery Life & Power Management (February 23, 2010).m4v" plist:@"15. iPhone Device APIs; Location, Accelerometer & Camera; Battery Life & Power Management (February 23, 2010).plist"];
	//[self loadMovie:@"18. Unit Testing; Fun with Objective-C; Localization (March 4, 2010).m4v" plist:@"18. Unit Testing; Fun with Objective-C; Localization (March 4, 2010).plist"];
	//[self loadMovie:@"Normal Force.mov" plist:@"Normal Force.plist"];
	//[self loadMovie:@"Episode 3. Free to Choose _ Who Owns Me.mp4" plist:@"Episode 3. Free to Choose _ Who Owns Me.plist"];
	//[self loadMovie:@"授業 中.m4v" plist:@"授業 中.plist"];
	//[self loadMovie:@"授業 - モバイル.m4v" plist:@"授業 - モバイル.plist"];
	//[self loadMovie:@"1. Programming Methodology Lecture 1.m4v" plist:@"1. Programming Methodology Lecture 1.plist"];
	//[self loadMovie:@"02 Lecture 02_ Operators and operands; statements; branching, conditionals, and iteration.mp4" plist:@"02 Lecture 02_ Operators and operands; statements; branching, conditionals, and iteration.plist"];
	//[self loadMovie:@"Lecture 37_ Infinite series and convergence tests.mp4" plist:@"Lecture 37_ Infinite series and convergence tests.plist"];
	//[self loadMovie:@"Lecture 39_ Final review.mp4" plist:@"Lecture 39_ Final review.plist"];
	//[self loadMovie:@"PHY24 Lecture 2 (October 2, 2006).m4v" plist:@"PHY24 Lecture 2 (October 2, 2006).plist"];
	//[self loadMovie:@"Lecture 38_ Taylor's series.mp4" plist:@"Lecture 38_ Taylor's series.plist"];
	
	//[self loadMovie:@"23 Lecture 23_ Stock market simulation.mp4" plist:@"23 Lecture 23_ Stock market simulation.plist"];
	//[self loadMovie:@"35 Lecture 35_ Farewell Special - High-energy Astrophysics.mp4" plist:@"35 Lecture 35_ Farewell Special - High-energy Astrophysics.plist"];
	//[self loadMovie:@"Section 8.2 - Polar Form of Complex Numbers.m4v" plist:@"Section 8.2 - Polar Form of Complex Numbers.plist"];
	//[self loadMovie:@"Section 3.1 - Radian Measure.m4v" plist:@"Section 3.1 - Radian Measure.plist"];
	//[self loadMovie:@"Lecture 38_ Taylor's series.mp4" plist:@"Lecture 38_ Taylor's series.plist"];
}

// Landscape orientations only
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[moviePlayerController release];
	[highlightedEvents release];
	[events release];
	[super viewDidUnload];
}

#pragma mark Events

- (void)loadMovie:(NSString	*)file plist:(NSString *)plist
{
	[self loadMovie:file plist:plist originalSize:CGSizeMake(0.0, 0.0)];
}

- (void)loadMovie:(NSString	*)file plist:(NSString *)plist originalSize:(CGSize)size
{
	self.originalSize = size;
	
	// Load movie
	self.moviePath = [[NSBundle mainBundle] pathForResource:file ofType:nil];
	
	// Maybe from Documents directory?
	if (!moviePath)
	{
		self.moviePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
						  stringByAppendingPathComponent:file];
	}
	
	NSLog(@"Loading movie: %@", moviePath);
	[moviePlayerController setContentURL:[NSURL fileURLWithPath:self.moviePath]];
	[moviePlayerController prepareToPlay];
	[filenameLabel setText:[moviePath lastPathComponent]]; 
	
	// Resolve plist path
	self.autosave = NO;
	if(!plist)
		plist = [[file stringByDeletingPathExtension] stringByAppendingPathExtension:@"plist"];
	self.plistPath = [[NSBundle mainBundle] pathForResource:plist ofType:nil];
	
	// Or choose one from the App's document directory
	if (!plistPath)
	{
		self.plistPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
						  stringByAppendingPathComponent:plist];
		// Do not save for now?
		self.autosave = YES;
	}
	NSLog(@"Loading plist: %@", plistPath);
}

- (void)finishLoadingMovie
{
	// Reset status
	[moviePlayerController play];
	[moviePlayerController pause];
	[playButton setPlaying:NO];
	[events removeAllObjects];
	[self goToTime:0];
	currentTime = 0;
	
	// Read original size and duration
	if (originalSize.width == 0.0)
		self.originalSize = moviePlayerController.naturalSize;
	movieDuration = moviePlayerController.duration;
	
	// Prepare tree views for the new movie
	[movieView loadNewMovie];
	[miniView loadNewMovie];
	[scrollView loadNewMovie];
	
	// Add events
	Event * event;
	NSArray * eventArray = [[[NSArray alloc] initWithContentsOfFile:plistPath] autorelease];
	for (NSDictionary * data in eventArray)
	{
		event = [[[Event alloc] initWithMetadata:data
									OriginalSize:originalSize] autorelease];
		[self addEvent:event save:NO];
	}
}

- (Event *)eventForKey:(NSObject *)key
{
	return [events objectForKey:key];
}

- (void)addEvent:(Event *)event
{
	[self addEvent:event save:autosave];
}

- (void)addEvent:(Event *)event save:(BOOL)yesOrNo
{
	[events setObject:event forKey:event.key];
	[movieView addEvent:event];
	[miniView addEvent:event];
	[scrollView addEvent:event];
	if (yesOrNo)
		[self savePlist];
}

- (void)addUserEventWithROI:(CGRect)roi
{
	// Create the event
	int time = moviePlayerController.currentPlaybackTime;
	NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:
						   @"annotation", @"kind",
						   [NSNumber numberWithInt:MAX(time - kUserEventTimeBefore, 0)], @"startFrame",
						   [NSNumber numberWithInt:time], @"thumbFrame",
						   [NSNumber numberWithInt:MIN(time + kUserEventTimeAfter, movieDuration)], @"endFrame",
						   [NSNumber numberWithFloat:roi.origin.x], @"x",
						   [NSNumber numberWithFloat:roi.origin.y], @"y",
						   [NSNumber numberWithFloat:roi.size.width], @"width",
						   [NSNumber numberWithFloat:roi.size.height], @"height", nil];
	Event * event = [[[Event alloc] initWithMetadata:data
										OriginalSize:originalSize] autorelease];
	
	// Add the event
	[self addEvent:event];
	[scrollView.scrollView layoutSubviews];
	
	// Highlight, flash and scroll to it
	[self setHighlight:YES forEvent:event];
	[movieView flashEventWithKey:event.key];
	[scrollView scrollToEventWithKey:event.key];
}

- (void)displayEventsWithKeys:(NSArray *)keys
{
	[movieView displayEventsWithKeys:keys];
	[miniView displayEventsWithKeys:keys];
	[scrollView displayEventsWithKeys:keys];
}

- (void)displayAllEvents
{
	//[movieView displayAllEvents]; Don't display this one
	[miniView displayAllEvents];
	[scrollView displayAllEvents];
}

- (void)removeEventWithKey:(NSObject *)key
{
	[movieView removeEventWithKey:key];
	[miniView removeEventWithKey:key];
	[scrollView removeEventWithKey:key];
	[events removeObjectForKey:key];
	if (autosave)
		[self savePlist];
}

- (void)enableEditing:(BOOL)yesOrNo
{
	[movieView enableEditing:yesOrNo];
	[scrollView enableEditing:yesOrNo];
}

- (IBAction)saveToImage:(id)sender
{
	[self saveTimelineToImage:[[plistPath stringByDeletingPathExtension]
											 stringByAppendingPathExtension:@"png"]];
}

- (void)saveTimelineToImage:(NSString *)path
{
	UIGraphicsBeginImageContext(scrollView.scrollView.contentSize);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	for (UIView * v in [scrollView.eventViews allValues])
	{
		CGContextTranslateCTM(context, v.frame.origin.x, v.frame.origin.y);
		[v.layer renderInContext:context];
		CGContextTranslateCTM(context, -v.frame.origin.x, -v.frame.origin.y);
	}
	
	UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	[UIImagePNGRepresentation(image) writeToFile:path atomically:NO];
}

- (void)updateHighlights:(int)time
{
	// Remove highlights if needed
	NSArray * tmp = [NSArray arrayWithArray:highlightedEvents];
	for (Event * event in tmp)
		if (![event activeAtTime:time] &&
			!(time < event.startFrame && event.startFrame - time <= kHighlightTolerance)) // Compensate player's lack of accuracy
			[self setHighlight:NO forEvent:event];
	
	// Add highlights if needed
	for (Event * event in [events allValues])
		if ([event activeAtTime:time] && ![tmp containsObject:event])
			[self setHighlight:YES forEvent:event];
}

- (void)setHighlight:(BOOL)yesOrNo forEvent:(Event *)event
{
	[movieView setHighlight:yesOrNo forEventWithKey:event.key];
	[miniView setHighlight:yesOrNo forEventWithKey:event.key];
	[scrollView setHighlight:yesOrNo forEventWithKey:event.key];
	if (yesOrNo)
		[highlightedEvents addObject:event];
	else
		[highlightedEvents removeObject:event];
}

- (BOOL)isHighlightingEvent:(Event *)event
{
	return [highlightedEvents containsObject:event];
}

- (void)savePlist
{
	NSMutableArray * buffer = [NSMutableArray arrayWithCapacity:[events count]];
	for (Event * event in [events allValues])
		[buffer addObject:event.metadata];
	[buffer writeToFile:plistPath atomically:NO];
}

#pragma mark GoTo

- (IBAction)goTo30SecBefore:(id)sender
{
	[self goToTime:moviePlayerController.currentPlaybackTime - 17]; // Not very accurate
}

- (IBAction)goTo30SecAfter:(id)sender
{
	[self goToTime:moviePlayerController.currentPlaybackTime + 53]; // Not accurate at all
}

- (void)goToTime:(int)time
{
	[moviePlayerController setCurrentPlaybackTime:time];
	[scrollView refreshCurrentPosition];
	[self currentPositionChanged];
}

- (void)goToEventWithKey:(NSObject *)key
{
	[moviePlayerController setCurrentPlaybackTime:[[self eventForKey:key] startFrame]];
	[self currentPositionChanged];
	[self setHighlight:YES forEvent:[self eventForKey:key]];
	[movieView flashEventWithKey:key];
	[scrollView scrollToEventWithKey:key];
}

# pragma mark Playback

- (IBAction)togglePlay:(id)sender
{
	if ([moviePlayerController playbackState] == MPMoviePlaybackStatePlaying)
		[moviePlayerController pause];
	else
		[moviePlayerController play];
	playButton.playing = [moviePlayerController playbackState] == MPMoviePlaybackStatePlaying;
}

- (IBAction)suspend:(id)sender
{
	wasPlaying = ([moviePlayerController playbackState] == MPMoviePlaybackStatePlaying);
	if (wasPlaying)
		[self togglePlay:sender];
}

- (IBAction)resume:(id)sender
{
	if (wasPlaying)
		[self togglePlay:sender];
}

#pragma mark Notifications

- (void)currentPositionChanged
{
	// Update time labels and highlights if needed
	int time = moviePlayerController.currentPlaybackTime;
	if (time == currentTime)
		return;
	
	// Update current time
	currentTime = time;
	if (currentTime >= 3600) // Display hours?
		[self.currentTimeLabel setText:[NSString stringWithFormat:@"%d:%02d:%02d", currentTime / 3600, (currentTime % 3600)/60, currentTime % 60]];
	else
		[self.currentTimeLabel setText:[NSString stringWithFormat:@"%d:%02d", (currentTime % 3600)/60, currentTime % 60]];
	
	[self updateHighlights:time];
	
	// Update timeline views
	[miniView setCurrentPosition:time];
	[scrollView setCurrentPosition:time];
	
	// Update remaining time
	time = moviePlayerController.duration - currentTime;
	remainingTime = time;
	if (remainingTime >= 3600) // Display hours?
		[self.remainingTimeLabel setText:[NSString stringWithFormat:@"-%d:%02d:%02d", remainingTime / 3600, (remainingTime % 3600)/60, remainingTime % 60]];
	else
		[self.remainingTimeLabel setText:[NSString stringWithFormat:@"-%d:%02d", (remainingTime % 3600)/60, remainingTime % 60]];
}

- (void)playbackChanged:(NSNotification *)notification
{
    // Update interface
	[self currentPositionChanged];
	
	// Manage the timer
	if ([moviePlayerController playbackState] == MPMoviePlaybackStatePlaying ||
		[moviePlayerController playbackState] == MPMoviePlaybackStateSeekingForward ||
		[moviePlayerController playbackState] == MPMoviePlaybackStateSeekingBackward)
	{
		if (!timer)
			timer = [NSTimer scheduledTimerWithTimeInterval:kUpdateInterval
													 target:self
												   selector:@selector(currentPositionChanged)
												   userInfo:nil
													repeats:YES];
	}
	else if (timer)
	{
		[timer invalidate];
		timer = nil;
	}
}

# pragma mark Modal view

- (IBAction)presentModalView:(id)sender
{
	if (self.modalViewController)
    {
        return;
    }
    [self suspend:self];
	[self presentModalViewController:modalController animated:YES];
}

- (IBAction)dismissModalView:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
	[self resume:self];
}

@end

#pragma mark -

@implementation PlayButton

#define kLen 8.0

@synthesize playing;

- (void)setPlaying:(BOOL)yesOrNo
{
	playing = yesOrNo;
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGPoint origin = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0);
	[[UIColor whiteColor] set];
	
	if (self.isPlaying)
	{
		CGContextSetLineCap(context, kCGLineCapRound);
		CGContextSetLineWidth(context, kLen * 2.0/3.0);
		
		CGContextMoveToPoint(context, origin.x - kLen * 2.0/3.0, origin.y - kLen * 2.0/3.0);
		CGContextAddLineToPoint(context, origin.x - kLen * 2.0/3.0, origin.y + kLen * 2.0/3.0);
		CGContextStrokePath(context);
		
		CGContextMoveToPoint(context, origin.x + kLen * 2.0/3.0, origin.y - kLen * 2.0/3.0);
		CGContextAddLineToPoint(context, origin.x + kLen * 2.0/3.0, origin.y + kLen * 2.0/3.0);
		CGContextStrokePath(context);
	}
	else
	{
		CGContextMoveToPoint(context, origin.x - kLen, origin.y - kLen);
		CGContextAddLineToPoint(context, origin.x + kLen, origin.y);
		CGContextAddLineToPoint(context, origin.x - kLen, origin.y + kLen);
		
		CGContextFillPath(context);
	}
}

@end

