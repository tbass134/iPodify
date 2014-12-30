//
//  PlaylistManager.h
//  Simple Player
//
//  Created by Antonio Hung on 2/17/14.
//  Copyright (c) 2014 Spotify. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlaylistManager : NSObject
@property(nonatomic,strong)NSArray *playlists;
@property(nonatomic,strong)NSMutableArray *songs;
@property(nonatomic,strong)NSMutableDictionary *playListTracks;
@property(nonatomic,strong)SPTPlaylistList *currentPlaylist;


+ (PlaylistManager*)sharedInstance;
-(void)loadPlaylists:(void (^)(SPTPlaylistList *playlists))block;
-(void)setPlaylistAsOffline:(SPTPlaylistList *)playlist;
-(BOOL)isTrackInPlaylist:(SPTTrack *)track;
@end
