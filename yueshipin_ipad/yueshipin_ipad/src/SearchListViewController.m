//
//  SearchListViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-29.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "SearchListViewController.h"
#import "CommonHeader.h"
#import "MovieDetailViewController.h"
#import "DramaDetailViewController.h"
#import "ShowDetailViewController.h"

@interface SearchListViewController (){
    UITableView *table;
    UIImageView *bgImage;
    UIImageView *titleImage;
    NSMutableArray *videoArray;
    UIButton *closeBtn;
    MNMBottomPullToRefreshManager *pullToRefreshManager_;
    NSUInteger reloads_;
    int pageSize;
}


@end

@implementation SearchListViewController
@synthesize keyword;

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.keyword = nil;
    table = nil;
    bgImage = nil;
    titleImage = nil;
    [videoArray removeAllObjects];
    videoArray = nil;
    closeBtn = nil;
    pullToRefreshManager_ = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor clearColor]];
    bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];bgImage.image = [UIImage imageNamed:@"detail_bg"];
    [self.view addSubview:bgImage];
    
    titleImage = [[UIImageView alloc]initWithFrame:CGRectMake(50, 35, 106, 27)];
    titleImage.image = [UIImage imageNamed:@"result_title"];
    [self.view addSubview:titleImage];
    
    closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(485, 20, 40, 42);
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    
    table = [[UITableView alloc]initWithFrame:CGRectMake(25, 100, 460, self.view.frame.size.height - 390)];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = [UIColor clearColor];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.showsVerticalScrollIndicator = NO;
    [self.view addSubview:table];
    reloads_ = 2;
    pageSize = 10;
    pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:480.0f tableView:table withClient:self];
    [self loadTable];
}

- (void)loadTable {
    [table reloadData];
    [pullToRefreshManager_ tableViewReloadFinished];
}


