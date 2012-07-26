//
//  GitTest_AppDelegate.h
//  GitTest
//
//  Created by Pieter de Bie on 13-06-08.
//  Copyright __MyCompanyName__ 2008 . All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ApplicationController : NSObject {
	IBOutlet NSWindow *window;
	IBOutlet id firstResponder;
}

- (IBAction)showAboutPanel:(id)sender;
- (IBAction)installCliTool:(id)sender;
- (IBAction)showHelp:(id)sender;
- (IBAction)reportAProblem:(id)sender;
@end
