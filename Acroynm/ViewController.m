//
//  ViewController.m
//  Acroynm
//
//  Created by Kumar, Prem on 1/12/17.
//  Copyright © 2017 Kumar, Prem. All rights reserved.
//

#import "ViewController.h"


//Necessary constants
NSString *const kURL = @"http://www.nactem.ac.uk/software/acromine/dictionary.py";
NSString *const kShortForm = @"sf";
NSString *const kLongForms = @"lfs";
NSString *const kLongForm = @"lf";
NSString *const kTextFormat = @"text/plain";

@interface ViewController ()

@end

@implementation ViewController
{
    NSMutableArray *resultArray;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Actions

- (IBAction)submitAction:(id)sender
{
    //Dismiss Simulator Keyboard to accomidate more space.
    [self.acronymTextField resignFirstResponder];
    
    NSString *acronym = self.acronymTextField.text;
    [self getResponseFromURL:acronym];
}

- (IBAction)clearAction:(id)sender
{
    self.acronymTextField.text = @"";
    [resultArray removeAllObjects];
    
    //Update UI on main thread.
    dispatch_async(dispatch_get_main_queue(), ^{
        [_resultTableView reloadData];
    });
}


#pragma mark Helper methods
//method to get the data
-(void)getResponseFromURL:(NSString *)acronym
{
    NSURL *URL = [NSURL URLWithString:kURL];
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    
    //Setting the Acceptable content types
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [sessionManager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:kTextFormat, nil]];
    
    NSDictionary *requestParameters = @{kShortForm : acronym};
    
    //Show Progress HUD on downloading data
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [sessionManager GET:URL.absoluteString parameters:requestParameters progress:nil success:^(NSURLSessionTask *task, NSData *responseObject) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *error;
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
            resultArray=[self getParsedData:jsonArray];
            
            //Update UI on main thread.
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //Hide Progress HUD after download.
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                NSString *meaning = [resultArray componentsJoinedByString:@"\n\n"];
                if([meaning isEqual: @""]){
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Result found" message:[NSString stringWithFormat:@""] preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *Ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
                    [alert addAction:Ok];
                    
                    [self presentViewController:alert animated:YES completion:nil];
                }
                
                [self.resultTableView reloadData];
            });
        });
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

//Parse Response data
-(NSMutableArray *)getParsedData:(NSArray *)responseData
{
    NSMutableArray *arrayOfMeanings = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in responseData)
    {
        NSArray *lfsArray=[dict valueForKey:kLongForms];
        for (NSDictionary *lfDict in lfsArray) {
            [arrayOfMeanings addObject:[lfDict valueForKey:kLongForm]];
        }
    }
    return arrayOfMeanings;
}

#pragma mark - TableView methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [resultArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *resultTableIdentifier = @"ResultTableItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:resultTableIdentifier];
    
    if(cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:resultTableIdentifier];
    
    cell.textLabel.text = [resultArray objectAtIndex:indexPath.row];

    return cell;
}

@end
