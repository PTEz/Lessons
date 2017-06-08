//
//  Survey.m
//  Lessons
//
//  Created by 利辺羅 on 10/10/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Survey.h"
#import "EventTreeView.h"

NSString * const kCurrentSectionKey = @"currentSection";
NSString * const kSurveyPlist = @"survey.plist";
NSString * const kEmptyPlist = @"empty.plist";
NSString * const kQuizMovie = @"Muscle cells and the lungs.m4v";
NSString * const kQuizPlist = @"Muscle cells and the lungs.plist";
NSString * const kSummarizationMovie1 = @"Hydrogen part 3 Eigenfunctions.m4v";
NSString * const kSummarizationPlist1 = @"Hydrogen part 3 Eigenfunctions.plist";
NSString * const kSummarizationMovie2 = @"Radian Measure.mov";
NSString * const kSummarizationPlist2 = @"Radian Measure.plist";

@implementation SurveyViewController

@synthesize surveyView;
@synthesize itemTitle;
@synthesize contentPlaceholder;
@synthesize surveyIDLabel;
@synthesize continueButton;
@synthesize timeButton;
@synthesize currentContent, lastContent;
@synthesize mainViewController;

- (void)awakeFromNib
{
	[super awakeFromNib];
	surveyAnswers = [[NSMutableDictionary alloc] init];
	
	// Listen to keyboard events
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWasShown:)
												 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWasHidden:)
												 name:UIKeyboardDidHideNotification object:nil];
	
	// Initializations
	self.modalPresentationStyle = UIModalPresentationPageSheet;
	self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	self.tabBar.hidden = YES;
	selectedSection = -1;
	keyboardShown = NO;
	itemTitle.title = @"Welcome";
	
	// Tests
	tests = [[NSArray arrayWithObjects:
			  @"quizWithSummary",
			  //@"quizWithNoSummary",
			  @"summarization1",
			  @"evaluation1",
			  @"summarization2",
			  @"evaluation2", nil] retain];
	
	// Allow triple tap on tab bar to force next content
	UITapGestureRecognizer * recognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self
																				   action:@selector(skipToNextContent)] autorelease];
	recognizer.numberOfTapsRequired = 3;
	[self.tabBar addGestureRecognizer:recognizer];
	
	// Initialize timer
	testInProgress = NO;
	if (!timer)
		[NSTimer scheduledTimerWithTimeInterval:60
										 target:self
									   selector:@selector(aMinuteHasPassed)
									   userInfo:nil
										repeats:YES];
	
	// Start
	[self doCurrentContent];
}

# pragma mark Tests

- (NSString *)personalizedPlist:(NSString *)plist
{
	return [NSString stringWithFormat:@"%@ %@ %@",
			[[[NSDate date] description] substringWithRange:NSMakeRange(5, 5)],
			surveyID,
			plist];
}

- (void)quizWithSummary
{
	[mainViewController enableEditing:NO];
	[mainViewController loadMovie:kQuizMovie
							plist:kQuizPlist];
	[surveyAnswers setObject:[NSString stringWithFormat:@"%@ %@", kQuizMovie, kQuizPlist]
					  forKey:[NSString stringWithFormat:@"(%d) %@", self.selectedIndex, @"quizWithSummary"]];
}

- (void)quizWithNoSummary
{
	[mainViewController enableEditing:NO];
	[mainViewController loadMovie:kQuizMovie
							plist:kEmptyPlist];
	[surveyAnswers setObject:[NSString stringWithFormat:@"%@ %@", kQuizMovie, kEmptyPlist]
					  forKey:[NSString stringWithFormat:@"(%d) %@", self.selectedIndex, @"quizWithNoSummary"]];
	
	// Wait...
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(continueQuizWithNoSummary)
												 name:MPMovieNaturalSizeAvailableNotification
											   object:mainViewController.moviePlayerController];
}

