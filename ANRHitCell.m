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
        [self configureSubviews];
    }
    return self;
}

-(void)configureSubviews {
//    round corners on profile picture imageviews;
    [self.profileImageOne.layer setCornerRadius:5.0];
    [self.profileImageTwo.layer setCornerRadius:5.0];
    [self.profileImageOne.layer setMasksToBounds:YES];
    [self.profileImageTwo.layer setMasksToBounds:YES];


}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
