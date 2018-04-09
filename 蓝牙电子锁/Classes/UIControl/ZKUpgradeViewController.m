//
//  ZKUpgradeViewController.m
//  蓝牙电子锁
//
//  Created by mosaic on 2017/12/27.
//  Copyright © 2017年 mosaic. All rights reserved.
//

#import "ZKUpgradeViewController.h"
#import "ZKEmp1Button.h"
#import "ZKFile.h"
#import "ZKProgressView.h"
#define Detail_path @"http://save.alarm.net.cn/updata/LockUpDataLog.txt"
#define Detail_store @"Detail_store"
@interface ZKUpgradeViewController ()<NSURLSessionDownloadDelegate,ZKPeripheralDelegate,ZKBleManagerDelegate>
@property (nonatomic,weak)UIImageView *backImgView;
@property (nonatomic,weak)ZKEmp1Button *upgradeButton;
@property (nonatomic,weak)ZKEmp1Button *lastButton;
@property(nonatomic,weak)ZKProgressView *progressView;
@property (nonatomic,weak)UILabel *progressLabel;
@property (nonatomic,weak)UILabel *detaileLabel;

@property (nonatomic,weak)UILabel *sysVersionLabel;
@property (nonatomic,weak)UILabel *lastVersionLabel;
@property (nonatomic,copy)NSString *fileUrlStr;
@property(nonatomic,strong)NSURLSessionDownloadTask*task;
@property(nonatomic,weak)NSURLSession*session;

@property (nonatomic,strong)ZKFile *file;
@property (nonatomic,weak)ZKBleManager *bleManager;



@end

@implementation ZKUpgradeViewController{
    BOOL _isFileExist;
    BOOL _isAutoConnect;
    int16_t _version ;//当前文件版本号
    BOOL _isInstalling;//是否正在升级中
    BOOL _isNextInstall;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    _isAutoConnect = YES;
    _isInstalling = NO;
    _isNextInstall = NO;
    self.bleManager = [ZKBleManager sharedZKBleManager];
    self.bleManager.scanType = BLEAutoConnectScanning;
    self.bleManager.centralDelegate = self;
    self.peri.peripheralDelegate = self;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    if (self.session) {
        [self.session invalidateAndCancel];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(isUpgradeInterruptTimeOut) object:nil];
    if (_isInstalling) {//中断升级
        //发送错误数据 中断升级
        int buff = 0xffff;
        [self.peri sendSysFirmwareData:[NSData dataWithBytes:&buff length:2]];
        ZKLog(@"发送错误数据");
    }
    [self.peri removeObserver:self forKeyPath:@"firmware"];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
    [self fileData];
}
-(NSString*)fileUrlStr{
    if (!_fileUrlStr) {
        NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        // response.suggestedFilename ： 建议使用的文件名，一般跟服务器端的文件名一致
        caches = [caches stringByAppendingString:[NSString stringWithFormat:@"/%@",FirmWare_Path]];
        _fileUrlStr = caches;
    }
    return _fileUrlStr;
}

