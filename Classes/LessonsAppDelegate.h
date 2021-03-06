//
//  LessonsAppDelegate.h
//  Lessons
//
//  Created by Ernesto Rivera on 10/02/01.
//  Copyright PTEz 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MainViewController.h"

@interface LessonsAppDelegate : NSObject <UIApplicationDelegate>
{
    NSManagedObjectModel * managedObjectModel;
    NSManagedObjectContext * managedObjectContext;	    
    NSPersistentStoreCoordinator * persistentStoreCoordinator;
	
	// Outlets
	UIWindow * window;
	MainViewController * mainViewController;
}

@property (nonatomic, retain, readonly) NSManagedObjectModel * managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator * persistentStoreCoordinator;

@property (nonatomic, retain) IBOutlet UIWindow * window;
@property (nonatomic, retain) IBOutlet MainViewController *mainViewController;

- (NSString *)applicationDocumentsDirectory;

@end

