//
//  PBGitRepository.h
//  GitTest
//
//  Created by Pieter de Bie on 13-06-08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PBGitHistoryList.h"
#import "PBGitRevSpecifier.h"
#import "PBGitConfig.h"
#import "PBGitRefish.h"

typedef enum branchFilterTypes {
	kGitXAllBranchesFilter = 0,
	kGitXLocalRemoteBranchesFilter,
	kGitXSelectedBranchFilter
} PBGitXBranchFilterType;

static NSString * PBStringFromBranchFilterType(PBGitXBranchFilterType type) {
    switch (type) {
        case kGitXAllBranchesFilter:
            return @"All";
            break;
        case kGitXLocalRemoteBranchesFilter:
            return @"Local";
            break;
        case kGitXSelectedBranchFilter:
            return @"Selected";
            break;
        default:
            break;
    }
    return @"Not a branch filter type";
}

@class PBGitWindowController;
@class PBGitCommit;
@class PBGitSHA;

@interface PBGitRepository : NSDocument {
	PBGitHistoryList *revisionList;
	PBGitConfig *config;

	BOOL hasChanged;
	NSMutableArray *branches;
	PBGitRevSpecifier *currentBranch;
	NSInteger currentBranchFilter;
	NSMutableDictionary *refs;

	PBGitRevSpecifier *_headRef; // Caching
	PBGitSHA* _headSha;
}

- (id)initWithURL:(NSURL *)path;

- (void)handleBranchFilterEventForFilter:(PBGitXBranchFilterType)filter additionalArguments:(NSMutableArray *)arguments inWorkingDirectory:(NSURL *)workingDirectory;
- (void)handleRevListArguments:(NSArray *)arguments inWorkingDirectory:(NSURL *)workingDirectory;

- (NSFileHandle *)handleForCommand:(NSString *) cmd;
- (NSFileHandle *)handleForArguments:(NSArray *) args;
- (NSFileHandle *)handleInWorkDirForArguments:(NSArray *)args;
- (NSString *) outputForCommand:(NSString*) cmd;
- (NSString *)outputForCommand:(NSString *)str retValue:(int *)ret;
- (NSString *)outputForArguments:(NSArray *)arguments inputString:(NSString *)input retValue:(int *)ret;
- (NSString *)outputForArguments:(NSArray *)arguments inputString:(NSString *)input byExtendingEnvironment:(NSDictionary *)dict retValue:(int *)ret;

- (NSString *)outputForArguments:(NSArray *)args;
- (NSString *)outputForArguments:(NSArray *)args retValue:(int *)ret;
- (NSString *)outputInWorkdirForArguments:(NSArray *)arguments;
- (NSString *)outputInWorkdirForArguments:(NSArray *)arguments retValue:(int *)ret;
- (BOOL)executeHook:(NSString *)name output:(NSString **)output;
- (BOOL)executeHook:(NSString *)name withArgs:(NSArray *)arguments output:(NSString **)output;

- (NSString *)workingDirectory;
- (NSString *)projectName;
- (NSString *)gitIgnoreFilename;
- (BOOL)isBareRepository;

- (void)reloadRefs;
- (void)addRef:(PBGitRef *)ref fromParameters:(NSArray *)params;
- (void)lazyReload;
- (PBGitRevSpecifier *)headRef;
- (PBGitSHA *)headSHA;
- (PBGitCommit *)headCommit;
- (PBGitSHA *)shaForRef:(PBGitRef *)ref;
- (PBGitCommit *)commitForRef:(PBGitRef *)ref;
- (PBGitCommit *)commitForSHA:(PBGitSHA *)sha;
- (BOOL)isOnSameBranch:(PBGitSHA *)baseSHA asSHA:(PBGitSHA *)testSHA;
- (BOOL)isSHAOnHeadBranch:(PBGitSHA *)testSHA;
- (BOOL)isRefOnHeadBranch:(PBGitRef *)testRef;
- (BOOL)checkRefFormat:(NSString *)refName;
- (BOOL)refExists:(PBGitRef *)ref;
- (PBGitRef *)refForName:(NSString *)name;

- (NSArray *)remotes;
- (BOOL)hasRemotes;
- (PBGitRef *)remoteRefForBranch:(PBGitRef *)branch error:(NSError **)error;
- (NSString *)infoForRemote:(NSString *)remoteName;

- (void)readCurrentBranch;

- (NSString *)parseSymbolicReference:(NSString *)ref;
- (NSString *)parseReference:(NSString *)ref;

+ (NSURL *)gitDirForURL:(NSURL *)repositoryURL;
+ (NSURL *)baseDirForURL:(NSURL *)repositoryURL;

- (void)setup;
- (void)forceUpdateRevisions;

- (void)findInModeScriptCommand:(NSScriptCommand *)command; // for the scripting bridge

@property (nonatomic) BOOL hasChanged;
@property (nonatomic, readonly) PBGitWindowController *windowController;
@property (nonatomic, readonly) PBGitConfig *config;
@property (nonatomic) PBGitHistoryList *revisionList;
@property (nonatomic) NSMutableArray* branches;
@property (nonatomic) PBGitRevSpecifier *currentBranch;
@property (nonatomic) NSInteger currentBranchFilter;
@property (nonatomic) NSMutableDictionary* refs;
@end
