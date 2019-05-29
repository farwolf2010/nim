//
//  WXNIMModule.m
//  Pods
//
//  Created by 郑江荣 on 2018/12/4.
//

#import "WXNIMModule.h"

#import "NIMSessionViewController.h"
#import <WeexPluginLoader/WeexPluginLoader.h>
#import "WeexNIMSessionViewController.h"
@implementation WXNIMModule
WX_PlUGIN_EXPORT_MODULE(nim, WXNIMModule)
WX_EXPORT_METHOD(@selector(login:callback:))
WX_EXPORT_METHOD(@selector(openP2P:))
WX_EXPORT_METHOD(@selector(openTeam:))
WX_EXPORT_METHOD(@selector(regist:))
WX_EXPORT_METHOD(@selector(recent:))
WX_EXPORT_METHOD(@selector(setMsgCallback:))
WX_EXPORT_METHOD(@selector(setRead:))
WX_EXPORT_METHOD_SYNC(@selector(unread))



@synthesize weexInstance;


-(void)regist:(NSDictionary*)params {
    NSString *appKey        = params[@"appKey"];
    NIMSDKOption *option    = [NIMSDKOption optionWithAppKey:appKey];
//    option.apnsCername      =  params[@"apnsCername"];
//    option.pkCername        = params[@"pkCername"];
    [[NIMSDK sharedSDK] registerWithOption:option];
    
    [[NIMSDK sharedSDK].chatManager addDelegate:self];
 
}


-(void)login:(NSDictionary*)params  callback:(WXModuleCallback)callback
{
    
    NSString *account =params[@"account"];
    NSString *token   = params[@"token"];
    [[[NIMSDK sharedSDK] loginManager] login:account
                                       token:token
                                  completion:^(NSError *error) {
                                      NSDictionary *res=@{@"err":@(0)};
                                      if(error!=nil){
                                         res= @{@"err":@(1)};
                                      }
                                      callback(res);
                                  }];
}

-(void)openP2P:(NSDictionary*)params
{
    NSString *uid=params[@"account"];
    NSString *navBarBgColor=params[@"navBarBgColor"];
    NSString *theme=params[@"theme"];
    NIMSession *session = [NIMSession session:uid type:NIMSessionTypeP2P];
    NIMSessionViewController *vc = [[NIMSessionViewController alloc] initWithSession:session];
    vc.theme=theme;
    vc.navBarBgColor=navBarBgColor;
    UIViewController *host=[UIViewController new];
    WeexNIMSessionViewController *nav=[[WeexNIMSessionViewController alloc] initWithRootViewController:vc];
    [host addVc:nav];
    [weexInstance.viewController.navigationController pushViewController:host animated:YES];
}

-(void)recent:(WXModuleCallback)callback
{
    NSArray *recentSessions = [NIMSDK sharedSDK].conversationManager.allRecentSessions;
    NSMutableArray *temp=[NSMutableArray new];
    for(NIMRecentSession *item in recentSessions){
        NSMutableDictionary *dic=[NSMutableDictionary new];
        dic[@"unreadCount"]=@(item.unreadCount);
        dic[@"sessionId"]=item.session.sessionId;
        dic[@"lastMessage"]=item.lastMessage.text;
        dic[@"time"]=@(item.lastMessage.timestamp);
        [temp addObject:dic];
//        item.unreadCount
    }
   
//    allUnreadCount
     callback(temp);
}


-(void)openTeam:(NSDictionary*)params
{
    NSString *uid=params[@"teamId"];
    NIMSession *session = [NIMSession session:uid type:NIMSessionTypeTeam];
    NIMSessionViewController *vc = [[NIMSessionViewController alloc] initWithSession:session];
    [weexInstance.viewController.navigationController pushViewController:vc animated:YES];
    //    [self.navigationController pushViewController:vc animated:YES];
}
-(void)setMsgCallback:(WXModuleKeepAliveCallback)callback
{
    self.callback=callback;
}

-(void)setRead:(NSString*)uid
{
     NIMSession *session = [NIMSession session:uid type:NIMSessionTypeTeam];
     [[NIMSDK sharedSDK].conversationManager markAllMessagesReadInSession:session];
}
- (void)onRecvMessages:(NSArray<NIMMessage *> *)messages{
    
     int count=  [[NIMSDK sharedSDK].conversationManager allUnreadCount];
    if(self.callback)
     self.callback(@{@"unread":@(count)},true);
    
}
-(int)unread{
     int count=  [[NIMSDK sharedSDK].conversationManager allUnreadCount];
    return count;
}
@end
