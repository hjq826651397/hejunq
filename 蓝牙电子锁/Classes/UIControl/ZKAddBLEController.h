//
//  ZKAddBLEController.h
//  蓝牙电子锁
//
//  Created by mosaic on 2017/12/2.
//  Copyright © 2017年 mosaic. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface ZKAddBLEController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic)  UITableView *tableView;
@property (weak, nonatomic)  UITextField *codeText;



@end
