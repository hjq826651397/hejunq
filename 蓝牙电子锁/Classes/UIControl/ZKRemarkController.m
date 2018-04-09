//
//  ZKRemarkController.m
//  蓝牙电子锁
//
//  Created by mosaic on 2017/12/14.
//  Copyright © 2017年 mosaic. All rights reserved.
//

#import "ZKRemarkController.h"
#import "ZKEmp1Button.h"
@interface ZKRemarkController ()

@property (nonatomic,weak)UITextField *textField;

@end

@implementation ZKRemarkController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
}

-(void)createUI{
    self.title = @"修改备注";
    [self.view setBackgroundColor:[UIColor colorWithHexString:@"F1F2F1"]];
    ZKEmp1Button *restoreButton = [[ZKEmp1Button alloc]init];
    [restoreButton setFrame:CGRectMake(0, relative_h(330)+64, relative_w(612), relative_h(108))];
    [restoreButton setTitle:@"保存" forState: UIControlStateNormal];
    restoreButton.centerX = ZKSCREEN_W/2;
    [self.view addSubview:restoreButton];
    
    UIView *lineView = [[UIView alloc]init];
    [lineView setBackgroundColor:[UIColor lightGrayColor]];
    [lineView setFrame:CGRectMake(0, relative_h(185)+64, relative_w(952), 0.5)];
    lineView.centerX = ZKSCREEN_W/2;
    [self.view addSubview:lineView];
    
    UITextField *textField = [[UITextField alloc]init];
    [textField setFrame:CGRectMake(0, relative_h(116)+64, lineView.width-relative_w(40), relative_h(40))];
    textField.centerX = ZKSCREEN_W/2;
    textField.font = LabelFount(15);
    [self.view addSubview:textField];
    self.textField = textField;
    
    //事件
    [restoreButton addTarget:self action:@selector(restoreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.textField.placeholder = self.zkper.note_name;
    [self.textField becomeFirstResponder];
}

-(void)restoreButtonClick:(ZKEmp1Button*)sender{
    self.zkper.note_name = self.textField.text;
    if ([[ZKCommonData sharedZKCommonData]updatePerToDatabase:self.zkper]) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [ZKAlertView showError:@"修改备注失败" viewController:self Completion:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


@end
