
#import "AiChecksum.h"
 
@implementation AiChecksum
 
+ (NSString *)md5HashOfPath:(NSString *)path
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:nil])
	{
		NSData *data = [NSData dataWithContentsOfFile:path];
		unsigned char digest[CC_MD5_DIGEST_LENGTH];
		CC_MD5(data.bytes, (CC_LONG)data.length, digest);
 
		NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
 
		for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++)
		{
			[output appendFormat:@"%02x", digest[i]];
		}
		return output;
	}
	return nil;
}
 
+ (NSString *)md5HashOfData:(NSData *)data
{
	if (data != nil)
	{
		unsigned char digest[CC_MD5_DIGEST_LENGTH];
		CC_MD5(data.bytes, (CC_LONG)data.length, digest);

		NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];

		for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++)
		{
			[output appendFormat:@"%02x", digest[i]];
		}
		return output;
	}
	return nil;
}

+ (NSString *)md5HashOfString:(NSString *)string
{
	if (string != nil)
	{
		NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
		unsigned char digest[CC_MD5_DIGEST_LENGTH];
		CC_MD5(data.bytes, (CC_LONG)data.length, digest);

		NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];

		for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++)
		{
			[output appendFormat:@"%02x", digest[i]];
		}
		return output;
	}
	return nil;
}

+ (NSString *)shaHashOfPath:(NSString *)path
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:nil])
	{
		NSData *data = [NSData dataWithContentsOfFile:path];
		unsigned char digest[CC_SHA1_DIGEST_LENGTH];
		CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
 
		NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
 
		for (int i=0; i<CC_SHA1_DIGEST_LENGTH; i++)
		{
			[output appendFormat:@"%02x", digest[i]];
		}
		return output;
	}
	return nil;
}

+ (NSString *)shaHashOfData:(NSData *)data
{
	if (data != nil)
	{
		unsigned char digest[CC_SHA1_DIGEST_LENGTH];
		CC_SHA1(data.bytes, (CC_LONG)data.length, digest);

		NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];

		for (int i=0; i<CC_SHA1_DIGEST_LENGTH; i++)
		{
			[output appendFormat:@"%02x", digest[i]];
		}
		return output;
	}
	return nil;
}

+ (NSString *)shaHashOfString:(NSString *)string
{
	if (string != nil)
	{
		NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
		unsigned char digest[CC_SHA1_DIGEST_LENGTH];
		CC_SHA1(data.bytes, (CC_LONG)data.length, digest);

		NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];

		for (int i=0; i<CC_SHA1_DIGEST_LENGTH; i++)
		{
			[output appendFormat:@"%02x", digest[i]];
		}
		return output;
	}
	return nil;
}

@end