- (void)viewWillAppear:(BOOL)animated
{
    [myHUD showProgressBar:self.view];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:self.keyword, @"keyword", @"1", @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", @"1,2,3", @"type", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathSearch parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        videoArray = [[NSMutableArray alloc]initWithCapacity:10];
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *searchResult = [result objectForKey:@"results"];
            if(searchResult != nil && searchResult.count > 0){
                [videoArray addObjectsFromArray:searchResult];
            }
            if(searchResult.count < pageSize){
                [pullToRefreshManager_ setPullToRefreshViewVisible:NO];
            }
        }
        [self loadTable];
        [myHUD hide];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [myHUD hide];
        videoArray = [[NSMutableArray alloc]initWithCapacity:10];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(videoArray == nil){
        return 0;
    }
    if(videoArray.count == 0){
        return 1;
    }
    return videoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(videoArray.count > 0){
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(40, 8, 102, 146)];
            imageView.image = [UIImage imageNamed:@"movie_frame"];
            [cell.contentView addSubview:imageView];
            
            UIImageView *contentImage = [[UIImageView alloc]initWithFrame:CGRectMake(44, 12, 94, 138)];
            contentImage.image = [UIImage imageNamed:@"test_movie"];
            contentImage.tag = 1001;
            [cell.contentView addSubview:contentImage];
            
            UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(160, 12, 306, 25)];
            nameLabel.font = CMConstants.titleFont;
            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.tag = 2001;
            [cell.contentView addSubview:nameLabel];
            
            UILabel *scoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(160, 45, 45, 20)];
            scoreLabel.tag = 3001;
            scoreLabel.text = @"0 分";
            scoreLabel.backgroundColor = [UIColor clearColor];
            scoreLabel.font = [UIFont boldSystemFontOfSize:15];
            scoreLabel.textColor = CMConstants.scoreBlueColor;
            [cell.contentView addSubview:scoreLabel];
            UIImageView *doubanLogo = [[UIImageView alloc]initWithFrame:CGRectMake(210, 50, 15, 15)];
            doubanLogo.tag = 9001;
            [cell.contentView addSubview:doubanLogo];
            
            UILabel *directorLabel = [[UILabel alloc]initWithFrame:CGRectMake(160, 75, 150, 25)];
            directorLabel.tag = 4011;
            directorLabel.textColor = CMConstants.grayColor;
            directorLabel.font = [UIFont systemFontOfSize:13];
            directorLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:directorLabel];
            
            UILabel *directorNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(205, 75, 220, 25)];
            directorNameLabel.textColor = CMConstants.grayColor;
            directorNameLabel.font = [UIFont systemFontOfSize:13];
            directorNameLabel.backgroundColor = [UIColor clearColor];
            directorNameLabel.tag = 4001;
            [cell.contentView addSubview:directorNameLabel];
            
            UILabel *actorLabel = [[UILabel alloc]initWithFrame:CGRectMake(160, 100, 150, 25)];
            actorLabel.tag = 5011;
            actorLabel.textColor = CMConstants.grayColor;
            actorLabel.font = [UIFont systemFontOfSize:13];
            actorLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:actorLabel];
            
            UILabel *actorName1Label = [[UILabel alloc]initWithFrame:CGRectMake(205, 100, 180, 25)];
            actorName1Label.font = [UIFont systemFontOfSize:13];
            actorName1Label.textColor = CMConstants.grayColor;
            actorName1Label.backgroundColor = [UIColor clearColor];
            actorName1Label.tag = 5001;
            [cell.contentView addSubview:actorName1Label];
            
            
            UIImageView *dingNumberImage = [[UIImageView alloc]initWithFrame:CGRectMake(160, 128, 75, 24)];
            dingNumberImage.image = [UIImage imageNamed:@"pushinguser"];
            [cell.contentView addSubview:dingNumberImage];
            
            UILabel *dingNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(165, 128, 40, 24)];
            dingNumberLabel.textAlignment = NSTextAlignmentCenter;
            dingNumberLabel.backgroundColor = [UIColor clearColor];
            dingNumberLabel.font = [UIFont systemFontOfSize:13];
            dingNumberLabel.tag = 6001;
            [cell.contentView addSubview:dingNumberLabel];
            
            UIImageView *collectioNumber = [[UIImageView alloc]initWithFrame:CGRectMake(250, 128, 84, 24)];
            collectioNumber.image = [UIImage imageNamed:@"collectinguser"];
            [cell.contentView addSubview:collectioNumber];
            
            UILabel *collectionNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(255, 128, 40, 24)];
            collectionNumberLabel.textAlignment = NSTextAlignmentCenter;
            collectionNumberLabel.backgroundColor = [UIColor clearColor];
            collectionNumberLabel.font = [UIFont systemFontOfSize:13];
            collectionNumberLabel.tag = 7001;
            [cell.contentView addSubview:collectionNumberLabel];
            
            UIImageView *devidingLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, 158, table.frame.size.width, 2)];
            devidingLine.image = [UIImage imageNamed:@"dividing"];
            [cell.contentView addSubview:devidingLine];
            
        }
        NSDictionary *item = [videoArray objectAtIndex:indexPath.row];
        UIImageView *contentImage = (UIImageView *)[cell viewWithTag:1001];
        [contentImage setImageWithURL:[NSURL URLWithString:[item objectForKey:@"prod_pic_url"]] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
        
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:2001];
        nameLabel.text = [item objectForKey:@"prod_name"];
        
        UILabel *directorNameLabel = (UILabel *)[cell viewWithTag:4001];
        
        UILabel *actorLabel1 = (UILabel *)[cell viewWithTag:5001];
        
        UILabel *scoreLabel = (UILabel *)[cell viewWithTag:3001];
        UILabel *directorLabel = (UILabel *)[cell viewWithTag:4011];
        UILabel *actorLabel = (UILabel *)[cell viewWithTag:5011];
        UIImageView *doubanlogo = (UIImageView *)[cell viewWithTag:9001];
        NSString *type = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_type"]];
        if([type isEqualToString:@"3"]){
            scoreLabel.text = @"";
            doubanlogo.image = nil;
            directorLabel.text = @"主持人：";
            directorNameLabel.text = [item objectForKey:@"star"];
            directorNameLabel.frame = CGRectMake(225, 75, 220, 25);
            actorLabel.text = @"首播时间：";
            actorLabel1.frame = CGRectMake(225, 100, 180, 25);
            actorLabel1.text =[item objectForKey:@"publish_date"];
        } else {
            scoreLabel.text = [NSString stringWithFormat:@"%@ 分", [item objectForKey:@"score"]];
            doubanlogo.image = [UIImage imageNamed:@"douban"];
            directorLabel.text = @"导演：";
            actorLabel.text = @"主演：";
            actorLabel1.frame = CGRectMake(205, 100, 180, 25);
            directorNameLabel.text = [item objectForKey:@"director"];
            directorNameLabel.frame = CGRectMake(205, 75, 220, 25);
            actorLabel1.text = [item objectForKey:@"star"];
        }
        
        UILabel *dingNumberLabel = (UILabel *)[cell viewWithTag:6001];
        dingNumberLabel.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"support_num"]];
        
        UILabel *collectionNumberLabel = (UILabel *)[cell viewWithTag:7001];
        collectionNumberLabel.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"favority_num"]];
        
        return cell;
    } else {
        static NSString *noRecordCellIdentifier = @"noRecordCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noRecordCellIdentifier];
        if(cell == nil){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:noRecordCellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(140, 0, 300, 40)];
            [label setBackgroundColor:[UIColor clearColor]];
            label.textColor = CMConstants.grayColor;
            label.font = [UIFont systemFontOfSize: 16];
            label.text = @"很抱歉，没有找到相关影片！";
            [cell.contentView addSubview:label];
        }
        return cell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 160;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(videoArray.count > 0){
        [table deselectRowAtIndexPath:indexPath animated:YES];
        NSDictionary *item = [videoArray objectAtIndex:indexPath.row];
        NSString *type = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_type"]];
        NSString *prodId = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_id"]];
        if([type isEqualToString:@"1"]){
            MovieDetailViewController *viewController = [[MovieDetailViewController alloc] initWithNibName:@"MovieDetailViewController" bundle:nil];
            viewController.prodId = prodId;
            viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
            [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:NO];
        } else if([type isEqualToString:@"2"]){
            DramaDetailViewController *viewController = [[DramaDetailViewController alloc] initWithNibName:@"DramaDetailViewController" bundle:nil];
            viewController.prodId = prodId;
            viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
            [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:NO];
        } else {
            ShowDetailViewController *viewController = [[ShowDetailViewController alloc] initWithNibName:@"ShowDetailViewController" bundle:nil];
            viewController.prodId = prodId;
            viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
            [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:NO];
        }
    }
}

#pragma mark -
#pragma mark MNMBottomPullToRefreshManagerClient

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [pullToRefreshManager_ tableViewScrolled];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [pullToRefreshManager_ tableViewReleased];
}

- (void)MNMBottomPullToRefreshManagerClientReloadTable {
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:2.0f];
        return;
    }
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:self.keyword, @"keyword", [NSNumber numberWithInt:reloads_], @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", @"1,2,3", @"type", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathSearch parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        NSArray *tempArray;
        if(responseCode == nil){
            tempArray = [result objectForKey:@"results"];
            if(tempArray.count > 0){
                [videoArray addObjectsFromArray:tempArray];
                reloads_ ++;
            }
        } else {
            
        }
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:0.0f];
        if(tempArray.count < pageSize){
            [pullToRefreshManager_ setPullToRefreshViewVisible:NO];
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:0.0f];
    }];
}
@end