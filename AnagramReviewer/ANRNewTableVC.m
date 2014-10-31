//
//  ANRNewTableVC.m
//  AnagramReviewer
//
//  Created by Colin Rothfels on 2013-07-19.
//  Copyright (c) 2013 cmyr. All rights reserved.
//

#import "ANRNewTableVC.h"
#import "ANRHitCell.h"
#import "ANRHit.h"
#import "ANRTweet.h"
#import "STTwitterAPIWrapper.h"
#import "ANRAuth.h"

@interface ANRNewTableVC ()
@property (strong, nonatomic) NSMutableOrderedSet *reviewHits;
@property (strong, nonatomic) NSMutableOrderedSet *approvedHits;
@property (weak, nonatomic) NSMutableOrderedSet *activeTable;
@property (strong, nonatomic) NSMutableSet *seenHits;
@property (strong, nonatomic) ANRServerHandler *serverHandler;
@property (nonatomic) BOOL isWaitingForHits;
@property (strong, nonatomic) STTwitterAPIWrapper *twitter;
@property (strong, nonatomic) NSString *statusToFetch;
@property (nonatomic) BOOL shouldClearHits;
@property (nonatomic) BOOL serverExhausted;
@property (strong, nonatomic) UIColor *ourGreen;

@property (strong, nonatomic) UIButton *footerButton;


@end

#define CELL_REUSE_IDENTIFIER @"Hit"

@implementation ANRNewTableVC


-(NSMutableOrderedSet*)reviewHits {
    if (!_reviewHits) _reviewHits = [[NSMutableOrderedSet alloc]init];
    return _reviewHits;
}

-(NSMutableOrderedSet*)approvedHits {
    if (!_approvedHits) _approvedHits = [[NSMutableOrderedSet alloc]init];
    return _approvedHits;
}

-(ANRServerHandler*)serverHandler {
    if (!_serverHandler) _serverHandler = [[ANRServerHandler alloc]init];
    _serverHandler.delegate = self;
    return _serverHandler;
}


-(NSMutableSet*)seenHits {
    if (!_seenHits) _seenHits = [[NSMutableSet alloc]init];
    return _seenHits;
}

-(UIColor*)ourGreen {
    if (!_ourGreen) _ourGreen = [UIColor colorWithRed:0.098 green:0.753 blue:0.02 alpha:1.0];
    return _ourGreen;
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showReviewTable];
    [self displayMessage:@"ANAGRAMATRON" Color:[UIColor whiteColor] Duration:4.0];
//    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.twitter = [STTwitterAPIWrapper twitterAPIWithOAuthConsumerName:@"name?"
                                                            consumerKey:TWITTER_CONSUMER_KEY
                                                         consumerSecret:TWITTER_CONSUMER_SECRET
                                                             oauthToken:TWITTER_ACCESS_KEY
                                                       oauthTokenSecret:TWITTER_ACCESS_SECRET];
    [self.twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
        NSLog(@"successfully logged into twitter with as %@", username);
    } errorBlock:^(NSError *error) {
        [self ANRServerFailedWithError:error];
    }];

    [self setupFooterButton];
    [self.tableView registerNib:[UINib nibWithNibName:@"hitCellView" bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:CELL_REUSE_IDENTIFIER];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

}

