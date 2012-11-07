//
//  ZPFileViewerViewController.h
//  ZotPad
//
//  Created by Rönkkö Mikko on 10/27/12.
//
//

#import <UIKit/UIKit.h>
#import "ZPAttachmentFileInteractionController.h"
#import "ZPCore.h"
#import "HLSPlaceholderViewController.h"

@interface ZPFileViewerViewController : HLSPlaceholderViewController <QLPreviewControllerDataSource, UITableViewDataSource, UITableViewDelegate>{
    ZPAttachmentFileInteractionController* _attachmentInteractionController;
    NSMutableArray* _attachments;
    NSInteger _activeAttachmentIndex;
    BOOL _leftPaneVisible;
    BOOL _rightPaneVisible;
    NSMutableArray* _previewControllers;
    UINavigationController* _itemViewers;
}

+(ZPFileViewerViewController*) instance;
+(void) presentWithAttachment:(ZPZoteroAttachment*)attachment;

@property (retain, nonatomic) IBOutlet UINavigationBar* navigationBar;
@property (retain, nonatomic) IBOutlet UIView* leftPullTab;
@property (retain, nonatomic) IBOutlet UIView* leftPullPane;
@property (retain, nonatomic) IBOutlet UIView* rightPullTab;
@property (retain, nonatomic) IBOutlet UIView* rightPullPane;
@property (retain, nonatomic) IBOutlet UISegmentedControl* navigationArrows;
@property (retain, nonatomic) IBOutlet UITableView* notesAndTagsTable;

- (IBAction) dismiss:(id)sender;
- (IBAction) actionButtonPressed:(id)sender;
- (IBAction) toggleStar:(id)sender;
- (IBAction) next:(id)sender;
- (IBAction) previous:(id)sender;
- (IBAction) presentAllFiles:(id)sender;
- (IBAction) toggleNavigationBar:(id)sender;

// Hiding and showing the pull panes
-(IBAction)togglePullPane:(id)sender;
-(IBAction)handlePanGestureOnPullPane:(UIPanGestureRecognizer *)gestureRecognizer;

-(void) addAttachmentToViewer:(ZPZoteroAttachment*)attachment;

@end
