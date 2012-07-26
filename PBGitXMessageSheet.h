//
//  PBGitXMessageSheet.h
//  GitX
//
//  Created by BrotherBard on 7/4/10.
//  Copyright 2010 BrotherBard. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PBGitXMessageSheet : NSWindowController
{
	NSImageView *iconView;
	NSTextField *messageField;
	NSTextView *infoView;
	NSScrollView *scrollView;
}

+ (void)beginMessageSheetForWindow:(NSWindow *)parentWindow withMessageText:(NSString *)message infoText:(NSString *)info;
+ (void)beginMessageSheetForWindow:(NSWindow *)parentWindow withError:(NSError *)error;


- (void)beginMessageSheetForWindow:(NSWindow *)parentWindow withMessageText:(NSString *)message infoText:(NSString *)info;
- (IBAction)closeMessageSheet:(id)sender;


@property (nonatomic) IBOutlet NSImageView *iconView;
@property (nonatomic) IBOutlet NSTextField *messageField;
@property (nonatomic) IBOutlet NSTextView *infoView;
@property (nonatomic) IBOutlet NSScrollView *scrollView;

@end
