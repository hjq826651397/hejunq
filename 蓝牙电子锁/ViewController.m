//
//  ViewController.m
//  蓝牙电子锁
//
//  Created by mosaic on 2017/11/14.
//  Copyright © 2017年 mosaic. All rights reserved.
//

#import "ViewController.h"

#import "ZKAddBLEController.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,ZKBleManagerDelegate>
@property (nonatomic,strong)NSMutableArray <ZKPeripheral*>*bleArray;

@property (nonatomic,weak)ZKBleManager*manager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UICKeyChainStore*keychainStore=[UICKeyChainStore keyChainStoreWithService:@"自定义存储"];
    //    [keychainStore setData:@”NSData类型的“ forKey:@"passwordabc"];
    NSString *_passWordStr = [keychainStore stringForKey:@"passwordabc"];
    if (!_passWordStr||_passWordStr.length==0) {
        NSString *deviceUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        keychainStore[@"passwordabc"] = deviceUUID;
    }else{
        ZKLog(@"%@",_passWordStr);
    }
    
    ZKLog(@"%@",[ZKCommonData sharedZKCommonData].matchPer);
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSMutableArray *)bleArray{
    if (!_bleArray) {
        _bleArray = [NSMutableArray array];
    }
    return _bleArray;
}

-(ZKBleManager *)manager{
    if (!_manager) {
        _manager = [ZKBleManager sharedZKBleManager];
    }
    _manager.centralDelegate = self;
    return _manager;
}

#pragma mark ==datasource==
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString*cellid = @"cellid";
    UITableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
   
    return cell;
}

#pragma mark == delegate ==
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    ZKPeripheral*peri = self.manager.perArray[indexPath.row];
//    [self.manager connectPeripheral:peri.peripheral];
}

- (IBAction)scanclick:(UIButton *)sender {

    ZKPeripheral *zkper = [[ZKPeripheral alloc]init];
    zkper.identifier = @"789216vfdve";
    zkper.note_name = @"你的scdsvv";
    zkper.auto_unlock = @(2);
//    zkper.type = @(10);
//    zkper.scene_id = @(9);
   [[ZKCommonData sharedZKCommonData] addPerToDatabase:zkper];
    ZKLog(@"%@",[ZKCommonData sharedZKCommonData].autoReconnectPer);
    
}

-(void)reloadTablew{
    [self.tableView reloadData];
}

//
-(void)bleDidDiscoverPeripheral:(ZKPeripheral*)per withInfo:(NSDictionary*)data{
    if ([per.peripheral.name isEqualToString:@"Light"]) {
        self.lable.text = per.RSSI.stringValue;
    }
}

- (IBAction)jumpBleVC:(UIButton *)sender {
    ZKAddBLEController* belVC = [[ZKAddBLEController alloc]init];
    [self.navigationController pushViewController:belVC animated:YES];
}




@end
