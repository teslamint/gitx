//
//  GitTest_AppDelegate.m
//  GitTest
//
//  Created by Pieter de Bie on 13-06-08.
//  Copyright __MyCompanyName__ 2008 . All rights reserved.
//

#import "ApplicationController.h"
#import "PBGitRepository.h"
#import "PBGitRevisionCell.h"
#import "PBGitWindowController.h"
#import "PBRepositoryDocumentController.h"
#import "PBServicesController.h"
#import "PBGitXProtocol.h"
#import "PBNSURLPathUserDefaultsTransfomer.h"
#import "PBGitDefaults.h"



@implementation ApplicationController

- (id)init {
#ifdef DEBUG_BUILD
	[NSApp activateIgnoringOtherApps:YES];
#endif

	if (self = [super init]) {
        if (![[NSBundle bundleWithPath:@"/System/Library/Frameworks/Quartz.framework/Frameworks/QuickLookUI.framework"] load])
            if (![[NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/QuickLookUI.framework"] load])
                NSLog(@"Could not load QuickLook");

        [NSValueTransformer setValueTransformer:[PBNSURLPathUserDefaultsTransfomer new] forName:@"PBNSURLPathUserDefaultsTransfomer"];
        
        [PBGitDefaults class]; // Make sure the PBGitDefaults is initialized, by calling a random method
    }
	return self;
}

- (void)registerServices
{
	// Register URL
	[NSURLProtocol registerClass:[PBGitXProtocol class]];

	// Register the service class
	PBServicesController *services = [[PBServicesController alloc] init];
	[NSApp setServicesProvider:services];

	// Force update the services menu if we have a new services version
	int serviceVersion = [[NSUserDefaults standardUserDefaults] integerForKey:@"Services Version"];
	if (serviceVersion < 2)
	{
		NSLog(@"Updating services menu…");
		NSUpdateDynamicServices();
		[[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"Services Version"];
	}
}

- (void)applicationDidFinishLaunching:(NSNotification*)notification
{
	// Make sure Git's SSH password requests get forwarded to our little UI tool:
	setenv( "SSH_ASKPASS", [[[NSBundle mainBundle] pathForResource:@"gitx_askpasswd" ofType:@""] UTF8String], 1 );
	setenv( "DISPLAY", "localhost:0", 1 );

	[self registerServices];

    NSArray *launchedDocuments = [[PBRepositoryDocumentController sharedDocumentController] documents];

    // to bring the launched documents to the front
    for (PBGitRepository *document in launchedDocuments)
        [document showWindows];
}

- (void)windowWillClose:sender
{
	[firstResponder terminate:sender];
}

- (IBAction)showAboutPanel:(id)sender
{
	NSString *gitversion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleGitVersion"];
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	if (gitversion)
		[dict addEntriesFromDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:gitversion, @"Version", nil]];

	#ifdef DEBUG_BUILD
		[dict addEntriesFromDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:@"GitX (DEBUG)", @"ApplicationName", nil]];
	#endif

	[NSApp orderFrontStandardAboutPanelWithOptions:dict];
}

- (BOOL)needsRoot {
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if ([fm fileExistsAtPath:@"/usr/local/bin/gitx"] && ![fm isWritableFileAtPath:@"/usr/local/bin/gitx"])
        return YES;
    
    if ([fm isWritableFileAtPath:@"/usr/local/bin"]) {
        BOOL isdir;
        if (![fm fileExistsAtPath:@"/usr/local/bin" isDirectory:&isdir] && !isdir)
            @throw @"/usr/local/bin is not a directory.";
        return NO;
    }
    if ([fm isWritableFileAtPath:@"/usr/local"]) {
        BOOL isdir;
        if (![fm fileExistsAtPath:@"/usr/local" isDirectory:&isdir] && !isdir)
            @throw @"/usr/local is not a directory.";
        return NO;
    }
    
    return YES;
}

- (IBAction)installCliTool:(id)sender {
    id from = [[NSBundle mainBundle] pathForResource:@"gitx" ofType:@""];
    id to = @"/usr/local/bin/gitx";
    
    @try {
        if (self.needsRoot) {
            AuthorizationRef auth;
            if (AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &auth) == errAuthorizationSuccess)
            {
                char const* mkdir_arg[] = { "-p", [[to stringByDeletingLastPathComponent] UTF8String], NULL};
                AuthorizationExecuteWithPrivileges(auth, "/bin/mkdir", kAuthorizationFlagDefaults, (char**)mkdir_arg, NULL);

                char const* arguments[] = { "-f", "-s", [from UTF8String], [to UTF8String],  NULL };
                if (AuthorizationExecuteWithPrivileges(auth, "/bin/ln", kAuthorizationFlagDefaults, (char**)arguments, NULL) == errAuthorizationSuccess) {
                    int status;
                    int pid = wait(&status);
                    if (!(pid != -1 && WIFEXITED(status) && WEXITSTATUS(status) == 0))
                        @throw @"Could not create gitx symlink :(";
                } else
                    @throw @"You canceled authorisation.";

                AuthorizationFree(auth, kAuthorizationFlagDefaults);
            }
        } else {
            //FIXME this is a hard link, root-route is symlink, should be same, hard links are better IMO
            
            [[NSFileManager defaultManager] removeItemAtPath:to error:nil];
            
            id error = nil;
            [[NSFileManager defaultManager] linkItemAtPath:from toPath:to error:&error];
            if (error)
                @throw error;
        }

        [[NSAlert alertWithMessageText:@"Command Line Tool Installed Successfully"
                         defaultButton:nil
                       alternateButton:nil
                           otherButton:nil
             informativeTextWithFormat:@"You now have: %@.", to] runModal];
    }
    @catch (id errmsg) {
        if ([errmsg isKindOfClass:[NSError class]])
            errmsg = [errmsg localizedFailureReason];
        
		[[NSAlert alertWithMessageText:@"Could Not Install Command Line Tool"
                         defaultButton:nil
                       alternateButton:nil
                           otherButton:nil
             informativeTextWithFormat:@"%@", errmsg] runModal];
    }
}

- (NSString *)applicationSupportFolder {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"GitTest"];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	[PBGitDefaults removePreviousDocumentPaths];

	if ([PBGitDefaults openPreviousDocumentsOnLaunch]) {
		NSArray *documents = [[PBRepositoryDocumentController sharedDocumentController] documents];
		if ([documents count] > 0) {
			NSMutableArray *paths = [NSMutableArray array];
			for (PBGitRepository *repository in documents)
				[paths addObject:[repository workingDirectory]];

			[PBGitDefaults setPreviousDocumentPaths:paths];
		}
	}
}

- (IBAction)showHelp:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://gitx.frim.nl/user_manual.html"]];
}

- (IBAction)reportAProblem:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"mailto:mxcl@me.com"]];
}

@end
