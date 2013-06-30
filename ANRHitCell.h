//
//  ANRHitCell.h
//  AnagramReviewer
//
//  Created by Colin Rothfels on 2013-06-22.
//  Copyright (c) 2013 cmyr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ANRHitCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *tweetContainer;
@property (weak, nonatomic) IBOutlet UIView *tweetOne;
@property (weak, nonatomic) IBOutlet UIView *tweetTwo;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageOne;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageTwo;
@property (weak, nonatomic) IBOutlet UILabel *nameOne;
@property (weak, nonatomic) IBOutlet UILabel *nameTwo;
@property (weak, nonatomic) IBOutlet UILabel *screenNameOne;
@property (weak, nonatomic) IBOutlet UILabel *screenNameTwo;
@property (weak, nonatomic) IBOutlet UILabel *tweetTextOne;
@property (weak, nonatomic) IBOutlet UILabel *tweetTextTwo;
@property (weak, nonatomic) IBOutlet UILabel *warningOne;
@property (weak, nonatomic) IBOutlet UILabel *warningTwo;


@property (strong, nonatomic) UIButton *topButton;
@property (strong, nonatomic) UIButton *bottomButton;

@property (nonatomic) BOOL hasMoved;


-(void)showButtons;
-(void)hideButtons;

//dynamic behaviors

-(void)snapToPlace;
-(void)resetDynamics;
@end
