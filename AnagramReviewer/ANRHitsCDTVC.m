//
//  ANRHitsCDVC.m
//  AnagramReviewer
//
//  Created by Colin Rothfels on 2013-06-17.
//  Copyright (c) 2013 cmyr. All rights reserved.
//

#import "ANRHitsCDTVC.h"
#import "ANRHitCell.h"
#import "ANRNotificationDropDownView.h"
#import "ANRSlideGestureRecognizer.h"
#import "Hit+Create.h"
#import "Tweet+Create.h"


#define CELL_REUSE_IDENTIFIER @"Hit"
#define SLIDE_GESTURE_START_KEYPATH @"startPoint"
#define SLIDE_GESTURE_LENGTH_KEYPATH @"gestureLength"

@interface ANRHitsCDTVC ()
@property (nonatomic) BOOL beganUpdates;
@property (strong, nonatomic) ANRServerHandler *serverHandler;
@property (strong, nonatomic) UIImage *placeholderImage;
@property (strong, nonatomic) ANRNotificationDropDownView *notificationView;
@property (nonatomic, weak) ANRHitCell *cellForSlideGesture;
@property (nonatomic) BOOL slideGestureInProgress;
@end

@implementation ANRHitsCDTVC

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.managedObjectContext) [self loadDocument];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"hitCellView" bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:CELL_REUSE_IDENTIFIER];
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor grayColor];
//    ANRSlideGestureRecognizer *gr = [[ANRSlideGestureRecognizer alloc]initWithTarget:self
//                                                                            action:@selector(respondToSlideGesture:)];
//                                    [self.view addGestureRecognizer:gr];
//    gr.delegate = self;
    
//    set up our drop-down view;
    self.notificationView = [[ANRNotificationDropDownView alloc]initForScreen];
    self.notificationView.backgroundColor = [UIColor orangeColor];
    self.notificationView.dynamicAnimator = [[UIDynamicAnimator alloc]initWithReferenceView:self.view];
    [self.notificationView.dynamicAnimator addBehavior:[[UIGravityBehavior alloc]initWithItems:@[self.notificationView]]];
    UICollisionBehavior *collision = [[UICollisionBehavior alloc]initWithItems:@[self.notificationView]];
    [collision addBoundaryWithIdentifier:@"boundary" fromPoint:CGPointMake(0, self.notificationView.frame.size.height) toPoint:CGPointMake(self.view.frame.size.width, self.notificationView.frame.size.height)];
    [self.notificationView.dynamicAnimator addBehavior:collision];
    
    [self.view addSubview:self.notificationView];
    [self.notificationView showIndefiniteNotification:@"PLEEEAAASSEE"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(ANRServerHandler*)serverHandler {
    if (!_serverHandler) _serverHandler = [[ANRServerHandler alloc]init];
    _serverHandler.delegate = self;
    return _serverHandler;
}

-(UIImage*)placeholderImage {
    if (!_placeholderImage) _placeholderImage = [UIImage imageNamed:@"missingprofile"];
    return _placeholderImage;
}

-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    if (managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Hit"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"status" ascending:YES]];
        request.predicate = nil;
        self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:@"status" cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}


-(void)fetchHits
{
    [self.serverHandler requestHits];
#warning network activity disabled for debug
}

#define DOCUMENT_NAME @"hitsfile"

-(void)loadDocument{
    NSURL *url = [[[NSFileManager defaultManager]URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]lastObject];
    url = [url URLByAppendingPathComponent:DOCUMENT_NAME];
    UIManagedDocument *document = [[UIManagedDocument alloc]initWithFileURL:url];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]){
//        create
        [document saveToURL:url
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              if (success){
                  self.managedObjectContext = document.managedObjectContext;
                  [self fetchHits];
              }else{
                  NSLog(@"failed to open document?");
              }
          }];
    }else if (document.documentState == UIDocumentStateClosed) {
        [document openWithCompletionHandler:^(BOOL success) {
            if (success){
                self.managedObjectContext = document.managedObjectContext;
                [self fetchHits];
            }
        }];
    }else {
        self.managedObjectContext = document.managedObjectContext;
        [self fetchHits];
        
    }
}

#pragma mark - hit server delegate methods
-(void)AGServerDid:(BOOL)successFlag updateStatusForHit:(NSDictionary *)hit
{
    
}

-(void)AGServerRetrievedHits:(NSArray *)hits
{
    for (NSDictionary *hit in hits)
    {
        [Hit hitWithServerInfo:hit inManagedContext:self.managedObjectContext];
    }
}

-(void)AGServerFailedWithError:(NSError *)error
{
    NSLog(@"AGServer failed with error: %@", error);
}
#pragma mark - handling touches

