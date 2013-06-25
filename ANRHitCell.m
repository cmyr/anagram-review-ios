//
//  ANRHitCell.m
//  AnagramReviewer
//
//  Created by Colin Rothfels on 2013-06-22.
//  Copyright (c) 2013 cmyr. All rights reserved.
//

#import "ANRHitCell.h"
#import <QuartzCore/QuartzCore.h>

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

-(void)configureSubviews {
//    round corners on profile picture imageviews;
    [self.profileImageOne.layer setCornerRadius:5.0];
    [self.profileImageTwo.layer setCornerRadius:5.0];
    [self.profileImageOne.layer setMasksToBounds:YES];
    [self.profileImageTwo.layer setMasksToBounds:YES];

    UIButton *b1, *b2;
    b1 = [UIButton buttonWithType:UIButtonTypeSystem];
    b2 = [UIButton buttonWithType:UIButtonTypeSystem];
    b1.backgroundColor = [UIColor greenColor];
    b2.backgroundColor = [UIColor redColor];
    b1.translatesAutoresizingMaskIntoConstraints = NO;
    b2.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView insertSubview:b1 belowSubview:self.tweetContainer];
    [self.contentView insertSubview:b2 belowSubview:self.tweetContainer];
    
    UIView *t1 = self.tweetOne;
    UIView *t2 = self.tweetTwo;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[b1(==t1)]-(>=0)-[b2(==t2)]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(b1,b2,t1,t2)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[b1(80)]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(b1)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[b2(==b1)]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(b1,b2)]];
    
    
// add the button views;
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
