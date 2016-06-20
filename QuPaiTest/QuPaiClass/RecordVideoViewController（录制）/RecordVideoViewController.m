//
//  RecordVideoViewController.m
//  SaleHouseTest04
//
//  Created by 陈胜华 on 16/6/16.
//  Copyright © 2016年 oneyd.me. All rights reserved.
//

#import "RecordVideoViewController.h"
#import "UIView+Toast.h"
#import "Header.h"

@interface RecordVideoViewController (){
    
    __weak IBOutlet UITextField *evtxfMaxTime;
    __weak IBOutlet UITextField *evtxfMinTime;
    __weak IBOutlet UITextField *evtxfCodeSpeed;
    __weak IBOutlet UITextField *evtxfVideoWidth;
    __weak IBOutlet UITextField *evtxfVideoHeight;
    __weak IBOutlet UITextField *evtxfQualityThumbnail;
    __weak IBOutlet UITextField *evtxfBottomScreenHeight;

    __weak IBOutlet UISlider *evsliderColorWithR;
    __weak IBOutlet UISlider *evsliderColorWithG;
    __weak IBOutlet UISlider *evsliderColorWithB;
    
    __weak IBOutlet UISwitch *_enableImportSwitch;
    __weak IBOutlet UISwitch *_enableMoreMusic;
    __weak IBOutlet UISwitch *_enableBeautySwitch;
    __weak IBOutlet UISwitch *_enableVideoEffect;
    __weak IBOutlet UISwitch *_enableWaterMask;
    __weak IBOutlet UISwitch *_frontCameraSwitch;
    
    __weak IBOutlet UISlider *evSliderBeautifulAlpa;
 
    __weak IBOutlet UIButton *evbtnStartRecordVideo;
    __weak IBOutlet UIView   *evLineView;
    
    BOOL _down;
}

@end

@implementation RecordVideoViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view updateConstraintsIfNeeded];
    
    [self efObserverThemeColor];
}

- (void)efObserverThemeColor{
    
    [evsliderColorWithR addTarget:self action:@selector(efRGBColorDidChange) forControlEvents:UIControlEventValueChanged];
    
    [evsliderColorWithG addTarget:self action:@selector(efRGBColorDidChange) forControlEvents:UIControlEventValueChanged];
    
    [evsliderColorWithB addTarget:self action:@selector(efRGBColorDidChange) forControlEvents:UIControlEventValueChanged];
}

//监听主题颜色变化
- (void)efRGBColorDidChange{
    
    evLineView.backgroundColor = [UIColor colorWithRed:evsliderColorWithR.value/255.0
                                                 green:evsliderColorWithG.value/255.0
                                                  blue:evsliderColorWithB.value/255.0 alpha:1];
}

//开始录制
- (IBAction)efOnClickRecord:(id)sender {
    
    QupaiSDK *sdk = [QupaiSDK shared];
    [sdk setDelegte:(id<QupaiSDKDelegate>)self];
    
    /* 属性设置 */
    [sdk setEnableImport:_enableImportSwitch.on];
    [sdk setEnableMoreMusic:_enableMoreMusic.on];
    [sdk setEnableBeauty:_enableBeautySwitch.on];
    [sdk setEnableVideoEffect:_enableVideoEffect.on];
    [sdk setEnableWatermark:_enableWaterMask.on];
    [sdk setWatermarkImage:_enableWaterMask.on ? [UIImage imageNamed:@"icon.png"] : nil];
    [sdk setCameraPosition:_frontCameraSwitch.on ? QupaiSDKCameraPositionFront :
                                                   QupaiSDKCameraPositionBack];
    [sdk setWatermarkPosition:QupaiSDKWatermarkPositionTopRight];
    [sdk setThumbnailCompressionQuality:[evtxfQualityThumbnail.text floatValue]];
    [sdk setTintColor:[UIColor colorWithRed:evsliderColorWithR.value/255.0
                                      green:evsliderColorWithG.value/255.0
                                       blue:evsliderColorWithB.value/255.0 alpha:1]];

    CGFloat minDurtion = [evtxfMinTime.text integerValue];
    CGFloat maxDurtion = [evtxfMaxTime.text integerValue];
    CGFloat bitRate    = [evtxfCodeSpeed.text integerValue];
    
    UIViewController *recordController = [sdk createRecordViewControllerWithMinDuration:minDurtion
                                                                            maxDuration:maxDurtion
                                                                                bitRate:bitRate];
    
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:recordController];
    
    navigation.navigationBarHidden = YES;
    
    [self presentViewController:navigation animated:YES completion:nil];
}

