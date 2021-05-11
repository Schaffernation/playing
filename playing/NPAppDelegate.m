//
//  NPAppDelegate.m
//  playing
//
//  Created by Joseph Schaffer on 5/8/14.
//  Copyright (c) 2014 now playing. All rights reserved.
//

#import "NPAppDelegate.h"
#import "Music.h"
#import "rdio.h"


@implementation NPAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  _music = [SBApplication applicationWithBundleIdentifier:@"com.apple.Music"];
//  _rdio = [SBApplication applicationWithBundleIdentifier:@"com.rdio.desktop"];
    
    
  if ( [_music isRunning] && _music.playerState == MusicEPlSPlaying ) {
    [self updateScreenFromMusic];
  } else if ( [_rdio isRunning] && _rdio.playerState == rdioEPSSPlaying ) {
    [self updateScreenFromRdio];
  } else {
    [self updateScreenNothingPlaying];
  }
  
  [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                      selector:@selector(MusicChanged:)
                                                          name:@"com.apple.Music.playerInfo"
                                                        object:@"com.apple.Music.player"];
  
//  [[NSDistributedNotificationCenter defaultCenter] addObserver:self
//                                                      selector:@selector(rdioChanged:)
//                                                          name:@"com.rdio.desktop.playStateChanged"
//                                                        object:nil];
  
    _artwork.imageScaling = NSImageScaleProportionallyUpOrDown;
  _window.backgroundColor = [NSColor blackColor];
  [[NSApplication sharedApplication]
   setPresentationOptions:NSFullScreenWindowMask];
}

- (void)MusicChanged:(NSNotification *)note {
  NSString *object = [note object];
  NSString *name = [note name];
  NSDictionary *userInfo = [note userInfo];
  NSLog(@"<%p>%s: object: %@ name: %@ userInfo: %@", self, __PRETTY_FUNCTION__, object, name, userInfo);
  
  switch (_music.playerState) {
    case MusicEPlSPlaying:
      [_rdio pause];

    case MusicEPlSPaused:
      if (_rdio.playerState == rdioEPSSPlaying) {
        [self updateScreenFromRdio];
      } else {
        [self updateScreenFromMusic];
      }
      break;
    default:
      break;
  }
  
}

- (void)rdioChanged:(NSNotification *)note {
  
  switch (_rdio.playerState) {
    case rdioEPSSPlaying:
      [_music pause];
    case rdioEPSSPaused:
      if (_music.playerState == MusicEPlSPlaying) {
        [self updateScreenFromMusic];
      } else {
        [self updateScreenFromRdio];
      }
      break;
    case rdioEPSSStopped:
      NSLog(@" rdio state : Stopped");

      break;
      
    default:
      break;
  }
  
}


- (void)updateScreenNothingPlaying {
  _title.stringValue  = @" ";
  _artist.stringValue = @" ";
  _album.stringValue  = @" ";
  _composer.stringValue = @" ";
  
  _artwork.image = nil;
  
  [_centeredLabel setHidden:NO];
}

- (void)updateScreenFromRdio {
  rdioTrack *cur = _rdio.currentTrack;
  
  NSLog(@" Current Rdio Track : %@", cur.name);
  [_centeredLabel setHidden:YES];
  
  _title.stringValue  = cur.name   ? cur.name   : @"Title";
  _artist.stringValue = cur.artist ? cur.artist : @"Artist";
  _album.stringValue  = cur.album  ? cur.album  : @"Album";
  _composer.stringValue = @" ";

  NSImage *artworkImage = (NSImage *)cur.artwork;
  artworkImage.size = NSMakeSize(1900, 1900);
  
  _artwork.image = artworkImage;
}

- (void)updateScreenFromMusic {
  MusicTrack *cur = _music.currentTrack;
  
  NSLog(@"Current Music Track : %@", cur.name);
  [_centeredLabel setHidden:YES];
  
  _title.stringValue  = cur.name   ? cur.name   : @"Title";
  NSString *artist = cur.artist ? cur.artist : @"Artist";
  _album.stringValue  = cur.album  ? cur.album  : @"Album";
  _composer.stringValue = cur.composer ? cur.composer  : @"";
    
    [_artist setAttributedStringValue:[self styleArtist:artist]];
    
    
    MusicArtwork *trackArt = cur.artworks.firstObject;
    NSImage *newArt = [[NSImage alloc] init];
                        
    // For some reason in the Music app sometimes the expected return of NSImage from trackArt.data
    // is instead an NSAppleEventDescriptor containing raw data otherwise it's an image like normal.
    // Also trackArt.rawData appears to be no longer used and empty :(
    if ([trackArt.data.className isEqualToString:@"NSAppleEventDescriptor"]) {
        NSAppleEventDescriptor *t = (NSAppleEventDescriptor*)trackArt.data;
        NSData *d = t.data;
        newArt = [[NSImage alloc] initWithData:d];
    } else {
        newArt = trackArt.data;
    }
    
    _artwork.image = newArt;
}

- (NSAttributedString *)styleArtist:(NSString *)artist {
    NSString *editedArtist = [artist stringByReplacingOccurrencesOfString:@", " withString:@"\n"];
    editedArtist = [editedArtist stringByReplacingOccurrencesOfString:@"," withString:@"\n"];
    editedArtist = [editedArtist stringByReplacingOccurrencesOfString:@"/" withString:@" / "];
    
    
    
    NSMutableAttributedString *styledArtist = [[NSMutableAttributedString alloc] initWithString:editedArtist];

    [self applyFont:@"Avenir-Light" withSize:35 toPattern:@"/" attributeString:styledArtist];
    [self applyFont:@"Avenir-Light" withSize:35 toPattern:@"\\(.+\\)" attributeString:styledArtist];
    
    return styledArtist;
    
}

- (void)applyFont:(NSString *)fontName withSize:(CGFloat)size toPattern:(NSString *)pattern attributeString:(NSMutableAttributedString *)attributedString {
    NSString *string = [attributedString string];
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    
    //  enumerate matches
    NSRange range = NSMakeRange(0, [string length]);
    [expression enumerateMatchesInString:string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange matchRange = [result rangeAtIndex:0];
        [attributedString addAttribute:NSFontAttributeName value:[NSFont fontWithName:fontName size:size] range:matchRange];
    }];
}

@end
