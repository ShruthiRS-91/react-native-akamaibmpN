
#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif
#import <AkamaiBMP/CYFMonitor.h>

@interface RNAkamaibmp : NSObject<RCTBridgeModule, CYFChallengeActionDelegate> 

@end