-(void)setupFooterButton {
    self.footerButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.footerButton setTitle:@"Clear All" forState:UIControlStateNormal];
    self.footerButton.frame = CGRectMake(0, 0, 100, 40);

    [self.footerButton addTarget:self action:@selector(footerButtonAction) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableFooterView = self.footerButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - serverhandler delegate & related

-(void)ANRServerDidReceiveHits:(NSArray *)hits Count:(NSUInteger)count {

//    [self serverIsOnline];
    NSString *message = [NSString stringWithFormat:@"%i hits on server", count];
    [self displayMessage:message Color:[UIColor whiteColor] Duration:3.0];

    if (self.shouldClearHits){
        [self.activeTable removeAllObjects];
        self.shouldClearHits = NO;
        self.serverExhausted = NO;
    }
    if ([hits count] != self.serverHandler.fetchBatchSize) {
//  if server returns fewer hits then requested we'll stop sending requests
        self.serverExhausted = YES;
    }
    for (ANRHit *hit in hits) {
        if ([hit.status isEqualToString:HIT_STATUS_REVIEW]) {
            [self.reviewHits addObject:hit];
        }else if ([hit.status isEqualToString:HIT_STATUS_APPROVE]) {
            [self.approvedHits addObject:hit];
            }
        }
    
    [self.tableView reloadData];
    self.isWaitingForHits = NO;
//    [self.refreshControl endRefreshing];
}

-(void)ANRServerDidReceiveInfo:(NSDictionary *)info {
    NSLog(@"%@", info);
    id lastPostTime = info[@"last_post"];
    if ([lastPostTime respondsToSelector:@selector(doubleValue)]) {
        NSDate *postDate = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)[lastPostTime doubleValue]];

        NSTimeInterval timeSinceLastPost = abs([postDate timeIntervalSinceNow]);
        NSUInteger hours = timeSinceLastPost / (60*60);
        timeSinceLastPost -= hours * (60*60);
        NSUInteger minutes = timeSinceLastPost / 60;
        
        NSString *intervalString;
        if (hours){
            intervalString = [NSString stringWithFormat:@"posted %ih ago", hours];
        }else{
            intervalString = [NSString stringWithFormat:@"posted %im ago", minutes];
        }
        [self displayMessage:intervalString Color:[UIColor whiteColor] Duration:4.0];
        
    }
}

-(void)ANRServerFailedWithError:(NSError *)error {
    NSString* errorString = error.description;
    UIColor* labelTextColor = [UIColor blackColor];
    NSLog(@"table view received error: %@", error);
    if (error.code == -1202) {
//        bad SSL certs
        errorString = @"Invalid Certificate";
    }
    if (error.code == 404) {
//        host offline
        errorString = @"Offline";
        labelTextColor = self.ourGreen;
    }
    if (error.code == -1004) {
//        could not connect to server
        [self serverIsOffline];
    }
    
    self.isWaitingForHits = NO;
}

-(void)ANRServerDidReceiveResponse:(NSDictionary *)response {
    NSLog(@"unhandled response: %@", response);
    
    if ([response[@"action"]isEqualToString:HIT_STATUS_SEEN] && [response[@"count"]intValue] > 1) {
//        means we've cleared our review table

        NSString *message = [NSString stringWithFormat:@"cleared %@ hits", response[@"count"]];
        [self displayMessage:message Color:[UIColor whiteColor] Duration:3.0];
    }
    
    if ([response[@"action"] isEqualToString:HIT_STATUS_POST]) {
        if (response[@"success"]) {
            [self displayMessage:@"Post Succeeded" Color:self.ourGreen Duration:5.0];
        }else{
            [self displayMessage:@"Post Failed" Color:[UIColor redColor] Duration:5.0];
        }
    }
}

-(NSNumber*)lastHitID {
    if (self.shouldClearHits) return nil;
    ANRHit *lastHit = [self.activeTable lastObject];
    return lastHit.hitID;
}

//-(NSNumber*)firstHitID {
//    ANRHit *firstHit = [self.activeTable firstObject];
//    return firstHit.hitID;
//}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

