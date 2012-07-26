//
//  GitTest_AppDelegate.m
//  GitTest
//
//  Created by Pieter de Bie on 13-06-08.
//  Copyright __MyCompanyName__ 2008 . All rights reserved.
//

#import "ApplicationController.h"
#import "PBGitRevisionCell.h"
#import "PBGitWindowController.h"
#import "PBRepositoryDocumentController.h"
#import "PBServicesController.h"
#import "PBGitXProtocol.h"
#import "PBPrefsWindowController.h"
#import "PBNSURLPathUserDefaultsTransfomer.h"
#import "PBGitDefaults.h"



@implementation ApplicationController

- (ApplicationController *)init {
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
	setenv( "SSH_ASKPASS", [[[NSBundle mainBundle] pathForResource: @"gitx_askpasswd" ofType: @""] UTF8String], 1 );
	setenv( "DISPLAY", "localhost:0", 1 );

	[self registerServices];

    BOOL hasOpenedDocuments = NO;
    NSArray *launchedDocuments = [[[PBRepositoryDocumentController sharedDocumentController] documents] copy];

	// Only try to open a default document if there are no documents open already.
	// For example, the application might have been launched by double-clicking a .git repository,
	// or by dragging a folder to the app icon
	if ([launchedDocuments count])
		hasOpenedDocuments = YES;

	// Try to find the current directory, to open that as a repository
	if ([PBGitDefaults openCurDirOnLaunch] && !hasOpenedDocuments) {
		NSString *curPath = [[[NSProcessInfo processInfo] environment] objectForKey:@"PWD"];
        NSURL *url = nil;
		if (curPath)
			url = [NSURL fileURLWithPath:curPath];
        // Try to open the found URL
        NSError *error = nil;
        if (url && [[PBRepositoryDocumentController sharedDocumentController] openDocumentWithContentsOfURL:url display:YES error:&error])
            hasOpenedDocuments = YES;
	}

    // to bring the launched documents to the front
    for (PBGitRepository *document in launchedDocuments)
        [document showWindows];

	if (![[NSApplication sharedApplication] isActive])
		return;

	// The current directory was not enabled or could not be opened (most likely it’s not a git repository).
	// show an open panel for the user to select a repository to view
	if ([PBGitDefaults showOpenPanelOnLaunch] && !hasOpenedDocuments)
		[[PBRepositoryDocumentController sharedDocumentController] openDocument:self];
}

- (void)windowWillClose:sender
{
	[firstResponder terminate:sender];
}

- (IBAction)openPreferencesWindow:(id)sender
{
	[[PBPrefsWindowController sharedPrefsWindowController] showWindow:nil];
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

- (IBAction)installCliTool:(id)sender;
{
	BOOL success               = NO;
	NSString* installationPath = @"/usr/local/bin/";
	NSString* installationName = @"gitx";
	NSString* toolPath         = [[NSBundle mainBundle] pathForResource:@"gitx" ofType:@""];
	if (toolPath) {
		AuthorizationRef auth;
		if (AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &auth) == errAuthorizationSuccess) {
			char const* mkdir_arg[] = { "-p", [installationPath UTF8String], NULL};
			char const* mkdir	= "/bin/mkdir";
			AuthorizationExecuteWithPrivileges(auth, mkdir, kAuthorizationFlagDefaults, (char**)mkdir_arg, NULL);
			char const* arguments[] = { "-f", "-s", [toolPath UTF8String], [[installationPath stringByAppendingString: installationName] UTF8String],  NULL };
			char const* helperTool  = "/bin/ln";
			if (AuthorizationExecuteWithPrivileges(auth, helperTool, kAuthorizationFlagDefaults, (char**)arguments, NULL) == errAuthorizationSuccess) {
				int status;
				int pid = wait(&status);
				if (pid != -1 && WIFEXITED(status) && WEXITSTATUS(status) == 0)
					success = true;
				else
					errno = WEXITSTATUS(status);
			}

			AuthorizationFree(auth, kAuthorizationFlagDefaults);
		}
	}

	if (success) {
		[[NSAlert alertWithMessageText:@"Installation Complete"
	                    defaultButton:nil
	                  alternateButton:nil
	                      otherButton:nil
	        informativeTextWithFormat:@"The gitx tool has been installed to %@", installationPath] runModal];
	} else {
		[[NSAlert alertWithMessageText:@"Installation Failed"
	                    defaultButton:nil
	                  alternateButton:nil
	                      otherButton:nil
	        informativeTextWithFormat:@"Installation to %@ failed", installationPath] runModal];
	}
}

- (NSString *)applicationSupportFolder {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"GitTest"];
}

- (NSManagedObjectModel *)managedObjectModel {
    return managedObjectModel ?: (managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil]);
}

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
    if (!persistentStoreCoordinator) {
        NSFileManager *fileManager;
        NSString *applicationSupportFolder = nil;
        NSURL *url;
        NSError *error;
        
        fileManager = [NSFileManager defaultManager];
        applicationSupportFolder = [self applicationSupportFolder];
        if ( ![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] ) {
            [fileManager createDirectoryAtPath:applicationSupportFolder withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        url = [NSURL fileURLWithPath: [applicationSupportFolder stringByAppendingPathComponent: @"GitTest.xml"]];
        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
        if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]){
            [[NSApplication sharedApplication] presentError:error];
        }
    }

    return persistentStoreCoordinator;
}

- (NSManagedObjectContext *) managedObjectContext {
    if (!managedObjectContext) {
        managedObjectContext = [NSManagedObjectContext new];
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    return managedObjectContext;
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return self.managedObjectContext.undoManager;
}
 
- (IBAction) saveAction:(id)sender {
    id error = nil;
    if (![[self managedObjectContext] save:&error]) {
        [NSApp presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    NSError *error;
    int reply = NSTerminateNow;
    
    if (managedObjectContext != nil) {
        if ([managedObjectContext commitEditing]) {
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
				
                // This error handling simply presents error information in a panel with an 
                // "Ok" button, which does not include any attempt at error recovery (meaning, 
                // attempting to fix the error.)  As a result, this implementation will 
                // present the information to the user and then follow up with a panel asking 
                // if the user wishes to "Quit Anyway", without saving the changes.

                // Typically, this process should be altered to include application-specific 
                // recovery steps.  

                BOOL errorResult = [[NSApplication sharedApplication] presentError:error];
				
                if (errorResult == YES) {
                    reply = NSTerminateCancel;
                } 

                else {
					
                    int alertReturn = NSRunAlertPanel(nil, @"Could not save changes while quitting. Quit anyway?" , @"Quit anyway", @"Cancel", nil);
                    if (alertReturn == NSAlertAlternateReturn) {
                        reply = NSTerminateCancel;	
                    }
                }
            }
        } 
        
        else {
            reply = NSTerminateCancel;
        }
    }
    
    return reply;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
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

/**
    Implementation of dealloc, to release the retained variables.
 */
 
- (void) dealloc {

    managedObjectContext = nil;
    persistentStoreCoordinator = nil;
    managedObjectModel = nil;
}

#pragma mark Help menu

- (IBAction)showHelp:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://gitx.frim.nl/user_manual.html"]];
}

- (IBAction)reportAProblem:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://gitx.lighthouseapp.com/tickets"]];
}



@end
