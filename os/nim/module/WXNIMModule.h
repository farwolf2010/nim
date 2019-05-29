//
//  WXNIMModule.h
//  Pods
//
//  Created by 郑江荣 on 2018/12/4.
//

#import <Foundation/Foundation.h>
#import "farwolf_weex.h"
#import <WeexSDK/WXModuleProtocol.h>
#import <NIMSDK/NIMSDK.h>

@interface WXNIMModule : NSObject<WXModuleProtocol,NIMChatManagerDelegate>
@property(nonatomic,strong)WXModuleKeepAliveCallback callback;
@end

 
