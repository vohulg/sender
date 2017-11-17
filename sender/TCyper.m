

#import "TCyper.h"
#import "RNCryptManager.h"
//#import <CommonCrypto/CommonDigest.h>

#define TCOMMON_CRYPTKEY_LENGTH 20


@implementation TCyper

#pragma mark - ENCRYPT DECRYPT by chunk

-(NSString*) encryptByChunk:(NSString*)filePathIn andGuid:(NSString*)guid {
    
    NSString* key = [guid substringFromIndex:TCOMMON_CRYPTKEY_LENGTH];
    
    int lenKey = key.length;
    
    NSString* filePathOut = [NSString stringWithFormat:@"%@.enc",filePathIn ];
    
    NSError* error = nil;
    
    NSInputStream * inStream = [NSInputStream inputStreamWithFileAtPath:filePathIn];
    [inStream open];
    
    NSOutputStream * outStream = [NSOutputStream outputStreamToFileAtPath:filePathOut append:NO];
    [outStream open];
    
    [RNCryptManager encryptFromStream:inStream toStream:outStream password:key error:&error];
    
    if (error){
        
        //[[VGUtils sharedInstance] writeLogToDB:[NSString stringWithFormat:@"Error in encryption of file %@",[error localizedDescription]] withPretty_func:__PRETTY_FUNCTION__ withLine:__LINE__ andLogType:LOG_TYPE(eLOG_ERROR_INDEX)];
        return nil;
    }
    
    return filePathOut;
}


-(BOOL) decryptByChunk:(NSString*)FilePathEncoded andFileOut:(NSString*)filePathDecoded andKey:(NSString*)key {
    
    
    // cut marker from file
    NSData* dataWithMarker = [NSData dataWithContentsOfFile:FilePathEncoded];
    
    NSData* dataWithNoMarker = [dataWithMarker subdataWithRange:NSMakeRange(4, [dataWithMarker length] - 4)];
    
    // check valid marker
    if (![self checkMarker:dataWithMarker]){
        //[[VGUtils sharedInstance] writeLogToDB:@"Invalid marker in encrypted file " withPretty_func:__PRETTY_FUNCTION__ withLine:__LINE__ andLogType:LOG_TYPE(eLOG_ERROR_INDEX)];
        return NO;
    }
   
    
    NSInputStream * inStream = [NSInputStream inputStreamWithData:dataWithNoMarker];
    [inStream open];
    
    
    NSOutputStream * outStream = [NSOutputStream outputStreamToFileAtPath:filePathDecoded append:NO];
    [outStream open];
    
    return [RNCryptManager decryptFromStream:inStream toStream:outStream password:key error:nil];
    
    
    
}

-(BOOL) checkMarker:(NSData*)dataWithMarker {
    
    Byte markerInFile[4];
    
    [dataWithMarker getBytes:markerInFile range:NSMakeRange(0, 4)];
    
    for (int I = 0; I < 3; I++){
        
        if (markerInFile[I] != MARKER[I]) {
            return NO;
        }
        
    }
    
    return YES;

}



@end