-(void)createUI{
    self.title = @"在线升级";
    
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc]initWithTitle:@"退出" style:UIBarButtonItemStylePlain target:self action:@selector(leftBtnClick)];
    [leftBtn setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = leftBtn;
    
    
    UIImageView *backImgView = [[UIImageView alloc]init];
    [backImgView setImage:[UIImage imageNamed:@"升级.png"]];
    [backImgView setFrame:CGRectMake(0, 64, ZKSCREEN_W, relative_h(815))];
    [self.view addSubview:backImgView];
    self.backImgView = backImgView;
    [self.view setBackgroundColor:[UIColor colorWithHexString:@"DDDEDD"]];
    
    //升级按钮
    ZKEmp1Button *upgradeButton = [[ZKEmp1Button alloc]init];
    [upgradeButton setFrame:CGRectMake(0, ZKSCREEN_H-relative_h(150)-relative_h(110), relative_w(612), relative_h(110))];
    upgradeButton.centerX = ZKSCREEN_W/2;
    [upgradeButton setTitle:@"立即升级" forState:UIControlStateNormal];
    [self.view addSubview:upgradeButton];
    self.upgradeButton = upgradeButton;
   
    
    UILabel *sysVersionLabel = [[UILabel alloc]init];
    [sysVersionLabel setFrame:CGRectMake(20, CGRectGetMaxY(backImgView.frame)+20, 0, 0)];
    sysVersionLabel.text = [NSString stringWithFormat:@"当前固件版本: %@",self.peri.firmware];
    sysVersionLabel.font = LabelFount(14);
    [sysVersionLabel sizeToFit];
    [self.view addSubview:sysVersionLabel];
    self.sysVersionLabel = sysVersionLabel;
    
    UILabel *lastVersionLabel = [[UILabel alloc]init];
    [lastVersionLabel setFrame:CGRectMake(sysVersionLabel.x, CGRectGetMaxY(sysVersionLabel.frame)+5, 0, 0)];
    lastVersionLabel.text = [NSString stringWithFormat:@"最新固件版本: "];
    lastVersionLabel.font = LabelFount(14);
    [lastVersionLabel sizeToFit];
    [self.view addSubview:lastVersionLabel];
    self.lastVersionLabel = lastVersionLabel;
    
    UILabel *detaileLabel=[[UILabel alloc]init];
    detaileLabel.font = LabelFount(14);
    detaileLabel.y = 64+5;//CGRectGetMaxY(lastVersionLabel.frame)+5;
    detaileLabel.x = lastVersionLabel.x;//ZKSCREEN_W/2;
    detaileLabel.numberOfLines=0;
    [self.view addSubview:detaileLabel];
    self.detaileLabel = detaileLabel;
    self.detaileLabel.text =[[NSUserDefaults standardUserDefaults] stringForKey:Detail_store];
    [self.detaileLabel sizeToFit];
    [detaileLabel setHidden:YES];
    //更新
    ZKEmp1Button *lastButton = [[ZKEmp1Button alloc]init];
    [lastButton setFrame:CGRectMake(ZKSCREEN_W-relative_w(612)/3-40, 0, relative_w(612)/3, relative_h(110)*4/5)];
    lastButton.centerY = lastVersionLabel.centerY;
    lastButton.titleLabel.font = LabelFount(13);
    [lastButton setTitle:@"下载固件" forState:UIControlStateNormal];
    [self.view addSubview:lastButton];
    self.lastButton = lastButton;
    //进度条
    CGFloat progressView_W = ZKSCREEN_W*2/3;
    CGFloat progressView_h = 8;
    CGFloat progressView_y = CGRectGetMaxY(lastVersionLabel.frame)+(upgradeButton.y-CGRectGetMaxY(lastVersionLabel.frame))*2/3;
    ZKProgressView *progressView = [[ZKProgressView alloc]initWithFrame:CGRectMake(0, progressView_y, progressView_W, progressView_h)baseColor:[UIColor colorWithWhite:0.9 alpha:0.9] progressColor:[UIColor colorWithHexString:@"FF3956"] ratio:0 withType:ZKProgressVerticalType];
    [progressView.layer setCornerRadius:progressView_h/2];
    [progressView.progressView.layer setCornerRadius:progressView_h/2];
    [progressView setClipsToBounds:YES];
    [self.view addSubview:progressView];
    self.progressView = progressView;
    progressView.centerX = ZKSCREEN_W/2;
    [self.progressView setHidden:YES];
    
    UILabel *progressLabel = [[UILabel alloc]init];
    [progressLabel setFrame:CGRectMake(10,10, 30, 30)];
    progressLabel.text = @"100.00 %";
    [progressLabel setTextAlignment:NSTextAlignmentCenter];
    [progressLabel sizeToFit];
    progressLabel.centerX = ZKSCREEN_W/2;
    progressLabel.y = progressView.y - 10-progressLabel.height;
    [self.view addSubview:progressLabel];
    self.progressLabel = progressLabel;
    [self.progressLabel setHidden:YES];
    //事件
    [self.upgradeButton addTarget:self action:@selector(upgradeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.lastButton addTarget:self action:@selector(lastButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    

    //监听版本号变化
    [self.peri addObserver:self forKeyPath:@"firmware" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)leftBtnClick{
    if (_isInstalling) {
        UIAlertController*alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"正在升级固件，此时退出可能造成未知错误" preferredStyle:UIAlertControllerStyleAlert];
        [alertVC addAction:[UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }]];
        [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alertVC animated:YES completion:^{
            
        }];
        
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}


//监听事件
- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context{
    ZKLog(@"%@",change);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.sysVersionLabel.text = [NSString stringWithFormat:@"当前固件版本: %@",self.peri.firmware];
        [self.sysVersionLabel sizeToFit];
    });
}

-(void)setlastVersionLabelTextStr:(NSString*)msg{
    self.lastVersionLabel.text = [NSString stringWithFormat:@"升级固件版本: %@",msg];
    [self.lastVersionLabel sizeToFit];
}

-(void)lastButtonClick:(ZKEmp1Button*)sender{
    if (_isInstalling) {
        [[ZKAlertView sharedZKAlertView]showTitle:@"正在升级固件......" message:nil showOnVC:self];
        [[ZKAlertView sharedZKAlertView] performSelector:@selector(hiddeAlertCompletion:) withObject:nil afterDelay:1];
        return;
    }
    NSString *detaile = [NSString stringWithContentsOfURL:[NSURL URLWithString:Detail_path] encoding:NSUTF8StringEncoding error:nil];
    ZKLog(@"%@",detaile);
    [self.detaileLabel setHidden:NO];
    self.detaileLabel.text = detaile;
    [self.detaileLabel sizeToFit];
    self.detaileLabel.x = self.lastVersionLabel.x;//ZKSCREEN_W/2;
    [[NSUserDefaults standardUserDefaults] setObject:detaile forKey:Detail_store];
    NSURL*url;
    if (self.peri.upgradeStr.length>0&&![self.peri.upgradeStr isEqualToString:@"N.A."]) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://save.alarm.net.cn/updata/mh109_%@.bin",self.peri.upgradeStr]];
    }else{
        url = [NSURL URLWithString:ULR_Path];
    }
    
    
    NSURLSessionConfiguration*config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession*session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDownloadTask* downloadTask = [session downloadTaskWithURL:url];
    [downloadTask resume];
    self.session = session;
    self.task = downloadTask;
    [self setlastVersionLabelTextStr:[NSString stringWithFormat:@"正在下载...%@",@"0%"]];

    ZKLog(@"%@",url);
}

