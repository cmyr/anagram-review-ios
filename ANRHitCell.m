//
//  ANRHitCell.m
//  AnagramReviewer
//
//  Created by Colin Rothfels on 2013-06-22.
//  Copyright (c) 2013 cmyr. All rights reserved.
//

#import "ANRHitCell.h"
#import <QuartzCore/QuartzCore.h>

@interface ANRHitCell()
@property (strong, nonatomic) UIDynamicAnimator *dynamicAnimator;
@property (strong, nonatomic) UIAttachmentBehavior *tweetViewAnchor;
@property (strong, nonatomic) UISnapBehavior *tweetViewSnap;
@end
@implementation ANRHitCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // ...
    }
    return self;
}


-(void)awakeFromNib {
    [self configureSubviews];
//    [self configureDynamics];
}

//-(void)setHasMoved:(BOOL)hasMoved
//{
////    we'll use this to add and remove our attachment behaviour
//    _hasMoved = hasMoved;
//    if (self.hasMoved){
////        [self.dynamicAnimator addBehavior:self.tweetViewAnchor];
//        UISnapBehavior *tweetSnap = [[UISnapBehavior alloc]initWithItem:self.tweetContainer
//                                                            snapToPoint:self.dynamicAnimator.referenceView.center];
//    }else{
//        [self.dynamicAnimator removeBehavior:self.tweetViewAnchor];
//    }
//}

-(void)configureSubviews {
    

    [self.layer setMasksToBounds:YES];
    [self.tweetOne.layer setShadowColor:[[UIColor blackColor]CGColor]];
    [self.tweetOne.layer setShadowRadius:1.0];
    [self.tweetOne.layer setShadowOpacity:0.5];
    [self.tweetOne.layer setShadowOffset:CGSizeMake(0, 2.0)];

    [self.tweetTwo.layer setShadowColor:[[UIColor blackColor]CGColor]];
    [self.tweetTwo.layer setShadowRadius:1.0];
    [self.tweetTwo.layer setShadowOpacity:0.5];
    [self.tweetTwo.layer setShadowOffset:CGSizeMake(0, -2.0)];

    [self.tweetTwo.layer setMasksToBounds:YES];

    //    create the view for the bottom buttons;
    UIView *underView = [[UIView alloc]init];
    underView.translatesAutoresizingMaskIntoConstraints = NO;
    underView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    
    UIButton *approveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIButton *rejectButton = [UIButton buttonWithType:UIButtonTypeSystem];
    approveButton.translatesAutoresizingMaskIntoConstraints = NO;
    rejectButton.translatesAutoresizingMaskIntoConstraints = NO;
    [underView addSubview:approveButton];
    [underView addSubview:rejectButton];

    [self.contentView insertSubview:underView belowSubview:self.tweetContainer];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[underView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(underView)]];
    [underView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[approveButton(==rejectButton)][rejectButton]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(approveButton, rejectButton)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[underView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(underView)]];
    [underView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[approveButton]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(approveButton)]];
    [underView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[rejectButton]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(rejectButton)]];

    
    approveButton.backgroundColor = [[UIColor greenColor]colorWithAlphaComponent:0.2];
    rejectButton.backgroundColor = [[UIColor redColor]colorWithAlphaComponent:0.2];
    self.approveButton = approveButton;
    self.rejectButton = rejectButton;
    
//    round corners on profile picture imageviews;
    [self.profileImageOne.layer setCornerRadius:5.0];
    [self.profileImageTwo.layer setCornerRadius:5.0];
    [self.profileImageOne.layer setMasksToBounds:YES];
    [self.profileImageTwo.layer setMasksToBounds:YES];   

// add the button views;
    
}

//-(void)configureDynamics {
//    self.dynamicAnimator = [[UIDynamicAnimator alloc]initWithReferenceView:self.contentView];
//    self.tweetViewSnap = [[UISnapBehavior alloc]initWithItem:self.tweetContainer
//                                                        snapToPoint:self.dynamicAnimator.referenceView.center];

//    self.tweetViewAnchor = [[UIAttachmentBehavior alloc]initWithItem:self.tweetContainer
//                                                               point:CGPointMake(self.frame.size.width -1, self.frame.size.height/2)
//                                                    attachedToAnchor:CGPointMake(self.contentView.frame.size.width -1, self.contentView.frame.size.height/2)];
    
    
//    [self.dynamicAnimator addBehavior:self.tweetViewAnchor];
//}

-(void)snapToPlace {
    [self.dynamicAnimator addBehavior:self.tweetViewSnap];
}

-(void)reset {
    self.tweetTwo.layer.masksToBounds = YES;
    self.tweetContainer.userInteractionEnabled = YES;
}
-(void)resetDynamics {
    [self.dynamicAnimator removeAllBehaviors];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
#pragma mark - button actions

#define TWEET_VIEW_OVERHANG 10.0
-(void)showButtons {
    self.tweetContainer.backgroundColor = [UIColor clearColor];
    self.tweetContainer.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.tweetOne.frame = CGRectMake(0,
                                                          -(self.tweetOne.frame.size.height - TWEET_VIEW_OVERHANG),
                                                          self.tweetOne.frame.size.width,
                                                          self.tweetOne.frame.size.height);
                         self.tweetTwo.frame = CGRectMake(0,
                                                          (self.tweetContainer.frame.size.height - TWEET_VIEW_OVERHANG),
                                                          self.tweetTwo.frame.size.width,
                                                          self.tweetTwo.frame.size.height);
                         self.tweetTwo.layer.masksToBounds = NO;
                     } completion:^(BOOL finished) {
//                         self.tweetContainer.frame = CGRectMake(0,
//                                                                -(self.tweetContainer.frame.size.height - TWEET_VIEW_OVERHANG),
//                                                                self.tweetContainer.frame.size.width,
//                                                                self.tweetContainer.frame.size.height);

                     }];
}

-(void)hideButtons {
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.tweetOne.frame = CGRectMake(0,
                                                          0,
                                                          self.tweetOne.frame.size.width,
                                                          self.tweetOne.frame.size.height);
                         self.tweetTwo.frame = CGRectMake(0,
                                                          (self.tweetOne.frame.size.height + 1.0),
                                                          self.tweetTwo.frame.size.width,
                                                          self.tweetTwo.frame.size.height);
                     } completion:^(BOOL finished) {
                         self.tweetContainer.userInteractionEnabled = YES;
                         self.tweetTwo.layer.masksToBounds = YES;
//                         self.tweetContainer.frame = CGRectMake(0,
//                                                                0,
//                                                                self.tweetContainer.frame.size.width,
//                                                                self.tweetContainer.frame.size.height);
                     }];
}

@end
