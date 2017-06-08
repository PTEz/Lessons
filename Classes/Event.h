//
//  Event.h
//  Lessons
//
//  Created by 利辺羅 on 10/04/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Event : NSObject
{
	// Variables
	NSObject * key;
	NSDictionary * metadata;
	NSString * kind;
	int startFrame, thumbFrame, endFrame;
	CGRect roi;
	CGSize originalSize;
}

@property (nonatomic, retain) NSObject * key;
@property (nonatomic, retain) NSDictionary * metadata;
@property (nonatomic, retain) NSString * kind;
@property int startFrame, thumbFrame, endFrame;
@property CGRect roi;
@property CGSize originalSize;

- (id)initWithMetadata:(NSDictionary *)metadata OriginalSize:(CGSize)size;
- (BOOL)activeAtTime:(int)time;

@end
