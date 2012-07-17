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

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain) NSMutableString *insertResults;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *readWritePersistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *readWriteManagedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *readWriteManagedObjectContext;


- (IBAction)saveAction:sender;
- (IBAction)runConversion:sender;
- (void) invokeUtility;

@end
