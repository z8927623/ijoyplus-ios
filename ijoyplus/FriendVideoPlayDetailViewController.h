//
//  PlayViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-11.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNMBottomPullToRefreshManager.h"
#import "IntroductionView.h"
#import "EGORefreshTableHeaderView.h"
#import "VideoPlayDetailViewController.h"
#import "LoadMoreCell.h"
@interface FriendVideoPlayDetailViewController : VideoPlayDetailViewController{
    NSMutableArray *friendCommentArray;
}

@end
