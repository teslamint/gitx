//
//  PBLabelController.h
//  GitX
//
//  Created by Pieter de Bie on 21-10-08.
//  Copyright 2008 Pieter de Bie. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PBRefContextDelegate.h"


@interface PBRefController : NSObject <PBRefContextDelegate> {
	IBOutlet PBGitHistoryController *historyController;
	IBOutlet NSArrayController *commitController;
	IBOutlet PBCommitList *commitList;
	IBOutlet NSPopUpButton *branchPopUp;
}

- (void) copySHA:(PBRefMenuItem *)sender;
- (void) copyPatch:(PBRefMenuItem *)sender;
- (void) diffWithHEAD:(PBRefMenuItem *)sender;
- (void) showTagInfoSheet:(PBRefMenuItem *)sender;

- (NSArray *)menuItemsForRef:(PBGitRef *)ref;
- (NSArray *)menuItemsForCommit:(PBGitCommit *)commit;
- (NSArray *)menuItemsForRow:(NSInteger)rowIndex;

@end
