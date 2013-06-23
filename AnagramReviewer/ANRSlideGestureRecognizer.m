//
//  ANRSlideGestureRecognizer.m
//  AnagramReviewer
//
//  Created by Colin Rothfels on 2013-06-22.
//  Copyright (c) 2013 cmyr. All rights reserved.
//

#import "ANRSlideGestureRecognizer.h"

@implementation ANRSlideGestureRecognizer
{
    CGPoint _startPoint;
}

#define DEFAULT_GESTURE_SUCCESS_LENGTH 50.0

-(NSNumber*)gestureSuccessLength {
    if (!_gestureSuccessLength) _gestureSuccessLength = @(DEFAULT_GESTURE_SUCCESS_LENGTH);
    return _gestureSuccessLength;
}

-(void)reset
{
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if ([touches count] != 1) {
        self.state = UIGestureRecognizerStateFailed;
    }
    _startPoint = [[touches anyObject]locationInView:[self.view window]];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    if (self.state == UIGestureRecognizerStateFailed) return;
    CGPoint point = [[touches anyObject]locationInView:[self.view window]];
    if (point.x > _startPoint.x){
     self.state = UIGestureRecognizerStateFailed;
    }else if (point.x < _startPoint.x){
        self.gestureLength = _startPoint.x - point.x;
        self.state = UIGestureRecognizerStatePossible;
    }
    
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if (self.state == UIGestureRecognizerStateFailed) return;
    CGPoint point = [[touches anyObject]locationInView:[self.view window]];
    if (point.x > _startPoint.x){
        self.state = UIGestureRecognizerStateFailed;
    }else if (point.x < _startPoint.x){
        self.gestureLength = _startPoint.x - point.x;
        if (self.gestureLength >= [self.gestureSuccessLength floatValue]){
            self.state = UIGestureRecognizerStateRecognized;
        }
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    _startPoint = CGPointZero;
    self.state = UIGestureRecognizerStateFailed;
}
@end
