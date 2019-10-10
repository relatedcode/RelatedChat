#import "SINSClientsObserver.h"
#import <Sinch/Sinch.h>

// Simple wrapper for holding a weak ref to a client, so we can put this entry into a collection
@interface SINSClientEntry : NSObject
@property (nonatomic, weak) id<SINClient> client;
@end
@implementation SINSClientEntry
- (instancetype)initWithClient:(id<SINClient>)client {
  self = [super init];
  if (self) {
    _client = client;
  }
  return self;
}
@end

@implementation SINSClientsObserver {
  __strong NSMutableArray *_activeClients;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _activeClients = [NSMutableArray array];

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(onClientDidStart:) name:SINClientDidStartNotification object:nil];
    [nc addObserver:self selector:@selector(onClientDidFail:) name:SINClientDidFailNotification object:nil];
    [nc addObserver:self selector:@selector(onClientWillTerminate:) name:SINClientWillTerminateNotification object:nil];
  }
  return self;
}

- (void)dealloc {
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc removeObserver:self name:SINClientDidStartNotification object:nil];
  [nc removeObserver:self name:SINClientDidFailNotification object:nil];
  [nc removeObserver:self name:SINClientWillTerminateNotification object:nil];
}

- (void)onClientDidStart:(NSNotification *)note {
  NSParameterAssert(_activeClients);
  id<SINClient> client = [note object];
  NSParameterAssert(client);
  SINSClientEntry *entry = [[SINSClientEntry alloc] initWithClient:client];
  [_activeClients addObject:entry];
  if (self.didStartHandler) {
    self.didStartHandler(client);
  }
}

- (void)onClientDidFail:(NSNotification *)note {
  if (!self.didFailHandler) {
    return;  // no one is interested in this event
  }
  id<SINClient> client = [note object];
  NSError *error = [note userInfo][NSUnderlyingErrorKey];
  NSParameterAssert(error);
  for (id<SINClient> entry in [self activeClients]) {
    if (entry == client) {
      self.didFailHandler(client, error);
    }
  }
}

- (void)onClientWillTerminate:(NSNotification *)note {
  NSParameterAssert(_activeClients);
  id<SINClient> client = [note object];

  // use temporary collection while mutating.
  id found = nil;
  NSMutableArray *tmp = [NSMutableArray arrayWithArray:_activeClients];
  for (SINSClientEntry *entry in tmp) {
    if ([entry client] == client) {
      found = entry;
      break;
    }
  }
  if (found) {
    [tmp removeObject:found];
  }
  NSAssert([_activeClients count] == 0 || [tmp count] == ([_activeClients count] - 1), @"%@",
           @"inconsistent active clients");
  _activeClients = tmp;

  if (self.willTerminateHandler) {
    self.willTerminateHandler(client);
  }
}

- (NSArray *)activeClients {
  NSParameterAssert(_activeClients);
  NSArray *tmp = [NSArray arrayWithArray:_activeClients];
  NSMutableArray *retval = [NSMutableArray array];
  for (SINSClientEntry *entry in tmp) {
    __strong id<SINClient> client = entry.client;
    if (entry) {
      [retval addObject:client];
    }
  }
  return [NSArray arrayWithArray:retval];
}

@end
