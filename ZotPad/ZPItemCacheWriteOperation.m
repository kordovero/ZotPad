//
//  ZPItemCacheOperation.m
//  ZotPad
//
//  Created by Rönkkö Mikko on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ZPItemCacheWriteOperation.h"
#import "ZPDataLayer.h"
#import "ZPZoteroItem.h"

//TODO: Consider the tradeoffs of not having this as operation. It is only tens or hundreds of DB writes anyway.

@implementation ZPItemCacheWriteOperation

-(id) initWithZoteroItemArray:(NSArray*)items{
    self = [super init];
    _items= items;
    return self;
}

-(void) main {
    if ( self.isCancelled ) return;
    
    NSEnumerator *e = [_items objectEnumerator];
    id object;
    while ((object = [e nextObject]) && ! self.isCancelled) {
        [[ZPDataLayer instance] addItemToDatabase:(ZPZoteroItem*) object];
        //TODO: Cache collection memberships
        
        //Notify the user interface that this item is now available
        
        [[ZPDataLayer instance] notifyItemBasicsAvailable:(ZPZoteroItem*) object];
    }
}

@end
