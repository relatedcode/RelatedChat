#import "SINServiceError.h"
#import "SINSParameterValidation.h"

NSString *const SINServiceErrorDomain = @"SINServiceErrorDomain";

NSError *SINServiceComponentNotAvailableError(void) {
  return SINServiceCreateError(SINServiceErrorComponentNotAvailable, @"SINClient is not started");
}

NSError *SINServiceCreateError(SINServiceError code, NSString *reason) {
  SINSParameterCondition(reason);
  if (!reason) {
    reason = @"";
  }
  NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey : reason, NSLocalizedDescriptionKey : reason};
  return [NSError errorWithDomain:SINServiceErrorDomain code:code userInfo:userInfo];
}
