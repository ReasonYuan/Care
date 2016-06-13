/*
 * MGSwipeTableCell is licensed under MIT licensed. See LICENSE.md file for more information.
 * Copyright (c) 2014 Imanol Fernandez @MortimerGoro
 */

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import "MGSwipeButton.h"

@class MGSwipeTableCell;

@implementation MGSwipeButton

+(instancetype) buttonWithTitle:(NSString *) title backgroundColor:(UIColor *) color
{
    return [MGSwipeButton buttonWithTitle:title icon:nil backgroundColor:color];
}

+(instancetype) buttonWithTitle:(NSString *) title backgroundColor:(UIColor *) color callback:(MGSwipeButtonCallback) callback
{
    return [MGSwipeButton buttonWithTitle:title icon:nil backgroundColor:color callback:callback];
}

+(instancetype) buttonWithTitle:(NSString *) title icon:(UIImage*) icon backgroundColor:(UIColor *) color
{
    return [MGSwipeButton buttonWithTitle:title icon:icon backgroundColor:color callback:nil];
}

+(instancetype) buttonWithTitle:(NSString *) title icon:(UIImage*) icon backgroundColor:(UIColor *) color callback:(MGSwipeButtonCallback) callback
{
    MGSwipeButton * button = [MGSwipeButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = color;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setImage:icon forState:UIControlStateNormal];
    button.callback = callback;
    button.titleLabel.numberOfLines = 0;
    [button sizeToFit];
    [button.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    CGRect frame = button.frame;
    frame.size.width += 10; //padding
    frame.size.width = MAX(50, frame.size.width); //initial min size
    button.frame = frame;
    return button;
}

-(BOOL) callMGSwipeConvenienceCallback: (MGSwipeTableCell *) sender
{
    if (_callback) {
        return _callback(sender);
    }
    return NO;
}

@end
