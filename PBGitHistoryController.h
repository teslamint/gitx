//
//  PBGitHistoryView.h
//  GitX
//
//  Created by Pieter de Bie on 19-09-08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PBViewController.h"



@interface PBGitHistoryController : PBViewController {
	IBOutlet PBRefController *__unsafe_unretained refController;
	IBOutlet NSSearchField *searchField;
	IBOutlet NSArrayController *commitController;
	IBOutlet NSTreeController *treeController;
	IBOutlet NSOutlineView* fileBrowser;
	NSArray *currentFileBrowserSelectionPath;
	IBOutlet PBCommitList *commitList;
	IBOutlet NSSplitView *historySplitView;
	IBOutlet PBWebHistoryController *webHistoryController;
    QLPreviewPanel* previewPanel;
	IBOutlet PBHistorySearchController *searchController;

	IBOutlet PBGitGradientBarView *upperToolbarView;
	IBOutlet NSButton *mergeButton;
	IBOutlet NSButton *cherryPickButton;
	IBOutlet NSButton *rebaseButton;

	IBOutlet PBGitGradientBarView *scopeBarView;
	IBOutlet NSButton *allBranchesFilterItem;
	IBOutlet NSButton *localRemoteBranchesFilterItem;
	IBOutlet NSButton *selectedBranchFilterItem;

	IBOutlet id webView;
	int selectedCommitDetailsIndex;
	BOOL forceSelectionUpdate;
	
	PBGitTree *gitTree;
	PBGitCommit *webCommit;
	PBGitCommit *selectedCommit;
}

@property (nonatomic, readonly) NSTreeController* treeController;
@property (nonatomic, assign) int selectedCommitDetailsIndex;
@property (nonatomic, strong) PBGitCommit *webCommit;
@property (nonatomic, strong) PBGitTree* gitTree;
@property (nonatomic, readonly) NSArrayController *commitController;
@property (nonatomic, unsafe_unretained, readonly) PBRefController *refController;
@property (nonatomic, readonly) PBHistorySearchController *searchController;
@property (nonatomic, readonly) PBCommitList *commitList;

- (IBAction) setDetailedView:(id)sender;
- (IBAction) setTreeView:(id)sender;
- (IBAction) setBranchFilter:(id)sender;

- (void)selectCommit:(PBGitSHA *)commit;
- (IBAction) refresh:(id)sender;
- (IBAction) toggleQLPreviewPanel:(id)sender;
- (IBAction) openSelectedFile:(id)sender;
- (void) updateQuicklookForce: (BOOL) force;

// Context menu methods
- (NSMenu *)contextMenuForTreeView;
- (NSArray *)menuItemsForPaths:(NSArray *)paths;
- (void)showCommitsFromTree:(id)sender;
- (void)showInFinderAction:(id)sender;
- (void)openFilesAction:(id)sender;

// Find/Search methods
- (IBAction)selectNext:(id)sender;
- (IBAction)selectPrevious:(id)sender;

- (void) copyCommitInfo;
- (void) copyCommitSHA;

- (BOOL) hasNonlinearPath;

- (NSMenu *)tableColumnMenu;

- (BOOL)splitView:(NSSplitView *)sender canCollapseSubview:(NSView *)subview;

@end
