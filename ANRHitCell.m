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
    
//    create the view for the bottom buttons;
    UIView *underView = [[UIView alloc]init];
    underView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView setClipsToBounds:YES];
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
    [underView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[approveButton][rejectButton]|"
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

    
    approveButton.backgroundColor = [UIColor greenColor];
    rejectButton.backgroundColor = [UIColor redColor];
    
//    round corners on profile picture imageviews;
    [self.profileImageOne.layer setCornerRadius:5.0];
    [self.profileImageTwo.layer setCornerRadius:5.0];
    [self.profileImageOne.layer setMasksToBounds:YES];
    [self.profileImageTwo.layer setMasksToBounds:YES];

//    UIButton *b1, *b2;
//    b1 = [UIButton buttonWithType:UIButtonTypeSystem];
//    b2 = [UIButton buttonWithType:UIButtonTypeSystem];
//    b1.backgroundColor = [UIColor greenColor];
//    b2.backgroundColor = [UIColor redColor];
//    b1.translatesAutoresizingMaskIntoConstraints = NO;
//    b2.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.contentView insertSubview:b1 belowSubview:self.tweetContainer];
//    [self.contentView insertSubview:b2 belowSubview:self.tweetContainer];
//    
//    UIView *t1 = self.tweetOne;
//    UIView *t2 = self.tweetTwo;
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[b1(==t1)]-(>=0)-[b2(==t2)]|"
//                                                                 options:0
//                                                                 metrics:nil
//                                                                   views:NSDictionaryOfVariableBindings(b1,b2,t1,t2)]];
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[b1(80)]|"
//                                                                 options:0
//                                                                 metrics:nil
//                                                                   views:NSDictionaryOfVariableBindings(b1)]];
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[b2(==b1)]|"
//                                                                 options:0
//                                                                 metrics:nil
//                                                                   views:NSDictionaryOfVariableBindings(b1,b2)]];
    

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

-(void)resetDynamics {
    [self.dynamicAnimator removeAllBehaviors];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
#pragma mark - button actions

-(void)showButtons {
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.tweetContainer.frame = CGRectMake(0,
                                                                -(self.tweetContainer.frame.size.height - 20),
                                                                self.tweetContainer.frame.size.width,
                                                                self.tweetContainer.frame.size.height);
                     } completion:^(BOOL finished) {
//                         chill
                     }];
}

-(void)hideButtons {
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.tweetContainer.frame = CGRectMake(0,
                                                                0,
                                                                self.tweetContainer.frame.size.width,
                                                                self.tweetContainer.frame.size.height);
                     } completion:^(BOOL finished) {
                         //                         chill
                     }];
}

@end
