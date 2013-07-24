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
//@property (strong, nonatomic) NSMutableSet *seenHits;
@property (weak, nonatomic) NSMutableOrderedSet *activeTable;
@property (strong, nonatomic) ANRServerHandler *serverHandler;
@property (nonatomic) BOOL isWaitingForHits;
@property (strong, nonatomic) STTwitterAPIWrapper *twitter;
@property (strong, nonatomic) NSString *statusToFetch;

@end

#define CELL_REUSE_IDENTIFIER @"Hit"

@implementation ANRNewTableVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}


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

//-(NSMutableSet*)seenHits {
//    if (!_seenHits) _seenHits = [[NSMutableSet alloc]init];
//    return _seenHits;
//}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    [self.serverHandler getInfo];
    [self showReviewTable];
    [self.tableView registerNib:[UINib nibWithNibName:@"hitCellView" bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:CELL_REUSE_IDENTIFIER];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.tableView.tableHeaderView = self.tableHeader;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    [self.displaySelectionControl setEnabled:NO forSegmentAtIndex:2];
    [self.refreshControl addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - serverhandler delegate & related

-(void)ANRServerDidReceiveHits:(NSArray *)hits {
    self.isWaitingForHits = NO;
    [self serverIsOnline];
//    for checking where we should be adding hits we receive:
    ANRHit *firstReviewHit = [self.reviewHits firstObject];
    ANRHit *firstApprovedHit = [self.approvedHits firstObject];

    for (ANRHit *hit in hits) {
        if ([hit.status isEqualToString:HIT_STATUS_REVIEW]) {
            if (!firstReviewHit){
//                yes this is ugly :-{
                [self.reviewHits addObject:hit];
                continue;
            }
            if ([hit.hitID compare:firstReviewHit.hitID] == NSOrderedDescending){
                [self.reviewHits insertObject:hit atIndex:0];
            }else{
            [self.reviewHits addObject:hit];
            }
        }else if ([hit.status isEqualToString:HIT_STATUS_APPROVE]) {
            if (!firstApprovedHit){
                [self.approvedHits addObject:hit];
                continue;
            }
            if ([hit.hitID compare:firstApprovedHit.hitID] == NSOrderedDescending){
                [self.approvedHits insertObject:hit atIndex:0];
            }else{
                [self.approvedHits addObject:hit];
            }
        }
    }
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

-(void)ANRServerDidReceiveInfo:(NSDictionary *)info {
    [self serverIsOnline];
    self.infoLabel.alpha = 0.0;
    self.infoLabel.text = [[info[@"new_hits"] stringValue] stringByAppendingString:@" New Hits"];
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.infoLabel.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.5
                                               delay:5.0
                                             options:0
                                          animations:^{
                                              self.infoLabel.alpha = 0.0;
                                          } completion:NULL];
                     }];
}

-(void)ANRServerFailedWithError:(NSError *)error {
    NSLog(@"table view received error: %@", error);
    self.isWaitingForHits = NO;
    self.statusLabel.text = [NSString stringWithFormat:@"%@", error];
    self.statusLabel.textColor = [UIColor blackColor];
    self.statusLabel.hidden = NO;
}

-(NSNumber*)lastHitID {
    ANRHit *lastHit = [self.activeTable lastObject];
    return lastHit.hitID;
}

-(NSNumber*)firstHitID {
    ANRHit *firstHit = [self.activeTable firstObject];
    return firstHit.hitID;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.activeTable.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    ANRHitCell *cell = (ANRHitCell*)[tableView dequeueReusableCellWithIdentifier:CELL_REUSE_IDENTIFIER forIndexPath:indexPath];
    NSAssert([cell isKindOfClass:[ANRHitCell class]], @"cell of wrong type");
    ANRHit *hit = [self.activeTable objectAtIndex:indexPath.row];
    
    [cell reset];
    [cell.approveButton addTarget:self action:@selector(cellApproveAction) forControlEvents:UIControlEventTouchUpInside];
    [cell.rejectButton addTarget:self action:@selector(cellRejectAction) forControlEvents:UIControlEventTouchUpInside];
    cell.hitForDisplay = hit;
    
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
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    check if we should get more hits;
    if ((self.activeTable.count - indexPath.row <= UNVIEWED_HITS_BEFORE_REQUEST) && (!self.isWaitingForHits)){
        [self.serverHandler requestHits:NO];
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
    if (!postNow) {
        [self.approvedHits addObject:hit];
    }
    [self.tableView deleteRowsAtIndexPaths:@[self.tableView.indexPathForSelectedRow] withRowAnimation:UITableViewRowAnimationRight];
    
//    NSLog(@"approve action");
//    ANRHitCell * cell = (ANRHitCell*)[self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
//    [cell showActivityIndicator:YES];
//    Hit *hit = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
//        [self.serverHandler postHit:hit];

}

-(void)cellRejectAction {
    ANRHit *hit = [self.activeTable objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    [self.serverHandler addHitToBlacklist:hit];
    [self.activeTable removeObject:hit];
    [self.tableView deleteRowsAtIndexPaths:@[self.tableView.indexPathForSelectedRow] withRowAnimation:UITableViewRowAnimationRight];
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
}

- (IBAction)updateInfoButton:(UIButton *)sender {
    [self.serverHandler getInfo];
}

-(void)showReviewTable {
    self.statusToFetch = HIT_STATUS_REVIEW;
    self.activeTable = self.reviewHits;
    [self.tableView reloadData];
    if (!self.reviewHits.count) {
        [self.serverHandler requestHits:NO];
    }
    
}

-(void)showApprovedTable {
    self.statusToFetch = HIT_STATUS_APPROVE;
    self.activeTable = self.approvedHits;
    [self.tableView reloadData];
    if (!self.approvedHits.count) {
        [self.serverHandler requestHits:NO];
    }
}

-(void)showQueueTable {
    
}

-(void)refreshAction {
    if ([self.activeTable isEqual:self.approvedHits]) {
        [self.approvedHits removeAllObjects];
    }
    [self.serverHandler requestHits:YES];
    self.isWaitingForHits = YES;
    
}

-(void)serverIsOnline {
//    show the 'online' label
    self.statusLabel.text = @"ONLINE";
    self.statusLabel.textColor = [UIColor colorWithRed:0.098 green:0.753 blue:0.02 alpha:1.0];
    self.statusLabel.hidden = NO;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */


@end
