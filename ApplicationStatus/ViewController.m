//
//  ViewController.m
//  ApplicationStatus
//
//  Created by wanghuiyong on 29/01/2017.
//  Copyright © 2017 Personal Organization. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIImage *smiley;
@property (strong, nonatomic) UIImageView *smileyView;
@property (assign, nonatomic) NSInteger index;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;

@end

@implementation ViewController {
    BOOL animate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CGRect bounds = self.view.bounds;
    
    // 添加标签
    CGRect labelFrame = CGRectMake(bounds.origin.x, CGRectGetMidY(bounds) - 50, bounds.size.width, 100);
    self.label = [[UILabel alloc] initWithFrame:labelFrame];
    self.label.font = [UIFont fontWithName:@"Helvetica" size:70];
    self.label.text = @"Bazinga!";
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.label];
    
	// 添加图片
    CGRect smileyFrame = CGRectMake(CGRectGetMidX(bounds) - 42, CGRectGetMidY(bounds) / 2, 84, 84);
    self.smileyView = [[UIImageView alloc] initWithFrame:smileyFrame];
    self.smileyView.contentMode = UIViewContentModeCenter;
    NSString *smileyPath = [[NSBundle mainBundle] pathForResource:@"smiley" ofType:@"png"];
    self.smiley = [UIImage imageWithContentsOfFile:smileyPath];
    self.smileyView.image = self.smiley;
    [self.view addSubview:self.smileyView];
    
    // 分段控件
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects: @"One", @"Two", @"Three", @"Four", nil]];
    self.segmentedControl.frame = CGRectMake(bounds.origin.x + 20, 50, bounds.size.width - 40, 30);
    [self.segmentedControl addTarget:self action:@selector(selectionChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.segmentedControl];
    
    // 恢复分段控件状态
    self.index = [[NSUserDefaults standardUserDefaults] integerForKey:@"index"];
    self.segmentedControl.selectedSegmentIndex = self.index;
    
    // 注册应用状态通知
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [center addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [center addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [center addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)appWillResignActive {
    NSLog(@"View Controller: %@", NSStringFromSelector(_cmd));
    
    // 暂停动画
    animate = NO;
}

- (void)appDidBecomeActive {
    NSLog(@"View Controller: %@", NSStringFromSelector(_cmd));
    
    // 恢复动画
    animate = YES;
    [self rotateLabelDown];
}

- (void)appDidEnterBackground {
    NSLog(@"View Controller: %@", NSStringFromSelector(_cmd));
    // 释放图片资源
    /*self.smiley = nil;
    self.smileyView.image = nil;*/
    
    // 保存分段控件状态
    [[NSUserDefaults standardUserDefaults] setInteger:self.index forKey:@"index"];
    
    // 后台运行释放图片资源
    UIApplication *app = [UIApplication sharedApplication];
    // begin 函数返回 taskId, 超时后传入 end 函数, 匹配以让系统知道工作完成
    __block UIBackgroundTaskIdentifier taskId = [app beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"Background task ran out of time and was terminated");
        [app endBackgroundTask:taskId];
    }];
    // 系统未提供多余时间
    if (taskId == UIBackgroundTaskInvalid) {
        NSLog(@"Failed to start background task");
        return;
    }
    // 将工作放入后台队列中
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Starting background gask with %f seconds remaining", app.backgroundTimeRemaining);
        self.smiley = nil;
        self.smileyView.image = nil;
        
        [NSThread sleepForTimeInterval:25];
        NSLog(@"Finishing background tast with %f seconds remaining", app.backgroundTimeRemaining);
        [app endBackgroundTask:taskId];
    });
}

- (void)appWillEnterForeground {
	NSLog(@"View Controller: %@", NSStringFromSelector(_cmd));
    
    // 加载图片资源
    NSString *smileyPath = [[NSBundle mainBundle] pathForResource:@"smiley" ofType:@"png"];
    self.smiley = [UIImage imageWithContentsOfFile:smileyPath];
    self.smileyView.image = self.smiley;
}

- (void)rotateLabelDown {
    [UIView animateWithDuration:0.5 
        animations:^{
    		self.label.transform = CGAffineTransformMakeRotation(M_PI);
    	}
        completion:^(BOOL finished){
            [self rotateLabelUp];
        }
     ];
}

- (void)rotateLabelUp {
    [UIView animateWithDuration:1.0
        animations:^{
            self.label.transform = CGAffineTransformMakeRotation(0);
        }
        completion:^(BOOL finished){
            // 此条件不满足则保证动画停留在正方向
            if (animate) {
                [self rotateLabelDown];
            }
        }
     ];
}

- (void)selectionChanged:(UISegmentedControl *)sender {
    self.index = sender.selectedSegmentIndex;
}


@end
