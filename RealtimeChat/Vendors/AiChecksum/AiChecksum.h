
#import <Foundation/Foundation.h>
#include <CommonCrypto/CommonDigest.h>
 
@interface AiChecksum : NSObject
{
}
 
+ (NSString *)md5HashOfPath:(NSString *)path;
+ (NSString *)md5HashOfData:(NSData *)data;
+ (NSString *)md5HashOfString:(NSString *)string;

+ (NSString *)shaHashOfPath:(NSString *)path;
+ (NSString *)shaHashOfData:(NSData *)data;
+ (NSString *)shaHashOfString:(NSString *)string;

@end
