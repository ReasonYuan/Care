//
//  MainViewController.m
//  DoctorPlus_ios
//
//  Created by reason on 15-7-14.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import "MainViewController.h"
#import "ScannerViewController.h"
#import "Care-Swift.h"
#import "TextViewController.h"
#import "PraHomeViewController.h"

static MessageInit *initMessage;

@interface MainViewController ()<UITabBarControllerDelegate>
{
    HomeLeftMenuView* leftMenuView;
    UIActionSheet* relationActioneSheet;
}
@end





@implementation MainViewController


//-(void) setViewController:(UIViewController*)controller WithTabTitle:(NSString*)title imgName:(NSString*)imageName selectImgName:(NSString*)selectImgName
//{
//    UITabBarItem *tabBarItem1 = controller.tabBarItem;//[self.tabBar.items objectAtIndex:0];
//    UIImage* tabBarItem1Image = [UIImage imageNamed:imageName];
//    UIImage *scaledTabBarItem1Image = [UIImage imageWithCGImage:[tabBarItem1Image CGImage] scale:(tabBarItem1Image.scale * 1.6) orientation:(tabBarItem1Image.imageOrientation)];
//    
//    UIImage* tabBarItem1SelectedImage = [UIImage imageNamed:selectImgName];
//    UIImage *scaledTabBarItem1SelectedImage = [UIImage imageWithCGImage:[tabBarItem1SelectedImage CGImage] scale:(tabBarItem1SelectedImage.scale * 1.6) orientation:(tabBarItem1SelectedImage.imageOrientation)];
//    
//     if ([[UIDevice currentDevice]systemVersion].floatValue >=7) {
//        scaledTabBarItem1Image = [scaledTabBarItem1Image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//        scaledTabBarItem1SelectedImage = [scaledTabBarItem1SelectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//     }
//    (void)[tabBarItem1 initWithTitle:title image:scaledTabBarItem1Image selectedImage:scaledTabBarItem1SelectedImage];
//    
//}

// Create a custom UIButton and add it to the center of our tab bar
//-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage
//{
//    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
//    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width*0.63, buttonImage.size.height*0.63);
//    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
//    [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
//    
//    CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height;
//    if (heightDifference < 0)
//        button.center = self.tabBar.center;
//    else
//    {
//        CGPoint center = self.tabBar.center;
//        center.y = center.y - heightDifference/2.0-0.5;//-15
//        button.center = center;
//    }
//    
//    [button addTarget:self action:@selector(selectCamera:) forControlEvents:UIControlEventTouchUpInside];
//    
//    
//    [self.view addSubview:button];
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    [MessageTools createTestDB];
//     PraHomeViewController* home = [[PraHomeViewController alloc] init];
    FileManagementViewController *home = [[FileManagementViewController alloc] init];
    (void)[home.tabBarItem initWithTitle:@"" image:nil selectedImage:nil];
//    [self setViewController:home WithTabTitle:@"" imgName:@"main_tab_home" selectImgName:@"main_tab_home_selected"];
    
    //TODO ==YY== MoreChatListViewController  TextViewController
//    MoreChatListViewController* chat = [[MoreChatListViewController alloc] init];
//    [self setViewController:chat WithTabTitle:@"聊天" imgName:@"main_tab_chat" selectImgName:@"main_tab_chat_selected"];
    
//    ScannerViewController* controll = [[ScannerViewController alloc] init];
//    controll.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:nil tag:0] ;
    
//    ContactsViewController* contacts = [[ContactsViewController alloc] init];
//    [self setViewController:contacts WithTabTitle:@"联系人" imgName:@"main_tab_account" selectImgName:@"main_tab_account_selected"];
    
    UIViewController* me = nil;
    if ([MessageTools isExperienceMode]) {
        me = [[VisitorMeViewController alloc] init];
    }else{
        me = [[MyHealthConsultantViewController alloc] initWithNibName:@"MyHealthConsultantViewController" bundle:nil];
    }
    (void)[me.tabBarItem initWithTitle:@"" image:nil selectedImage:nil];
//    [self setViewController:me WithTabTitle:@"" imgName:@"main_tab_me" selectImgName:@"main_tab_me_selected"];
    
    self.viewControllers = [NSArray arrayWithObjects:home,me, nil];
    
    
