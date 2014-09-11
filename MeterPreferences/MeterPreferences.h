#import <Preferences/Preferences.h>
#import <Twitter/Twitter.h>
#import <UIKit/UIKit.h>
#import <Foundation/NSDistributedNotificationCenter.h>

@interface MRListController : PSListController {
	NSMutableArray *themes;
}

@end

@interface MRListItemsController : PSListItemsController

@end

@interface PSListController (SettingsKit)
-(UIView*)view;
-(UINavigationController*)navigationController;
-(void)viewWillAppear:(BOOL)animated;
-(void)viewWillDisappear:(BOOL)animated;
-(void)viewDidDisappear:(BOOL)animated;

-(UINavigationController*)navigationController;
-(UINavigationItem*) navigationItem;

-(void)loadView;

-(id) tableView:(UITableView*)table cellForRowAtIndexPath:(NSIndexPath*)path;
-(void) tableView:(UITableView*)table didSelectRowAtIndexPath:(NSIndexPath*)path;
@end