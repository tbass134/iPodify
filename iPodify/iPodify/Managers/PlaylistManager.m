//
//  PlaylistManager.m
//  Simple Player
//
//  Created by Antonio Hung on 2/17/14.
//  Copyright (c) 2014 Spotify. All rights reserved.
//

#import "PlaylistManager.h"
#import "PlayerManager.h"
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

- (void)loadPlaylists:(void (^)(NSError *, NSArray *))callback
{
    [SPTRequest playlistsForUserInSession:[PlayerManager sharedInstance].session callback:^(NSError *error, id object) {
        [self didFetchListPageForSession:[PlayerManager sharedInstance].session finalCallback:callback error:error object:object allPlaylists:[NSMutableArray array]];
    }];
}

- (void)loadTracksForPlaylist:(SPTPartialPlaylist *)playlist completion:(void (^)(NSError *, NSArray *))callback
{
    [SPTRequest requestItemFromPartialObject:playlist withSession:[PlayerManager sharedInstance].session callback:^(NSError *error, SPTPlaylistSnapshot *object) {

        SPTPlaylistSnapshot *snapshot = (SPTPlaylistSnapshot *)object;
        [self didFetchListPageForSession:[PlayerManager sharedInstance].session finalCallback:callback error:error object:snapshot.firstTrackPage allTracks:[NSMutableArray array]];
        
    }];
}

- (void)loadStarredPlaylist:(void (^)(NSError *, id object))callback
{
    [SPTRequest starredListForUserInSession:[PlayerManager sharedInstance].session callback:^(NSError *error, id object) {
        callback(error,object);
        //[self didFetchListPageForSession:[PlayerManager sharedInstance].session finalCallback:callback error:error object:object allPlaylists:[NSMutableArray array]];

    }];
}

- (void)loadSavedTracks:(void (^)(NSError *, NSArray *))callback
{
    [SPTRequest savedTracksForUserInSession:[PlayerManager sharedInstance].session callback:^(NSError *error, id object) {
        [self didFetchListPageForSession:[PlayerManager sharedInstance].session finalCallback:callback error:error object:object allPlaylists:[NSMutableArray array]];
        
    }];
}


- (void)didFetchListPageForSession:(SPTSession *)session finalCallback:(void (^)(NSError*, NSArray*))finalCallback error:(NSError *)error object:(id)object allPlaylists:(NSMutableArray *)allPlaylists
{
    if (error != nil) {
        finalCallback(error, nil);
    } else {
            SPTPlaylistList *playlistList = (SPTPlaylistList *)object;
            
            for (SPTPartialPlaylist *playlist in playlistList.items) {
                [allPlaylists addObject:playlist];
            }
            if (playlistList.hasNextPage) {
                [playlistList requestNextPageWithSession:session callback:^(NSError *error, id object) {
                    [self didFetchListPageForSession:session
                                                           finalCallback:finalCallback
                                                                   error:error
                                                                  object:object
                                                            allPlaylists:allPlaylists];
                }];
            }
            else {
                finalCallback(nil, [allPlaylists copy]);
            }
        }
}

- (void)didFetchListPageForSession:(SPTSession *)session finalCallback:(void (^)(NSError*, NSArray*))finalCallback error:(NSError *)error object:(id)object allTracks:(NSMutableArray *)allTracks
{
    if (error != nil) {
        finalCallback(error, nil);
    } else {
        SPTListPage *page = (SPTListPage *)object;
        
        for (SPTPartialPlaylist *playlist in page.items) {
            [allTracks addObject:playlist];
        }
        if (page.hasNextPage) {
            [page requestNextPageWithSession:session callback:^(NSError *error, id object) {
                [self didFetchListPageForSession:session
                                   finalCallback:finalCallback
                                           error:error
                                          object:object
                                    allPlaylists:allTracks];
            }];
        }
        else {
            finalCallback(nil, [allTracks copy]);
        }
    }
}

-(void)loadAllSongs
{
    //TODO build Dictionary sorted by artists-albums-tracks
    if(!self.playListTracks)
        self.playListTracks = [[NSMutableDictionary alloc]init];
    
    if(self.songs == nil)
        self.songs = [[NSMutableArray alloc]init];
    
//    for(SPTPlaylistList *playlist in self.playlists)
//    {
//        for(SPTPartialTrack *_track in playlist.items)
//        {
//            if (_track.itemClass == [SPTTrack class])
//            {
//                SPTTrack *track = _track.item;
//                SPTArtist *artist = track.album.artist;
//                
//                NSString *artistName= artist.name;
//                //NSLog(@"artistName %@",artistName);
//                
//                
//                if(![self containsKey:artistName])
//                {
//                    [self.playListTracks setValue:@{} forKey:artistName];
//                }
//                else
//                {
//                    //add the track
//                    
//                }
//
//            }
//        }
//
//    }
    
    NSLog(@"self.playListTracks %@",self.playListTracks);
}
- (BOOL)containsKey: (NSString *)key {
    BOOL retVal = 0;
    NSArray *allKeys = [self.playListTracks allKeys];
    retVal = [allKeys containsObject:key];
    return retVal;
}
//check if the track is in any of our playlists
-(BOOL)isTrackInPlaylist:(SPTTrack *)track
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
-(void)setPlaylistAsOffline:(SPTPlaylistList *)playlist;
{
    //[playlist setMarkedForOfflinePlayback:YES];
}
@end
