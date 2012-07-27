//
//  PBViewController.m
//  GitX
//
//  Created by Pieter de Bie on 22-09-08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PBViewController.h"
#import "PBGitRepository.h"
#import "PBGitWindowController.h"


@implementation PBViewController
@synthesize repository;
@synthesize status;
@synthesize isBusy;

- (id)initWithRepository:(PBGitRepository *)theRepository superController:(PBGitWindowController *)controller {
	NSString *nib = [[[self class] description] stringByReplacingOccurrencesOfString:@"Controller" withString:@"View"];
	if (self = [self initWithNibName:nib bundle:nil]) {
		repository = theRepository;
		superController = controller;
	}
	return self;
}

- (void)closeView
{
	[self unbind:@"repository"];
	if (hasViewLoaded)
		[[self view] removeFromSuperview];	// remove the current view
}

- (void)awakeFromNib
{
	hasViewLoaded = YES;
}

- (NSResponder *)firstResponder;
{
	return nil;
}

- (IBAction) refresh: sender
{
}

// The next methods should be implemented in the subclass if necessary
- (void)updateView
{
}

- (void)viewLoaded
{
}

@end