#define MIN_GESTURE_LENGTH 10.0
-(void)respondToSlideGesture:(UIGestureRecognizer*)gesture {
    ANRSlideGestureRecognizer *slideGesture = (ANRSlideGestureRecognizer*)gesture;
    if (slideGesture.state == UIGestureRecognizerStateBegan){
        CGPoint startPoint = [slideGesture locationInView:self.tableView];
        self.cellForSlideGesture = (ANRHitCell*)[self.tableView cellForRowAtIndexPath:
                                                 [self.tableView indexPathForRowAtPoint:startPoint]];
    }
    if (slideGesture.state == UIGestureRecognizerStateChanged)
    {
        NSLog(@"gesture state changed %f", slideGesture.gestureLength);
        if (slideGesture.gestureLength > MIN_GESTURE_LENGTH)
            self.slideGestureInProgress = YES;

        if (self.slideGestureInProgress) {
            [UIView animateWithDuration:0.01
                                  delay:0.0
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 self.cellForSlideGesture.tweetContainer.frame = CGRectMake(0 - slideGesture.gestureLength,
                                                                                            self.cellForSlideGesture.tweetContainer.frame.origin.y,
                                                                                            self.cellForSlideGesture.tweetContainer.frame.size.width,
                                                                                            self.cellForSlideGesture.tweetContainer.frame.size.height);
                             } completion:^(BOOL finished) {
                                 self.cellForSlideGesture.hasMoved = YES;
                             }];
        }
    }
    if (slideGesture.state == UIGestureRecognizerStateEnded) {
        NSLog(@"gesture state ended");
        [self.cellForSlideGesture snapToPlace];
        self.cellForSlideGesture = nil;
        self.slideGestureInProgress = NO;
//        self.cellForSlideGesture.hasMoved = NO;
    }
    
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - Fetching

- (void)performFetch
{
    if (self.fetchedResultsController) {
        if (self.fetchedResultsController.fetchRequest.predicate) {
            if (self.debug) NSLog(@"[%@ %@] fetching %@ with predicate: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.fetchedResultsController.fetchRequest.entityName, self.fetchedResultsController.fetchRequest.predicate);
        } else {
            if (self.debug) NSLog(@"[%@ %@] fetching all %@ (i.e., no predicate)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.fetchedResultsController.fetchRequest.entityName);
        }
        NSError *error;
        [self.fetchedResultsController performFetch:&error];
        if (error) NSLog(@"[%@ %@] %@ (%@)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription], [error localizedFailureReason]);
    } else {
        if (self.debug) NSLog(@"[%@ %@] no NSFetchedResultsController (yet?)", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    }
    [self.tableView reloadData];
}

- (void)setFetchedResultsController:(NSFetchedResultsController *)newfrc
{
    NSFetchedResultsController *oldfrc = _fetchedResultsController;
    if (newfrc != oldfrc) {
        _fetchedResultsController = newfrc;
        newfrc.delegate = self;
        if ((!self.title || [self.title isEqualToString:oldfrc.fetchRequest.entity.name]) && (!self.navigationController || !self.navigationItem.title)) {
            self.title = newfrc.fetchRequest.entity.name;
        }
        if (newfrc) {
            if (self.debug) NSLog(@"[%@ %@] %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), oldfrc ? @"updated" : @"set");
            [self performFetch];
        } else {
            if (self.debug) NSLog(@"[%@ %@] reset to nil", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
            [self.tableView reloadData];
        }
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext) {
        [self.tableView beginUpdates];
        self.beganUpdates = YES;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type
{
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext)
    {
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext)
    {
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeUpdate:
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeMove:
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (self.beganUpdates) [self.tableView endUpdates];
}

- (void)endSuspensionOfUpdatesDueToContextChanges
{
    _suspendAutomaticTrackingOfChangesInManagedObjectContext = NO;
}

- (void)setSuspendAutomaticTrackingOfChangesInManagedObjectContext:(BOOL)suspend
{
    if (suspend) {
        _suspendAutomaticTrackingOfChangesInManagedObjectContext = YES;
    } else {
        [self performSelector:@selector(endSuspensionOfUpdatesDueToContextChanges) withObject:0 afterDelay:0];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 141.0;
}

#define DEFAULT_CELL_HEIGHT 141.0
#define DEFAULT_CELL_WIDTH  320.0
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = CELL_REUSE_IDENTIFIER;
    ANRHitCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (!cell) {
//        cell = [[ANRHitCell alloc]initWithStyle:UITableViewCellStyleDefault
//                                reuseIdentifier:CellIdentifier];
//    }
    assert([cell isKindOfClass:[ANRHitCell class]]);
    cell.tweetContainer.frame = CGRectMake(0, 0, DEFAULT_CELL_WIDTH, DEFAULT_CELL_HEIGHT);
    [cell resetDynamics];
    Hit *hit = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSArray* tweets = [hit.tweets allObjects];
    Tweet* tweetOne = tweets[0];
    Tweet* tweetTwo = tweets[1];
    
    if (tweetOne.profile_img_url && !tweetOne.profile_img) [tweetOne fetchProfileImage];
    if (tweetTwo.profile_img_url && !tweetTwo.profile_img) [tweetTwo fetchProfileImage];
            
    cell.profileImageOne.image = tweetOne.profile_img ? [UIImage imageWithData:tweetOne.profile_img] : self.placeholderImage;
    cell.nameOne.text = tweetOne.username ;
    cell.screenNameOne.text = tweetOne.screenname ? [@"@" stringByAppendingString:tweetOne.screenname] : nil;
    cell.tweetTextOne.text = tweetOne.text;
    cell.warningOne.hidden = YES;
    if (!tweetOne.username && !tweetOne.screenname) cell.warningOne.hidden = NO;

    cell.profileImageTwo.image = tweetTwo.profile_img ? [UIImage imageWithData:tweetTwo.profile_img] : self.placeholderImage;
    cell.nameTwo.text = tweetTwo.username ;
    cell.screenNameTwo.text = tweetTwo.screenname ? [@"@" stringByAppendingString:tweetTwo.screenname] : nil;
    cell.tweetTextTwo.text = tweetTwo.text;
    cell.warningTwo.hidden = YES;
    if (!tweetTwo.username && !tweetTwo.screenname) cell.warningTwo.hidden = NO;
 
    return cell;
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
