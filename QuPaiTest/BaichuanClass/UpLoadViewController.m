//
//  UpLoadViewController.m
//  BaiChuanTest
//
//  Created by 陈胜华 on 16/6/20.
//  Copyright © 2016年 oneyd.me. All rights reserved.
//

#import "UpLoadViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "NSURL+Extend.h"
#import <ALBBSDK/ALBBSDK.h>
#import "ALBBMedia.h"
#import "UpLoadCell.h"
#import "PlayerVideoViewController.h"

static NSString *const cellIndentifier = @"UpLoadViewCell";

@interface UpLoadViewController ()<UpLoadCellDelegate>{
    
    __weak IBOutlet UITableView *_evtblImagesList;
    
    UIImagePickerController *_picker;
    
    NSMutableArray<NSMutableDictionary*> *_imagesArray;
}


@end

@implementation UpLoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self efConfigure];
}

//配置UI及数据
- (void)efConfigure{

    _picker = ({
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = sourceType;
        picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeMovie, (NSString *) kUTTypeImage, nil];
        picker;
    });
    
    [_evtblImagesList registerNib:[UINib nibWithNibName:@"UpLoadCell" bundle:nil] forCellReuseIdentifier:cellIndentifier];
    
    _imagesArray = [NSMutableArray new];
}

/*********************************************************************/
- (IBAction)efOnClickSelectedPictures:(id)sender {

    NSLog(@"选择图片");
    
    [self presentViewController:_picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [_picker dismissViewControllerAnimated:YES completion:nil];
    
    NSURL *localUrl = [info valueForKey:UIImagePickerControllerReferenceURL];
    
    NSString *mediaurl = localUrl.absoluteString;
    
    
    BOOL flag = YES;
    
    for (NSDictionary *info in _imagesArray) {
        
        if ([mediaurl isEqualToString:[info objectForKey:@"assetsUrl"]]) {
            
            flag = NO;
            
            break;
        }
    }
    
    if (flag) {
        [_imagesArray addObject:[@{@"assetsUrl" : mediaurl,
                                  @"type" : @0,
                                  @"name" : [self uuidString],
                                  @"uploadedSize " : @0,
                                  @"size" : @0,
                                  @"status" : @0
                                  } mutableCopy]];
    }
    
    _evtblImagesList.rowHeight = 120;
    
    [_evtblImagesList reloadData];
    
}


#pragma mark - table view datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_imagesArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UpLoadCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    
    cell.delegate = self;
    
    NSMutableDictionary *data = [_imagesArray objectAtIndex:indexPath.item];
    
    NSString *path;
    if ([[data objectForKey:@"type"] integerValue] == 0) {
        path = [data objectForKey:@"assetsUrl"];
        if (![data objectForKey:@"image"]) {
            ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset) {
                ALAssetRepresentation *rep = [myasset defaultRepresentation];
                CGImageRef iref = [rep fullResolutionImage];
                if (iref) {
                    [data setObject:[UIImage imageWithCGImage:iref] forKey:@"image"];
                    [data setObject:[NSNumber numberWithLongLong:[rep size]] forKey:@"size"];
                    [data setObject:rep.filename forKey:@"filename"];
                    [_evtblImagesList reloadData];
                }
            };
            
            ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror) {
                //NSLog(@"cant get image - %@", [myerror localizedDescription]);
            };
            
            NSURL *asseturl = [NSURL URLWithString:path];
            ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
            [assetslibrary assetForURL:asseturl
                           resultBlock:resultblock
                          failureBlock:failureblock];
        }
        
        cell.evimgeHeader.layer.cornerRadius = 32;
        cell.evimgeHeader.layer.masksToBounds = YES;
        cell.evbtnCancleUpLoad.layer.cornerRadius = 1.5;

        cell.row = (int) indexPath.item;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.evbtnCancleUpLoad.tag = indexPath.item;
        cell.deleteRow = ^(int row) {
            [_imagesArray removeObjectAtIndex:row];
            [_evtblImagesList reloadData];
        };
        cell.data = data;
    }
    
    return cell;
}

- (void)upLoadCell:(UpLoadCell *)cell withData:(NSMutableDictionary *)data withLoadStatus:(LoadStatus)loadStatus{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"refresh......%@,%@",@(loadStatus),_imagesArray);
        
        [_evtblImagesList reloadData];
    });
}

- (void)upLoadCell:(UpLoadCell *)cell withIndexPath:(NSInteger)indexPath withData:(NSMutableDictionary *)data {
    /**
     {
     assetsUrl = "assets-library://asset/asset.JPG?id=36990CD9-C9C7-4D76-9C5B-24390F4140E1&ext=JPG";
     dTime = 0;
     filename = "IMG_1457.JPG";
     image = "<UIImage: 0x146464f10> size {640, 640} orientation 0 scale 1.000000";
     name = "D38B0602-92A8-4DDF-91C2-405A615A9CDA";
     progress = 95;
     size = 23965;
     sizeUploaded = 23965;
     status = 1;
     taskId = 0673D553F4834C169125BBF0CF304718;
     timeStart = "1466417648.354697";
     timeUsed = "477.8549671173096";
     type = 0;
     "uploadedSize " = 0;
     url = "http://jonkeychenbaichuan.image.alimmdn.com/PictureFiles/0F0936C7-1A28-4BD7-9E33-33C51FD3DD34";
     }
  
     {
     assetsUrl = "assets-library://asset/asset.mp4?id=AE75FCC2-CD52-4533-B853-8E9FB1FE299E&ext=mp4";
     dTime = 0;
     filename = "IMG_1456.mp4";
     image = "<UIImage: 0x1464112d0> size {640, 640} orientation 0 scale 1.000000";
     name = "18951C4F-F82C-4772-B76E-C715C8298726";
     progress = 95;
     size = 400227;
     sizeUploaded = 400227;
     status = 1;
     taskId = A203D1E140CB4510A25ED2967ADA59E7;
     timeStart = "1466417740.734767";
     timeUsed = "440.9301280975342";
     type = 0;
     "uploadedSize " = 0;
     url = "http://jonkeychenbaichuan.file.alimmdn.com/PictureFiles/A9B4B11A-FE14-40BF-8F55-6DC5BA7A8EA0";
     }
     
     */
    NSString *urlStr  = [NSString stringWithFormat:@"%@",[data objectForKey:@"url"]];
    NSString *assetUrl= [NSString stringWithFormat:@"%@",[data objectForKey:@"assetsUrl"]];
    
    if (urlStr && [assetUrl hasSuffix:@"mp4"]) {
        
        PlayerVideoViewController *playerVC = [[PlayerVideoViewController alloc]init];
        
        playerVC.playerUrl = data[@"url"];
        
        [self.navigationController pushViewController:playerVC animated:YES];
    } else if (urlStr && [assetUrl hasSuffix:@"JPG"]){
    
//        PlayerVideoViewController *playerVC = [[PlayerVideoViewController alloc]init];
        
//        playerVC.playerUrl = data[@"url"];
        
//        [self.navigationController pushViewController:playerVC animated:YES];
    }
}

- (NSString *)uuidString {
    
    NSString *uuidString = [[NSUUID UUID] UUIDString];
    
    return uuidString;
}

@end
