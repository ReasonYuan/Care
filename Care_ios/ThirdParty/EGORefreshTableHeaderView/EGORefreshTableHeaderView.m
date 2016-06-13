//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EGORefreshTableHeaderView.h"
#import "Tools.h"

#define FLIP_ANIMATION_DURATION 0.18f


@interface EGORefreshTableHeaderView (Private)

- (void)setState:(EGOPullRefreshState)aState;
@end


@implementation EGORefreshTableHeaderView

@synthesize delegate=_delegate;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor clearColor];
        
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont systemFontOfSize:12.0f];
		label.textColor = [UIColor grayColor];
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		[self addSubview:label];
		_lastUpdatedLabel=label;
		
		label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont boldSystemFontOfSize:13.0f];
		label.textColor = [UIColor grayColor];
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		[self addSubview:label];
		_statusLabel=label;
		
		CALayer *layer = [CALayer layer];
		layer.frame = CGRectMake(25.0f, frame.size.height - 65.0f, 30.0f, 55.0f);
		layer.contentsGravity = kCAGravityResizeAspect;
		layer.contents = (id)[UIImage imageNamed:@"EGORefresh.bundle/grayArrow"].CGImage;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			layer.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
		
		[[self layer] addSublayer:layer];
		_arrowImage=layer;
		
		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		view.frame = CGRectMake(25.0f, frame.size.height - 38.0f, 20.0f, 20.0f);
		[self addSubview:view];
		_activityView = view;
		
		
		[self setState:EGOOPullRefreshNormal];
    }
	
    return self;
}


- (void)adjustPosition {
    CGSize size = _scrollView.frame.size;
    CGPoint center = CGPointZero;
    
    switch (_orientation) {
        case EGOPullOrientationDown:
            center = CGPointMake(size.width/2, 0.0f-size.height/2);
            break;
        case EGOPullOrientationUp:
            center = CGPointMake(size.width/2, _scrollView.contentSize.height+size.height/2);
            break;
        case EGOPullOrientationRight:
            center = CGPointMake(0.0f-size.width/2, size.height/2);
             _statusLabel.frame = CGRectMake(0.0f, size.width - 48.0f, self.frame.size.height, 20.0f);
            _arrowImage.frame =  CGRectMake(25.0f,size.width - 65.0f, 30.0f, 55.0f);
            _activityView.frame = CGRectMake(25.0f, size.width - 38.0f, 20.0f, 20.0f);
            _lastUpdatedLabel.frame = CGRectMake(0.0f, size.width - 30.0f, self.frame.size.height, 20.0f);
            break;
        case EGOPullOrientationLeft:
            center = CGPointMake(_scrollView.contentSize.width+size.width/2, size.height/2);
            _statusLabel.frame = CGRectMake(0.0f, size.width - 48.0f, self.frame.size.height, 20.0f);
            _arrowImage.frame =  CGRectMake(25.0f,size.width - 65.0f, 30.0f, 55.0f);
            _activityView.frame = CGRectMake(25.0f, size.width - 38.0f, 20.0f, 20.0f);
            _lastUpdatedLabel.frame = CGRectMake(0.0f, size.width - 30.0f, self.frame.size.height, 20.0f);
            break;
        default:
            break;
    }
    self.center = center;
}


