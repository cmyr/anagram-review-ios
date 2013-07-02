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
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

#define DROPDOWN_VIEW_HEIGHT 44.0
//-(id)initForScreen{
////    assigns a frame based on screen size
////    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
////    CGRect viewRect = CGRectMake(0, -DROPDOWN_VIEW_HEIGHT,
////                          screenRect.size.width,
////                          DROPDOWN_VIEW_HEIGHT);
////    self.backgroundColor = [UIColor whiteColor];
////    return [self initWithFrame:viewRect];
//}

-(UILabel*)notificationLabel{
    if (!_notificationLabel) {
        _notificationLabel = [[UILabel alloc]init];
        _notificationLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _notificationLabel.font = [UIFont systemFontOfSize:14.0];
        [self addSubview:_notificationLabel];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_notificationLabel]-8-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_notificationLabel)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_notificationLabel(>=14)]-8-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_notificationLabel)]];
    }
    return _notificationLabel;
}

-(void)setNotification:(NSString *)notification{
    _notification = notification;
    self.notificationLabel.text = notification;
//    [self.notificationLabel sizeToFit];
//    self.notificationLabel.backgroundColor = [UIColor orangeColor];
}

//-(void)showIndefiniteNotification:(NSString *)notification{
//    self.notification = notification;
//    self.isActive = YES;
//}

-(void)showNotification:(NSString *)notification autohide:(float)seconds{
    self.notification = notification;
    self.isActive = YES;
    self.hidden = NO;
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.frame = CGRectMake(0, 0,
                                                 self.frame.size.width,
                                                 self.frame.size.height);
                     } completion:^(BOOL finished) {
                         if (seconds)
                             [self performSelector:@selector(hideNotification) withObject:nil afterDelay:seconds];
                     }];
}

-(void)hideNotification{
    [UIView animateWithDuration:0.5
                          delay:5.0
                        options:0
                     animations:^{
                         self.frame = CGRectMake(0,
                                                 -self.frame.size.height,
                                                 self.frame.size.width,
                                                 self.frame.size.height);
                     } completion:^(BOOL finished) {
                         self.isActive = NO;
                         self.hidden = YES;
                     }];
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
