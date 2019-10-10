#import <Foundation/Foundation.h>

#define SINSParameterCondition(_condition_)                                                                      \
  if (!_condition_) {                                                                                            \
    @throw [NSException exceptionWithName:NSInvalidArgumentException                                             \
                                   reason:[NSString stringWithFormat:@"Parameter '%s' is invalid", #_condition_] \
                                 userInfo:nil];                                                                  \
  }
