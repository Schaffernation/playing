//
//  NPAppDelegate.m
//  playing
//
//  Created by Joseph Schaffer on 5/8/14.
//  Copyright (c) 2014 now playing. All rights reserved.
//

#import "NPAppDelegate.h"
#import "iTunes.h"
#import "rdio.h"


@implementation NPAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  _iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
  _rdio = [SBApplication applicationWithBundleIdentifier:@"com.rdio.desktop"];
  
  if ( [_iTunes isRunning] && _iTunes.playerState == iTunesEPlSPlaying ) {
    [self updateScreenFromiTunes];
  } else if ( [_rdio isRunning] && _rdio.playerState == rdioEPSSPlaying ) {
    [self updateScreenFromRdio];
  } else {
    [self updateScreenNothingPlaying];
  }
  
  [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                      selector:@selector(iTunesChanged:)
                                                          name:@"com.apple.iTunes.playerInfo"
                                                        object:@"com.apple.iTunes.player"];
  
  [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                      selector:@selector(rdioChanged:)
                                                          name:@"com.rdio.desktop.playStateChanged"
                                                        object:nil];
  
    _artwork.imageScaling = NSScaleToFit;
  _window.backgroundColor = [NSColor blackColor];
  [[NSApplication sharedApplication]
   setPresentationOptions:NSFullScreenWindowMask];
}

- (void)iTunesChanged:(NSNotification *)note {
  NSString *object = [note object];
  NSString *name = [note name];
  NSDictionary *userInfo = [note userInfo];
  NSLog(@"<%p>%s: object: %@ name: %@ userInfo: %@", self, __PRETTY_FUNCTION__, object, name, userInfo);
  
  
  switch (_iTunes.playerState) {
    case iTunesEPlSPlaying:
      [_rdio pause];
      
    case iTunesEPlSPaused:
      if (_rdio.playerState == rdioEPSSPlaying) {
        [self updateScreenFromRdio];
      } else {
        [self updateScreenFromiTunes];
      }
      break;
    default:
      break;
  }
  
}

- (void)rdioChanged:(NSNotification *)note {
  
  switch (_rdio.playerState) {
    case rdioEPSSPlaying:
      [_iTunes pause];
    case rdioEPSSPaused:
      if (_iTunes.playerState == iTunesEPlSPlaying) {
        [self updateScreenFromiTunes];
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

- (void)updateScreenFromiTunes {
  iTunesTrack *cur = _iTunes.currentTrack;
  
  NSLog(@"Current iTunes Track : %@", cur.name);
  [_centeredLabel setHidden:YES];
  
  _title.stringValue  = cur.name   ? cur.name   : @"Title";
  NSString *artist = cur.artist ? cur.artist : @"Artist";
  _album.stringValue  = cur.album  ? cur.album  : @"Album";
  _composer.stringValue = cur.composer ? cur.composer  : @"";
    
    [_artist setAttributedStringValue:[self styleArtist:artist]];
  
  iTunesArtwork *artwork = [[cur artworks] firstObject];
  NSImage *artworkImage = [[NSImage alloc] initWithData:artwork.rawData];
  
  _artwork.image = artworkImage;
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
