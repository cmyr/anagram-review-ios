//
//  ANRHitCell.m
//  AnagramReviewer
//
//  Created by Colin Rothfels on 2013-06-22.
//  Copyright (c) 2013 cmyr. All rights reserved.
//

#import "ANRHitCell.h"
#import "ANRTweet.h"
#import <QuartzCore/QuartzCore.h>

@interface ANRHitCell()
@property (strong, nonatomic) UIDynamicAnimator *dynamicAnimator;
@property (strong, nonatomic) UIAttachmentBehavior *tweetViewAnchor;
@property (strong, nonatomic) UISnapBehavior *tweetViewSnap;
@property (nonatomic) BOOL isObservingTweetOne;
@property (nonatomic) BOOL isObservingTweetTwo;
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
}
#define PROFILE_IMAGE_KEY @"profile_img"
static int oneObservanceContext;
static int twoObservanceContext;
-(void)setHitForDisplay:(ANRHit *)hitForDisplay {
    if (self.isObservingTweetOne) {
        [_hitForDisplay.tweet1 removeObserver:self forKeyPath:PROFILE_IMAGE_KEY context:&oneObservanceContext];
        self.isObservingTweetOne = NO;
    }
    if (self.isObservingTweetTwo) {
        [_hitForDisplay.tweet2 removeObserver:self forKeyPath:PROFILE_IMAGE_KEY context:&twoObservanceContext];
        self.isObservingTweetTwo = NO;
    }


    _hitForDisplay = hitForDisplay;
    [self setPropertiesFromHit:self.hitForDisplay];
}

-(BOOL)isDisplayingHit:(ANRHit *)hit {
    if ([self.hitForDisplay isEqual:hit]){
        return YES;
    }
    return NO;
}

-(void)configureSubviews {
    

    [self.layer setMasksToBounds:YES];
    [self.tweetOne.layer setShadowColor:[[UIColor grayColor]CGColor]];
    [self.tweetOne.layer setShadowRadius:1.0];
    [self.tweetOne.layer setShadowOpacity:0.5];
    [self.tweetOne.layer setShadowOffset:CGSizeMake(0, 1.0)];

    [self.tweetTwo.layer setShadowColor:[[UIColor grayColor]CGColor]];
    [self.tweetTwo.layer setShadowRadius:1.0];
    [self.tweetTwo.layer setShadowOpacity:0.5];
    [self.tweetTwo.layer setShadowOffset:CGSizeMake(0, -1.0)];

    [self.tweetTwo.layer setMasksToBounds:YES];

    //    create the view for the bottom buttons;
    UIView *underView = [[UIView alloc]init];
    underView.translatesAutoresizingMaskIntoConstraints = NO;
    underView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    
    UIButton *approveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *rejectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    approveButton.translatesAutoresizingMaskIntoConstraints = NO;
    rejectButton.translatesAutoresizingMaskIntoConstraints = NO;
    [approveButton setImage:[UIImage imageNamed:@"check64"] forState:UIControlStateNormal];
    [rejectButton setImage:[UIImage imageNamed:@"cross64"] forState:UIControlStateNormal];
    approveButton.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1.0];//[[UIColor greenColor]colorWithAlphaComponent:0.2];
    rejectButton.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1.0];//[[UIColor redColor]colorWithAlphaComponent:0.2];
    [underView addSubview:approveButton];
    [underView addSubview:rejectButton];
//    underView.tintColor = [UIColor blackColor];
    self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [underView addSubview:self.activityIndicator];
    [underView addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:underView
                                                          attribute:NSLayoutAttributeCenterX multiplier:1.0
                                                           constant:0.0]];
    [underView addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:underView
                                                          attribute:NSLayoutAttributeCenterY multiplier:1.0
                                                           constant:0.0]];
    
     
    
//    button actions to show touch events:
    [approveButton addTarget:self action:@selector(approveButtonDown) forControlEvents:UIControlEventTouchDown];
    [approveButton addTarget:self action:@selector(approveButtonUp) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [rejectButton addTarget:self action:@selector(rejectButtonDown) forControlEvents:UIControlEventTouchDown];
    [rejectButton addTarget:self action:@selector(rejectButtonUp) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];

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

    self.approveButton = approveButton;
    self.rejectButton = rejectButton;
    
//    round corners on profile picture imageviews;
    [self.profileImageOne.layer setCornerRadius:5.0];
    [self.profileImageTwo.layer setCornerRadius:5.0];
    [self.profileImageOne.layer setMasksToBounds:YES];
    [self.profileImageTwo.layer setMasksToBounds:YES];   

// add the button views;
    
}


-(void)setPropertiesFromHit:(ANRHit*)hit{
    if (1) {
        self.warningOne.hidden = YES;
        self.tweetTextOne.text = hit.tweet1.text;
        self.nameOne.text = hit.tweet1.username;
        self.screenNameOne.text = hit.tweet1.screenname;
        if (self.hitForDisplay.tweet1.error) {
            self.warningOne.hidden = NO;
        }
        if (hit.tweet1.profile_img){
            self.profileImageOne.image = hit.tweet1.profile_img;
        }else{
            [hit.tweet1 addObserver:self
                         forKeyPath:PROFILE_IMAGE_KEY
                            options:NSKeyValueObservingOptionNew
                            context:&oneObservanceContext];
            self.isObservingTweetOne = YES;
        }

    }

    if (1) {
        self.warningTwo.hidden = YES;
        self.tweetTextTwo.text = hit.tweet2.text;
        self.nameTwo.text = hit.tweet2.username;
        self.screenNameTwo.text = hit.tweet2.screenname;
        if (self.hitForDisplay.tweet2.error) {
            self.warningTwo.hidden = NO;
        }
        if (hit.tweet2.profile_img){
            self.profileImageTwo.image = hit.tweet2.profile_img;
        }else{
            [hit.tweet2 addObserver:self
                         forKeyPath:PROFILE_IMAGE_KEY
                            options:NSKeyValueObservingOptionNew
                            context:&twoObservanceContext];
            self.isObservingTweetTwo = YES;
        }
        
    }

    
    
}

-(void)snapToPlace {
    [self.dynamicAnimator addBehavior:self.tweetViewSnap];
}

-(void)reset {
    self.tweetTwo.layer.masksToBounds = YES;
    self.tweetContainer.userInteractionEnabled = YES;
    [self showActivityIndicator:NO];
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
-(void)approveButtonDown {
    self.approveButton.backgroundColor = [UIColor whiteColor];
}

-(void)rejectButtonDown {
    self.rejectButton.backgroundColor = [UIColor whiteColor];
}

-(void)approveButtonUp {
     self.approveButton.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1.0];
}

-(void)rejectButtonUp {
     self.rejectButton.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1.0];
}

-(void)showActivityIndicator:(BOOL)show {
    if (show){
        [UIView animateWithDuration:0.3 animations:^{
            self.approveButton.alpha = 0.0;
            self.rejectButton.alpha = 0.0;
        }];
        [self.activityIndicator startAnimating];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            self.approveButton.alpha = 1.0;
            self.rejectButton.alpha = 1.0;
        }];
        [self.activityIndicator stopAnimating];
    }
}

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

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isEqual:self.hitForDisplay.tweet1]) {
        self.profileImageOne.image = [object valueForKey:PROFILE_IMAGE_KEY];
    }else if ([object isEqual:self.hitForDisplay.tweet2]) {
        self.profileImageTwo.image = [object valueForKey:PROFILE_IMAGE_KEY];
    }
}

@end
