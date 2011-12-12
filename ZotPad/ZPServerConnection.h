//
//  ZPServerConnection.h
//  ZotPad
//
//  Handles communication with Zotero server. Used as a singleton.
//
//  Created by Rönkkö Mikko on 11/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZPAuthenticationDialog.h"
#import "ZPServerResponseXMLParser.h"
#import "ZPZoteroItem.h"

@interface ZPServerConnection : NSObject{
        
    // Dialog that will show the Zotero login
 
    BOOL _debugServerConnection;
    
    NSInteger _activeRequestCount;
}

// This class is used as a singleton
+ (ZPServerConnection*) instance;

// Check if the connection is already authenticated
- (BOOL) authenticated;

// Methods to get data from the server
-(NSArray*) retrieveLibrariesFromServer;
-(NSArray*) retrieveCollectionsForLibraryFromServer:(NSInteger)libraryID;
-(ZPServerResponseXMLParser*) retrieveItemsFromLibrary:(NSInteger)libraryID collection:(NSString*)collectionKey searchString:(NSString*)searchString orderField:(NSString*)orderField sortDescending:(BOOL)sortIsDescending limit:(NSInteger)maxCount start:(NSInteger)offset;

-(ZPZoteroItem*) retrieveSingleItemDetailsFromServer:(ZPZoteroItem*)key;

@end
