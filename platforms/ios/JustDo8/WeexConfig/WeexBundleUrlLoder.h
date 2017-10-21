//
//  WeexPlugin.h
//  JustDo8
//
//  Created by yangshengtao on 16/11/15.
//  Copyright © 2016年 zwwill. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeexBundleUrlLoder : NSObject

@property (nonatomic, readonly, copy) NSString* configFile;


- (NSURL *)jsBundleURL;

@end
