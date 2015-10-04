//
//  XGFileSecurityHelper.h
//  XGuardian
//
//  Created by  吴亚冬 on 15/7/15.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XGFileSecurityHelper : NSObject

+ (void) getACLfromPath:(NSString*) fullPath;


@end