- (void)continueQuizWithNoSummary
{
	// Stop waiting
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	// Create fixed interval events
	Event * event;
	NSString * plist = [[NSBundle mainBundle] pathForResource:kQuizPlist ofType:nil];
	int nEvents = [[[[NSArray alloc] initWithContentsOfFile:plist] autorelease] count];
	CGSize size = mainViewController.originalSize;
	int duration = mainViewController.moviePlayerController.duration;
	for (int i = 0; i < nEvents; i++)
	{
		NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:
							   @"fixedInterval", @"kind",
							   [NSNumber numberWithInt:i * duration/nEvents], @"startFrame",
							   [NSNumber numberWithInt:i * duration/nEvents], @"thumbFrame",
							   [NSNumber numberWithInt:i * duration/nEvents + 5], @"endFrame",
							   [NSNumber numberWithFloat:0.0], @"x",
							   [NSNumber numberWithFloat:0.0], @"y",
							   [NSNumber numberWithFloat:size.width], @"width",
							   [NSNumber numberWithFloat:size.height], @"height", nil];
		event = [[[Event alloc] initWithMetadata:data
									OriginalSize:mainViewController.originalSize] autorelease];
		[mainViewController addEvent:event save:NO];
	}
}

- (void)summarization1
{
	[mainViewController enableEditing:YES];
	[mainViewController loadMovie:kSummarizationMovie1
							plist:[self personalizedPlist:kSummarizationPlist1]
					 originalSize:CGSizeMake(1280, 720)];
	[surveyAnswers setObject:kSummarizationMovie1
					  forKey:[NSString stringWithFormat:@"(%d) %@", self.selectedIndex, @"summarization1"]];
}

- (void)evaluation1
{
	[mainViewController enableEditing:NO];
	[mainViewController loadMovie:kSummarizationMovie1
							plist:kSummarizationPlist1
					 originalSize:CGSizeMake(1280, 720)];
	[surveyAnswers setObject:[NSString stringWithFormat:@"%@ %@", kSummarizationMovie1, kSummarizationPlist1]
					  forKey:[NSString stringWithFormat:@"(%d) %@", self.selectedIndex, @"evaluation1"]];
}

- (void)summarization2
{
	[mainViewController enableEditing:YES];
	[mainViewController loadMovie:kSummarizationMovie2
							plist:[self personalizedPlist:kSummarizationPlist2]];
	[surveyAnswers setObject:kSummarizationMovie2
					  forKey:[NSString stringWithFormat:@"(%d) %@", self.selectedIndex, @"summarization2"]];
}

- (void)evaluation2
{
	[mainViewController enableEditing:NO];
	[mainViewController loadMovie:kSummarizationMovie2
							plist:kSummarizationPlist2];
	[surveyAnswers setObject:[NSString stringWithFormat:@"%@ %@", kSummarizationMovie2, kSummarizationPlist2]
					  forKey:[NSString stringWithFormat:@"(%d) %@", self.selectedIndex, @"evaluation2"]];
}

# pragma mark Content validation

- (void)skipToNextContent
{
	contentShouldFinish = YES;
	[self shouldFinishCurrentContent:self];
}

- (void)aMinuteHasPassed
{
	if (!testInProgress)
		return;
	
	int minutesLeft = MAX(0, (testShouldFinishTime - [NSDate timeIntervalSinceReferenceDate] + 59)/60);
	[timeButton setTitle:[NSString stringWithFormat:@"%d'", minutesLeft] forState:UIControlStateNormal];
	if (timeButton.hidden)
		timeButton.hidden = NO;
	if (!minutesLeft)
		[self skipToNextContent];
}

- (void)doCurrentContent
{
	// Make sure the modal view is visible
	if (!self.parentViewController)
		[mainViewController presentModalView:self];
	
	// No content? Then try to switch sections
	if (!currentContent && selectedSection + 1 < [self.viewControllers count])
	{
		// Select new section
		selectedSection++;
		self.selectedIndex = selectedSection;
		itemTitle.title = self.tabBar.selectedItem.title;
		self.tabBar.hidden = NO;
		
		// Mark progress
		[surveyAnswers setObject:[NSNumber numberWithInt:self.selectedIndex] forKey:kCurrentSectionKey];
		[surveyAnswers writeToFile:surveyPath atomically:NO];
		
		// Do section's content
		self.currentContent = [(SurveySectionViewController *)self.selectedViewController nextContent];
	}
	
	// Still no content? Then finish survey
	if (!currentContent)
	{
		[timer invalidate];
		self.continueButton.enabled = NO;
		self.tabBar.hidden = YES;
		itemTitle.title = @"End of the survey";
		self.currentContent = lastContent;
	}
	
	// Display new content
	contentShouldFinish = NO;
	[[contentPlaceholder.subviews lastObject] removeFromSuperview];
	[contentPlaceholder addSubview:(SurveyContentView *)currentContent];
	
	// Is it a test?
	if (currentContent.tag >= 0)
	{
		[self performSelector:NSSelectorFromString([tests objectAtIndex:currentContent.tag])];
		testInProgress = YES;
		testShouldFinishTime = [NSDate timeIntervalSinceReferenceDate] + self.tabBar.selectedItem.tag*60;
		[self aMinuteHasPassed];
	}
}

