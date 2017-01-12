//
//  ViewController.h
//  Acroynm
//
//  Created by Kumar, Prem on 1/12/17.
//  Copyright © 2017 Kumar, Prem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"
#import "MBProgressHUD.h"

extern NSString *const kURL;
extern NSString *const kShortForm;
extern NSString *const kLongForms;
extern NSString *const kLongForm;
extern NSString *const kTextFormat;


@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *acronymTextField;
@property (strong, nonatomic) IBOutlet UITableView *resultTableView;

- (IBAction)clearAction:(id)sender;
- (IBAction)submitAction:(id)sender;

@end

