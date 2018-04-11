//
//  ViewController.m
//  AVCompositionDemo
//
//  Created by navy on 2018/4/11.
//  Copyright © 2018 navy. All rights reserved.
//

#import "ViewController.h"
#import "AVCompositionManager.h"

@interface ViewController ()
@property (nonatomic, weak) IBOutlet UIButton *mergeButton;
@property (nonatomic, strong) AVCompositionManager *compositionManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)mergeButtonDidPress:(id)sender {
    NSString *videoURL1 = [[NSBundle mainBundle] pathForResource:@"test1" ofType:@"mp4"];
    NSString *videoURL2 = [[NSBundle mainBundle] pathForResource:@"test2" ofType:@"mp4"];
    _compositionManager = [AVCompositionManager sharedInstance];
    [_compositionManager composeWithUrls:@[videoURL1, videoURL2] completion:^{
        NSLog(@"合成成功");
    }];
}

@end
