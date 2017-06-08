//
//  Event.m
//  Lessons
//
//  Created by 利辺羅 on 10/04/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Event.h"

@implementation Event

@synthesize metadata;
@synthesize kind;
@synthesize startFrame;
@synthesize thumbFrame;
@synthesize endFrame;
@synthesize roi;
@synthesize originalSize;
@synthesize key;

- (id)initWithMetadata:(NSDictionary *)data OriginalSize:(CGSize)size
{
	if ((self = [super init]))
	{
        key = data;
		metadata = data;
		kind = [metadata valueForKey:@"kind"];
		startFrame = MAX([(NSNumber *)[metadata valueForKey:@"startFrame"] intValue], 0.0);
		thumbFrame = [(NSNumber *)[metadata valueForKey:@"thumbFrame"] intValue];
		endFrame = [(NSNumber *)[metadata valueForKey:@"endFrame"] intValue];
		roi = CGRectMake([(NSNumber *)[metadata valueForKey:@"x"] floatValue],
						 [(NSNumber *)[metadata valueForKey:@"y"] floatValue],
						 [(NSNumber *)[metadata valueForKey:@"width"] floatValue],
						 [(NSNumber *)[metadata valueForKey:@"height"] floatValue]);
		
		// Validate values
		endFrame = MAX(thumbFrame, endFrame);
		
		originalSize = size;
		// Adjust to iOS' inverted Y coordinates
		roi.origin.y = size.height - roi.origin.y - roi.size.height;
    }
    return self;
}

- (BOOL)activeAtTime:(int)time
{
	return (startFrame <= time &&
			time <= endFrame);
}

@end
