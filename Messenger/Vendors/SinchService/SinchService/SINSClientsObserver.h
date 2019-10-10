#import <Foundation/Foundation.h>

// Helper for listening to SINClient NSNotifications
// Simplifies subscribing to events, and safely unsubscribing.

@protocol SINClient;

typedef void (^SINSClientBlock)(id<SINClient> client);
typedef void (^SINSClientDidFailBlock)(id<SINClient> client, NSError* error);

@interface SINSClientsObserver : NSObject

@property (nonatomic, copy) SINSClientBlock didStartHandler;
@property (nonatomic, copy) SINSClientDidFailBlock didFailHandler;
@property (nonatomic, copy) SINSClientBlock willTerminateHandler;

// array of id<SINClient>
- (NSArray*)activeClients;

@end
