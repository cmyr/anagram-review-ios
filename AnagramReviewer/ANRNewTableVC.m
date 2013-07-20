//
//  ANRNewTableVC.m
//  AnagramReviewer
//
//  Created by Colin Rothfels on 2013-07-19.
//  Copyright (c) 2013 cmyr. All rights reserved.
//

#import "ANRNewTableVC.h"
#import "ANRHitCell.h"

@interface ANRNewTableVC ()
@property (strong, nonatomic) NSMutableArray *hits;
@property (strong, nonatomic) ANRServerHandler *serverHandler;
@end

#define CELL_REUSE_IDENTIFIER @"Hit"

@implementation ANRNewTableVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
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

#pragma mark - serverhandler delegate


-(void)ANRServerDidReceiveHits:(NSArray *)hits {
    [self.hits addObjectsFromArray:hits];
    [self.tableView reloadData];
}

-(void)ANRServerFailedWithError:(NSError *)error {
    
}

-(NSUInteger)lastHitID {
    return 0;
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
    [cell setPropertiesFromHit:[self.hits objectAtIndex:indexPath.row]];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 141.0;
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