//-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    return self.footerButton;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.activeTable.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    ANRHitCell *cell = (ANRHitCell*)[tableView dequeueReusableCellWithIdentifier:CELL_REUSE_IDENTIFIER forIndexPath:indexPath];
    NSAssert([cell isKindOfClass:[ANRHitCell class]], @"cell of wrong type");
    ANRHit *hit = [self.activeTable objectAtIndex:indexPath.row];
    
    ANRHit *previousHit = [cell hitForDisplay];
    if (previousHit) {
        [self.seenHits addObject:previousHit];
    }
    
    [cell reset];
    [cell.approveButton addTarget:self action:@selector(cellApproveAction) forControlEvents:UIControlEventTouchUpInside];
    [cell.rejectButton addTarget:self action:@selector(cellRejectAction) forControlEvents:UIControlEventTouchUpInside];
    cell.hitForDisplay = hit;
    
    if (hit.tweet1.fetched && !hit.tweet1.profile_img && !hit.tweet1.imageMissing) {
        [hit.tweet1 fetchProfileImage];
    }
    
    if (hit.tweet2.fetched && !hit.tweet2.profile_img && !hit.tweet2.imageMissing) {
        [hit.tweet2 fetchProfileImage];
    }
    
    if (!hit.tweet1.fetched && !hit.tweet1.error){
        NSLog(@"requesting tweet");
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [self.twitter getStatusWithID:[hit.tweet1.tweetID stringValue]
                      includeEntities:YES
                         successBlock:^(NSDictionary *status) {
                             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                             [hit.tweet1 updateWithTwitterInfo:status];
                             if ([cell isDisplayingHit:hit]){
                                 cell.hitForDisplay = hit;
                                 [cell setNeedsLayout];
                             }
                                    } errorBlock:^(NSError *error) {
                                        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                        [hit.tweet1 updateFailedWitheError:error];
                                        if ([cell isDisplayingHit:hit]){
                                            cell.hitForDisplay = hit;
                                            [cell setNeedsLayout];
                                        }
                                    }];

    }
    if (!hit.tweet2.fetched && !hit.tweet2.error){
        NSLog(@"requesting tweet");
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [self.twitter getStatusWithID:[hit.tweet2.tweetID stringValue]
                      includeEntities:YES
                         successBlock:^(NSDictionary *status) {
                             [hit.tweet2 updateWithTwitterInfo:status];
                             if ([cell isDisplayingHit:hit]){
                                 cell.hitForDisplay = hit;
                                [cell setNeedsLayout];
                                 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                             }
                         } errorBlock:^(NSError *error) {
                             [hit.tweet2 updateFailedWitheError:error];
                             if ([cell isDisplayingHit:hit]){
                                 cell.hitForDisplay = hit;
                                 [cell setNeedsLayout];
                                 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                             }
                         }];

    }
//    check if we need to retrieve twitter data for this hit:
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 141.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ANRHitCell *cell = (ANRHitCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell showButtons];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    ANRHitCell *cell = (ANRHitCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell hideButtons];
}

#define UNVIEWED_HITS_BEFORE_REQUEST 5.0
#define MAX_REVIEWED_HITS_BEFORE_HALT_REFRESH 40
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    check if we should get more hits;
    if ((self.activeTable.count - indexPath.row <= UNVIEWED_HITS_BEFORE_REQUEST) &&
        (!self.isWaitingForHits) && (!self.serverExhausted) &&
        (self.reviewHits.count <= MAX_REVIEWED_HITS_BEFORE_HALT_REFRESH)
        ){

        [self.serverHandler requestHits];
        self.isWaitingForHits = YES;
    }

    
    ANRHitCell *hitCell = (ANRHitCell*)cell;
    NSAssert([cell isKindOfClass:[ANRHitCell class]], @"cell of wrong type");
    
    if (indexPath.row % 2){
        hitCell.tweetOne.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        hitCell.tweetTwo.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    }else{
        hitCell.tweetOne.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        hitCell.tweetTwo.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    }

}

