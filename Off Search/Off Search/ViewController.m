//                                                                             / \
//  ViewController.m                                                          /   \
//  No connection Dictionary                                                 /     \
//                                                                           ここ選択すると  TODOコロン ~  で記述したコメントを見ることができる
//  Created by Shinya Hirai on 2013/11/22.　　　　　　　　　　　　　　　　　　　　　#pragma mark を記述したところでグループ分けをしてくれるので見やすくなる
//  Copyright (c) 2013年 Shinya Hirai. All rights reserved.                  下記コメントにて説明
//


/*
 【ネットに繋がなくても使える辞書アプリ】
 このアプリは、インターネットに接続されていなくても使える辞書アプリです。
 Wi-fiがないと携帯が使えない海外なんかで活躍するでしょう。
 
 【コード説明】
 データの保存には、iOSでのデータ保存に特化した専用の上位フレームワーク[Core Data]を使用。
 かなりハードルが高いがTableViewとの相性が良い。
 
 コード内のコメントに多々出てくる  // TODOコロン ~  という記述の仕方で右上に書いてあるコメントの部分を
 タップするとTODO管理ができる。
 
 #pragma mark -
 #pragma mark コメント
 という記述は同じく右上のバーの部分をタップして見た時に、コードのグループ分けがされた状態で表示される。
 
 
 */

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController {
    NSString* _nowSearchStr;
    NSMutableArray* _beforeHistoryArr;
    NSMutableArray* _afterhistoryArr;
    
    // ローディング画面用変数
    UIView *_loadingViewGround;
    UIView *_loadingView;
    UIActivityIndicatorView *_indicatorView;
    UILabel *_processinglabel;
}

@synthesize adBannerView;

#pragma mark adBannerView
//広告の初期化
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    adBannerView = [[ADBannerView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 50.0)];
    adBannerView.delegate = self;
    [adBannerView setHidden:YES];
//    CGRect bannerFrame = adBannerView.frame;
//    bannerFrame.origin.y = self.view.frame.size.height - self.navigationBar.frame.size.height - adBannerView.frame.size.height;
//    self.adBannerView.frame = bannerFrame;
    [self.view addSubview:adBannerView];
}

//広告の在庫がある場合は表示する
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [banner setHidden:NO];
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner {
}

//広告の在庫がない場合は非表示にする
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [banner setHidden:YES];
}

#pragma mark -
#pragma mark roading view
-(void) indicatorStart {
    // スタートメソッド
    // 元となるViewをつくる
    _loadingViewGround = [[UIView alloc] initWithFrame:[[self view] bounds]];
    [self.view addSubview:_loadingViewGround];
    
    // 丸みを帯びた土台となるViewをつくる
    _loadingView = [[UIView alloc] initWithFrame:CGRectMake(60,100,200,110)];
    [_loadingView setBackgroundColor:[UIColor lightGrayColor]];
    _loadingView.layer.cornerRadius = 10;
    _loadingView.clipsToBounds = YES;
    [_loadingView setAlpha:0.0];
    [_loadingViewGround addSubview:_loadingView];
    
    // indicator(処理中を知らせるためのクルクル回るあれ)をつくる
    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_indicatorView setFrame:CGRectMake (79, 15, 40, 40)];
    [_indicatorView setAlpha:0.0];
    [_loadingView addSubview:_indicatorView];
    
    // 処理中のコメント表示用ラベルをつくる
    _processinglabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 26, 200,90)];
    _processinglabel.text = @"読み込み中...";
    _processinglabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:18.0f];
    _processinglabel.textAlignment = 1;
    _processinglabel.backgroundColor = [UIColor clearColor];
    _processinglabel.textColor = [UIColor whiteColor];
    [_processinglabel setAlpha:0.0];
    [_loadingView addSubview:_processinglabel];
    
    [_indicatorView startAnimating];
    
    // 0.5秒かけてフワッとローディング画面がでるようにするアニメーション
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
    [_loadingView setAlpha:0.4];
    [_indicatorView setAlpha:1.0];
    [_processinglabel setAlpha:1.0];
	[UIView commitAnimations];
}

-(void) indicatorStop {
    // ストップメソッド
    [_indicatorView stopAnimating];
    [_loadingViewGround removeFromSuperview];
    [_loadingView removeFromSuperview];
}

