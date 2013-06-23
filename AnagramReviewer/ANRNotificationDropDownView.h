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

-(void)showNotification:(NSString*)notification autohide:(BOOL)hide;
-(void)showIndefiniteNotification:(NSString*)notification;
-(void)hideNotification;
-(id)initForScreen;

@end