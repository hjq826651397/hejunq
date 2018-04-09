//
//  ZKSignalController.m
//  蓝牙电子锁
//
//  Created by mosaic on 2018/1/24.
//  Copyright © 2018年 mosaic. All rights reserved.
//

#import "ZKSignalController.h"
#import "ZKEmp1Button.h"
@interface ZKSignalController ()<ZKPeripheralDelegate>
@property (nonatomic,weak)UISlider *sliderView;
@property (nonatomic,weak)UILabel *sinLable;
@property (nonatomic,weak)ZKEmp1Button *calibrationButton;
@property (nonatomic,strong)NSTimer *caliTimer;
@end

@implementation ZKSignalController{
    NSNumber *_signal;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.peri.peripheralDelegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
}

-(void)createUI{
    self.title = @"距离校准";
    [self.view setBackgroundColor:[UIColor colorWithHexString:@"F1F2F1"]];
    UIBarButtonItem*rightItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(rightClick:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    _signal = self.peri.signal_set;
    
    UISlider *sliderView = [[UISlider alloc]init];
    [sliderView setFrame:CGRectMake(0, 0, ZKSCREEN_W/2, 30)];
    sliderView.centerX = ZKSCREEN_W/2;
    sliderView.centerY = (ZKSCREEN_H+64)/2;
    [self.view addSubview:sliderView];
    self.sliderView = sliderView;
    [sliderView setMaximumValue:-30];
    [sliderView setMinimumValue:-70];
    [sliderView setValue:self.peri.signal_set.intValue];
    
    UILabel *sinLable = [[UILabel alloc]init];
    [sinLable setText:[NSString stringWithFormat:@"%d",self.peri.signal_set.intValue]];
    [sinLable sizeToFit];
    sinLable.centerX = ZKSCREEN_W/2;
    sinLable.centerY = sliderView.y-sinLable.height;
    [self.view addSubview:sinLable];
    self.sinLable = sinLable;
    
    ZKEmp1Button *calibrationButton = [[ZKEmp1Button alloc]init];
    [calibrationButton setFrame:CGRectMake(0, ZKSCREEN_H-relative_h(150)-relative_h(110), relative_w(612), relative_h(110))];
    [calibrationButton setTitle:@"校准距离" forState:UIControlStateNormal];
    calibrationButton.centerX = ZKSCREEN_W/2;
    [self.view addSubview:calibrationButton];
    self.calibrationButton = calibrationButton;
    
    //事件
    [self.sliderView addTarget:self action:@selector(sliderViewChange:) forControlEvents:UIControlEventValueChanged];
    [self.calibrationButton addTarget:self action:@selector(calibrationButtonClick:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)rightClick:(id)sender{
    self.peri.signal_set = _signal;
    if ([[ZKCommonData sharedZKCommonData] updatePerToDatabase:self.peri]) {
        [self.peri sendConnectionCode];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [ZKNotificationView show:@"保存设置失败" willShowBlock:^{}Tapblock:^{} didShowBlock:^{}];
    }
}

-(void)sliderViewChange:(UISlider*)sender{
    ZKLog(@"%f",sender.value);
    _signal = [NSNumber numberWithInt:(int)sender.value];
    self.sinLable.text = [NSString stringWithFormat:@"%@",_signal];
    [self.sinLable sizeToFit];
}

-(void)calibrationButtonClick:(ZKEmp1Button*)sender{
    //开始校准距离
//    [self createTimer];
//    [self.caliTimer fire];
    [self.peri sendRSSICommand];
    //弹框提示
    [[ZKAlertView sharedZKAlertView] showTitle:@"提示" message:@"正在校准距离......" showOnVC:self handler:^{
        //中止校准
//        [_caliTimer invalidate];
    }];
//    [self performSelector:@selector(completeEvent) withObject:nil afterDelay:5];
}

//-(void)completeEvent{
//    [_caliTimer invalidate];
//    //校准完毕
//    [[ZKAlertView sharedZKAlertView] hiddeAlertCompletion:^{}];
//}

//-(void)sendCalibrationSignal{
//    ZKLog(@"正在校准距离");
//}

//-(void)createTimer{
//    _caliTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(sendCalibrationSignal) userInfo:nil repeats:YES];
//}

#pragma mark ==ZKPeripheralDelegate==
- (void)customPeripheral:(ZKPeripheral*)peripheral DidUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if ([characteristic isEqual:self.peri.chc_UpdateTime]) {
        ZKLog(@"%@",characteristic.value);
        NSData*resultData = characteristic.value;
        if (resultData.length<1) {
            return ;
        }
        //截取第一个字节判断类型
        if (resultData.length>=2) {
            Byte buff[2];
            [resultData getBytes:buff length:2];
            if (buff[0]==37) {
                int8_t sig = buff[1];
                if (sig>=-70&&sig<=-30) {
                    ZKLog(@"%d",sig);
                    _signal = [NSNumber numberWithInt:sig];
                    self.sinLable.text = [NSString stringWithFormat:@"%@",_signal];
                    [self.sinLable sizeToFit];
                    self.sliderView.value = sig;
                    [[ZKAlertView sharedZKAlertView] hiddeAlertCompletion:^{
                        [ZKAlertView showSuccess:@"已获取校准后的距离" viewController:self Completion:^{}];
                    }];
                }else{
                    [[ZKAlertView sharedZKAlertView] hiddeAlertCompletion:^{
                        [ZKAlertView showError:@"校准失败,请调整距离再次校准" viewController:self Completion:^{}];
                    }];
                }
            }
        }
    }
}

-(void)customPeripheral:(ZKPeripheral*)peripheral NotiyCode:(ZKPeripheralCode)notiyCode value:(NSData*)value error:(NSError *)error{
    if (notiyCode==PeripheralNotiyReadRSSISuccess) {
        ZKLog(@"%@",value);

        [self.peri.peripheral readValueForCharacteristic:self.peri.chc_UpdateTime];
    }
}

@end