- (id)initWithScrollView:(UIScrollView* )scrollView orientation:(EGOPullOrientation)orientation {
    CGSize size = scrollView.frame.size;
    CGPoint center = CGPointZero;
    CGFloat degrees = 0.0f;
    
    _orientation = orientation;
    _scrollView = scrollView;
    
    switch (orientation) {
        case EGOPullOrientationDown:
            center = CGPointMake(size.width/2, 0.0f-size.height/2);
            degrees = 0.0f;
            break;
        case EGOPullOrientationUp:
            center = CGPointMake(size.width/2, scrollView.contentSize.height+size.height/2);
            degrees = 180.0f;
            break;
        case EGOPullOrientationRight:
            center = CGPointMake(0.0f-size.width/2, size.height/2);
            size = CGSizeMake(size.height, size.width);
            degrees = -90.0f;
            break;
        case EGOPullOrientationLeft:
            center = CGPointMake(scrollView.contentSize.width+size.width/2, size.height/2);
            size = CGSizeMake(size.height, size.width);
            degrees = 90.0f;
            break;
        default:
            break;
    }
    self = [self initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    if (self) {
        _ScrollViewContentsize = scrollView.contentSize;
        self.transform = CGAffineTransformMakeRotation((degrees * M_PI) / 180.0f);
        self.center = center;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        if (EGOPullOrientationUp == _orientation) {
            _lastUpdatedLabel.transform = CGAffineTransformMakeRotation((degrees * M_PI) / 180.0f);
            _statusLabel.transform = CGAffineTransformMakeRotation((degrees * M_PI) / 180.0f);
        }
        [scrollView addSubview:self];
    }
    [scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"]) {
        NSValue* newValue = [change valueForKey:NSKeyValueChangeNewKey];
        CGSize size;
        [newValue getValue:&size];
        if(!CGSizeEqualToSize(_ScrollViewContentsize, size)){
            _ScrollViewContentsize = size;
            if(!CGSizeEqualToSize(size,CGSizeZero)){
                [Tools Post:^{
                    [self adjustPosition];
                } Delay:.5];
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark -
#pragma mark Setters

- (void)refreshLastUpdatedDate {
	
	if ([self.delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceLastUpdated:)]) {
		
		NSDate *date = [_delegate egoRefreshTableHeaderDataSourceLastUpdated:self];
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setAMSymbol:@"AM"];
		[formatter setPMSymbol:@"PM"];
		[formatter setDateFormat:@"MM/dd/yyyy hh:mm:ss"];
		_lastUpdatedLabel.text = [NSString stringWithFormat:@"Last Updated: %@", [formatter stringFromDate:date]];
		[[NSUserDefaults standardUserDefaults] setObject:_lastUpdatedLabel.text forKey:@"EGORefreshTableView_LastRefresh"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
	} else {
		_lastUpdatedLabel.text = nil;
		
	}
    
}

-(BOOL)isLoading{
    return _state == EGOOPullRefreshLoading;
}

- (void)setState:(EGOPullRefreshState)aState{
    BOOL refresh = (_orientation == EGOPullOrientationDown||_orientation == EGOPullOrientationRight);
     _scrollView.scrollEnabled = YES;
	switch (aState) {
		case EGOOPullRefreshPulling:
             _statusLabel.text = NSLocalizedString(@"拖动刷新数据...", @"Release to refresh status");
			
			[CATransaction begin];
			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
			_arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
			break;
		case EGOOPullRefreshNormal:
			if (_state == EGOOPullRefreshPulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
				_arrowImage.transform = CATransform3DIdentity;
				[CATransaction commit];
			}
			
            _statusLabel.text = NSLocalizedString(@"拖动刷新数据...", @"Release to refresh status");
			
			[_activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			_arrowImage.hidden = NO;
			_arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];
			
			[self refreshLastUpdatedDate];
			break;
		case EGOOPullRefreshLoading:
            _scrollView.scrollEnabled = NO;
			_statusLabel.text = NSLocalizedString(@"正在加载数据...", @"Loading Status");
			[_activityView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			_arrowImage.hidden = YES;
			[CATransaction commit];
			
			break;
		default:
			break;
	}
	
	_state = aState;
}


#pragma mark - ScrollView Methods
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {
	if (_state == EGOOPullRefreshLoading) {
        switch (_orientation) {
            case EGOPullOrientationDown: {
                CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
                offset = MIN(offset, 60);
                scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
                break;
            }
            case EGOPullOrientationUp: {
                CGFloat offset = MAX(scrollView.frame.size.height+scrollView.contentOffset.y-scrollView.contentSize.height, 0);
                offset = MIN(offset, 60);
                scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, offset, 0.0f);
                break;
            }
            case EGOPullOrientationRight: {
                CGFloat offset = MAX(scrollView.contentOffset.x * -1, 0);
                offset = MIN(offset, 60);
                scrollView.contentInset = UIEdgeInsetsMake(0.0f, offset, 0.0f, 0.0f);
                break;
            }
            case EGOPullOrientationLeft: {
                CGFloat offset = MAX(scrollView.frame.size.width+scrollView.contentOffset.x-scrollView.contentSize.width, 0);
                offset = MIN(offset, 60);
                scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, offset);
                break;
            }
            default:
                break;
        }
		
	} else if (scrollView.isDragging) {
		
		BOOL _loading = NO;
		if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
			_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
		}
        
        if (_loading){
            _statusLabel.text = NSLocalizedString(@"没有更多数据", @"Loading Status");
            _lastUpdatedLabel.hidden = YES;
            _arrowImage.hidden = YES;
        }else{
            _statusLabel.text = NSLocalizedString(@"拖动刷新数据...", @"Loading Status");
            _lastUpdatedLabel.hidden = NO;
            _arrowImage.hidden = NO;
        }
        
        BOOL pullingCondition = NO;
        BOOL normalCondition = NO;
        switch (_orientation) {
            case EGOPullOrientationDown:
                pullingCondition = (scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f);
                normalCondition = (scrollView.contentOffset.y < -65.0f);
                break;
            case EGOPullOrientationUp: {
                CGFloat y = scrollView.contentOffset.y+scrollView.frame.size.height;
                pullingCondition = ((y < (scrollView.contentSize.height+65.0f)) && (y > scrollView.contentSize.height));
                normalCondition = (y > (scrollView.contentSize.height+65.0f));
                break;
            }
            case EGOPullOrientationRight:
                pullingCondition = (scrollView.contentOffset.x > -65.0f && scrollView.contentOffset.x < 0.0f);
                normalCondition = (scrollView.contentOffset.x < -65.0f);
                break;
            case EGOPullOrientationLeft: {
                CGFloat x = scrollView.contentOffset.x+scrollView.frame.size.width;
                pullingCondition = ((x < (scrollView.contentSize.width+65.0f)) && (x > scrollView.contentSize.width));
                normalCondition = (x > (scrollView.contentSize.width+65.0f));
                break;
            }
            default:
                break;
        }
        
		if (_state == EGOOPullRefreshPulling && pullingCondition && !_loading) {
			[self setState:EGOOPullRefreshNormal];
		} else if (_state == EGOOPullRefreshNormal && normalCondition && !_loading) {
			[self setState:EGOOPullRefreshPulling];
		}
		
		if (scrollView.contentInset.top != 0) {
			scrollView.contentInset = UIEdgeInsetsZero;
		}
		
	}
	
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
	
	BOOL _loading = NO;
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
		_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
	}
    
    BOOL condition = NO;
    UIEdgeInsets insets = UIEdgeInsetsZero;
    switch (_orientation) {
        case EGOPullOrientationDown:
            condition = (scrollView.contentOffset.y <= - 65.0f);
            insets = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
            break;
        case EGOPullOrientationUp: {
            CGFloat y = scrollView.contentOffset.y+scrollView.frame.size.height-scrollView.contentSize.height;
            condition = (y > 65.0f);
            insets = UIEdgeInsetsMake(0.0f, 0.0f, 60.0f, 0.0f);
            break;
        }
        case EGOPullOrientationRight:
            condition = (scrollView.contentOffset.x <= - 65.0f);
            insets = UIEdgeInsetsMake(0.0f, 60.0f, 0.0f, 0.0f);
            break;
        case EGOPullOrientationLeft: {
            CGFloat x = scrollView.contentOffset.x+scrollView.frame.size.width-scrollView.contentSize.width;
            condition = (x > 65.0f);
            insets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 60.0f);
            break;
        }
        default:
            break;
    }
	
	if (condition && !_loading) {
		
		if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)]) {
			[_delegate egoRefreshTableHeaderDidTriggerRefresh:self];
		}
		
        /* Set NO paging Disable */
        _pagingEnabled = scrollView.pagingEnabled;
        scrollView.pagingEnabled = NO;
        
		[self setState:EGOOPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		scrollView.contentInset = insets;
		[UIView commitAnimations];
		
	}
	
}

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	scrollView.pagingEnabled = _pagingEnabled;
	[self setState:EGOOPullRefreshNormal];
    
}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"contentSize"];
	_delegate=nil;
	_activityView = nil;
	_statusLabel = nil;
	_arrowImage = nil;
	_lastUpdatedLabel = nil;
}


@end
