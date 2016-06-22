//
//  UpLoadViewController.m
//  BaiChuanTest
//
//  Created by 陈胜华 on 16/6/20.
//  Copyright © 2016年 oneyd.me. All rights reserved.
//

#import "UpLoadViewController.h"
#import "UpLoadCell.h"
#import "UpLoadEntity.h"
#import "PlayerVideoViewController.h"
#import "RecordVideoViewController.h"
#import "PlayerViewController.h"


static NSString *const cellIndentifier = @"UpLoadViewCell";

@interface UpLoadViewController ()<UpLoadCellDelegate>{
    
    __weak IBOutlet UITableView *_evtblImagesList;
    
    UIImagePickerController *_picker;
    
    NSMutableArray<UpLoadEntity*> *_imagesArray;
}

@property (nonatomic,strong) NSMutableArray *groupArrays;

@end

@implementation UpLoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self efConfigure];
}

//配置UI及数据
- (void)efConfigure{
    
    //录制Button
    UIBarButtonItem*etRightItem = ({
        
        UIButton*rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,30,30)];
        
        rightButton.layer.masksToBounds = YES;
        
        rightButton.layer.borderColor = [UIColor orangeColor].CGColor;
        
        rightButton.layer.borderWidth = 3;
        
        [rightButton setTitle:@"录制" forState:UIControlStateNormal];
        
        [rightButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
        
        [rightButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        
        [rightButton addTarget:self action:@selector(_efOnClcikRecord) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem*rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
        rightItem;
    });
    
    self.navigationItem.rightBarButtonItem = etRightItem;
    
    //
    _picker = ({
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        
        picker.delegate = self;
        
        picker.allowsEditing = NO;
        
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeMovie, (NSString *) kUTTypeImage, nil];
        
        picker;
    });
    
    _evtblImagesList.rowHeight = 120;
    
    [_evtblImagesList registerNib:[UINib nibWithNibName:@"UpLoadCell"
                                                 bundle:nil]
           forCellReuseIdentifier:cellIndentifier];
    
    _imagesArray = [NSMutableArray new];
    
    _groupArrays = [NSMutableArray new];

    [self efGetLibraryAllVideo];
}

//录制视频
- (void)_efOnClcikRecord{
    
#warning 打开之后，就可以录制了
    
    RecordVideoViewController *recordVideoVC = [[RecordVideoViewController alloc]init];
    
    __weak UpLoadViewController *weakSelf = self;
    
    recordVideoVC.value = ^(QPUploadTask *task) {
        
        [weakSelf efGetLibraryAllVideo];
    };

    [self.navigationController pushViewController:recordVideoVC animated:YES];
}

//读取本地全部视频
- (void)efGetLibraryAllVideo{
    
    [_imagesArray removeAllObjects];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
            
            if (group != nil) {
            
                [_groupArrays addObject:group];
            } else {
                
                [_groupArrays enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

                    [obj enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                        

                        if ([result thumbnail] != nil) {
                            
                            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]){
                            
                                    NSURL *url = [[result defaultRepresentation] url];
                                    
                                    UpLoadEntity *upLoadEntity = [[UpLoadEntity alloc]init];
                                    upLoadEntity.assetsUrl = url.absoluteString;
                                    upLoadEntity.type = 0;
                                    upLoadEntity.name = [self uuidString];
                                    upLoadEntity.uploadedSize = 0;
                                    upLoadEntity.size = 0;
                                    upLoadEntity.status = 0;
                                    
                                    [_imagesArray addObject:upLoadEntity];
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                    
                                        [_evtblImagesList reloadData];
                                    });
                            }
                        }
                    }];
                }];
            }
        };
        
        ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error){
            
            NSString *errorMessage = nil;
            
            switch ([error code]) {
                case ALAssetsLibraryAccessUserDeniedError:
                case ALAssetsLibraryAccessGloballyDeniedError:
                    errorMessage = @"用户拒绝访问相册,请在<隐私>中开启";
                    break;
                    
                default:
                    errorMessage = @"Reason unknown";
                    break;
            }
        };
        
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc]  init];
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                     usingBlock:listGroupBlock failureBlock:failureBlock];
    });
}

