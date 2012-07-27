//
//  PBWebGitController.h
//  GitTest
//
//  Created by Pieter de Bie on 14-06-08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PBWebController.h"


@interface PBWebHistoryController : PBWebController {
	IBOutlet PBGitHistoryController* historyController;
	IBOutlet id<PBRefContextDelegate> contextMenuDelegate;
	PBGitSHA *currentSha;
	NSString *diff;
}

- (void)changeContentTo:(PBGitCommit *)content;
- (void)sendKey:(NSString*) key;

@property (nonatomic, readonly) NSString* diff;
@end
