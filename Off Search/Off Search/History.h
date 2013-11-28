//
//  History.h
//  No connection Dictionary
//
//  Created by Shinya Hirai on 2013/11/23.
//  Copyright (c) 2013年 Shinya Hirai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface History : NSManagedObject

@property (nonatomic, retain) NSString * history;
@property (nonatomic, retain) NSDate * added;

@end
