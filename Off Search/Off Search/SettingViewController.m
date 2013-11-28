//
//  SettingViewController.m
//  No connection Dictionary
//
//  Created by Shinya Hirai on 2013/11/24.
//  Copyright (c) 2013年 Shinya Hirai. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)pushbackButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // tableview
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    /* NavigationBar */
    UINavigationBar* navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
    // NavigationItemを生成
    UINavigationItem *navTitle = [[UINavigationItem alloc] initWithTitle:@"アプリ情報"];
    // 設定ボタン生成
    UIBarButtonItem *btn1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(pushbackButton)];
    // NavigationBarの表示
    navTitle.rightBarButtonItem = btn1;
    [navBar pushNavigationItem:navTitle animated:YES];
    
    [self.view addSubview:navBar];
    
    // ステータスバーの文字色をViewごとに切り替える
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        //viewControllerで制御することを伝える。iOS7 からできたメソッド
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

#pragma mark -
#pragma mark status bar
- (BOOL)prefersStatusBarHidden {
    //YESでステータスバーを非表示（NOなら表示）
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    //文字を白くする
    return UIStatusBarStyleLightContent;
}

#pragma mark -
#pragma mark Cell function

- (void)postSocial {
    // UIActivityViewControllerはソーシャル等に共有する機能を持ったViewを下からmodalでだしてくれる
    // 今回はSettingの中の共有ボタンで使用
    NSString *text = @"Hello World!";
    NSURL* url = [NSURL URLWithString:@"http://nonetdictionary.com"];  // テストURL挿入
    NSArray* actItems = [NSArray arrayWithObjects: text, url, nil];
    NSLog(@"actItems = %@",actItems);
    
    UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:actItems applicationActivities:nil];
    [self presentViewController:activityView animated:YES completion:nil];
}

- (void)deleteHistory {
    // 履歴一括削除ボタンを押した時の処理
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"履歴一括削除"
                                                        message:@"検索履歴を全部削除します"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        // AppDelegateからManagedObjectContextを召喚
        AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        
        NSFetchRequest * allHistoryRequest = [[NSFetchRequest alloc] init];
        [allHistoryRequest setEntity:[NSEntityDescription entityForName:@"History" inManagedObjectContext:context]];
        [allHistoryRequest setIncludesPropertyValues:NO];
        
        NSError * error = nil;
        NSArray * history = [context executeFetchRequest:allHistoryRequest error:&error];
        
        //error handling goes here
        for (NSManagedObject * his in history) {
            [context deleteObject:his];
        }
        NSError *saveError = nil;
        [context save:&saveError];
        //more error handling here
        NSLog(@"OKが押された時にこの処理がされているか確認");
    }
}

#pragma mark -
#pragma mark tableview

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    if (section == 0) {
//        return nil;
//    } else if (section == 1) {
//        return @"入力履歴";
//    } else {
//        return @"ノーネット辞書について";
//    }
    if (section == 0) {
        return @"入力履歴";
    } else {
        return @"ノーネット辞書について";
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // 条件分岐処理が簡単な命令で行えるため、switchを使用
    switch (section) {
        case 1:
            return 2;
            break;
        default:
            return 1;
            break;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Cellの生成と初期化
    static NSString* cellIdentifier = @"Cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // 条件分岐処理が難しい命令を挟むため、else if 等を使用
//    if (indexPath.section == 0) {
//        cell.textLabel.text = @"広告の削除";
//    } else if (indexPath.section == 2 && indexPath.row == 0){
//        cell.textLabel.text = @"バージョン";
//        
//        // バージョン表示用ラベル
//        UILabel* rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(260,12, 100, 20)];
//        // アプリバージョン情報
//        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//        rightLabel.text = version;
//        rightLabel.textColor = [UIColor grayColor];
//        [cell addSubview:rightLabel];
//
//    } else if (indexPath.section == 2 && indexPath.row == 1) {
//        cell.textLabel.text = @"友達にこのアプリを共有";
//    } else {
//        cell.textLabel.text = @"履歴の一括削除";
//    }

    if (indexPath.section == 0) {
        cell.textLabel.text = @"履歴の一括削除";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.section == 1 && indexPath.row == 0){
        cell.textLabel.text = @"バージョン";
        
        // バージョン表示用ラベル
        UILabel* rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(260,12, 100, 20)];
        // アプリバージョン情報
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        rightLabel.text = version;
        rightLabel.textColor = [UIColor grayColor];
        [cell addSubview:rightLabel];
        
    } else {
        cell.textLabel.text = @"友達にこのアプリを共有";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.textColor = [UIColor colorWithRed:1.00 green:0.39 blue:0.28 alpha:1.00];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 0) {
//        // 広告削除(有料)機能実装予定
//    } else if (indexPath.section == 2 && indexPath.row == 0) {
//        // バージョン確認機能
//        
//    } else if (indexPath.section == 2 && indexPath.row == 1) {
//        // Social共有機能
//        [self postSocial];
//    } else {
//        // 履歴削除機能
//        [self deleteHistory];
//    }

    if (indexPath.section == 0) {
        // 履歴削除機能
        [self deleteHistory];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        // バージョン確認機能
        
    } else {
        // Social共有機能
        [self postSocial];
    }}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