#pragma mark -

- (NSManagedObject *)checkDupulicationInEntity:(NSString *) entityName withKey:(NSString *)keyString withValue:(NSString *)valueString {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entityName];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", keyString, valueString];
    [fetchRequest setPredicate:predicate];
    NSLog(@"predicate keyString = %@", keyString);
    NSLog(@"predicate vavlueString = %@",valueString);

    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    NSLog(@"results = %@", results);
    
    if (results.count > 0) {
        return [results objectAtIndex:0];
    }
    
    return NULL;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
}

- (void)firstTime {
    // アプリが初めて起動された時だけこのif文を通し、アラートビューを使ってThanksメッセージを表示する。
    // NSUserDefaultsの取得
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // KEY_BOOLの内容を取得し、BOOL型変数へ格納
    BOOL isBool = [defaults boolForKey:@"KEY_BOOL"];
    // isBoolがNOの場合、...
    if (!isBool) {
    
        NSString* messageStr = @"ネットにまったく繋がっていない状態でも、調べたい単語をその場ですぐに調べることができるアプリです。";
    
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"ノーネット辞書とは"
                                                            message:messageStr
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
        [alertView show];
        
        // KEY_BOOLにYESを設定
        [defaults setBool:YES forKey:@"KEY_BOOL"];
        // 設定を保存
        [defaults synchronize];
        NSLog(@"アプリをダウンロードして初回起動時のみ処理");
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self firstTime];
    // TableView
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    // SearchBar
    _searchBar.delegate = self;
    _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    _searchBar.spellCheckingType = UITextSpellCheckingTypeNo;
    [UISearchBar appearance].barTintColor = [UIColor colorWithRed:1.00 green:0.39 blue:0.28 alpha:1.00];
    [UISearchBar appearance].tintColor = [UIColor whiteColor];
    
    // Core Data 用
    _objectChanges = [NSMutableArray array];
    _sectionChanges = [NSMutableArray array];
    
    /*
     キーボードが表示された時の通知を登録する
     2種類の書き方がある
     */
    // 1
    NSNotificationCenter *center;
    center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    // 2
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    
    // NavigationBarの右側にセッティング画面に遷移するためのボタンを作成
    // TODO: 広告解除用     UINavigationBar* navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
    UINavigationBar* navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 70, 320, 44)];
    // NavigationItemを生成
    UINavigationItem *navTitle = [[UINavigationItem alloc] initWithTitle:@"ノーネット辞書"];
    // 設定ボタン生成
    UIBarButtonItem *btn1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(pushSettingButton)];
    // NavigationBarの表示
    navTitle.rightBarButtonItem = btn1;
    [navBar pushNavigationItem:navTitle animated:YES];
    [UINavigationBar appearance].barTintColor = [UIColor colorWithRed:1.00 green:0.39 blue:0.28 alpha:1.00];
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    
    // TODO: 広告解除用     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"Header"];

    [self.view addSubview:navBar];
}

- (void)pushSettingButton {
    // セッティング画面にはコードで遷移
    SettingViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingViewController"];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark tableview

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    
//    return [NSString stringWithFormat:@"セクション%d", section];
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *tableViewHeader = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"Header"];
    tableViewHeader.textLabel.text = @"履歴";
    tableViewHeader.textLabel.textColor = [UIColor colorWithRed:0.13 green:0.55 blue:0.13 alpha:1.00];
    return tableViewHeader;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections] [section];
    return [sectionInfo numberOfObjects];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Cellの生成と初期化
    static NSString* cellIdentifier = @"Cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];

    cell.textLabel.text = [object valueForKey:@"history"];
    cell.textLabel.textColor = [UIColor colorWithRed:1.00 green:0.39 blue:0.28 alpha:1.00];
    
    // 検索日時表示用ラベル
    // deleteのあとにもう一度データを入れると時間がダブルバグが残ってる
    // 予測：多分時間表示のラベルが自作ラベルのため、CoreData + TableViewの削除ではキャッシュが残ってて消えない
