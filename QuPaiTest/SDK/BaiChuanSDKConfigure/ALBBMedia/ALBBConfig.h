//
//  ALBBConfig.h
//  ALBBKernel
//
//  Created by madding.lip on 8/20/15.
//  Copyright (c) 2015 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  /** 获取系统环境变量key */
  ALBBKConfigEnvironment = 0,
  
  /** 获取系统版本 */
  ALBBKConfigSystemVersion = 1,
  
  /** 日志信息开关 */
  ALBBKConfigLogLevel = 2
  
} ALBBConfigEnum;

typedef enum {
  /** 未定义环境 */
  ALBBEnvironmentNone,
  /** 测试环境 */
  ALBBEnvironmentDaily,
  /** 预发环境 */
  ALBBEnvironmentPreRelease,
  /** 线上环境 */
  ALBBEnvironmentRelease,
  /** 沙箱环境 */
  ALBBEnvironmentSandBox
} ALBBEnvironment;


typedef enum {
  ALBBLogLevelDebug = 0,
  ALBBLogLevelInfo = 1,
  ALBBLogLevelPerf = 2,
  ALBBLogLevelWarn = 3,
  ALBBLogLevelError = 4,
  ALBBLogLevelNone = 5
} ALBBLogLevel;



@interface ALBBConfig : NSObject

+ (instancetype)sharedConfig;

/**
 *  获取系统版本信息
 *
 *  @return 具体版本，形如:2.0.0
 */
- (NSString *)systemVersion;

/**
 *  设置系统版本信息
 *
 *  @param version 具体版本值
 */
- (void)setSystemVersion:(NSString *)version;

/**
 *  获取环境变量
 *
 *  @return 返回当前环境
 */
- (ALBBEnvironment)environment;

/**
 *  设置当前环境
 *
 *  @param environment 环境参数
 */
- (void)setEnvironment:(ALBBEnvironment)environment;

/**
 *  获取日志级别
 *
 *  @return
 */
- (ALBBLogLevel)logLevel;

/**
 *  设置日志级别
 *
 *  @param level 日志级别枚举
 */
- (void)setLogLevel:(ALBBLogLevel)level;

/**
 *  设置插件之间的共享信息，主要是一些环境参数，build模式
 *  @param key   环境参数
 *  @param value 环境参数内容
 *
 *  @return 当前实例
 */
- (instancetype)addEnvConfig:(NSString *)key value:(NSString *)value;

/**
 *  获取指定环境参数信息
 *
 *  @param key   环境参数
 *  @param value 没设置时的环境参数值
 *
 *  @return 返回指定key的环境信息
 */
- (NSString *)envConfigForKey:(NSString *)key withDefault:(NSString *)value;

@end