//    [self addCenterButtonWithImage:[UIImage imageNamed:@"main_tab_camera"] highlightImage:[UIImage imageNamed:@"main_tab_camera_selected"]];

    self.tabBar.barTintColor = [UIColor blackColor];
    
    
    UIView* view = [[NSBundle mainBundle] loadNibNamed:@"MainTabBarView" owner:self options:nil][0];
    view.frame = CGRectMake(0, 0, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
//        [self.view addSubview:view];
        [self.tabBar addSubview:view];
    
    
    //设置按钮点击后的背景色，禁用是因为让它再次点击时失效
    [_btnDocument setBackgroundImage:[UITools imageWithColor:[UIColor whiteColor]] forState:UIControlStateDisabled];
    [_btnChat setBackgroundImage:[UITools imageWithColor:[UIColor whiteColor]] forState:UIControlStateDisabled];
    
    //设置点按钮的样式，只会在点击后出现
    _btnDocument.layer.cornerRadius = _btnDocument.frame.size.height/2;
    _btnChat.layer.cornerRadius = _btnChat.frame.size.height/2;
    
    //未读消息数圆角
    _labelDocNumber.layer.cornerRadius = _labelDocNumber.frame.size.height/2;
    _labelChatNumber.layer.cornerRadius = _labelChatNumber.frame.size.height/2;
   
    //初始化默认健康档案被选中
    [self selectDocument:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendAddFriendMessage:) name:@"sendAddFriendMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendUnReadMessageCount:) name:@"sendUnReadMessageCount" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingBtnOnClickListener:) name:@"SettingBtnOnClickListener" object:nil];
    
    /**初始化IMSDK**/
    initMessage = [[MessageInit alloc] init];
    [initMessage testIMSDK];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.tabBar.tintColor = [UIColor colorWithRed:43.0/255.0 green:42/255.0 blue:117/255.0 alpha:1.0];
}

/**通知tabbar改变加好友未处理数**/
-(void)sendAddFriendMessage:(NSNotification*)nofication
{
    int count = 0;
    NSDictionary *dictionaray  = nofication.userInfo;
    NSString *Str = (NSString*)[dictionaray objectForKey:@"sendAddFriendMessage"];
    count = [Str intValue];
    
    int mCount = 0;
    mCount = (int)[MessageTools getUnreadMessageCountWithAddFriend];
//    [self setMsgNunber:mCount ByIndex:4];
//
//    [self setMsgNumber:count ByIndex:3];
    [self setMsgNumber:mCount ByIndex:2];
}

/**通知tabbar改变消息未处理数**/
-(void)sendUnReadMessageCount:(NSNotification*)nofication
{
    int count = 0;
    NSDictionary *dictionaray  = nofication.userInfo;
    NSString *Str = (NSString*)[dictionaray objectForKey:@"sendUnReadMessageCount"];
    count = [Str intValue];

    int mCount = 0;
    mCount = (int)[MessageTools getUnreadMessageCountWithAddFriend];
//    [self setMsgNunber:count ByIndex:4];

    [self setMsgNumber:mCount ByIndex:2];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (leftMenuView) {
        [leftMenuView setUserInfo];
    }
}


-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.selectedViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.tabBar.frame.size.height);
}

/**
 * 显示的消息数
 * index:需要显示的位置；0:健康档案，1:健康顾问
 */
-(void)setMsgNumber:(int)number ByIndex:(int)index{
    UILabel* label = _labelChatNumber;
    if (index == 0) {
        label = _labelDocNumber;
    }
    
    if (number <= 0) {
        label.hidden = YES;
        label.text = @"";
    }else{
        label.hidden = NO;
        if (number > 99){
            label.text = @"99+";
        }else{
            label.text = [NSString stringWithFormat:@"%d",number];
        }
    }
}

/**
 * 拍照按钮被选择
 */
- (IBAction)selectCamera:(id)sender {
    [self.navigationController pushViewController:[[ScannerViewController alloc] init] animated:YES];
//     [self.navigationController pushViewController:[[FileManagementViewController alloc] init] animated:YES];
}

/**
 * 健康档案管理按钮被选择
 */
- (IBAction)selectDocument:(id)sender {
    [_btnChat setEnabled:YES];
    [_btnDocument setEnabled:NO];
    self.selectedIndex = 0;
    [self layoutSubViews];
}

/**
 * 我的健康顾问按钮被选择
 */
- (IBAction)selectChat:(id)sender {
    [_btnChat setEnabled:NO];
    [_btnDocument setEnabled:YES];
    self.selectedIndex = 1;
    [self layoutSubViews];
//    [[self.tabBar.items objectAtIndex:1] setSelected:YES];
//    [self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:1]];
}


-(void)layoutSubViews{
    self.selectedViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.tabBar.frame.size.height);
}

/**
 * 主页左上角设置按钮点击事件
 */
-(void)settingBtnOnClickListener:(NSNotification*)nofication{
    if (!leftMenuView) {
        leftMenuView = [[HomeLeftMenuView alloc] initWithFrame:self.view.frame];
        [self.view addSubview:leftMenuView];
    }
    
    [leftMenuView showMenu:true];
}


- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    viewController.view.frame = CGRectMake(0, 0, tabBarController.view.frame.size.width, tabBarController.view.frame.size.height - 44);
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
//    if([viewController isKindOfClass:[ScannerViewController class]]){
//        [tabBarController.navigationController pushViewController:[[ScannerViewController alloc] init] animated:YES];
//        return NO;
//    }else if([viewController isKindOfClass:[MoreChatListViewController class]] || [viewController isKindOfClass:[ContactsViewController class]]){
//        if ([UITools isExperienceMode : tabBarController.navigationController]) {
//            return NO;
//        }
//    }
//    if ([UITools isExperienceMode]){
//        if([viewController isKindOfClass:[ContactsViewController class]] ||  [viewController isKindOfClass:[MoreChatListViewController class]]) {
//            [UITools isExperienceMode:self.navigationController];
//            return NO;
//        }
//    }
    return YES;
}

@end
