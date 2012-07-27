//
//  PBHistorySearchController.h
//  GitX
//
//  Created by Nathan Kinsinger on 8/21/10.
//  Copyright 2010 Nathan Kinsinger. All rights reserved.
//

#import <Cocoa/Cocoa.h>


typedef enum historySearchModes {
	kGitXBasicSeachMode = 1,
	kGitXPickaxeSearchMode,
	kGitXRegexSearchMode,
	kGitXPathSearchMode,
	kGitXMaxSearchMode    // always keep this item last
} PBHistorySearchMode;



@interface PBHistorySearchController : NSObject {
	PBGitHistoryController *historyController;
	NSArrayController *commitController;

	PBHistorySearchMode searchMode;
	NSIndexSet *results;

	NSSearchField *searchField;
	NSSegmentedControl *stepper;
	NSTextField *numberOfMatchesField;
	NSProgressIndicator *progressIndicator;
	NSTimer *searchTimer;

	NSTask *backgroundSearchTask;

	NSPanel *rewindPanel;
}

@property (nonatomic) IBOutlet PBGitHistoryController *historyController;
@property (nonatomic) IBOutlet NSArrayController *commitController;

@property (nonatomic) IBOutlet NSSearchField *searchField;
@property (nonatomic) IBOutlet NSSegmentedControl *stepper;
@property (nonatomic) IBOutlet NSTextField *numberOfMatchesField;
@property (nonatomic) IBOutlet NSProgressIndicator *progressIndicator;

@property (nonatomic) PBHistorySearchMode searchMode;


- (BOOL)isRowInSearchResults:(NSInteger)rowIndex;
- (BOOL)hasSearchResults;

- (void)selectSearchMode:(id)sender;

- (void)selectNextResult;
- (void)selectPreviousResult;
- (IBAction)stepperPressed:(id)sender;

- (void)clearSearch;
- (IBAction)updateSearch:(id)sender;

- (void)setHistorySearch:(NSString *)searchString mode:(NSInteger)mode;

@end