- (NSString *)targetValue:(SurveyLabel *)label
{
	if ([label.target isKindOfClass:[UITextField class]])
		return [(UITextField *)label.target text];
	
	if ([label.target isKindOfClass:[UITextView class]])
		return [(UITextView *)label.target text];
	
	if ([label.target isKindOfClass:[UISegmentedControl class]])
	{
		UISegmentedControl * segmentedControl = (UISegmentedControl *)label.target;
		if (segmentedControl.selectedSegmentIndex >= 0)
			return [segmentedControl titleForSegmentAtIndex:segmentedControl.selectedSegmentIndex];
	}
	return @"";
}

- (IBAction)shouldFinishCurrentContent:(id)sender
{
	// Resign first responder (hide keyboard)
	if (activeField)
	{
		[activeField resignFirstResponder];
		activeField = nil;
	}
	
	// Finish test?
	if (testInProgress)
		if (contentShouldFinish)
		{
			[mainViewController suspend:self];
			[mainViewController saveTimelineToImage:[[mainViewController.plistPath stringByDeletingPathExtension]
													 stringByAppendingPathExtension:@"png"]];
			testInProgress = NO;
		}
		else
		{
			// Continue the test
			[mainViewController dismissModalView:self];
			return;
		}
	
	// Highlight errors
	BOOL validationError = NO;
	SurveyLabel * label;
	NSString * value;
	for (UIView * view in currentContent.subviews)
		if ([view isKindOfClass:[SurveyLabel class]])
		{
			label = (SurveyLabel *)view;
			if (!label.target)
				continue;
			
			// Not valid
			value = [self targetValue:label];
			if (!label.tag && ![value length])
			{
				label.textColor = [UIColor colorWithRed:kHighlightedEventR
												  green:kHighlightedEventG
												   blue:kHighlightedEventB alpha:1.0];
				validationError = YES;
			}
			
			// Valid
			else
			{
				label.textColor = label.colorWhenValid;
				[surveyAnswers setObject:value
								  forKey:[NSString stringWithFormat:@"(%d) %@", self.selectedIndex, label.text]];
			}
		}
	
	// Validation errors?
	if (validationError && !contentShouldFinish)
		return;
	
	// Prepare for first save?
	if (!surveyID)
	{
		surveyID = [[surveyAnswers allValues] lastObject];
		surveyIDLabel.text = [NSString stringWithFormat:@"#%@", surveyID];
		surveyPath = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
					   stringByAppendingPathComponent:[self personalizedPlist:kSurveyPlist]] retain];
		
		// Read previous values (if any)
		[surveyAnswers addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:surveyPath]];
		
		// Resume survey if it was interrupted
		NSNumber * interruptedSection = [surveyAnswers objectForKey:kCurrentSectionKey];
		if (interruptedSection)
		{
			selectedSection = [interruptedSection intValue] - 1;
			self.currentContent = nil;
			[self doCurrentContent];
			return;
		}
	}
	
	// Clean time badge
	timeButton.hidden = YES;
	
	// Save and move to next content
	NSLog(@">>> %@", surveyAnswers);
	[surveyAnswers writeToFile:surveyPath atomically:NO];
	self.currentContent = [currentContent nextContent];
	[self doCurrentContent];
}

# pragma mark Utilities