//升级按钮
-(void)upgradeButtonClick:(ZKEmp1Button*)sender{
    
    if (_isInstalling) {
        [[ZKAlertView sharedZKAlertView]showTitle:@"正在升级固件......" message:nil showOnVC:self];
        [[ZKAlertView sharedZKAlertView] performSelector:@selector(hiddeAlertCompletion:) withObject:nil afterDelay:1];
        return;
    }
    if (_isFileExist&&self.file) {
        [self lastButtonClick:self.lastButton];
        //读取第一片数据
        NSData *firstData = [self.file readDataWithChunk:0];
        ZKLog(@"firstData:%@",firstData);
        [self.peri sendSysHeaderData:firstData];
    }else{
        _isNextInstall = YES;
        [self lastButtonClick:self.lastButton];
    }
    _isInstalling = YES;
}
//更新文件版本号
-(void)fileVersionLoad{
    //读取文件版本号
    NSData *firstData = [self.file readDataWithChunk:0];
    int16_t version =0;
    if (firstData) {
        [firstData getBytes:&version range:NSMakeRange(4, 2)];
        ZKLog(@"%d  %@",version,firstData);
        [self setlastVersionLabelTextStr:[NSString stringWithFormat:@"%.2f",version/100.0]];
    }
    _version = version;
}

-(void)fileData{
    //1、判断文件是否存在
    if ([ZKFileTool isFileExist:FirmWare_Path]) {
        _isFileExist = YES;
        self.file = [[ZKFile alloc]initWithFilePath:self.fileUrlStr];
        [self fileVersionLoad];
    }else{
        _isFileExist = NO;
    }
}

//下载完毕
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
 
    [session finishTasksAndInvalidate];
    //    ZKLog(@"%@",caches);
    NSFileManager *mgr = [NSFileManager defaultManager];
    BOOL result;
    result = [mgr removeItemAtPath:self.fileUrlStr error:nil];
    result = [mgr moveItemAtPath:location.path toPath:self.fileUrlStr error:nil];
    if (result) {
        ZKLog(@"成功");
        _isFileExist = YES;
        self.file = [[ZKFile alloc]initWithFilePath:self.fileUrlStr];
        
        [self performSelector:@selector(fileVersionLoad) withObject:nil afterDelay:0.5];
        if (_isNextInstall) {
            [self upgradeButtonClick:self.upgradeButton];
            _isNextInstall = NO;
        }
//        [self fileVersionLoad];
    }
}
//每次写入沙盒完毕调用
//@param bytesWritten 这次写入的大小
//@param totalBytesWritten 已经写入沙盒的大小
//@param totalBytesExpectedToWrite 文件总大小
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    ZKLog(@"%@",[NSString stringWithFormat:@"下载进度:%f",(double)totalBytesWritten/totalBytesExpectedToWrite]);
    [self setlastVersionLabelTextStr:[NSString stringWithFormat:@"正在下载...%.2f%@",(double)totalBytesWritten*100/totalBytesExpectedToWrite,@"%"]];
}

//恢复下载后调用
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
}



#pragma mark ==BLEDelegate==
//扫描到设备
-(void)customBleDidDiscoverPeripheral:(ZKPeripheral*)per {
    if ([self.peri.peripheral isEqual:per.peripheral]) {
        if (_isAutoConnect) {
            [self.bleManager connectPeripheral:per.peripheral];
        }
    }
}
//连接成功
- (void)customBleDidConnectPeripheral:(ZKPeripheral *)peripheral{
    if ([self.peri.peripheral isEqual:peripheral.peripheral]) {
        peripheral.peripheralDelegate = self;
    }
}
- (void)customBleDidDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    if ([self.peri.peripheral isEqual:peripheral]) {
        _isInstalling = NO;
    }
}


