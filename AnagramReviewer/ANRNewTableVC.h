//
//  ANRNewTableVC.h
//  AnagramReviewer
//
//  Created by Colin Rothfels on 2013-07-19.
//  Copyright (c) 2013 cmyr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANRServerHandler.h"
@interface ANRNewTableVC : UITableViewController <ANRServerDelegateProtocol>
@property (weak, nonatomic) IBOutlet UISegmentedControl *displaySelectionControl;
- (IBAction)selectionControlAction:(UISegmentedControl *)sender;

@end
