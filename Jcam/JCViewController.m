//
//  JCViewController.m
//  Jcam
//
//  Created by 上原 将司 on 2014/09/12.
//  Copyright (c) 2014年 Project Wolf. All rights reserved.
//

#import "JCViewController.h"

@interface JCViewController ()

@end

@implementation JCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIImagePickerViewDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    return;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    return;
}

@end