/*********************************************************************/
//从相册中读取 视频/图片
- (IBAction)efOnClickSelectedPictures:(id)sender {
    
    [self presentViewController:_picker animated:YES completion:nil];
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [_picker dismissViewControllerAnimated:YES completion:nil];
    
    NSURL *localUrl = [info valueForKey:UIImagePickerControllerReferenceURL];
    
    NSString *mediaurl = localUrl.absoluteString;
    
    BOOL flag = YES;
    
    //判断是否添加过相同的视频／图片
    for (NSDictionary *infoDic in _imagesArray) {
        
        if ([mediaurl isEqualToString:[infoDic objectForKey:@"assetsUrl"]]) {
            
            flag = NO;
            
            break;
        }
    }
    
    if (flag) {
        
        UpLoadEntity *upLoadEntity = [[UpLoadEntity alloc]init];
        upLoadEntity.assetsUrl = mediaurl;
        upLoadEntity.type = 0;
        upLoadEntity.name = [self uuidString];
        upLoadEntity.uploadedSize = 0;
        upLoadEntity.size = 0;
        upLoadEntity.status = 0;

        [_imagesArray addObject:upLoadEntity];
    }
    
    [_evtblImagesList reloadData];
}


#pragma mark - table view datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_imagesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UpLoadCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    
    cell.delegate = self;
    
    UpLoadEntity *data = [_imagesArray objectAtIndex:indexPath.item];
    
    NSString *path;
    
    if (data.type == 0) {
        
        path = data.assetsUrl;

        if (!data.image) {
            ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset) {
                
                ALAssetRepresentation *rep = [myasset defaultRepresentation];
                
                CGImageRef iref = [rep fullResolutionImage];
                
                if (iref) {
                    
                    data.image = [UIImage imageWithCGImage:iref];
                    
                    data.size = [rep size];
                    
                    data.filename = rep.filename;
                    
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
        
        cell.row = (int) indexPath.item;
        
        cell.data = data;
    }
    
    return cell;
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UpLoadEntity *task = _imagesArray[indexPath.row];
    
    [[[ALBBMedia sharedInstance] taeFileEngine] cancelUploadByUniqueId:task.taskId];
    
    [_imagesArray removeObject:task];
    
    [_evtblImagesList reloadData];
}

#pragma  mark -UpLoadCellDelegate
- (void)upLoadCell:(UpLoadCell *)cell withData:(UpLoadEntity *)data withLoadStatus:(LoadStatus)loadStatus{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [_imagesArray replaceObjectAtIndex:cell.row withObject:data];
        
        [_evtblImagesList reloadData];
    });
}

- (void)upLoadCell:(UpLoadCell *)cell withIndexPath:(NSInteger)indexPath withData:(UpLoadEntity *)data {
    
    if (data.url && ([data.assetsUrl hasSuffix:@"mp4"]||
                     [data.assetsUrl hasSuffix:@"MOV"])) {
        
        PlayerViewController *playerVC = [[PlayerViewController alloc]init];
        
        playerVC.urlString = data.url;
        
        [self.navigationController pushViewController:playerVC animated:YES];
    } else if (data.url && ([data.assetsUrl hasSuffix:@"JPG"]||
                            [data.assetsUrl hasSuffix:@"PNG"])){
        
        PlayerVideoViewController *playerVC = [[PlayerVideoViewController alloc]init];
        
        playerVC.imageUrl = data.url;
        
        [self.navigationController pushViewController:playerVC animated:YES];
    }
}

- (void)dealloc {
    
    //取消所有下载任务
    [[[ALBBMedia sharedInstance] taeFileEngine] cancelAllUploads];
}

- (NSString *)uuidString {
    
    NSString *uuidString = [[NSUUID UUID] UUIDString];
    
    return uuidString;
}

@end
