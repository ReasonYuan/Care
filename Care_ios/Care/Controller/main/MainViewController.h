//
//  MainViewController.h
//  DoctorPlus_ios
//
//  Created by reason on 15-7-14.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UITabBarController
{
}


/**tabbar上健康档案管理按钮*/
@property (weak, nonatomic) IBOutlet UIButton *btnDocument;

/**tabbar上健康顾问(聊天)按钮*/
@property (weak, nonatomic) IBOutlet UIButton *btnChat;

/**健康档案的消息数*/
@property (weak, nonatomic) IBOutlet UILabel *labelDocNumber;
/**健康顾问的消息数*/
@property (weak, nonatomic) IBOutlet UILabel *labelChatNumber;

/**
 *给tabbarItem的按钮设置消息条数
 */
-(void)setMsgNumber:(int)number ByIndex:(int)index;

@end
