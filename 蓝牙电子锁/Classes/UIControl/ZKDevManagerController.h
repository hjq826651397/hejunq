//
//  ZKDevManagerController.h
//  蓝牙电子锁
//
//  Created by mosaic on 2018/1/12.
//  Copyright © 2018年 mosaic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZKPeripheral.h"

@interface ZKDevManagerController : UIViewController
@property(nonatomic,weak)ZKPeripheral*perip;
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@end
