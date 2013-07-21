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
@property (strong, nonatomic) NSMutableArray *hits;
@property (strong, nonatomic) ANRServerHandler *serverHandler;
@property (nonatomic) BOOL isWaitingForHits;
@property (strong, nonatomic) STTwitterAPIWrapper *twitter;


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

-(NSMutableArray*)hits {
    if (!_hits) _hits = [[NSMutableArray alloc]init];
    return _hits;
}

-(ANRServerHandler*)serverHandler {
    if (!_serverHandler) _serverHandler = [[ANRServerHandler alloc]init];
    _serverHandler.delegate = self;
    return _serverHandler;
}

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
    
    [self.serverHandler requestHits];
    [self.tableView registerNib:[UINib nibWithNibName:@"hitCellView" bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:CELL_REUSE_IDENTIFIER];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - serverhandler delegate & related

-(void)ANRServerDidReceiveHits:(NSArray *)hits {
    [self.hits addObjectsFromArray:hits];
    [self.tableView reloadData];
    self.isWaitingForHits = NO;
}

-(void)ANRServerFailedWithError:(NSError *)error {
    NSLog(@"table view received error: %@", error);
    self.isWaitingForHits = NO;
}

-(NSNumber*)lastHitID {
    ANRHit *lastHit = [self.hits lastObject];
    return lastHit.hitID;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.hits.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    ANRHitCell *cell = (ANRHitCell*)[tableView dequeueReusableCellWithIdentifier:CELL_REUSE_IDENTIFIER forIndexPath:indexPath];
    NSAssert([cell isKindOfClass:[ANRHitCell class]], @"cell of wrong type");
    ANRHit *hit = [self.hits objectAtIndex:indexPath.row];
    
    [cell reset];
    [cell.approveButton addTarget:self action:@selector(cellApproveAction) forControlEvents:UIControlEventTouchUpInside];
    [cell.rejectButton addTarget:self action:@selector(cellRejectAction) forControlEvents:UIControlEventTouchUpInside];
    cell.hitForDisplay = hit;
    
    if (!hit.tweet1.fetched && !hit.tweet1.error){
        NSLog(@"requesting tweet");
        [self.twitter getStatusWithID:[hit.tweet1.tweetID stringValue]
                      includeEntities:YES
                         successBlock:^(NSDictionary *status) {
                             [hit.tweet1 updateWithTwitterInfo:status];
                             if ([cell isDisplayingHit:hit]){
                                 cell.hitForDisplay = hit;
                                 [cell setNeedsLayout];
                             }
                                    } errorBlock:^(NSError *error) {
                                        [hit.tweet1 updateFailedWitheError:error];
                                        if ([cell isDisplayingHit:hit]){
                                            cell.hitForDisplay = hit;
                                            [cell setNeedsLayout];
                                        }
                                    }];

    }
    if (!hit.tweet2.fetched && !hit.tweet2.error){
        NSLog(@"requesting tweet");
        [self.twitter getStatusWithID:[hit.tweet2.tweetID stringValue]
                      includeEntities:YES
                         successBlock:^(NSDictionary *status) {
                             [hit.tweet2 updateWithTwitterInfo:status];
                             if ([cell isDisplayingHit:hit]){
                                 cell.hitForDisplay = hit;
                                [cell setNeedsLayout];
                             }
                         } errorBlock:^(NSError *error) {
                             [hit.tweet2 updateFailedWitheError:error];
                             if ([cell isDisplayingHit:hit]){
                                 cell.hitForDisplay = hit;
                                 [cell setNeedsLayout];
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
    if ((self.hits.count - indexPath.row <= UNVIEWED_HITS_BEFORE_REQUEST) && (!self.isWaitingForHits)){
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

-(void)cellApproveAction {
    ANRHit *hit = [self.hits objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    [self.serverHandler approveHit:hit postImmediately:YES];
    [self.hits removeObject:hit];
    [self.tableView deleteRowsAtIndexPaths:@[self.tableView.indexPathForSelectedRow] withRowAnimation:UITableViewRowAnimationRight];
    
//    NSLog(@"approve action");
//    ANRHitCell * cell = (ANRHitCell*)[self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
//    [cell showActivityIndicator:YES];
//    Hit *hit = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
//        [self.serverHandler postHit:hit];

}

-(void)cellRejectAction {
    ANRHit *hit = [self.hits objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    [self.serverHandler addHitToBlacklist:hit];
    [self.hits removeObject:hit];
    [self.tableView deleteRowsAtIndexPaths:@[self.tableView.indexPathForSelectedRow] withRowAnimation:UITableViewRowAnimationRight];
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
