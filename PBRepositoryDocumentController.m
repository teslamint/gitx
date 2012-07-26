//
//  PBRepositoryDocumentController.mm
//  GitX
//
//  Created by Ciarán Walsh on 15/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PBRepositoryDocumentController.h"
#import "PBGitRepository.h"


@implementation PBRepositoryDocumentController

- (NSInteger)runModalOpenPanel:(NSOpenPanel *)openPanel forTypes:(NSArray *)extensions {
    // configure the open panel to only allow selection of directories

	[openPanel setCanChooseFiles:YES];
	[openPanel setCanChooseDirectories:YES];
    [openPanel setAllowedFileTypes:@[@"git"]];
    return [openPanel runModal];
}

- (id)documentForURL:(NSURL *)URL {
    // Convert paths to the .git dir before searching for an already open document
	return [super documentForURL:[PBGitRepository gitDirForURL:URL]];
}

- (void)noteNewRecentDocumentURL:(NSURL*)url {
	[super noteNewRecentDocumentURL:[PBGitRepository baseDirForURL:url]];
}

- (id)documentForLocation:(NSURL*)url {
	id document = [self documentForURL:url];
	if (!document) {
		
		if (!(document = [[PBGitRepository alloc] initWithURL:url]))
			return nil;

		[self addDocument:document];
	}
	else
		[document showWindows];

	return document;
}

@end
