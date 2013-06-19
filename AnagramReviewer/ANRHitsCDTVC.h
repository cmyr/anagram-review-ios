//
//  ANRHitsCDVC.h
//  AnagramReviewer
//
//  Created by Colin Rothfels on 2013-06-17.
//  Copyright (c) 2013 cmyr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANRServerHandler.h"

@interface ANRHitsCDTVC : UITableViewController <NSFetchedResultsControllerDelegate, ANRServerDelegateProtocol>
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) BOOL debug;
@property (nonatomic) BOOL suspendAutomaticTrackingOfChangesInManagedObjectContext;

-(void)performFetch;

@end
