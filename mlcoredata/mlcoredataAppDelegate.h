/**
MoraLife Core Data population application.  Parse flat file data and populate User persistent store

MLCoreData is the OS X application which will provide MoraLife with its default data set.  System data resides in easily manipulated csv files.  No easy method of Core Data population is available freely.  This is a custom Core Data population application

@class mlcoredataAppDelegate
@mainpage
@see Utility

@author Copyright 2010 Team Axe, LLC. All rights reserved. http://www.teamaxe.org
@date 05/22/2011
@file
*/

#import <Cocoa/Cocoa.h>

@interface mlcoredataAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
    IBOutlet NSTextView *resultsView;
    NSPersistentStoreCoordinator *__persistentStoreCoordinator;
    NSManagedObjectModel *__managedObjectModel;
    NSManagedObjectContext *__managedObjectContext;
    NSPersistentStoreCoordinator *__readWritePersistentStoreCoordinator;
    NSManagedObjectModel *__readWriteManagedObjectModel;
    NSManagedObjectContext *__readWriteManagedObjectContext;

}

@property (unsafe_unretained) IBOutlet NSWindow *window;
@property (nonatomic, strong) NSMutableString *insertResults;

@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *readWritePersistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSManagedObjectModel *readWriteManagedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext *readWriteManagedObjectContext;


- (IBAction)saveAction:sender;
- (IBAction)runConversion:sender;
- (void) invokeUtility;

@end
