//
//  PBGitCommit.h
//  GitTest
//
//  Created by Pieter de Bie on 13-06-08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PBGitRefish.h"


extern NSString * const kGitXCommitType;


@interface PBGitCommit : NSObject <PBGitRefish> {
	PBGitSHA *sha;

	NSString* subject;
	NSString* author;
	NSString *committer;
	NSString* details;
	NSString *_patch;
	NSArray *parents;
	NSString *realSHA;

	int timestamp;
	char sign;
	id lineInfo;
	PBGitRepository* repository;
}

+ (PBGitCommit *)commitWithRepository:(PBGitRepository*)repo andSha:(PBGitSHA *)newSha;
- (id)initWithRepository:(PBGitRepository *)repo andSha:(PBGitSHA *)newSha;

- (void) addRef:(PBGitRef *)ref;
- (void) removeRef:(id)ref;
- (BOOL) hasRef:(PBGitRef *)ref;

- (NSString *)realSha;
- (BOOL) isOnSameBranchAs:(PBGitCommit *)other;
- (BOOL) isOnHeadBranch;

// <PBGitRefish>
- (NSString *) refishName;
- (NSString *) shortName;
- (NSString *) refishType;

@property (nonatomic, readonly) PBGitSHA *sha;
@property (nonatomic, copy) NSString* subject;
@property (nonatomic, copy) NSString* author;
@property (nonatomic, copy) NSString *committer;
@property (nonatomic, strong) NSArray *parents;

@property (nonatomic) int timestamp;

@property (nonatomic, strong) NSMutableArray* refs;
@property (nonatomic, readonly) NSDate *date;
@property (nonatomic, readonly) NSString* dateString;
@property (nonatomic, readonly) NSString* patch;
@property (nonatomic) char sign;

@property (nonatomic, readonly) NSString* details;
@property (nonatomic, readonly) PBGitTree* tree;
@property (nonatomic, readonly) NSArray* treeContents;
@property (nonatomic, strong) PBGitRepository* repository;
@property (nonatomic, strong) id lineInfo;
@end
