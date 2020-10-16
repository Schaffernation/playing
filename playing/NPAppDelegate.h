//
//  NPAppDelegate.h
//  playing
//
//  Created by Joseph Schaffer on 5/8/14.
//  Copyright (c) 2014 now playing. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MusicApplication;
@class rdioApplication;

@interface NPAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *title;
@property (weak) IBOutlet NSTextFieldCell *artist;
@property (weak) IBOutlet NSTextField *album;
@property (weak) IBOutlet NSTextField *composer;
@property (weak) IBOutlet NSImageView *artwork;
@property (weak) IBOutlet NSTextField *centeredLabel;
@property (weak) IBOutlet NSTextFieldCell *centeredCell;

@property (strong) MusicApplication *Music;
@property (strong) rdioApplication *rdio;

@end
