//
//  ZPFileChannel.m
//  ZotPad
//
//  Created by Mikko Rönkkö on 18.3.2012.
//  Copyright (c) 2012 Mikko Rönkkö. All rights reserved.
//

#import "ZPCore.h"

#import "ZPFileChannel.h"


#import "ZPUploadVersionConflictViewControllerViewController.h"
#import "ZPFileImportViewController.h"
#import "ZPAppDelegate.h"

@implementation ZPFileChannel

-(id) init{
    self = [super init];
    _requestsByAttachment = [[NSMutableDictionary alloc] init];
    return self;
}

-(int) fileChannelType{
    return 0;
}
-(void) startDownloadingAttachment:(ZPZoteroAttachment*)attachment{
    //Does nothing by default
}
-(void) cancelDownloadingAttachment:(ZPZoteroAttachment*)attachment{
    //Does nothing by default
}
-(void) useProgressView:(UIProgressView*) progressView forDownloadingAttachment:(ZPZoteroAttachment*)attachment{
    //Does nothing by default
}

-(void) startUploadingAttachment:(ZPZoteroAttachment*)attachment overWriteConflictingServerVersion:(BOOL)overwriteConflicting{
    //Does nothing by default
}

-(void) cancelUploadingAttachment:(ZPZoteroAttachment*)attachment{
    //Does nothing by default
}

-(void) useProgressView:(UIProgressView*) progressView forUploadingAttachment:(ZPZoteroAttachment*)attachment{
    //Does nothing by default
}

-(void) removeProgressView:(UIProgressView*) progressView{
    //Does nothing by default
}

 
 
-(void) linkAttachment:(ZPZoteroAttachment*)attachment withRequest:(NSObject*)request{
    @synchronized(self){
        [_requestsByAttachment setObject:request forKey:attachment.key];
    }
}

-(id) requestWithAttachment:(ZPZoteroAttachment*)attachment{
    id ret;
    @synchronized(self){
        ret = [_requestsByAttachment objectForKey:attachment.key];
    }
    return ret;
}

-(NSArray*) allRequests{
    @synchronized(self){
        return [_requestsByAttachment allValues];
    }
}


-(void) cleanupAfterFinishingAttachment:(ZPZoteroAttachment*)attachment{
    @synchronized(self){
        [_requestsByAttachment removeObjectForKey:attachment.key];
    }
}


-(void) presentConflictViewForAttachment:(ZPZoteroAttachment*) attachment reason:(NSString*) reason{
    
    DDLogWarn(@"Version conflict for file %@ (%@): %@",attachment.key, attachment.filename, reason);
    
    if(![NSThread isMainThread]){
        [self performSelectorOnMainThread:@selector(presentConflictViewForAttachment:) withObject:attachment waitUntilDone:YES];
    }
    else{
        [attachment logFileRevisions];
        
        UIViewController* root = [UIApplication sharedApplication].delegate.window.rootViewController;
        
        //TODO: Consider refactoring this some place else
        NSDictionary* sender = [NSDictionary dictionaryWithObjectsAndKeys:self,@"fileChannel",attachment,ZPKEY_ATTACHMENT, nil];
        if(root.presentedViewController == NULL){
            [root performSegueWithIdentifier:@"FileUploadConflict" sender:sender];
        }
        else if ([root.presentedViewController isKindOfClass:[ZPFileImportViewController class]] && [(ZPFileImportViewController*) root.presentedViewController isFullyPresented]){
            [root.presentedViewController performSegueWithIdentifier:@"FileUploadConflictFromDialog" sender:sender];
        }
        else{
            //Delay one second and check again if this can be presented
            [self performSelector:@selector(presentConflictViewForAttachment:) withObject:attachment afterDelay:(NSTimeInterval) 1];
        }
    }
}


-(NSString*) requestDumpAsString:(ASIHTTPRequest*)request{

    NSMutableString* dump = [[NSMutableString alloc] initWithFormat:@"Request: \n\n%@ %@ HTTP/1.1\n",request.requestMethod,request.url];
    
    for(NSString* key in request.requestHeaders){
        [dump appendFormat:@"%@: %@\n",key,[request.requestHeaders objectForKey:key]];
    }
    
    if(request.postBody){
        [dump appendString:@"\n"];
        [dump appendString:[[NSString alloc] initWithData:request.postBody
                                                 encoding:NSUTF8StringEncoding]];
    }

    [dump appendFormat: @"\n\nResponse: \n\n%@\n",request.responseStatusMessage];

    for(NSString* key in request.responseHeaders){
        [dump appendFormat:@"%@: %@\n",key,[request.responseHeaders objectForKey:key]];
    }

    if(request.responseString){
        [dump appendString:@"\n"];
        [dump appendString:request.responseString];
    }
    return dump;
}

-(void) logVersionInformationForAttachment:(ZPZoteroAttachment *)attachment{

    //Do some extra logging if we have a prefence set for this
    if([ZPPreferences debugFileUploads]){
        NSString* newMD5 = [ZPZoteroAttachment md5ForFileAtPath:attachment.fileSystemPath_modified];
        NSString* oldMD5 = NULL;
        if(attachment.fileExists_original){
            oldMD5 = [ZPZoteroAttachment md5ForFileAtPath:attachment.fileSystemPath_original];
        }
        DDLogInfo(@"Additional version information for file %@:",attachment.filename);
        DDLogInfo(@"MD5 sum for old version:   %@", oldMD5);
        DDLogInfo(@"MD5 sum for new version:   %@", newMD5);
        DDLogInfo(@"MD5 from current metadata: %@", attachment.md5);
        DDLogInfo(@"Local version identifier:  %@", attachment.versionIdentifier_local);
        DDLogInfo(@"Server version identifier:  %@", attachment.versionIdentifier_server);
    }

}

@end
