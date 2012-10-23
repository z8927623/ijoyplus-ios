#import "DramaViewController.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "DramaPlayDetailViewController.h"
#import "CMConstants.h"
#import <QuartzCore/QuartzCore.h>
#import "ContainerUtility.h"
#import "StringUtility.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "CacheUtility.h"
#import "UIUtility.h"

@interface DramaViewController(){
    WaterflowView *flowView;
    NSMutableArray *videoArray;
    int pageSize;
}
- (void)addContentView;
@end

@implementation DramaViewController

- (void)viewDidUnload
{
    flowView = nil;
    videoArray = nil;
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        [self addContentView];
    //    UISwipeGestureRecognizer *downGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(hideNavigationBarAnimation)];
    //    downGesture.direction = UISwipeGestureRecognizerDirectionDown;
    //    [flowView addGestureRecognizer:downGesture];
    pageSize = 12;
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        id cacheResult = [[CacheUtility sharedCache] loadFromCache:@"DramaViewController"];
        [self parseData:cacheResult];
        [flowView reloadData];
    } else {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: kAppKey, @"app_key", @"1", @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathTV parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self parseData:result];
            [flowView reloadData];
            [[CacheUtility sharedCache] putInCache:@"DramaViewController" result:result];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
            videoArray = [[NSMutableArray alloc]initWithCapacity:pageSize];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
        }];
    }
}

- (void)parseData:(id)result
{
    videoArray = [[NSMutableArray alloc]initWithCapacity:pageSize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        NSArray *videos = [result objectForKey:@"tv"];
        if(videos.count > 0){
            [videoArray addObjectsFromArray:videos];
        }
    } else {
        
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    if(videoArray == nil){
        [self showProgressBar];
    }
}

- (void)addContentView
{
    if(flowView != nil){
        [flowView removeFromSuperview];
    }
    flowView = [[WaterflowView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-135)];
    flowView.parentControllerName = @"DramaViewController";
    [flowView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    flowView.cellSelectedNotificationName = @"dramaSelected";
    [flowView showsVerticalScrollIndicator];
    flowView.flowdatasource = self;
    flowView.flowdelegate = self;
    [self.view addSubview:flowView];
    [flowView reloadData];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark-
#pragma mark- WaterflowDataSource

- (NSInteger)numberOfColumnsInFlowView:(WaterflowView *)flowView
{
    return NUMBER_OF_COLUMNS;
}

- (NSInteger)flowView:(WaterflowView *)flowView numberOfRowsInColumn:(NSInteger)column
{
    return 4;
}

- (WaterFlowCell*)flowView:(WaterflowView *)flowView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"movieCell";
	WaterFlowCell *cell = [[WaterFlowCell alloc] initWithReuseIdentifier:CellIdentifier];
    if(indexPath.row * 3 + indexPath.section >= videoArray.count){
        return cell;
    }
    cell.cellSelectedNotificationName = flowView.cellSelectedNotificationName;
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    if(indexPath.section == 0){
        imageView.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP, 0, MOVIE_LOGO_WIDTH, MOVIE_LOGO_HEIGHT);
    } else if(indexPath.section == NUMBER_OF_COLUMNS - 1){
        imageView.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP/2, 0, MOVIE_LOGO_WIDTH, MOVIE_LOGO_HEIGHT);
    } else {
        imageView.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP/2, 0, MOVIE_LOGO_WIDTH, MOVIE_LOGO_HEIGHT);
    }
    NSDictionary *movie = [videoArray objectAtIndex:indexPath.row * 3 + indexPath.section];
    NSString *url = [movie valueForKey:@"prod_pic_url"];
    if([StringUtility stringIsEmpty:url]){
        imageView.image = [UIImage imageNamed:@"movie_placeholder"];
    } else {
        [imageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"movie_placeholder"]];
    }
    imageView.layer.borderWidth = 1;
    imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    imageView.layer.shadowColor = [UIColor blackColor].CGColor;
    imageView.layer.shadowOffset = CGSizeMake(1, 1);
    imageView.layer.shadowOpacity = 1;
    [cell addSubview:imageView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(MOVIE_LOGO_WIDTH_GAP, MOVIE_LOGO_HEIGHT, MOVE_NAME_LABEL_WIDTH, MOVE_NAME_LABEL_HEIGHT)];
    NSString *name = [movie valueForKey:@"prod_name"];
    if([StringUtility stringIsEmpty:name]){
        titleLabel.text = @"...";
    } else {
        titleLabel.text = name;
    }
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = CMConstants.titleFont;
    [cell addSubview:titleLabel];
    return cell;
    
}

#pragma mark-
#pragma mark- WaterflowDelegate
-(CGFloat)flowView:(WaterflowView *)flowView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row * 3 + indexPath.section >= videoArray.count){
        return 0;
    }
	return MOVIE_LOGO_HEIGHT + MOVE_NAME_LABEL_HEIGHT;
    
}

- (void)flowView:(WaterflowView *)flowView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UINavigationController *navController = (UINavigationController *)appDelegate.window.rootViewController;
    DramaPlayDetailViewController *viewController = [[DramaPlayDetailViewController alloc]initWithStretchImage];
    NSDictionary *movie = [videoArray objectAtIndex:indexPath.row * 3 + indexPath.section];
    viewController.programId = [movie objectForKey:@"prod_id"];
    //    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:viewController];
    [navController pushViewController:viewController animated:YES];
}

- (void)flowView:(WaterflowView *)_flowView willLoadData:(int)page
{
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        return;
    }
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: kAppKey, @"app_key", [NSString stringWithFormat:@"%i", page], @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathTV parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *videos = [result objectForKey:@"tv"];
            if(videos.count > 0){
                [videoArray addObjectsFromArray:videos];
            }
            [flowView reloadData];
        } else {
            
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)flowView:(WaterflowView *)_flowView refreshData:(int)page
{
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        return;
    }
    [videoArray removeAllObjects];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: kAppKey, @"app_key", [NSString stringWithFormat:@"%i", 1], @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathTV parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *videos = [result objectForKey:@"tv"];
            if(videos.count > 0){
                [videoArray addObjectsFromArray:videos];
            }
            [flowView reloadData];
        } else {
            
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

@end