- (void)qupaiSDK:(id<QupaiSDKDelegate>)sdk compeleteVideoPath:(NSString *)videoPath thumbnailPath:(NSString *)thumbnailPath{
    
    NSLog(@"Qupai SDK compelete %@",videoPath);
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (videoPath) {
        
        UISaveVideoAtPathToSavedPhotosAlbum(videoPath, nil, nil, nil);
    }
    
    if (thumbnailPath) {
        
        UIImageWriteToSavedPhotosAlbum([UIImage imageWithContentsOfFile:thumbnailPath], nil, nil, nil);
    }
    
    if (videoPath) {
        
        [self.view makeToast:@"成功录制视频，已经保存至相册"];
        
        [self saveVideo:videoPath thumbnail:thumbnailPath];
    }
}

//把视频从临时目录拷贝出来，因为下次录制时会清空临时目录。
- (void)saveVideo:(NSString *)videoPath thumbnail:(NSString *)thumbnailPath {
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *tempDirPath = [documentPath stringByAppendingPathComponent:kStringTempFiles];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    if (![fileMgr fileExistsAtPath:tempDirPath]) {
        
        [fileMgr createDirectoryAtPath:tempDirPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    NSString *tempVideoPath = [tempDirPath stringByAppendingPathComponent:[videoPath lastPathComponent]];
    
    [[NSFileManager defaultManager] copyItemAtPath:videoPath toPath:tempVideoPath error:nil];
    
    NSString *tempThumbnailPath = [tempDirPath stringByAppendingPathComponent:[thumbnailPath lastPathComponent]];
    
    [[NSFileManager defaultManager] copyItemAtPath:thumbnailPath toPath:tempThumbnailPath error:nil];
    
    QPUploadTask *task= [[QPUploadTaskManager shared] createUploadTaskWithVideoPath:tempVideoPath thumbnailPath:tempThumbnailPath];
    
    if (_value) {
        
        _value(task);
    }
}

- (NSArray *)qupaiSDKMusics:(id<QupaiSDKDelegate>)sdk{
    
    NSString *baseDir = [[NSBundle mainBundle] bundlePath];
    
    NSString *configPath = [[NSBundle mainBundle] pathForResource:_down ? @"music2" : @"music1" ofType:@"json"];
    
    NSData *configData = [NSData dataWithContentsOfFile:configPath];
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:configData options:NSJSONReadingAllowFragments error:nil];
    
    NSArray *items = dic[@"music"];
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSDictionary *item in items) {
        
        NSString *path = [baseDir stringByAppendingPathComponent:item[@"resourceUrl"]];
        
        QPEffectMusic *effect = [[QPEffectMusic alloc] init];
        
        effect.name = item[@"name"];
        
        effect.eid = [item[@"id"] intValue];
        
        effect.musicName = [path stringByAppendingPathComponent:@"audio.mp3"];
        
        effect.icon = [path stringByAppendingPathComponent:@"icon.png"];
        
        [array addObject:effect];
    }
    
    return array;
}

- (void)qupaiSDKShowMoreMusicView:(id<QupaiSDKDelegate>)sdk viewController:(UIViewController *)viewController{

    QupaiSDK *sdkUpdateMusic = [QupaiSDK shared];
    
    [sdkUpdateMusic updateMoreMusic];
    
    _down = YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
}

@end
