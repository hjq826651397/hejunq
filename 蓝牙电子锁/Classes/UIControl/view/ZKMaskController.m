//
//  ZKMaskController.m
//  蓝牙电子锁
//
//  Created by mosaic on 2017/12/13.
//  Copyright © 2017年 mosaic. All rights reserved.
//

#import "ZKMaskController.h"

@interface ZKMaskController ()
@property (nonatomic,copy)MaskSure mask;



@end

@implementation ZKMaskController{
    CGRect _viewFrame;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
}
-(void)getResultBlock:(MaskSure)mask{
    self.mask = mask;
}

-(void)createUI{
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.8 alpha:0.4]];
    
    UIView *backGroundView = [[UIView alloc]init];
    [backGroundView setFrame:CGRectMake(relative_w(80), relative_h(490)+64, relative_h(916), relative_h(566))];
    [backGroundView setBackgroundColor:[UIColor whiteColor]];
    backGroundView.layer.cornerRadius = 8;
//    [backGroundView setClipsToBounds:YES];
    [self.view addSubview:backGroundView];
    self.backgroundView = backGroundView;
    //设置阴影
    self.backgroundView.layer.shadowColor = [UIColor blackColor].CGColor;
    //阴影的透明度
    self.backgroundView.layer.shadowOpacity = 0.4f;
    //阴影的圆角
    self.backgroundView.layer.shadowRadius = 3.f;
    //阴影偏移量
    self.backgroundView.layer.shadowOffset = CGSizeMake(0,0);
    
    UIView *blackView = [[UIView alloc]init];
    [blackView setBackgroundColor:[UIColor blackColor]];
    [blackView setFrame:CGRectMake(0, 0, backGroundView.width, relative_h(140))];
    [self.backgroundView addSubview:blackView];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:blackView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(8,8)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = blackView.bounds;
    maskLayer.path = maskPath.CGPath;
    blackView.layer.mask = maskLayer;
    

    
    
    //@“输入连接码”
    UILabel*titleLab = [[UILabel alloc]init];
    titleLab.text = self.titleStr;
    [titleLab setTextColor:[UIColor whiteColor]];
    [titleLab setFont:LabelFount(17)];
    [titleLab setFrame:CGRectMake(relative_w(43), 0, 0, 0)];
    [titleLab sizeToFit];
    titleLab.centerY = blackView.centerY;
    [blackView addSubview:titleLab];
    
    //输入框
    UITextField *inputF = [[UITextField alloc]init];
    [inputF setFrame:CGRectMake(relative_w(78), relative_h(78)+CGRectGetMaxY(blackView.frame), self.backgroundView.width-2*relative_w(78), relative_h(110))];
    [inputF setBackgroundColor:[UIColor colorWithHexString:@"ececec"]];
    inputF.layer.cornerRadius = 8;
    [inputF.layer setBorderWidth:1];
    [inputF.layer setBorderColor:[UIColor colorWithHexString:@"DDDEDD"].CGColor];
    inputF.keyboardType = UIKeyboardTypeNumberPad;
    [self.backgroundView addSubview:inputF];
    self.inputCodeField = inputF;
    
    CGRect frame = CGRectMake(0, 0, 20, 1);
    UIView *leftview = [[UIView alloc] initWithFrame:frame];
    self.inputCodeField.leftViewMode = UITextFieldViewModeAlways;
    self.inputCodeField.leftView = leftview;
    //取消按钮
    ZKButton *cancelButton = [[ZKButton alloc]init];
    [cancelButton setFrame:CGRectMake(inputF.x, CGRectGetMaxY(inputF.frame)+relative_h(78), relative_w(334), relative_h(118))];
    [cancelButton setTitle:@"取消" forState: UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelButton.layer setBorderWidth:1];
    [cancelButton.layer setBorderColor:[UIColor colorWithHexString:@"DDDEDD"].CGColor];
    [cancelButton.layer setCornerRadius:8];
    [self.backgroundView addSubview:cancelButton];
    self.cancelButton = cancelButton;
    
    //确定按钮
    ZKButton *sureButton = [[ZKButton alloc]init];
    [sureButton setFrame:CGRectMake(CGRectGetMaxX(inputF.frame)-cancelButton.width,cancelButton.y,cancelButton.width, cancelButton.height)];
    [sureButton setTitle:@"确定" forState: UIControlStateNormal];
    [sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [sureButton.layer setBorderWidth:1];
//    [sureButton.layer setBorderColor:[UIColor colorWithHexString:@"DDDEDD"].CGColor];
    [sureButton.layer setCornerRadius:8];
//    [sureButton setBackgroundColor:[UIColor colorWithHexString:@"ff3956"] forState:UIControlStateNormal];
    [sureButton setBackgroundColor:[UIColor colorWithHexString:@"ff3956"]];
    [self.backgroundView addSubview:sureButton];
    self.sureButton = sureButton;
    
    
    //事件
    [self.cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.sureButton addTarget:self action:@selector(sureButton:) forControlEvents:UIControlEventTouchUpInside];
    
    //第一响应者
    [self.inputCodeField becomeFirstResponder];
    _viewFrame = self.backgroundView.frame;
    //监听键盘
    //注册键盘出现的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:)name:UIKeyboardWillShowNotification object:nil];
    //注册键盘消失的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:)name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    //键盘高度
    CGRect keyBoardFrame = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
     double duration = [aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    if (CGRectGetMaxY(self.backgroundView.frame)>keyBoardFrame.origin.y) {
        [UIView animateWithDuration:duration animations:^{
            self.backgroundView.y = keyBoardFrame.origin.y - self.backgroundView.height-relative_h(20);
        } completion:^(BOOL finished) {
        }];
    }
}

-(void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    double duration = [aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        self.backgroundView.frame = _viewFrame;
    } completion:^(BOOL finished) {
        
    }];
}
-(void)cancelButtonClick:(UIButton*)sender{
    [self dismissViewControllerAnimated:YES completion:^{
        self.mask(self.inputCodeField.text,YES);
    }];
}

-(void)sureButton:(UIButton*)sender{
    [self dismissViewControllerAnimated:YES completion:^{
        self.mask(self.inputCodeField.text,NO);
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