- (IBAction)generateTimelineImages:(id)sender
{
	if (!plistPaths)
	{
		NSError * error = nil;
		NSString * plistDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
		plistPaths = [[NSMutableArray alloc] initWithArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:plistDirectory
																											   error:&error]];
	}
	else
		[mainViewController saveTimelineToImage:[[mainViewController.plistPath stringByDeletingPathExtension]
												 stringByAppendingPathExtension:@"png"]];
	
	NSString * path = @"";
	while (plistPaths.count > 0 && ![path.pathExtension isEqual:@"plist"])
	{
		path = [plistPaths.lastObject retain];
		[plistPaths removeLastObject];
	}
	
	if ([path.pathExtension isEqual:@"plist"])
	{
		//[mainViewController loadMovie:kSummarizationMovie1 plist:path originalSize:CGSizeMake(1280, 720)];
		[mainViewController loadMovie:kSummarizationMovie2 plist:path];
		NSLog(@">>> %@", path);
		[path release];
	}
}

- (IBAction)mergeSurveys:(id)sender
{
	NSError * error = nil;
	NSString * surveysDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	NSArray * surveyPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:surveysDir
																				error:&error];
	
	NSMutableSet * questions = [NSMutableSet set];
	NSMutableArray * surveys = [NSMutableArray array];
	NSDictionary * survey;
	for (NSString * path in surveyPaths)
	{
		survey = [NSDictionary dictionaryWithContentsOfFile:[surveysDir stringByAppendingPathComponent:path]];
		if (!survey)
			continue;
		[questions addObjectsFromArray:[survey allKeys]];
		[surveys addObject:survey];
	}
	NSArray * sortedQuestions = [[questions allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	
	NSString * buffer = @"";
	for (NSString * q in sortedQuestions)
	{
		buffer = [buffer stringByAppendingFormat:@"\"%@\"	", q];
	}
	
	NSString * answer;
	for (survey in surveys)
	{
		buffer = [buffer stringByAppendingString:@"\n"];
		for (NSString * q in sortedQuestions)
		{
			answer = [survey objectForKey:q];
			buffer = [buffer stringByAppendingFormat:@"\"%@\"	", answer?answer:@""];
		}
	}
	
	[buffer writeToFile:[surveysDir stringByAppendingPathComponent:@"surveys.txt"]
			 atomically:NO
			   encoding:NSUTF8StringEncoding
				  error:&error];
}

# pragma mark Keyboard handling

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    activeField = textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    activeField = nil;
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    if (keyboardShown)
        return;
	
    NSDictionary * info = [aNotification userInfo];
	
	// Get the size of the keyboard
    NSValue * aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
	
    // Resize the content view
	NSLog(@">>> from: %@", currentContent);
	CGRect frame = currentContent.frame;
	frame.size.height -= keyboardSize.width;
	currentContent.frame = frame;
	NSLog(@">>> to: %@", currentContent);	
	
    // Scroll the active text field into view.
    CGRect textFieldRect = activeField.frame;
    [currentContent scrollRectToVisible:textFieldRect animated:YES];
	
    keyboardShown = YES;
}

- (void)keyboardWasHidden:(NSNotification*)aNotification
{
    if (!keyboardShown)
        return;
	
	NSDictionary * info = [aNotification userInfo];
	
    // Get the size of the keyboard.
    NSValue * aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
	
    // Reset the height of the content to its original value
	SurveyContentView * sc = (SurveyContentView *)currentContent;
    CGRect viewFrame = [sc frame];
    viewFrame.size.height += keyboardSize.width;
    sc.frame = viewFrame;
	
    keyboardShown = NO;
}

# pragma mark Other

// Landscape orientations only
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[super viewDidUnload];
}


- (void)dealloc
{
    [surveyAnswers release];
	[super dealloc];
}

@end


@implementation SurveySectionViewController

@synthesize nextContent;

@end


@implementation SurveyContentView

@synthesize nextContent;

- (void)awakeFromNib
{
	[super awakeFromNib];
	self.contentSize = self.frame.size;
}
@end


@implementation SurveyLabel

@synthesize colorWhenValid;
@synthesize target;

- (void)awakeFromNib
{
	[super awakeFromNib];
	self.colorWhenValid = self.textColor;
}

@end

