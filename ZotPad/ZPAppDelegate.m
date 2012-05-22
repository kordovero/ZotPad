//
//  ZPAppDelegate.m
//  ZotPad
//
//  Created by Rönkkö Mikko on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ZPCore.h"
#import "ZPAppDelegate.h"
#import "ZPCacheController.h"
#import "ZPPreferences.h"
#import "ZPLocalization.h"
#import <DropboxSDK/DropboxSDK.h>
#import "ZPDatabase.h"
#import "ZPFileImportViewController.h"
#import "ZPFileChannel_Dropbox.h"

@implementation ZPAppDelegate


@synthesize window = _window;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    [TestFlight takeOff:@"5e753f234f33fc2bddf4437600037fbf_NjcyMjEyMDEyLTA0LTA5IDE0OjUyOjU0LjE4MDQwMg"];
    
    //Manual override for userID and Key. Useful for running the code in debugger with other people's credentials.
    

    /*
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"" forKey:@"userID"];
    [defaults setObject:@"" forKey:@"OAuthKey"];

    //Uncomment these to always reset the app after launch
    [[ZPDatabase instance] resetDatabase];
    [[ZPCacheController instance] performSelectorInBackground:@selector(purgeAllAttachmentFilesFromCache) withObject:NULL];
    */
    
    [[ZPPreferences instance] checkAndProcessApplicationResetPreferences];
    [[ZPPreferences instance] reload];
     
    
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;

        if ([splitViewController respondsToSelector:@selector(setPresentsWithGesture:)]) {
            [splitViewController setPresentsWithGesture:NO];
        }

        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
    }

    //These will trigger authentication

    [ZPFileChannel_Dropbox linkDroboxIfNeeded];
    [[ZPCacheController instance] performSelectorInBackground:@selector(updateLibrariesAndCollectionsFromServer) withObject:NULL];

    TFLog(@"Started");
    
    return YES;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application{
    TFLog(@"Start freeing memory");
    [ZPZoteroItem dropCache];
    [ZPZoteroCollection dropCache];
    [ZPZoteroLibrary dropCache];
    [ZPLocalization dropCache];
    TFLog(@"Done freeing memory");

}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    
    [[ZPPreferences instance] reload];
    [ZPFileChannel_Dropbox linkDroboxIfNeeded];


}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    NSLog(@"Terminating");

    
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    //DropBox authentication
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            TFLog(@"App linked successfully with DropBox");
            // At this point you can start making API calls
        }
        return YES;
    }
    else{
              
        NSLog(@"Received file %@",url);
        [[[UIAlertView alloc] initWithTitle:@"Not implemented" message:@"This feature has not been fully implemented and is currently disabled. The file is ignored by ZotPad" delegate:NULL cancelButtonTitle:@"Cancel" otherButtonTitles: nil] show];
        //[self.window.rootViewController performSegueWithIdentifier:@"ReceivedFile" sender:url];
        return YES;
    }
    // Add whatever other url handling code your app requires here
    return NO;
}

@end
