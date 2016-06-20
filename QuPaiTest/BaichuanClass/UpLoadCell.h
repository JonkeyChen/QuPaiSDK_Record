//
//  UpLoadCell.h
//  BaiChuanTest
//
//  Created by 陈胜华 on 16/6/20.
//  Copyright © 2016年 oneyd.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALBBMedia.h"


typedef NS_ENUM(NSUInteger, LoadStatus) {
    LoadStatusReady = 0,
    LoadStatusSuccess = 1,
    LoadStatusFailed = 2,
    LoadStatusUploading = 3,
    LoadStatusCancel = 4
};

typedef void (^DeleteRow) (int row);

@class UpLoadCell,UpLoadViewController;
@protocol UpLoadCellDelegate <NSObject>

- (void)upLoadCell:(UpLoadCell*)cell withData:(NSMutableDictionary*)data withLoadStatus:(LoadStatus)loadStatus;
@optional
- (void)upLoadCell:(UpLoadCell*)cell withIndexPath:(NSInteger)indexPath withData:(NSMutableDictionary*)data;

@end

@interface UpLoadCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIImageView *evimgeHeader;
@property (nonatomic,weak) IBOutlet UILabel *evlblImageName;
@property (nonatomic,weak) IBOutlet UILabel *evlblStatus;
@property (nonatomic,weak) IBOutlet UILabel *evlblImageSize;
@property (nonatomic,weak) IBOutlet UILabel *evlblUpLoadInfo;

@property (nonatomic,weak) IBOutlet UIButton *evbtnApiPicture;
@property (nonatomic,weak) IBOutlet UIButton *evbtnApiData;
@property (nonatomic,weak) IBOutlet UIButton *evbtnApiFile;
@property (nonatomic,weak) IBOutlet UIButton *evbtnCancleUpLoad;

@property (nonatomic,weak) IBOutlet UIView *evProgressContent;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *evProgressToRightProgress;

@property (copy,   nonatomic) DeleteRow deleteRow;
@property (assign, nonatomic) NSInteger row;
@property (strong, nonatomic) NSMutableDictionary *data;

@property (assign, nonatomic) id<UpLoadCellDelegate> delegate;

@end
