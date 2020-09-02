//
//  TestViewController.m
//  WKJKitDemo
//
//  Created by Zed on 2020/8/21.
//  Copyright © 2020 Zed. All rights reserved.
//

#import "TestViewController.h"
#import <WKJKit/WKJKit.h>

@interface TestViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    self.textView.wkj_textLimit = 10;
    self.textField.text = @"1234";
}

- (void)dealloc
{
    NSLog(@"11111");
}

@end
