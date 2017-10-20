//
//  NatAudio.h
//
//  Created by huangyake on 17/1/7.
//  Copyright © 2017 Instapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface NatAudio : NSObject
typedef void (^NatCallback)(id error, id result);

+ (NatAudio *)singletonManger;

//播放音频
- (void)play:(NSString *)path :(NatCallback)callback;

//暂停音频
- (void)pause:(NatCallback)callback;

//停止音频
- (void)stop:(NatCallback)callback;

@end
