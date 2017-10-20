//
//  NatAudio.m
//
//  Created by huangyake on 17/1/7.
//  Copyright © 2017 Instapp. All rights reserved.
//

#import "NatAudio.h"

@interface NatAudio ()
@property(nonatomic, strong)AVPlayer *avplayer;
@property(nonatomic, assign)BOOL isplay;
@property(nonatomic, strong)AVPlayerItem * songItem;
@property(nonatomic, strong)NatCallback playBack;
@property(nonatomic, strong)NSString *path;
@end

@implementation NatAudio


+ (NatAudio *)singletonManger{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}


- (void)play:(NSString *)path :(NatCallback)callback{
    self.playBack = callback;
    
    if (!path || ![path isKindOfClass:[NSString class]] || [path isEqualToString:@""]) {
        callback(@{@"error":@{@"msg":@"MEDIA_INVALID_ARGUMENT",@"code":@110040}},nil);
        return;
    }
    
    // url
    NSURL * url  = [NSURL URLWithString:path];
    
    if ([url.scheme isEqual:@"nat"]) {
        NSString *str = [path substringFromIndex:19];
        url = [NSURL fileURLWithPath:str];
    } else if ([url.scheme isEqual:@"http"] || [url.scheme isEqual:@"http"]){
    }
    
    if (self.avplayer) {
        if ([self.path isEqualToString:path]) {
            if (self.avplayer.rate == 0) {
                [self.avplayer play];
                callback(nil,nil);
            }
            return;
        } else {
            [self.avplayer pause];
            self.avplayer.rate = 0.0;
            [self.songItem cancelPendingSeeks];
            [self.songItem.asset cancelLoading];
            [self.avplayer removeObserver:self forKeyPath:@"status"];
            self.songItem = [[AVPlayerItem alloc]initWithURL:url];
            
            [self.avplayer replaceCurrentItemWithPlayerItem: self.songItem];
            [self.avplayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        }
    } else {
        AVPlayerItem * item = [[AVPlayerItem alloc]initWithURL:url];
        AVPlayer * player = [[AVPlayer alloc]initWithPlayerItem:item];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
        
        [player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        
        self.songItem = item;
        self.avplayer = player;
    }
    
    self.path = path;
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        if ([(AVPlayer *)self.avplayer status] == AVPlayerStatusReadyToPlay) {
            [self.avplayer play];
        }else if (self.avplayer.status == AVPlayerStatusUnknown){
            self.playBack(@{@"error":@{@"msg":@"MEDIA_DECODE_ERROR ",@"code":@110060}},nil);
        }else if (self.avplayer.status == AVPlayerStatusFailed){
            
            self.playBack(@{@"error":@{@"msg":@"MEDIA_FILE_TYPE_NOT_SUPPORTED",@"code":@110110}},nil);
        }
    }
}

- (void)pause:(NatCallback)callback{
    if (self.avplayer) {
        [self.avplayer pause];
        callback(nil,nil);
    }else{
        callback(@{@"error":@{@"msg":@"MEDIA_PLAYER_NOT_STARTED",@"code":@110100}},nil);
    }
}

- (void)stop:(NatCallback)callback{
    if (self.avplayer) {
        [self.avplayer pause];
        self.avplayer.rate = 0.0;
        [self.songItem cancelPendingSeeks];
        [self.songItem.asset cancelLoading];
        [self.avplayer removeObserver:self forKeyPath:@"status"];
        [self.avplayer replaceCurrentItemWithPlayerItem:nil];
        self.avplayer = nil;
        callback(nil,nil);
    }else{
        callback(@{@"error":@{@"msg":@"MEDIA_PLAYER_NOT_STARTED",@"code":@110100}},nil);
    }
    
}

-(void)playerDidFinishPlaying:(NSNotification *) notification {
    if (self.avplayer) {
        [self.avplayer pause];
        self.avplayer.rate = 0.0;
        [self.songItem cancelPendingSeeks];
        [self.songItem.asset cancelLoading];
        [self.avplayer removeObserver:self forKeyPath:@"status"];
        [self.avplayer replaceCurrentItemWithPlayerItem:nil];
        self.avplayer = nil;
//        callback(nil,nil);
    }
}


@end
