//
//  ANRNewTableVC.h
//  AnagramReviewer
//
//  Created by Colin Rothfels on 2013-07-19.
//  Copyright (c) 2013 cmyr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANRServerHandler.h"
@interface ANRNewTableVC : UIViewController <ANRServerDelegateProtocol, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *displaySelectionControl;
//@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

- (IBAction)refreshAction:(UIButton *)sender;
- (IBAction)selectionControlAction:(UISegmentedControl *)sender;
//- (IBAction)updateInfoButton:(UIButton *)sender;
//@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
