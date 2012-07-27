//
//  PBRepositoryDocumentController.mm
//  GitX
//
//  Created by Ciarán Walsh on 15/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GXDocumentController.h"
#import "PBGitDefaults.h"
#import "PBGitRepository.h"
#import "PBGitWindowController.h"
#import "GitXScriptingConstants.h"

@interface NSAppleEventManager (GitX)
- (NSMutableArray *)arguments;
@end

//FIXME this code is shit. It was written by a noob. Make it proper.


@implementation GXDocumentController

- (NSInteger)runModalOpenPanel:(NSOpenPanel *)openPanel forTypes:(NSArray *)extensions {
    // configure the open panel to only allow selection of directories

	[openPanel setCanChooseFiles:YES];
	[openPanel setCanChooseDirectories:YES];
    [openPanel setAllowedFileTypes:@[@"git"]];
    return [openPanel runModal];
}

- (id)documentForURL:(NSURL *)url {
    // Convert paths to the .git dir before searching for an already open document
	return [super documentForURL:[PBGitRepository gitDirForURL:url]];
}

- (void)noteNewRecentDocumentURL:(NSURL*)url {
	[super noteNewRecentDocumentURL:[PBGitRepository baseDirForURL:url]];
}

- (void)openDocumentWithContentsOfURL:(NSURL *)url display:(BOOL)displayDocument completionHandler:(void (^)(NSDocument *, BOOL, NSError *))completionHandler
{
    PBGitRepository *document = [self documentForURL:url];
	if (!document) {
        document = [[PBGitRepository alloc] initWithURL:url];
		if (document)
            [self addDocument:document];
	}
    
    NSMutableArray *args = [[NSAppleEventManager sharedAppleEventManager] arguments];
	NSString *arg1 = args.count ? [args objectAtIndex:0] : nil;

	if ([arg1 isEqualToString:@"-c"] || [arg1 isEqualToString:@"--commit"]) {
		[PBGitDefaults setShowStageView:YES];
		[document.windowController showCommitView:self];
	}
    else if ([arg1 isEqualToString:@"--all"]) {
		[document handleBranchFilterEventForFilter:kGitXAllBranchesFilter additionalArguments:args inWorkingDirectory:url];
	}
    else if ([arg1 isEqualToString:@"--local"]) {
		[document handleBranchFilterEventForFilter:kGitXLocalRemoteBranchesFilter additionalArguments:args inWorkingDirectory:url];
	}
    else if ([arg1 isEqualToString:@"--branch"]) {
		[document handleBranchFilterEventForFilter:kGitXSelectedBranchFilter additionalArguments:args inWorkingDirectory:url];
	}
    else {
        // if the argument is not a known command then treat it as a rev-list specifier
        [document handleRevListArguments:args inWorkingDirectory:url];
    }

    if (displayDocument)
        [document showWindows];

    completionHandler(document, displayDocument, nil);
}

@end



@implementation NSAppleEventManager (GitX)

- (NSMutableArray *)arguments {
    NSAppleEventDescriptor *argumentsList = [[[self currentAppleEvent] paramDescriptorForKeyword:keyAEPropData] paramDescriptorForKeyword:kGitXAEKeyArgumentsList];

    NSMutableArray *arguments = [NSMutableArray array];
	uint argumentsIndex = 1; // AppleEvent list descriptor's are one based
	while(1) {
		NSAppleEventDescriptor *arg = [argumentsList descriptorAtIndex:argumentsIndex++];
		if (arg)
			[arguments addObject:[arg stringValue]];
		else
			break;
	}

    return arguments;
}

@end