#pragma mark - UI & interactions
-(void)cellApproveAction {
    ANRHit *hit = [self.activeTable objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    BOOL postNow = [hit.status isEqualToString:HIT_STATUS_APPROVE] ? YES : NO;
    [self.serverHandler approveHit:hit postImmediately:postNow];
    [self.activeTable removeObject:hit];
//    if ([self.activeTable isEqual:self.reviewHits]) {
//        [self.approvedHits addObject:hit];
//    }
    [self.tableView deleteRowsAtIndexPaths:@[self.tableView.indexPathForSelectedRow] withRowAnimation:UITableViewRowAnimationRight];
    
//    NSLog(@"approve action");
//    ANRHitCell * cell = (ANRHitCell*)[self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
//    [cell showActivityIndicator:YES];
//    Hit *hit = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
//        [self.serverHandler postHit:hit];

}

-(void)cellRejectAction {
    ANRHit *hit = [self.activeTable objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    [self.serverHandler  markHitsAsSeen:[NSSet setWithObject:hit.hitID]];
    [self.activeTable removeObject:hit];
    [self.tableView deleteRowsAtIndexPaths:@[self.tableView.indexPathForSelectedRow] withRowAnimation:UITableViewRowAnimationRight];
}

- (IBAction)refreshAction:(UIButton *)sender {
    self.shouldClearHits = YES;
    [self.serverHandler requestHits];
    self.isWaitingForHits = YES;
}

- (IBAction)infoAction:(UIButton *)sender {
    [self.serverHandler getInfo];
}

- (IBAction)selectionControlAction:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
//            review
            [self showReviewTable];
            break;
        case 1:
//            approved
            [self showApprovedTable];
            break;
        case 2:
//            queue
            break;
            
        default:
            break;
    }
    self.serverExhausted = NO;
}


-(void)footerButtonAction{
    if (self.activeTable == self.approvedHits) return;
    
    NSMutableSet *seenList = [NSMutableSet set];
    for (ANRHit* hit in self.reviewHits) {
        [seenList addObject:hit.hitID];
    }
    [self.serverHandler markHitsAsSeen:seenList];
    [self.reviewHits removeAllObjects];
    [self.tableView reloadData];
}



-(void)showReviewTable {
    self.statusToFetch = HIT_STATUS_REVIEW;
    self.activeTable = self.reviewHits;
    self.footerButton.hidden = NO;
    [self.tableView reloadData];
    if (!self.reviewHits.count) {
        [self.serverHandler requestHits];
        self.isWaitingForHits = YES;
    }
    
}

-(void)showApprovedTable {
    self.statusToFetch = HIT_STATUS_APPROVE;
    self.activeTable = self.approvedHits;
    self.footerButton.hidden = YES;
    [self.tableView reloadData];
    if (!self.approvedHits.count) {
        [self.serverHandler requestHits];
        self.isWaitingForHits = YES;
    }
}


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)serverIsOnline {
    [self displayMessage:@"ONLINE" Color:self.ourGreen Duration:3.0];

}

-(void)serverIsOffline {
    [self displayMessage:@"OFFLINE" Color:[UIColor redColor] Duration:5.0];
}

-(void)displayMessage:(NSString*)message Color:(UIColor*)color Duration:(NSTimeInterval)duration {
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:0
                     animations:^{
                         self.titleLabel.alpha = 0.0;
                     } completion:^(BOOL finished){
                         self.titleLabel.text = message;
                         self.titleLabel.textColor = color;
                         [UIView animateWithDuration:0.4
                                               delay:0.0
                                             options:UIViewAnimationOptionBeginFromCurrentState
                                          animations:^{
                                              self.titleLabel.alpha = 1.0;
                                          }
                                          completion:^(BOOL finished){
                                              [UIView animateWithDuration:0.4
                                                                    delay:duration
                                                                  options:0
                                                               animations:^{
                                                                   self.titleLabel.alpha = 0.0;
                                                               } completion:^(BOOL finished) {
                                                                   self.titleLabel.text = @"";
                                                                   self.titleLabel.textColor = [UIColor whiteColor];
                                                                   [UIView animateWithDuration:0.4
                                                                                    animations:^{
                                                                                        self.titleLabel.alpha = 1.0;
                                                                                    } completion:^(BOOL finished) {
                                                                                        self.titleLabel.alpha = 1.0;
                                                                                    }];
                                                                   
                                                               }];
                                          }];}
     ];

}



@end
