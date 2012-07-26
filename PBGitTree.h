//
//  PBGitTree.h
//  GitTest
//
//  Created by Pieter de Bie on 15-06-08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PBGitRepository.h"

@interface PBGitTree : NSObject {
	long long _fileSize;

	NSString* sha;
	NSString* path;
	PBGitRepository* repository;
	PBGitTree* parent;
	NSArray* children;
	BOOL leaf;

	NSString* localFileName;
	NSDate* localMtime;
}

+ (PBGitTree*)rootForCommit:(id)commit;
+ (PBGitTree*)treeForTree:(PBGitTree *)tree andPath:(NSString *)path;
- (void)saveToFolder:(NSString *)directory;
- (NSString *)textContents;
- (NSString *)blame;
- (NSString *)log:(NSString *)format;
- (NSString *)tmpFileNameForContents;
- (long long)fileSize;

@property (nonatomic, copy) NSString* sha;
@property (nonatomic, copy) NSString* path;
@property (nonatomic) BOOL leaf;
@property (nonatomic) PBGitRepository* repository;
@property (nonatomic) PBGitTree* parent;
@property (nonatomic, readonly) NSArray* children;
@property (nonatomic, readonly) NSString* fullPath;
@property (nonatomic, readonly) NSString* contents;
@end
