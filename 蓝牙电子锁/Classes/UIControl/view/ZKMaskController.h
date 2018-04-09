//
//  ZKMaskController.h
//  蓝牙电子锁
//
//  Created by mosaic on 2017/12/13.
//  Copyright © 2017年 mosaic. All rights reserved.
//

// 弹框

#import <UIKit/UIKit.h>
typedef void (^MaskSure)(NSString*codeStr,BOOL isCancel);

@interface ZKMaskController : UIViewController

@property (nonatomic,weak)UIView *backgroundView;
@property (nonatomic,weak)UITextField *inputCodeField;
@property (nonatomic,weak)ZKButton *cancelButton;
@property (nonatomic,weak)ZKButton *sureButton;

@property (nonatomic,copy)NSString *titleStr;

-(void)getResultBlock:(MaskSure)mask;

@end
