//
//  ZKKeyboardLockController.m
//  蓝牙电子锁
//
//  Created by mosaic on 2018/1/12.
//  Copyright © 2018年 mosaic. All rights reserved.
//

#import "ZKKeyboardLockController.h"
#import "ZKEmp3Button.h"
#import "ZKEmp2Button.h"
#import "ZKMaskController.h"
@interface ZKKeyboardLockController ()
@property (nonatomic,weak) ZKEmp3Button *keyUnlockButton;
@property (nonatomic,weak) ZKEmp2Button *pwdButton;

@end

@implementation ZKKeyboardLockController

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    ZKLog(@"密码测试:%@",self.perip.KeyboardPwdData);
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    ZKLog(@"密码测试:%@",self.perip.KeyboardPwdData);
}
- (void)viewDidLoad {
    [super viewDidLoad];

    [self createUI];
    
    [self loadData];
}

-(void)createUI{
    self.title = @"键盘开锁";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.view setBackgroundColor:[UIColor colorWithHexString:@"F1F2F1"]];
  
    //键盘开锁
    ZKEmp3Button *keyUnlockButton = [[ZKEmp3Button alloc]init];
    [keyUnlockButton setBackgroundColor:[UIColor whiteColor]];
    keyUnlockButton.tLabel.text = @"键盘开锁";
    [keyUnlockButton setFrame:CGRectMake(0, 64+relative_h(20), ZKSCREEN_W, relative_h(125))];
    [self.view addSubview:keyUnlockButton];
    self.keyUnlockButton = keyUnlockButton;
    
    //设置密码
    ZKEmp2Button *pwdButton  = [[ZKEmp2Button alloc]init];
    [pwdButton setBackgroundColor:[UIColor whiteColor]];
    pwdButton.tLabel.text = @"设置密码";
    [pwdButton.dLabel setTextColor:[UIColor colorWithWhite:0.3 alpha:1]];
    [pwdButton setFrame:CGRectMake(0, CGRectGetMaxY(keyUnlockButton.frame)+relative_h(20), ZKSCREEN_W, relative_h(125))];
    [self.view addSubview:pwdButton];
    self.pwdButton = pwdButton;
    [pwdButton addTarget:self action:@selector(pwdButtonClick:) forControlEvents:UIControlEventTouchUpInside];
}



//载入数据
-(void)loadData{
    [self.keyUnlockButton.autoUnlockSwitch setOn:self.perip.isOpenKeyboard];
    long  pwd = 0;
    [self.perip.KeyboardPwdData getBytes:&pwd length:4];
    [self.pwdButton.dLabel setText:[NSString stringWithFormat:@"%ld",pwd]];
    [self.pwdButton refresh];
    ZKLog(@"键盘开锁密码:%ld",pwd);
    ZKLog(@"键盘开锁数据:%@",self.perip.KeyboardPwdData);
    [self.perip addObserver:self forKeyPath:@"isOpenKeyboard" options:NSKeyValueObservingOptionNew context:nil];
    [self.perip addObserver:self forKeyPath:@"KeyboardPwdData" options:NSKeyValueObservingOptionNew context:nil];

    //发送查询钥匙指令
    [self.perip sendQueryKeyboardPwd];
    
    [self.keyUnlockButton.autoUnlockSwitch addTarget:self action:@selector(keyUnlockButtonClick:) forControlEvents:UIControlEventTouchUpInside];
}


//监听事件
- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context{
    ZKLog(@"%@",change);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([keyPath isEqualToString:@"isOpenKeyboard"]) {
            [self.keyUnlockButton.autoUnlockSwitch setOn:self.perip.isOpenKeyboard];
        }else{
            long  pwd = 0;
            [self.perip.KeyboardPwdData getBytes:&pwd length:4];
            [self.pwdButton.dLabel setText:[NSString stringWithFormat:@"%ld",pwd]];
            [self.pwdButton refresh];
        }
    });
}

-(void)keyUnlockButtonClick:(UISwitch*)sender{
  
//    if (self.perip.KeyboardPwdData.length==4) {
        long  pwd = 0;
        [self.perip.KeyboardPwdData getBytes:&pwd length:4];
        if (sender.on) {
            self.perip.keyboardStatus = KeyboardStatusOpen;
        }else{
            self.perip.keyboardStatus = KeyboardStatusClose;
        }
    
        if (pwd<1000000&&pwd>99999) {
            [self.perip sendIsOpenKeyboard:sender.on KeyPwd:self.perip.KeyboardPwdData];
        }else{
            int pwf = 123456;
            NSData *data = [NSData dataWithBytes:&pwf length:4];
            [self.perip sendIsOpenKeyboard:sender.on KeyPwd:data];
        }
//    }
}

-(void)pwdButtonClick:(ZKEmp2Button*)sender{
    self.perip.keyboardStatus = KeyboardStatusSet;
    ZKMaskController *setVC = [[ZKMaskController alloc]init];
    setVC.titleStr = @"请输入6位数密码";
    setVC.modalPresentationStyle = UIModalPresentationCustom;
    setVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:setVC animated:YES completion:nil];
    [setVC getResultBlock:^(NSString *codeStr, BOOL isCancel) {
        if (!isCancel&&codeStr.length==6) {
            int pwd = codeStr.intValue;
            NSData *data = [NSData dataWithBytes:&pwd length:4];
            [self.perip sendIsOpenKeyboard:self.keyUnlockButton.autoUnlockSwitch.on KeyPwd:data];
        }else if(!isCancel){
            [ZKAlertView showError:@"请输入6位数的密码" viewController:self Completion:^{}];
        }
    }];
}


-(void)dealloc{
    [self.perip removeObserver:self forKeyPath:@"isOpenKeyboard"];
    [self.perip removeObserver:self forKeyPath:@"KeyboardPwdData"];
}

@end
