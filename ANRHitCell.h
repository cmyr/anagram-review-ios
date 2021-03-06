//
//  ANRHitCell.h
//  AnagramReviewer
//
//  Created by Colin Rothfels on 2013-06-22.
//  Copyright (c) 2013 cmyr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANRHit.h"

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


@property (strong, nonatomic) UIButton *approveButton;
@property (strong, nonatomic) UIButton *rejectButton;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (nonatomic) BOOL hasMoved;

@property (strong, nonatomic) ANRHit *hitForDisplay;

-(BOOL)isDisplayingHit:(ANRHit*)hit;
-(void)showButtons;
-(void)hideButtons;
-(void)setPropertiesFromHit:(ANRHit*)hit;
-(void)showActivityIndicator:(BOOL)show;
//call to reset some drawing properties that might've been changed;
-(void)reset;
//dynamic behaviors

-(void)snapToPlace;
-(void)resetDynamics;
@end
