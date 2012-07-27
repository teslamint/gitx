//
//  PBGraphCellInfo.h
//  GitX
//
//  Created by Pieter de Bie on 27-08-08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PBGraphCellInfo : NSObject
{
	int position;
	struct PBGitGraphLine *lines;
	int nLines;
	int numColumns;
	char sign;	
}

- (id)initWithPosition:(int)p andLines:(struct PBGitGraphLine *)l;

@property (nonatomic, assign) struct PBGitGraphLine *lines;
@property (nonatomic, assign) int nLines;
@property (nonatomic, assign) int position, numColumns;
@property (nonatomic, assign) char sign;
@end