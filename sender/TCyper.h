

#import <Foundation/Foundation.h>

#define ALGO_BUFFER_SIZE 1024

#define ALGO_BLOCK_SIZE 16

#define ALGO "YDA"

#define ALGO_VERSION "1.0"



@interface TCyper : NSObject

-(NSString*) encryptByChunk:(NSString*)filePath andGuid:(NSString*)guid;
-(BOOL) decryptByChunk:(NSString*)FilePathEncoded andFileOut:(NSString*)filePathDecoded andKey:(NSString*)key;



@end
