//
//  PlaylistManager.m
//  Simple Player
//
//  Created by Antonio Hung on 2/17/14.
//  Copyright (c) 2014 Spotify. All rights reserved.
//

#import "PlaylistManager.h"

@implementation PlaylistManager


+ (PlaylistManager*)sharedInstance
{
    static PlaylistManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[PlaylistManager alloc] init];
    });
    return _sharedInstance;
}
-(void)loadPlaylists:(void (^)(NSArray *playlists))block
{

    [SPAsyncLoading waitUntilLoaded:[SPSession sharedSession].userPlaylists timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *loadedContainers, NSArray *notLoadedContainers)
     {
         // User playlists are loaded — wait for playlists to load their metadata.
         
         NSMutableArray *playlists = [NSMutableArray array];
         
         [playlists addObject:[SPSession sharedSession].starredPlaylist];
         [playlists addObject:[SPSession sharedSession].inboxPlaylist];
         [playlists addObjectsFromArray:[SPSession sharedSession].userPlaylists.flattenedPlaylists];
         
         [SPAsyncLoading waitUntilLoaded:playlists timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *loadedPlaylists, NSArray *notLoadedPlaylists)
          {
              
              self.playlists = loadedPlaylists;
              //[self loadAllSongs];
              
                // All of our playlists have loaded their metadata — wait for all tracks to load their metadata.
              //self.playlists = [[NSMutableArray alloc] initWithArray:loadedPlaylists];
              //NSLog(@"arrPlaylist %@",self.playlists);
              //NSLog(@"notLoadedPlaylists %@",notLoadedPlaylists);
              if(block)
              {
                  block(loadedPlaylists);
              }
              
          }];
     }];
}
-(void)loadAllSongs
{
    //TODO build Dictionary sorted by artists-albums-tracks
    if(!self.playListTracks)
        self.playListTracks = [[NSMutableDictionary alloc]init];
    
    if(self.songs == nil)
        self.songs = [[NSMutableArray alloc]init];
    
    for(SPPlaylist *playlist in self.playlists)
    {
        for(SPPlaylistItem *_track in playlist.items)
        {
            if (_track.itemClass == [SPTrack class])
            {
                SPTrack *track = _track.item;
                SPArtist *artist = track.album.artist;
                
                NSString *artistName= artist.name;
                //NSLog(@"artistName %@",artistName);
                
                
                if(![self containsKey:artistName])
                {
                    [self.playListTracks setValue:@{} forKey:artistName];
                }
                else
                {
                    //add the track
                    
                }

            }
        }

    }
    
    NSLog(@"self.playListTracks %@",self.playListTracks);
}
- (BOOL)containsKey: (NSString *)key {
    BOOL retVal = 0;
    NSArray *allKeys = [self.playListTracks allKeys];
    retVal = [allKeys containsObject:key];
    return retVal;
}
//check if the track is in any of our playlists
-(BOOL)isTrackInPlaylist:(SPTrack *)track
{
    //background thread
    
    BOOL trackLocated = NO;
//    for(SPTrack *theTrack in self.songs)
//    {
//        //NSLog(@"theTrack.hash %lu",(unsigned long)theTrack.hash);
//        if([theTrack.name isEqualToString:track.name])
//        {
//            trackLocated = YES;
//            break;
//        }
//    }
    return trackLocated;
}
-(void)setPlaylistAsOffline:(SPPlaylist *)playlist;
{
    [playlist setMarkedForOfflinePlayback:YES];
}
@end
