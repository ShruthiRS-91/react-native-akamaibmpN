
#import "RNAkamaibmp.h"
#import <Foundation/Foundation.h>
#import <React/RCTConvert.h>
#import <AkamaiBMP/CYFMonitor.h>

@implementation RCTConvert (LogLevel)
RCT_ENUM_CONVERTER(CYFLogLevel, (@{
                       @"logLevelInfo" : @(CYFLogLevelInfo),
                       @"logLevelWarn" : @(CYFLogLevelWarn),
                       @"logLevelError" : @(CYFLogLevelError),
                       @"logLevelNone" : @(CYFLogLevelNone)
                   }),
                   CYFLogLevelInfo, integerValue)
@end

@implementation RNAkamaibmp

+ (BOOL)requiresMainQueueSetup {
    return NO;
}

RCT_EXPORT_MODULE(AkamaiBMP)
RCTResponseSenderBlock ResponseCallback;
RCTPromiseResolveBlock CCAResolveBlock;
RCTPromiseRejectBlock CCARejectBlock;
Boolean isInitialized = false;
Boolean isChallengeActionInitialized = false;

- (NSDictionary *)constantsToExport {
    return @{
        @"logLevelInfo" : @(CYFLogLevelInfo),
        @"logLevelWarn" : @(CYFLogLevelWarn),
        @"logLevelError" : @(CYFLogLevelError),
        @"logLevelNone" : @(CYFLogLevelNone),
        @"challengeActionSuccess" : [NSNumber numberWithInt:1],
        @"challengeActionFail" : [NSNumber numberWithInt:-1],
        @"challengeActionCancel" : [NSNumber numberWithInt:0]
    };
};

RCT_EXPORT_METHOD(getSensorData : (RCTResponseSenderBlock)callback) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      NSString *sd = [CYFMonitor getSensorData];
      callback(@[ sd ]);
    });
}

RCT_EXPORT_METHOD(setLogLevel : (CYFLogLevel)logLevel) { [CYFMonitor setLogLevel:logLevel]; }

RCT_EXPORT_METHOD(configure) {
    dispatch_async(dispatch_get_main_queue(), ^(){
        [CYFMonitor configure];
        [self akamaiBMPDidInitialize];
    });
    isInitialized = true;
}

RCT_EXPORT_METHOD(configureWithUrl: url) {
    dispatch_async(dispatch_get_main_queue(), ^(){
        [CYFMonitor configureSDK:url];
        [self akamaiBMPDidInitialize];
    });
    isInitialized = true;
}

- (void)akamaiBMPDidInitialize {
    /** posting notification so that the listeners will start capturing events  */
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CYF_BMP_SDK_INITIALIZED"
                            object:nil
                            userInfo:nil];
}

RCT_EXPORT_METHOD(didConfigure : (RCTResponseSenderBlock)callback) {
    callback(@[@(isInitialized)]);
}

//RCT_EXPORT_METHOD(collectTestData : (RCTResponseSenderBlock)callback) {
//    NSDictionary *testData = [CYFMonitor collectTestData];
//    NSString *touch_totalCount = [testData objectForKey:@"touch_totalCount"];
//    NSString *touch_totalUpDownCount = [testData objectForKey:@"touch_totalUpDownCount"];
//    NSString *touch_totalMoveCount = [testData objectForKey:@"touch_totalMoveCount"];
//    NSString *text_totalChangeCount = [testData objectForKey:@"text_totalChangeCount"];
//    NSString *text_totalCount = [testData objectForKey:@"text_totalCount"];
//    NSString *ori_totalCount = [testData objectForKey:@"ori_totalCount"];
//    NSString *motion_totalCount = [testData objectForKey:@"motion_totalCount"];
//    NSString *pow_status = [testData objectForKey:@"pow_status"];
//
//    callback(@[ @[ touch_totalCount ], @[ touch_totalMoveCount ], @[ touch_totalUpDownCount ],
//        @[ ori_totalCount ], @[ motion_totalCount ],
//        @[ text_totalCount ], @[ text_totalChangeCount ], @[ pow_status ]]
//    );
//}

RCT_EXPORT_METHOD(configureChallengeAction : url) {
    [CYFMonitor configureChallengeAction:url];
    isChallengeActionInitialized = true;
}

RCT_EXPORT_METHOD(didChallengeActionConfigure : (RCTResponseSenderBlock)callback) {
    callback(@[@(isChallengeActionInitialized)]);
}

RCT_EXPORT_METHOD(showChallengeAction:challenContext title:(NSString *)title message:(NSString *)message cancelButton:(NSString *)cancelButton resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {// callback:(RCTResponseSenderBlock)callback) {//successCallback:(RCTResponseSenderBlock)successCallback cancelCallback:(RCTResponseSenderBlock)cancelCallback) {
  
  NSLog(@"showChallengeAction");
  dispatch_async(dispatch_get_main_queue(), ^{
    [CYFMonitor showChallengeAction: challenContext
      title: title
      message: message
      cancelButtonTitle: cancelButton
      delegate:self];
  });

  CCAResolveBlock = resolve;
}



- (void)onChallengeActionCancel {
  NSLog(@"onChallengeActionCancel");
  NSDictionary *ccaResult = [[NSMutableDictionary alloc] init];
  [ccaResult setValue:[NSNumber numberWithInt:0] forKey:@"challengeActionStatus"];
  CCAResolveBlock(ccaResult);
}
- (void)onChallengeActionSuccess {
  NSLog(@"onChallengeActionSuccess");
  NSDictionary *ccaResult = [[NSMutableDictionary alloc] init];
  [ccaResult setValue:[NSNumber numberWithInt:1] forKey:@"challengeActionStatus"];
  CCAResolveBlock(ccaResult);
}
- (void)onChallengeActionFailure:(NSString *)message {
  NSLog(@"onChallengeActionFailure: %@", message);
  NSDictionary *ccaResult = [[NSMutableDictionary alloc] init];
  [ccaResult setValue:[NSNumber numberWithInt:-1] forKey:@"challengeActionStatus"];
  [ccaResult setValue:@[ message ] forKey:@"challengeActionMessage"];
  CCAResolveBlock(ccaResult);
}


@end
