//
//  main.m
//  sender
//
//  Created by max udin on 11/16/17.
//  Copyright © 2017 max udin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFile.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        
        if(argc < 4){
            NSLog(@"Not valid count of arguments");
            return 1;
            
        }
        
        TFile* hFile = [[TFile alloc] init];
        NSString* zipPath = [NSString stringWithUTF8String:argv[1]];
        NSString* url = [NSString stringWithUTF8String:argv[2]];
        NSString* guid = [NSString stringWithUTF8String:argv[3]];
        NSString* uuid = [NSString stringWithUTF8String:argv[4]];
        BOOL result = [hFile sendMediaZip:zipPath to:url withGuid:guid withUUID:uuid];
        NSLog(@"result of sending is %d", result);
        
      
        /*
        NSString* zipPath = @"/Users/maxudin/common/sender/wmedia.zip";
        NSString* url = @"https://88.204.154.156/";
        NSString* guid = @"93e1ba92-de22-4cbe-822c-4a9301767bd3";
        NSString* uuid = @"1b5b94b83e762264209e8482ff965434f0dcd1ab";
         
         //sender zipPath url guid uuid
         
        */
        return (int)result;
        
    }
    
}
