//
//  AGNotificationDropDownView.m
//  Anagrammarian
//
//  Created by Colin Rothfels on 2013-06-12.
//  Copyright (c) 2013 cmyr. All rights reserved.
//

#import "ANRNotificationDropDownView.h"
@interface ANRNotificationDropDownView ()
@property (strong, nonatomic) NSString* notification;
@property (strong, nonatomic) UIActivityIndicatorView* activityIndicator;
@property (strong, nonatomic) UILabel *notificationLabel;
@end

@implementation ANRNotificationDropDownView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#define DROPDOWN_VIEW_HEIGHT 56.0
-(id)initForScreen{
//    assigns a frame based on screen size
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    CGRect viewRect = CGRectMake(0, -DROPDOWN_VIEW_HEIGHT,
                          screenRect.size.width,
                          DROPDOWN_VIEW_HEIGHT);
    return [self initWithFrame:viewRect];
}
-(void)setupViews{
    UILabel *notificationLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    notificationLabel.font = [UIFont systemFontOfSize:14.0];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[notificationLabel]-8-"
                                                                options:0
                                                                metrics:nil
                                                                  views:NSDictionaryOfVariableBindings(notificationLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[notificationLabel(>=14)]-8-"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(notificationLabel)]];
}

-(void)setNotification:(NSString *)notification{
    _notification = notification;
    self.notificationLabel.text = notification;
    [self.notificationLabel sizeToFit];
}

-(void)showIndefiniteNotification:(NSString *)notification{
    
}

-(void)showNotification:(NSString *)notification autohide:(BOOL)hide{
    self.notification = notification;
    self.isActive = YES;
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.frame = CGRectMake(0, 0,
                                                 self.frame.size.width,
                                                 self.frame.size.height);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.5
                                               delay:5.0
                                             options:0
                                          animations:^{
                                              self.frame = CGRectMake(0,
                                                                      -DROPDOWN_VIEW_HEIGHT,
                                                                      self.frame.size.width,
                                                                      self.frame.size.height);
                                       } completion:^(BOOL finished) {
                                           self.isActive = NO;
                                       }];}];
}

-(void)hideNotification{
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
