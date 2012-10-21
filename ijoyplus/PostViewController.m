//
//  PostViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-25.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "PostViewController.h"
#import "CustomBackButton.h"
#import "UIUtility.h"
#import "CMConstants.h"
#import "ContainerUtility.h"
#import "SinaLoginViewController.h"
#import "TecentViewController.h"
#import "AFSinaWeiboAPIClient.h"
#import "CacheUtility.h"
#import "StringUtility.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "CustomPlaceHolderTextView.h"
#import "AppDelegate.h"

#define  TEXT_MAX_COUNT 140

@interface PostViewController (){
    UIButton *btn1;
    BOOL btn1Selected;
    UIButton *btn2;
    BOOL btn2Selected;
}
@property (strong, nonatomic) IBOutlet UILabel *textCount;
@property (strong, nonatomic) IBOutlet UILabel *tipLabel;
@property (strong, nonatomic) IBOutlet CustomPlaceHolderTextView *textView;
- (void)startObservingNotifications;
- (void)stopObservingNotifications;
- (void)didReceiveTextDidChangeNotification:(NSNotification*)notification;
- (void)updateCount;
@end

@implementation PostViewController
@synthesize textCount;
@synthesize tipLabel;
@synthesize textView;
@synthesize sinaBtn = btn1;
@synthesize qqBtn = btn2;
@synthesize programId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"share", nil);
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    CustomBackButton *backButton = [[CustomBackButton alloc] initWith:[UIImage imageNamed:@"back-button"] highlight:[UIImage imageNamed:@"back-button"] leftCapWidth:14.0 text:NSLocalizedString(@"back", nil)];
    [backButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"post", nil) style:UIBarButtonSystemItemSearch target:self action:@selector(post)];
    self.navigationItem.rightBarButtonItem = rightButton;
    btn1Selected = YES;
    [btn1 setBackgroundImage:[UIImage imageNamed:@"sina_normal"] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(sinaLoginScreen)forControlEvents:UIControlEventTouchUpInside];
    [btn2 setHidden:YES];
//    [btn2 setBackgroundImage:[UIImage imageNamed:@"qq_press"] forState:UIControlStateNormal];
//    [btn2 addTarget:self action:@selector(tencentLoginScreen)forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidUnload
{
    btn1 = nil;
    btn2 = nil;
    [self setTextView:nil];
    [self setTextCount:nil];
    [self stopObservingNotifications];
    [self setTipLabel:nil];
    [self setSinaBtn:nil];
    [self setQqBtn:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    self.textCount.text = [NSString stringWithFormat:@"%i", TEXT_MAX_COUNT];
    [self updateCount];
    [self startObservingNotifications];
    [self.textView becomeFirstResponder];
}

- (void)closeSelf
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)startObservingNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveTextDidChangeNotification:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:nil];
}

- (void)stopObservingNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

- (void)didReceiveTextDidChangeNotification:(NSNotification*)notification
{
    [self updateCount];
}

- (void)updateCount
{
    NSUInteger count = [self.textView.text length];
    self.textCount.text = [NSString stringWithFormat:@"%d", TEXT_MAX_COUNT-count];
    
    if(count > TEXT_MAX_COUNT){
        self.tipLabel.text = NSLocalizedString(@"tip_text", nil);
        self.textCount.textColor = [UIColor redColor];
        self.textCount.text =  [NSString stringWithFormat:@"%d", -TEXT_MAX_COUNT+count];
    }
    
}

- (void)sinaLoginScreen
{
//    btn1Selected = !btn1Selected;
    if([WBEngine sharedClient].isLoggedIn && ![WBEngine sharedClient].isAuthorizeExpired){
        if(btn1Selected){
            [btn1 setBackgroundImage:[UIImage imageNamed:@"sina_normal"] forState:UIControlStateNormal];
        } else {
            [btn1 setBackgroundImage:[UIImage imageNamed:@"sina_inactive"]forState:UIControlStateNormal];
        }
    } else{
        SinaLoginViewController *viewController = [[SinaLoginViewController alloc]init];
        viewController.fromController = @"PostViewController";
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)tencentLoginScreen
{
//    btn2Selected = !btn2Selected;
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//	if([appDelegate._tencentOAuth isSessionValid]){
//        if(btn2Selected){
//            [btn2 setBackgroundImage:[UIImage imageNamed:@"qq_normal"] forState:UIControlStateNormal];
//        } else {
//            [btn2 setBackgroundImage:[UIImage imageNamed:@"qq_press"] forState:UIControlStateNormal];
//        }
//    } else{
//        TecentViewController *viewController = [[TecentViewController alloc] init];
//        viewController.fromController = @"PostViewController";
//        [self.navigationController pushViewController:viewController animated:YES];
//    }
}

- (void)post
{
    [self.textView resignFirstResponder];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    if([StringUtility stringIsEmpty:self.textView.text]){
        //        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
        HUD.mode = MBProgressHUDModeText;
        [self.view addSubview:HUD];
        HUD.labelText = @"您想说点什么呢？";
        [HUD show:YES];
        [HUD hide:YES afterDelay:1.5];
        return;
    }
    [self.navigationController.view addSubview:HUD];
    if(!btn1Selected && !btn2Selected){
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"请选择分享地址！";
        [HUD show:YES];
        [HUD hide:YES afterDelay:2];
        return;
    }
    if(btn1Selected){
        [[WBEngine sharedClient] sendWeiBoWithText:self.textView.text image:nil];
    }
//    if(btn2Selected){
//        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//        
//        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                       @"转自悦视频", @"title",
//                                       self.textView.text,@"summary",
//                                       @"4",@"source",
//                                       nil];
//        
//        [appDelegate._tencentOAuth addShareWithParams:params];
//    }
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = NSLocalizedString(@"share_success", nil);
    [HUD showWhileExecuting:@selector(postSuccess) onTarget:self withObject:nil animated:YES];
    
    //    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:kAppKey, @"app_key", self.programId, @"prod_id", self.textView.text, @"content", nil];
    //    [[AFServiceAPIClient sharedClient] postPath:kPathProgramComment parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
    //        NSString *responseCode = [result objectForKey:@"res_code"];
    //        if([responseCode isEqualToString:kSuccessResCode]){
    //            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    //            [self.navigationController.view addSubview:HUD];
    //            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    //            HUD.mode = MBProgressHUDModeCustomView;
    //            HUD.labelText = NSLocalizedString(@"post_success", nil);
    //            [HUD showWhileExecuting:@selector(postSuccess) onTarget:self withObject:nil animated:YES];
    //        } else {
    //            //            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
    //            //            NSString *msg = [NSString stringWithFormat:@"msg_%@", responseCode];
    //            //            HUD.labelText = NSLocalizedString(msg, nil);
    //            //            [HUD showWhileExecuting:@selector(showError) onTarget:self withObject:nil animated:YES];
    //        }
    //    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
    //
    //    }];
    
    
}

- (void)postSuccess
{
    sleep(1.5);
    [self performSelectorOnMainThread:@selector(closeSelf) withObject:nil waitUntilDone:YES];
}
@end