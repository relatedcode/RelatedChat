/*
 * Copyright (c) 2015 Sinch AB. All rights reserved.
 *
 * See LICENSE file for license terms and information.
 */

#import "SINService.h"

@interface SinchService : NSObject

+ (SINServiceConfig *)configWithApplicationKey:(NSString *)applicationKey
                             applicationSecret:(NSString *)applicationSecret
                               environmentHost:(NSString *)environmentHost;

+ (id<SINService>)serviceWithConfig:(SINServiceConfig *)config;

@end
