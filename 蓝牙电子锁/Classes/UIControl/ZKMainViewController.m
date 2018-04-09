//
//  ZKMainViewController.m
//  蓝牙电子锁
//
//  Created by mosaic on 2017/12/12.
//  Copyright © 2017年 mosaic. All rights reserved.
//

#import "ZKMainViewController.h"
#import "ZKAddBLEController.h"
#import "ZKUnlockController.h"
#import "ZKMainTableCell.h"
@interface ZKMainViewController ()<UITableViewDelegate,UITableViewDataSource,ZKPeripheralDelegate>

@property (nonatomic,weak)UITableView *tableView;

@property (nonatomic,weak)ZKButton *addDevButton;


@end

@implementation ZKMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
}
//
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [ZKBleManager sharedZKBleManager].scanType = BLEAutoConnectScanning;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.tableView reloadData];

}


//创建UI
-(void)createUI{
    //navagitonbar
    self.title = @"镶阳智能电子锁";
   self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    //addDevButton
    ZKButton *addDevButton = [[ZKButton alloc]init];
    [addDevButton setImage:[UIImage imageNamed:@"添加按钮.png"] forState:UIControlStateNormal];
    [addDevButton setImage:[UIImage imageNamed:@"添加按钮.png"] forState:UIControlStateHighlighted];
    [addDevButton setTitle:@"添加设备" forState:UIControlStateNormal];
    [addDevButton setFrame:CGRectMake(relative_w(236),ZKSCREEN_H-relative_h(110)-relative_h(150) , relative_w(610), relative_h(110))];
    [addDevButton setBackgroundColor:[UIColor colorWithHexString:@"FF3956"] forState:UIControlStateNormal];
    [addDevButton setBackgroundColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [addDevButton.layer setCornerRadius:relative_h(110)/2];
    [addDevButton setImageFrame:CGRectMake(relative_w(200), relative_h(35), relative_w(45), relative_h(45))];
    [addDevButton.titleLabel setFont:LabelFount(15)];
    [addDevButton.titleLabel sizeToFit];
    CGFloat titleLabel_x = relative_w(200)+ relative_w(45)+relative_w(20);
    CGFloat titleLabel_w = addDevButton.titleLabel.width;
    CGFloat titleLabel_h = addDevButton.titleLabel.height;
    CGFloat titleLabel_y = (relative_h(110)-titleLabel_h)/2;
    [addDevButton setTitleFrame:CGRectMake(titleLabel_x, titleLabel_y, titleLabel_w, titleLabel_h)];
    [self.view addSubview:addDevButton];
    self.addDevButton = addDevButton;
    [self.addDevButton addTarget:self action:@selector(addDevButtonClick:) forControlEvents:UIControlEventTouchUpInside];

    //tableView
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(relative_w(70), 64+relative_h(200), relative_w(576), relative_h(1100)) style:UITableViewStylePlain];
    [tableView setBackgroundColor:[UIColor clearColor]];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsVerticalScrollIndicator = NO;
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

-(void)addDevButtonClick:(UIButton*)sender{
    ZKAddBLEController *addVC = [[ZKAddBLEController alloc]init];
    [self.navigationController pushViewController:addVC animated:YES];
    
}


#pragma mark ==UITableViewDataSource==
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}


- (ZKMainTableCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"ZKMainViewController";
    ZKMainTableCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[ZKMainTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        [cell setClipsToBounds:YES];
        [cell.layer setCornerRadius:8];
        [cell setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.7]];
    }
   ZKPeripheral*per = [ZKCommonData sharedZKCommonData].matchPer[indexPath.section];
    per.peripheralDelegate = self;
    ZKCommonData*dataManager = [ZKCommonData sharedZKCommonData];
    for (ZKPeripheral*temper in dataManager.connectedPer){
        if ([temper.identifier isEqualToString:per.identifier]) {
            temper.peripheralDelegate = self;
        }
    }
    if (per.note_name.length>0) {
//        if (per.RSSI) {
//            cell.nameStr = [NSString stringWithFormat:@"%@:%@",per.note_name,per.RSSI];
//        }else{
//            cell.nameStr = [NSString stringWithFormat:@"%@",per.note_name];
//        }
        cell.nameStr = [NSString stringWithFormat:@"%@",per.note_name];
    }else{
        cell.nameStr = per.peripheral.name;
    }
    if (per.type.intValue==1) {
        cell.detailStr = @"管理员";
    }else{
        cell.detailStr = @"";
    }
    [cell.accImgV setImage:[UIImage imageNamed:@"下一级按钮.png"]];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [ZKCommonData sharedZKCommonData].matchPer.count;;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return relative_h(20);
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    return relative_h(120);
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    static NSString *footerId = @"ZKMainViewController_footer";
    UITableViewHeaderFooterView *footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:footerId];
    if (!footer) {
      footer =  [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:footerId];
    }
    return footer;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        ((UITableViewHeaderFooterView *)view).backgroundView.backgroundColor = [UIColor clearColor];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ZKUnlockController *unlockVC = [[ZKUnlockController alloc]init];
    unlockVC.zkper = [ZKCommonData sharedZKCommonData].matchPer[indexPath.section];
    //判断设备
   ZKCommonData*dataManager = [ZKCommonData sharedZKCommonData];
    for (ZKPeripheral*temper in dataManager.connectedPer) {
        if (!unlockVC.zkper.peripheral) {
            if ([unlockVC.zkper.identifier isEqualToString:
                 temper.peripheral.identifier.UUIDString ]) {
                unlockVC.zkper = temper;
            }
        }
    }
    ZKLog(@"%@:%@",unlockVC.zkper.peripheral,unlockVC.zkper.identifier);
    
    
    [self.navigationController pushViewController:unlockVC animated:YES];
}


- (void)customPeripheralDidReadRSSI:(ZKPeripheral*)peripheral error:(NSError *)error{
//    ZKLog(@"%@",peripheral);
//    ZKLog(@"%@",peripheral.RSSI)
//    NSUInteger section;
//    for (ZKPeripheral *per in [ZKCommonData sharedZKCommonData].matchPer) {
//        if ([per.identifier isEqualToString:peripheral.identifier]) {
//             section =  [[ZKCommonData sharedZKCommonData].matchPer indexOfObject:per];
//            NSIndexPath*indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
//            ZKMainTableCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//            if (peripheral.note_name.length>0) {
//
//                cell.nameStr = [NSString stringWithFormat:@"%@:%@",peripheral.note_name,peripheral.RSSI];
//            }else{
//                cell.nameStr = peripheral.peripheral.name;
//            }
//        }
//    }
    
    
    
}


@end
