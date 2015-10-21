//
// Copyright (c) 2015 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "RNEncryptor.h"
#import "RNDecryptor.h"

#import "AppConstant.h"
#import "password.h"

#import "encryption.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSString* EncryptText(NSString *groupId, NSString *string)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSError *error;
	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
	NSData *encryptedData = [RNEncryptor encryptData:data withSettings:kRNCryptorAES256Settings password:PasswordGet(groupId) error:&error];
	return [encryptedData base64EncodedStringWithOptions:0];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSString* DecryptText(NSString *groupId, NSString *string)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSError *error;
	NSData *encryptedData = [[NSData alloc] initWithBase64EncodedString:string options:0];
	NSData *decryptedData = [RNDecryptor decryptData:encryptedData withPassword:PasswordGet(groupId) error:&error];
	return [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSData* EncryptData(NSString *groupId, NSData *data)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSError *error;
	return [RNEncryptor encryptData:data withSettings:kRNCryptorAES256Settings password:PasswordGet(groupId) error:&error];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSData* DecryptData(NSString *groupId, NSData *data)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSError *error;
	return [RNDecryptor decryptData:data withPassword:PasswordGet(groupId) error:&error];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void EncryptFile(NSString *groupId, NSString *path)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSData *dataDecrypted = [NSData dataWithContentsOfFile:path];
	NSData *dataEncrypted = EncryptData(groupId, dataDecrypted);
	[dataEncrypted writeToFile:path atomically:NO];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void DecryptFile(NSString *groupId, NSString *path)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSData *dataEncrypted = [NSData dataWithContentsOfFile:path];
	NSData *dataDecrypted = DecryptData(groupId, dataEncrypted);
	[dataDecrypted writeToFile:path atomically:NO];
}