#pragma mark ===ZKPeripheralDelegate===
//接收值
- (void)customPeripheral:(ZKPeripheral*)peripheral DidUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    //升级-Identify
    if ([characteristic isEqual:self.peri.chc_Identify]) {
        ZKLog(@"chc_Identify:%@",characteristic.value);
        int16_t version =0;
        if (characteristic.value) {
            [characteristic.value getBytes:&version range:NSMakeRange(0, 2)];
            if (version>=_version) {
                [ZKAlertView showError:@"当前固件版本高于升级固件版本" viewController:self Completion:^{
                    int buff = 0xffff;
                    [self.peri sendSysFirmwareData:[NSData dataWithBytes:&buff length:2]];
                }];
            }
        }
    }
    //升级-Block
    if ([characteristic isEqual:self.peri.chc_Block]) {
        ZKLog(@"chc_Block:%@",characteristic.value);
        NSData *value = characteristic.value;
        int16_t buff ;
        [value getBytes:&buff range:NSMakeRange(0, 2)];
        if (buff==0) {
            ZKLog(@"开始升级");
            [self.progressView setHidden:NO];
            [self.progressLabel setHidden:NO];
            [self.upgradeButton setTitle:@"正在升级" forState:UIControlStateNormal];
            _isInstalling = YES;
        }
        
        [self.progressView setRatio:(buff+1)*1.0/self.file.trunks];
        [self.progressLabel setText:[NSString stringWithFormat:@"%.2f%%",(buff+1)*100.0/self.file.trunks]];
//        [self.progressLabel sizeToFit];
        if (buff >= self.file.trunks) {
            return;
        }
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(isUpgradeInterruptTimeOut) object:nil];
        //检测升级是否中断
        if (buff<self.file.trunks-1) {
            [self performSelector:@selector(isUpgradeInterruptTimeOut) withObject:nil afterDelay:2];
        }
       
        if (!_isInstalling) {
            return;
        }
        ZKLog(@"chc_Block:%@  -- %d",characteristic.value,buff);
        NSData *firstData = [self.file readDataWithChunk:buff];
        NSMutableData *tempdata = [NSMutableData dataWithData:value];
        [tempdata appendData:firstData];
        [self.peri sendSysFirmwareData:tempdata];
    }
    //升级-Status
    if ([characteristic isEqual:self.peri.chc_Status]) {
        NSData *value = characteristic.value;
        int buff = 0;
        [value getBytes:&buff range:NSMakeRange(0, 1)];
        if (buff==0) {
            ZKLog(@"完成升级");
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(isUpgradeInterruptTimeOut) object:nil];

            [self.progressView setHidden:YES];
            [self.progressLabel setHidden:YES];
            _isInstalling = NO;
            [self.upgradeButton setTitle:@"立即升级" forState:UIControlStateNormal];
            [ZKAlertView showSuccess:@"完成升级" viewController:self Completion:^{}];
        }else{
            if (_isInstalling) {//中断升级
                _isInstalling = NO;
                [self.upgradeButton setTitle:@"立即升级" forState:UIControlStateNormal];
                [self.progressView setHidden:YES];
                [self.progressLabel setHidden:YES];
                
                [ZKNotificationView show:[NSString stringWithFormat:@"升级失败! 状态码：%d",buff] delay:1.5 willShowBlock:^{
                    
                } Tapblock:^{
                    
                } didShowBlock:^{
                    
                }];
//                [ZKAlertView showError:@"升级中断" viewController:self Completion:^{}];
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(isUpgradeInterruptTimeOut) object:nil];
            }else{
                [ZKNotificationView show:[NSString stringWithFormat:@"升级失败! 状态码：%d",buff] delay:1.5 willShowBlock:^{
                } Tapblock:^{
                    
                } didShowBlock:^{
                    
                }];
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(isUpgradeInterruptTimeOut) object:nil];
            }
        }
        ZKLog(@"chc_Status:%@",characteristic.value);
    }
}

//
-(void)isUpgradeInterruptTimeOut{
    ZKLog(@"升级中断");
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(isUpgradeInterruptTimeOut) object:nil];
    if (_isInstalling) {//中断升级
        //发送错误数据 中断升级
        int buff = 0xffff;
        [self.peri sendSysFirmwareData:[NSData dataWithBytes:&buff length:2]];
    }
    _isInstalling = NO;
    [self.upgradeButton setTitle:@"立即升级" forState:UIControlStateNormal];
    [self.progressView setHidden:YES];
    [self.progressLabel setHidden:YES];
    [ZKAlertView showError:@"升级中断" viewController:self Completion:^{
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.detaileLabel setHidden:!self.detaileLabel.hidden];
}

-(void)dealloc{
//    [self.peri removeObserver:self forKeyPath:@"firmware"];
    [self.task cancel];
    self.task = nil;
}
@end