//    UILabel* rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(220,12, 100, 20)];
//    NSDateFormatter* df = [[NSDateFormatter alloc] init];
//    df.dateFormat = @"MM/dd HH:mm";
//    rightLabel.text = [df stringFromDate:[object valueForKey:@"added"]];
//    rightLabel.textColor = [UIColor grayColor];
//    [cell addSubview:rightLabel];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self indicatorStart];
    NSString* term = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    if (term) {
        UIReferenceLibraryViewController* libraryViewController = [[UIReferenceLibraryViewController alloc] initWithTerm:term];
        [self presentViewController:libraryViewController animated:YES completion:^(void){
                                                                                [self indicatorStop];
                                                                                }];
    } else {
        // こいつ何？
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    _searchBar.text = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    
    
    /*
     Core Dataに保存する処理
     */
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    // _nowSearchStrがnil,nullではなく、文字の長さが0ではなければ、要するに空でなければCore Dataに保存し、tableviewに履歴として表示
    if (![_nowSearchStr isEqual:[NSNull null]] && [_nowSearchStr length] > 0) {
        NSLog(@"_nowSearchStr = %@",_nowSearchStr);
        NSLog(@"_searchBar.text= %@",_searchBar.text);
        
        NSManagedObject *checkForDuplicate = [self checkDupulicationInEntity:NSStringFromClass([History class]) withKey:@"history" withValue:_nowSearchStr];
        if (checkForDuplicate == NULL) {
            // 重複がない場合はここに処理を書く
            // エンティティはHistoryという名前のNSManagedObjectのサブクラス。
            NSManagedObjectContext *context = [appDelegate managedObjectContext];
            NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"History" inManagedObjectContext:context];
            
            // 検索した日時のデータと検索したワードをCore Dataに保存
            [newManagedObject setValue:[NSDate date] forKey:@"added"];
            [newManagedObject setValue:_nowSearchStr forKey:@"history"];
            
            // Save the context.
            NSError *error = nil;
            if (![context save:&error]) {
                // もしエラーなら内容を表示
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            } else {
                NSLog(@"save to coredata");
            }
            
        }else{
            // 重複があった場合はここに処理を書く
            NSLog(@"重複 : %@", [checkForDuplicate description]);
        }
        
    } else {
        NSLog(@"検索窓は空");
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Cellが編集処理に入った時のメソッド
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark -
#pragma mark search bar & keyboard
- (void)keyboardWillShow:(NSNotification*)notification {
    /*
     キーボードが表示される前にイベントをキャッチして処理をする
     */
    
    CGSize screenSize = [[UIScreen mainScreen] applicationFrame].size;
    
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    // UIViewAnimationCurve　を UIViewAnimationOptionに変換
    UIViewAnimationOptions animationOptions = animationCurve << 16;
    
    // keyboard の上に TextField を移動する
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:animationOptions
                     animations:^{
                         // 1. キーボードの top を取得する
                         CGRect keyboardFrame;
                         keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
                         
                         CGFloat keyboardTop = [[UIScreen mainScreen] bounds].size.height - (keyboardFrame.size.height + 44.f );   // 55.f:予測変換領域の高さ
                         NSLog(@"keyboardtop = %f",keyboardTop);
                         
                         float heightSize = [[UIScreen mainScreen] bounds].size.height;
                         if (heightSize == 568.000000) {
                             NSLog(@"device 568 = %f",heightSize);
                             // キーボードの高さで条件分岐
                             if (keyboardTop == 308.000000) {
                                 // キーボードの高さ + searchBarの高さを引いたサイズでtableviewを表示
                                 // TODO: 広告解除用     _tableView.frame = CGRectMake(0, 64, 320, screenSize.height - (keyboardTop - 4.f));
                                 _tableView.frame = CGRectMake(0, 114, 320, screenSize.height - (keyboardTop + 46.f));
                             } else if (keyboardTop == 272.000000) {
                                 // キーボードの高さ + 日本語変換が出た場合の高さ + searchBarの高さを引いたサイズでtableviewを表示
                                 // TODO: 広告解除用     _tableView.frame = CGRectMake(0, 64, 320, screenSize.height - (keyboardTop + 68.f));
                                 _tableView.frame = CGRectMake(0, 114, 320, screenSize.height - (keyboardTop + 118.f));
                             }
                             _searchBar.frame = CGRectMake(0, keyboardTop, 320, 44);
                             _searchBar.showsCancelButton = YES;
                             
                         } else if (heightSize == 480.000000) {
                             NSLog(@"device 480 = %f",heightSize);
                             // キーボードの高さで条件分岐
                             if (keyboardTop == 220.000000) {
                                 // キーボードの高さ + searchBarの高さを引いたサイズでtableviewを表示
                                 // TODO: 広告解除用     _tableView.frame = CGRectMake(0, 64, 320, screenSize.height - (keyboardTop - 4.f));
                                 _tableView.frame = CGRectMake(0, 114, 320, screenSize.height - (keyboardTop + 134.f));
                             } else if (keyboardTop == 184.000000) {
                                 // キーボードの高さ + 日本語変換が出た場合の高さ + searchBarの高さを引いたサイズでtableviewを表示
                                 // TODO: 広告解除用     _tableView.frame = CGRectMake(0, 64, 320, screenSize.height - (keyboardTop + 68.f));
                                 _tableView.frame = CGRectMake(0, 114, 320, screenSize.height - (keyboardTop + 206.f));
                             }
                             _searchBar.frame = CGRectMake(0, keyboardTop, 320, 44);
                             _searchBar.showsCancelButton = YES;
                             
                         } else {
                             NSLog(@"device else = %f",heightSize);
                         }
                     }
                     completion:^(BOOL finished) {}];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    // UIViewAnimationCurve　を UIViewAnimationOptionに変換
    UIViewAnimationOptions animationOptions = animationCurve << 16;
    
    // 元の位置に戻す
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:animationOptions
                     animations:^{
                         CGSize screenSize = [[UIScreen mainScreen] applicationFrame].size;
                         _searchBar.frame = CGRectMake(0, screenSize.height - 24, 320, 44);
                         _searchBar.showsCancelButton = NO;
                         // TODO: 広告解除用     _tableView.frame = CGRectMake(0, 64, 320, screenSize.height - 88);
                         _tableView.frame = CGRectMake(0, 114, 320, screenSize.height - 138);
                     }
                     completion:^(BOOL finished) {}];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // 検索ボタンが押された時の処理
    [self indicatorStart];
    [_searchBar resignFirstResponder];
    _searchBar.showsCancelButton = NO;
    UIReferenceLibraryViewController* libraryViewController = [[UIReferenceLibraryViewController alloc] initWithTerm:_searchBar.text];
    [self presentViewController:libraryViewController animated:YES completion:^(void){
        NSLog(@"_nowSearchStr = %@",_nowSearchStr);
        NSLog(@"_searchBar.text= %@",_searchBar.text);

        [self indicatorStop];
        
        /*
         Core Dataに保存する処理
         */
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        
        // _nowSearchStrがnil,nullではなく、文字の長さが0ではなければ、要するに空でなければCore Dataに保存し、tableviewに履歴として表示
        if (![_nowSearchStr isEqual:[NSNull null]] && [_nowSearchStr length] > 0) {
            
            NSManagedObject *checkForDuplicate = [self checkDupulicationInEntity:NSStringFromClass([History class]) withKey:@"history" withValue:_nowSearchStr];
            if (checkForDuplicate == NULL) {
                // 重複がない場合はここに処理を書く
                // エンティティはHistoryという名前のNSManagedObjectのサブクラス。
                NSManagedObjectContext *context = [appDelegate managedObjectContext];
                NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"History" inManagedObjectContext:context];
                
                // 検索した日時のデータと検索したワードをCore Dataに保存
                [newManagedObject setValue:[NSDate date] forKey:@"added"];
                [newManagedObject setValue:_nowSearchStr forKey:@"history"];
                
                // Save the context.
                NSError *error = nil;
                if (![context save:&error]) {
                    // もしエラーなら内容を表示
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                } else {
                    NSLog(@"save to coredata");
                }
                
            }else{
                // 重複があった場合はここに処理を書く
                NSLog(@"重複 : %@", [checkForDuplicate description]);
            }
            
        } else {
            NSLog(@"検索窓は空");
        }
    }];
    // 検索した文字を履歴データとして保存
    _nowSearchStr = [[NSString alloc] init];
    _nowSearchStr = _searchBar.text;
}

//- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    // _searchBarがタップされた時の処理
    // keyboardWillShowメソッドに移植したので現在は未使用
//}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    // キャンセルボタンが押された時の処理
    [_searchBar resignFirstResponder];
}

#pragma mark -
#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"History" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"added" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[object valueForKey:@"timeStamp"] description];
}

@end
