//
//  AGNotificationDropDownView.h
//  Anagrammarian
//
//  Created by Colin Rothfels on 2013-06-12.
//  Copyright (c) 2013 cmyr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ANRNotificationDropDownView : UIView

@property (nonatomic) BOOL isActive;
@property (strong, nonatomic) UIDynamicAnimator *dynamicAnimator;

-(void)showNotification:(NSString*)notification autohide:(float)seconds;
//-(void)showIndefiniteNotification:(NSString*)notification;
-(void)hideNotification;
//-(id)initForScreen;


@end
