/**
Implemenation:  Take csv data files and convert them to Core Data.  Build default set of UserData as well.
This class will not reside on shipping, production code.  It is only utilized to build the default Core Data store.  
It is entirely too time-consuming to be built on device.

@class Utility Utility.h
 */

#import "Utility.h"
#import "Constants.h"
#import "mlcoredataAppDelegate.h"
#import "NSString+ParsingExtensions.h"
#import "ReferencePerson.h"
#import "ReferenceText.h"
#import "ConscienceAsset.h"
#import "ReferenceBelief.h"
#import "Moral.h"
#import "Dilemma.h"
#import "Character.h"
#import "UserCharacter.h"
#import "UserCollectable.h"
#import "UserChoice.h"

@implementation Utility

- (instancetype)init
{
    self = [super init];
    if (self) {
		
		appDelegate = (mlcoredataAppDelegate *)[NSApplication sharedApplication].delegate;
        
		//Parse CSV's and then load Core Data with results
		NSMutableString *csvFilename = [NSMutableString stringWithString:@"tbl-morals"];
		[self readCSVData:csvFilename];
		[self buildReadOnlyCoreData:csvFilename];
        [self verifyData:csvFilename];

		csvFilename = [NSMutableString stringWithString:@"tbl-assets"];
		[self readCSVData:csvFilename];
		[self buildReadOnlyCoreData:csvFilename];
		[self verifyData:csvFilename];

		csvFilename = [NSMutableString stringWithString:@"tbl-figures"];
		[self readCSVData:csvFilename];
		[self buildReadOnlyCoreData:csvFilename];
		[self verifyData:csvFilename];

		csvFilename = [NSMutableString stringWithString:@"tbl-beliefs"];
		[self readCSVData:csvFilename];
		[self buildReadOnlyCoreData:csvFilename];
		[self verifyData:csvFilename];

		csvFilename = [NSMutableString stringWithString:@"tbl-texts"];
		[self readCSVData:csvFilename];
		[self buildReadOnlyCoreData:csvFilename];	
		[self verifyData:csvFilename];

		csvFilename = [NSMutableString stringWithString:@"tbl-texts-ref"];
		[self readCSVData:csvFilename];
		[self buildReadOnlyCoreData:csvFilename];
		[self verifyData:csvFilename];

		//Characters must be loaded first for RI with dilemmas
		csvFilename = [NSMutableString stringWithString:@"tbl-characters"];
		[self readCSVData:csvFilename];
		[self buildReadOnlyCoreData:csvFilename];
		[self verifyData:csvFilename];

		csvFilename = [NSMutableString stringWithString:@"tbl-dilemmas"];
		[self readCSVData:csvFilename];
		[self buildReadOnlyCoreData:csvFilename];
		[self verifyData:csvFilename];
        
		[self buildReadWriteCoreData];
		
    }

    return self;
}

/**
Implemenation:  Using an NSString parsing category, read in the flat file (CSV) and return an array of row records
 */
- (void) readCSVData:(NSString *) filename {

	NSString *csvPath = [[NSBundle mainBundle] pathForResource:filename ofType:@"csv"];
	NSError *csvReadError = nil;
	
	NSString *fileString = [NSString stringWithContentsOfFile:csvPath encoding:NSUTF8StringEncoding error: &csvReadError];
	
	NSLog(@"csv read error:%@", csvReadError);
	
	[csvDataImport removeAllObjects];
	csvDataImport = [fileString csvRows];
	
}

/**
Implemenation:  Overwrite the persistent store of the shipping application with default data in the User's RW store
 */
- (void) buildReadWriteCoreData{
    
    NSManagedObjectContext *context = appDelegate.readWriteManagedObjectContext;    
    
    //Retrieve readwrite Documents directory
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *userData =  [documentsDirectory stringByAppendingPathComponent:@"UserData.sqlite"];
//    NSURL *storeURL = [NSURL fileURLWithPath:userData];
//
//    NSLog(@"RWPATH:%@", userData);
    NSURL *storeURL = [NSURL fileURLWithPath:@"/Users/adamaxe/Workspace/projects/teamaxe/code/moralife/Classes/Model/UserData.sqlite"];
    
    id readWriteStore = [context.persistentStoreCoordinator persistentStoreForURL:storeURL];
	
    NSError *outError = nil;
	
    //Construct Unique Primary Key from dtstamp to millisecond
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMddHHmmssSSS";	
	
    NSString *currentDTS = [dateFormatter stringFromDate:[NSDate date]];
	
    UserCharacter *currentUserCharacter = [NSEntityDescription insertNewObjectForEntityForName:@"UserCharacter" inManagedObjectContext:context];
	
    currentUserCharacter.characterEye = MLEyeFileNameResourceDefault;
    currentUserCharacter.characterMouth = MLMouthFileNameResourceDefault;
    currentUserCharacter.characterFace = MLSymbolFileNameResourceDefault;
    currentUserCharacter.characterEyeColor = MLConscienceEyeColorDefault;
    currentUserCharacter.characterBrowColor = MLConscienceBrowColorDefault;
    currentUserCharacter.characterBubbleColor = MLBubbleColorDefault;
    currentUserCharacter.characterBubbleType = @0;
    currentUserCharacter.characterAge = @0;
    currentUserCharacter.characterSize = @1.0f;
    
    currentUserCharacter.characterAccessoryPrimary = MLPrimaryAccessoryFileNameResourceDefault;
    currentUserCharacter.characterAccessorySecondary = MLSecondaryAccessoryFileNameResourceDefault;
    currentUserCharacter.characterAccessoryTop = MLTopAccessoryFileNameResourceDefault;
    currentUserCharacter.characterAccessoryBottom = MLBottomAccessoryFileNameResourceDefault;
    currentUserCharacter.characterName = currentDTS; 
    currentUserCharacter.characterEnthusiasm = @(MLConscienceEnthusiasmDefault);   
    currentUserCharacter.characterMood = @(MLConscienceMoodDefault);   

    [context assignObject:currentUserCharacter toPersistentStore:readWriteStore];
    
    //Create the default bank
    UserCollectable *currentUserCollectable = [NSEntityDescription insertNewObjectForEntityForName:@"UserCollectable" inManagedObjectContext:context];
    
    currentUserCollectable.collectableCreationDate = [NSDate date];
    currentUserCollectable.collectableKey = [NSString stringWithFormat:@"%@%@", currentDTS, MLCollectableEthicals];
    currentUserCollectable.collectableName = MLCollectableEthicals;
    currentUserCollectable.collectableValue = @10.0f;
    
    [context assignObject:currentUserCollectable toPersistentStore:readWriteStore];
    
    currentUserCollectable = [NSEntityDescription insertNewObjectForEntityForName:@"UserCollectable" inManagedObjectContext:context];
    
    currentUserCollectable.collectableCreationDate = [NSDate date];
    currentUserCollectable.collectableKey = [NSString stringWithFormat:@"%@%@", currentDTS, @"mora-responsibility"];
    currentUserCollectable.collectableName = @"mora-responsibility";
    currentUserCollectable.collectableValue = @1.0f;
    
    [context assignObject:currentUserCollectable toPersistentStore:readWriteStore];
    
    currentUserCollectable = [NSEntityDescription insertNewObjectForEntityForName:@"UserCollectable" inManagedObjectContext:context];
    
    currentUserCollectable.collectableCreationDate = [NSDate date];
    currentUserCollectable.collectableKey = [NSString stringWithFormat:@"%@%@", currentDTS, @"figu-you"];
    currentUserCollectable.collectableName = @"figu-you";
    currentUserCollectable.collectableValue = @1.0f;
    
    currentUserCollectable = [NSEntityDescription insertNewObjectForEntityForName:@"UserCollectable" inManagedObjectContext:context];
    
    currentUserCollectable.collectableCreationDate = [NSDate date];
    currentUserCollectable.collectableKey = [NSString stringWithFormat:@"%@%@", currentDTS, @"asse-eye2"];
    currentUserCollectable.collectableName = @"asse-eye2";
    currentUserCollectable.collectableValue = @1.0f;
    [context assignObject:currentUserCollectable toPersistentStore:readWriteStore];

    currentUserCollectable = [NSEntityDescription insertNewObjectForEntityForName:@"UserCollectable" inManagedObjectContext:context];

    currentUserCollectable.collectableCreationDate = [NSDate date];
    currentUserCollectable.collectableKey = [NSString stringWithFormat:@"%@%@", currentDTS, @"asse-eyecolorgreen"];
    currentUserCollectable.collectableName = @"asse-eyecolorgreen";
    currentUserCollectable.collectableValue = @1.0f;
    [context assignObject:currentUserCollectable toPersistentStore:readWriteStore];

    currentUserCollectable = [NSEntityDescription insertNewObjectForEntityForName:@"UserCollectable" inManagedObjectContext:context];

    currentUserCollectable.collectableCreationDate = [NSDate date];
    currentUserCollectable.collectableKey = [NSString stringWithFormat:@"%@%@", currentDTS, @"asse-mouth1"];
    currentUserCollectable.collectableName = @"asse-mouth1";
    currentUserCollectable.collectableValue = @1.0f;
    [context assignObject:currentUserCollectable toPersistentStore:readWriteStore];

    currentUserCollectable = [NSEntityDescription insertNewObjectForEntityForName:@"UserCollectable" inManagedObjectContext:context];

    currentUserCollectable.collectableCreationDate = [NSDate date];
    currentUserCollectable.collectableKey = [NSString stringWithFormat:@"%@%@", currentDTS, @"asse-bubblecolorblue"];
    currentUserCollectable.collectableName = @"asse-bubblecolorblue";
    currentUserCollectable.collectableValue = @1.0f;
    [context assignObject:currentUserCollectable toPersistentStore:readWriteStore];

    currentUserCollectable = [NSEntityDescription insertNewObjectForEntityForName:@"UserCollectable" inManagedObjectContext:context];

    currentUserCollectable.collectableCreationDate = [NSDate date];
    currentUserCollectable.collectableKey = [NSString stringWithFormat:@"%@%@", currentDTS, @"asse-blankside"];
    currentUserCollectable.collectableName = @"asse-blankside";
    currentUserCollectable.collectableValue = @1.0f;
    [context assignObject:currentUserCollectable toPersistentStore:readWriteStore];
    
    currentUserCollectable = [NSEntityDescription insertNewObjectForEntityForName:@"UserCollectable" inManagedObjectContext:context];
    
    currentUserCollectable.collectableCreationDate = [NSDate date];
    currentUserCollectable.collectableKey = [NSString stringWithFormat:@"%@%@", currentDTS, @"asse-facenothing"];
    currentUserCollectable.collectableName = @"asse-facenothing";
    currentUserCollectable.collectableValue = @1.0f;
    [context assignObject:currentUserCollectable toPersistentStore:readWriteStore];
    
    currentUserCollectable = [NSEntityDescription insertNewObjectForEntityForName:@"UserCollectable" inManagedObjectContext:context];
    
    currentUserCollectable.collectableCreationDate = [NSDate date];
    currentUserCollectable.collectableKey = [NSString stringWithFormat:@"%@%@", currentDTS, @"asse-blanktop"];
    currentUserCollectable.collectableName = @"asse-blanktop";
    currentUserCollectable.collectableValue = @1.0f;
    [context assignObject:currentUserCollectable toPersistentStore:readWriteStore];
    
    currentUserCollectable = [NSEntityDescription insertNewObjectForEntityForName:@"UserCollectable" inManagedObjectContext:context];
    
    currentUserCollectable.collectableCreationDate = [NSDate date];
    currentUserCollectable.collectableKey = [NSString stringWithFormat:@"%@%@", currentDTS, @"asse-blankbottom"];
    currentUserCollectable.collectableName = @"asse-blankbottom";
    currentUserCollectable.collectableValue = @1.0f;
    [context assignObject:currentUserCollectable toPersistentStore:readWriteStore];
    
    currentUserCollectable = [NSEntityDescription insertNewObjectForEntityForName:@"UserCollectable" inManagedObjectContext:context];

    currentUserCollectable.collectableCreationDate = [NSDate date];
    currentUserCollectable.collectableKey = [NSString stringWithFormat:@"%@%@", currentDTS, @"asse-browcolorbrown"];
    currentUserCollectable.collectableName = @"asse-browcolorbrown";
    currentUserCollectable.collectableValue = @1.0f;
    
    [context assignObject:currentUserCollectable toPersistentStore:readWriteStore];

    currentUserCollectable = [NSEntityDescription insertNewObjectForEntityForName:@"UserCollectable" inManagedObjectContext:context];
    
    currentUserCollectable.collectableCreationDate = [NSDate date];
    currentUserCollectable.collectableKey = [NSString stringWithFormat:@"%@%@", currentDTS, @"asse-bubbletypeaverage"];
    currentUserCollectable.collectableName = @"asse-bubbletypeaverage";
    currentUserCollectable.collectableValue = @1.0f;
    
    [context assignObject:currentUserCollectable toPersistentStore:readWriteStore];

    currentUserCollectable = [NSEntityDescription insertNewObjectForEntityForName:@"UserCollectable" inManagedObjectContext:context];

    currentUserCollectable.collectableCreationDate = [NSDate date];
    currentUserCollectable.collectableKey = [NSString stringWithFormat:@"%@%@", currentDTS, @"asse-lancercap"];
    currentUserCollectable.collectableName = @"asse-lancercap";
    currentUserCollectable.collectableValue = @1.0f;

    [context assignObject:currentUserCollectable toPersistentStore:readWriteStore];

    UserChoice *currentUserChoice = [NSEntityDescription insertNewObjectForEntityForName:@"UserChoice" inManagedObjectContext:context];
    
    currentUserChoice.entryCreationDate = [NSDate date];
    [context assignObject:currentUserChoice toPersistentStore:readWriteStore];    
    currentUserChoice.entryShortDescription = @"Downloaded MoraLife!";
    currentUserChoice.entryLongDescription = @"Decided to give Ethical Accounting a try.";
    currentUserChoice.entrySeverity = @1.0f;
    currentUserChoice.entryModificationDate = [NSDate date];
    currentUserChoice.entryKey = [NSString stringWithFormat:@"%@%@", currentDTS, @"mora-responsibility"];
    currentUserChoice.choiceMoral = @"mora-responsibility";
    currentUserChoice.choiceJustification = @"Was moved by the MoraLife marketing campaign.";
    currentUserChoice.choiceInfluence = @1;
    currentUserChoice.entryIsGood = [NSNumber numberWithBool:TRUE];
    currentUserChoice.choiceConsequences = @"My wallet is a little lighter.";
    currentUserChoice.choiceWeight = @1.0f;          
    
    [context assignObject:currentUserCollectable toPersistentStore:readWriteStore];
        	
    [context save:&outError];
	    
    if (outError != nil) {
        NSLog(@"save error:%@", outError);
    }
	
    [context reset];
    
}

/**
Implemenation:  Based upon the filename argument, determine which type of records are to be entered into the RO store.
 */
- (void) buildReadOnlyCoreData:(NSString *) filename {
	
	NSManagedObjectContext *context = appDelegate.managedObjectContext;
	
	[context setUndoManager:nil];
	NSError *outError = nil;
	
	NSUInteger count = 0, LOOP_LIMIT = 500;

	ConscienceAsset *newAsset = nil;
	Moral *newMoral = nil;
	ReferenceText *newText = nil;
	ReferencePerson *newPerson = nil;
	ReferenceBelief *newBelief = nil;

    //Retrieve readwrite Documents directory
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
//	//Create pre-loaded SQLite db location
//	NSString *preloadDataReadOnly =  [documentsDirectory stringByAppendingPathComponent:@"SystemData.sqlite"];
//	NSURL *storeURLReadOnly = [NSURL fileURLWithPath:preloadDataReadOnly];
//
//    NSLog(@"RWPATH:%@", preloadDataReadOnly);

    NSURL *storeURLReadOnly = [NSURL fileURLWithPath:@"/Users/adamaxe/Workspace/projects/teamaxe/code/moralife/Classes/Model/SystemData.sqlite"];
    
	id readOnlyStore = [context.persistentStoreCoordinator persistentStoreForURL:storeURLReadOnly];
			
	for (NSArray *row in csvDataImport){
		
		if ([filename isEqualToString:@"tbl-assets"]) {
			
			newAsset = [NSEntityDescription insertNewObjectForEntityForName:@"ConscienceAsset" inManagedObjectContext:context];
			[newAsset setValue:row[0] forKey:@"nameReference"];
			[newAsset setValue:row[1] forKey:@"displayNameReference"];
			[newAsset setValue:row[2] forKey:@"imageNameReference"];
			[newAsset setValue:row[3] forKey:@"shortDescriptionReference"];
			[newAsset setValue:row[4] forKey:@"longDescriptionReference"];
			[newAsset setValue:row[5] forKey:@"orientationAsset"];
			[newAsset setValue:@([row[6] floatValue]) forKey:@"costAsset"];
			[newAsset setValue:@([row[9] intValue]) forKey:@"moralValueAsset"];
            
            //Determine if moral lookup is necessary
			if (![row[8] isEqualToString:@""]) {
				
				//If parent found, find Moral that needs parent relationship
				NSEntityDescription *entityMoralDesc = [NSEntityDescription entityForName:@"Moral" inManagedObjectContext:context];	
				NSFetchRequest *requestRef1 = [[NSFetchRequest alloc] init];
				requestRef1.entity = entityMoralDesc;
				
				NSString *value1 = row[8];
				NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"nameMoral == %@", value1];
				requestRef1.predicate = pred1;
				
				NSArray *objectsRef1 = [context executeFetchRequest:requestRef1 error:&outError];
				
				if (objectsRef1.count == 0) {
                    //					NSLog(@"No matches for a row");
				} else {
                    //					NSLog(@"moral:%@", [[objectsRef1 objectAtIndex:0] nameMoral]);
                    [newAsset setValue:objectsRef1[0] forKey:@"relatedMoral"];
//					NSLog(@"moral:%@", [[objectsRef1 objectAtIndex:0] imageNameMoral]);
				}
				
				
			}
            
            [context assignObject:newAsset toPersistentStore:readOnlyStore];
            

		}else if([filename isEqualToString:@"tbl-morals"]){
			
			newMoral = [NSEntityDescription insertNewObjectForEntityForName:@"Moral" inManagedObjectContext:context];
			[newMoral setValue:row[0] forKey:@"nameMoral"];	
			[newMoral setValue:row[1] forKey:@"displayNameMoral"];
			[newMoral setValue:row[2] forKey:@"imageNameMoral"];
			[newMoral setValue:row[3] forKey:@"linkMoral"];
			[newMoral setValue:row[4] forKey:@"shortDescriptionMoral"];
			[newMoral setValue:row[5] forKey:@"longDescriptionMoral"];
			[newMoral setValue:row[6] forKey:@"component"];
			[newMoral setValue:row[7] forKey:@"colorMoral"];
			[newMoral setValue:row[8] forKey:@"definitionMoral"];            
			[context assignObject:newMoral toPersistentStore:readOnlyStore];
			
		}else if ([filename isEqualToString:@"tbl-figures"]) {

			newPerson = [NSEntityDescription insertNewObjectForEntityForName:@"ReferencePerson" inManagedObjectContext:context];
			[newPerson setValue:row[0] forKey:@"nameReference"];	
			[newPerson setValue:row[1] forKey:@"displayNameReference"];
			[newPerson setValue:@([row[2] intValue]) forKey:@"originYear"];
			[newPerson setValue:@([row[8] intValue]) forKey:@"deathYearPerson"];
			[newPerson setValue:row[3] forKey:@"originLocation"];
			[newPerson setValue:row[4] forKey:@"imageNameReference"];
			[newPerson setValue:row[5] forKey:@"linkReference"];
			[newPerson setValue:row[6] forKey:@"shortDescriptionReference"];
			[newPerson setValue:row[7] forKey:@"longDescriptionReference"];
            [newPerson setValue:row[9] forKey:@"quotePerson"];

            //Determine if moralA lookup is necessary
			if (![row[11] isEqualToString:@""]) {
				
				//If parent found, find Moral that needs parent relationship
				NSEntityDescription *entityMoralDesc = [NSEntityDescription entityForName:@"Moral" inManagedObjectContext:context];	
				NSFetchRequest *requestRef1 = [[NSFetchRequest alloc] init];
				requestRef1.entity = entityMoralDesc;
				
				NSString *value1 = row[11];
				NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"nameMoral == %@", value1];
				requestRef1.predicate = pred1;
				
				NSArray *objectsRef1 = [context executeFetchRequest:requestRef1 error:&outError];
				
				if (objectsRef1.count == 0) {
                    //					NSLog(@"No matches for a row");
				} else {
                    //					NSLog(@"moral:%@", [[objectsRef1 objectAtIndex:0] nameMoral]);
                    [newPerson setValue:objectsRef1[0] forKey:@"relatedMoral"];
//					NSLog(@"moral:%@", [[objectsRef1 objectAtIndex:0] imageNameMoral]);
				}
				
				
			}
            
			[context assignObject:newPerson toPersistentStore:readOnlyStore];

		}else if ([filename isEqualToString:@"tbl-beliefs"]) {

			newBelief = [NSEntityDescription insertNewObjectForEntityForName:@"ReferenceBelief" inManagedObjectContext:context];
			[newBelief setValue:row[0] forKey:@"nameReference"];	
			[newBelief setValue:row[1] forKey:@"displayNameReference"];
			[newBelief setValue:@([row[2] intValue]) forKey:@"originYear"];
			[newBelief setValue:row[3] forKey:@"originLocation"];
			[newBelief setValue:row[4] forKey:@"imageNameReference"];
			[newBelief setValue:row[5] forKey:@"linkReference"];
			[newBelief setValue:row[6] forKey:@"shortDescriptionReference"];
			[newBelief setValue:row[7] forKey:@"longDescriptionReference"];
			[newBelief setValue:row[8] forKey:@"typeBelief"];
			
			[context assignObject:newBelief toPersistentStore:readOnlyStore];

		}else if ([filename isEqualToString:@"tbl-texts"]) {
			
			newText = [NSEntityDescription insertNewObjectForEntityForName:@"ReferenceText" inManagedObjectContext:context];
			[newText setValue:row[0] forKey:@"nameReference"];	
			[newText setValue:row[1] forKey:@"displayNameReference"];
			[newText setValue:@([row[2] intValue]) forKey:@"originYear"];
			[newText setValue:row[3] forKey:@"originLocation"];
			[newText setValue:row[4] forKey:@"imageNameReference"];
			[newText setValue:row[5] forKey:@"linkReference"];
			[newText setValue:row[6] forKey:@"shortDescriptionReference"];
			[newText setValue:row[7] forKey:@"longDescriptionReference"];
			
			[context assignObject:newText toPersistentStore:readOnlyStore];
		}else if ([filename isEqualToString:@"tbl-texts-ref"]) {
			
			
			//Determine if text parent lookup is necessary
			if (![row[1] isEqualToString:@""]) {
				
				//If parent found, find ReferenceText that needs parent relationship
				NSEntityDescription *entityTextRef1Desc = [NSEntityDescription entityForName:@"ReferenceText" inManagedObjectContext:context];	
				NSFetchRequest *requestRef1 = [[NSFetchRequest alloc] init];
				requestRef1.entity = entityTextRef1Desc;
				
				NSString *value1 = row[0];
				NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"nameReference == %@", value1];
				requestRef1.predicate = pred1;
				
				NSArray *objectsRef1 = [context executeFetchRequest:requestRef1 error:&outError];
				
				if (objectsRef1.count == 0) {
//					NSLog(@"No matches for a row %@ with an author:%@", [row objectAtIndex:0], [row objectAtIndex:1]);
				} else {
					
					//Assign ReferenceText that needs author
					ReferenceText *match1 = objectsRef1[0];
					
					//Find author reference
					NSEntityDescription *entityTextRef2Desc = [NSEntityDescription entityForName:@"ReferencePerson" inManagedObjectContext:context];	
					NSFetchRequest *requestRef2 = [[NSFetchRequest alloc] init];
					requestRef2.entity = entityTextRef2Desc;
					
					NSString *value2 = row[1];
					NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"nameReference == %@", value2];
					requestRef2.predicate = pred2;
					
					NSArray *objectsRef2 = [context executeFetchRequest:requestRef2 error:&outError];
					
					if (objectsRef2.count == 0) {
//						NSLog(@"No matches for author:%@", [row objectAtIndex:1]);
					} else {
						
						//Parent found
						ReferencePerson *author = objectsRef2[0];
						//NSLog(@"author:%@", [author nameReference]);
						
						[match1 setValue:author forKey:@"author"];
						//NSLog(@"author loaded:%@, %@", [match1 nameReference], [[match1 author] nameReference]);
						
					}
					
					
				}
				
				
			}
			
			//Determine if text parent lookup is necessary
			if (![row[2] isEqualToString:@""]) {
				
				//If parent found, find ReferenceText that needs parent relationship
				NSEntityDescription *entityTextRef1Desc = [NSEntityDescription entityForName:@"ReferenceText" inManagedObjectContext:context];	
				NSFetchRequest *requestRef1 = [[NSFetchRequest alloc] init];
				requestRef1.entity = entityTextRef1Desc;
				
				NSString *value1 = row[0];
				//NSString *wildcardedString2 = [NSString stringWithFormat:@"%@*", value2];
				//NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"nameReference == %@", wildcardedString2];
				NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"nameReference == %@", value1];
				requestRef1.predicate = pred1;
				
				NSArray *objectsRef1 = [context executeFetchRequest:requestRef1 error:&outError];
				
				if (objectsRef1.count == 0) {
//					NSLog(@"No matches");
				} else {
					
					//Assign ReferenceText that needs parent
					ReferenceText *match1 = objectsRef1[0];
					
					//Find parent reference
					NSEntityDescription *entityTextRef2Desc = [NSEntityDescription entityForName:@"ReferenceText" inManagedObjectContext:context];	
					NSFetchRequest *requestRef2 = [[NSFetchRequest alloc] init];
					requestRef2.entity = entityTextRef2Desc;
					
					NSString *value2 = row[2];
					//NSString *wildcardedString2 = [NSString stringWithFormat:@"%@*", value2];
					//NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"nameReference == %@", wildcardedString2];
					NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"nameReference == %@", value2];
					requestRef2.predicate = pred2;
					
					NSArray *objectsRef2 = [context executeFetchRequest:requestRef2 error:&outError];
					
					if (objectsRef2.count == 0) {
//						NSLog(@"No matches");
					} else {
						
						//Parent found
						ReferenceText *parent = objectsRef2[0];
						//NSLog(@"parent:%@", [parent nameReference]);
						
						[match1 setValue:parent forKey:@"parentReference"];
						//NSLog(@"parent loaded:%@, %@", [match1 nameReference], [[match1 parentReference] nameReference]);
						
					}
					
					
				}
				
				
			}
			
			
		}else if ([filename isEqualToString:@"tbl-characters"]) {
            
            newText = [NSEntityDescription insertNewObjectForEntityForName:@"Character" inManagedObjectContext:context];
			[newText setValue:row[0] forKey:@"nameCharacter"];	
			[newText setValue:row[2] forKey:@"bubbleColor"];
			[newText setValue:row[3] forKey:@"eyeColor"];
			[newText setValue:row[4] forKey:@"browColor"];
			[newText setValue:row[5] forKey:@"eyeCharacter"];
			[newText setValue:row[6] forKey:@"mouthCharacter"];
            [newText setValue:row[7] forKey:@"faceCharacter"];
            [newText setValue:@([row[8] intValue]) forKey:@"ageCharacter"];
            [newText setValue:@([row[9] intValue]) forKey:@"sizeCharacter"];
            [newText setValue:@([row[10] intValue]) forKey:@"bubbleType"];
			[newText setValue:row[11] forKey:@"accessoryTopCharacter"];
			[newText setValue:row[12] forKey:@"accessoryBottomCharacter"];
			[newText setValue:row[13] forKey:@"accessoryPrimaryCharacter"];
			[newText setValue:row[14] forKey:@"accessorySecondaryCharacter"];
            
			[context assignObject:newText toPersistentStore:readOnlyStore];
            
		}else if ([filename isEqualToString:@"tbl-dilemmas"]) {
            
			newText = [NSEntityDescription insertNewObjectForEntityForName:@"Dilemma" inManagedObjectContext:context];
			[newText setValue:row[0] forKey:@"nameDilemma"];	
			[newText setValue:row[1] forKey:@"displayNameDilemma"];
			[newText setValue:row[2] forKey:@"dilemmaText"];
			[newText setValue:row[3] forKey:@"choiceA"];
			[newText setValue:row[4] forKey:@"choiceB"];
            [newText setValue:row[7] forKey:@"rewardADilemma"];
            [newText setValue:row[8] forKey:@"rewardBDilemma"];
			[newText setValue:row[9] forKey:@"surrounding"];
            [newText setValue:@([row[11] intValue]) forKey:@"moodDilemma"];
            [newText setValue:@([row[12] intValue]) forKey:@"enthusiasmDilemma"];
            
            //Determine if moralA lookup is necessary
			if (![row[5] isEqualToString:@""]) {
				
				//If parent found, find ReferenceText that needs parent relationship
				NSEntityDescription *entityMoralDesc = [NSEntityDescription entityForName:@"Moral" inManagedObjectContext:context];	
				NSFetchRequest *requestRef1 = [[NSFetchRequest alloc] init];
				requestRef1.entity = entityMoralDesc;
				
				NSString *value1 = row[5];
				NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"nameMoral == %@", value1];
				requestRef1.predicate = pred1;
				
				NSArray *objectsRef1 = [context executeFetchRequest:requestRef1 error:&outError];
				
				if (objectsRef1.count == 0) {
//					NSLog(@"No matches for a row");
				} else {
//					NSLog(@"moral:%@", [[objectsRef1 objectAtIndex:0] nameMoral]);
                    [newText setValue:objectsRef1[0] forKey:@"moralChoiceA"];
					
				}
				
				
			}
            
            //Determine if moralB lookup is necessary
			if (![row[6] isEqualToString:@""]) {
				
				//If parent found, find ReferenceText that needs parent relationship
				NSEntityDescription *entityMoralDesc = [NSEntityDescription entityForName:@"Moral" inManagedObjectContext:context];	
				NSFetchRequest *requestRef1 = [[NSFetchRequest alloc] init];
				requestRef1.entity = entityMoralDesc;
				
				NSString *value1 = row[6];
				NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"nameMoral == %@", value1];
				requestRef1.predicate = pred1;
				
				NSArray *objectsRef1 = [context executeFetchRequest:requestRef1 error:&outError];
				
				if (objectsRef1.count == 0) {
//					NSLog(@"No matches for a row");
				} else {
//					NSLog(@"moral:%@", [[objectsRef1 objectAtIndex:0] nameMoral]);
                    [newText setValue:objectsRef1[0] forKey:@"moralChoiceB"];
					
				}
				
				
			}
            
            //Determine if character lookup is necessary
			if (![row[10] isEqualToString:@""]) {

				//If parent found, find ReferenceText that needs parent relationship
				NSEntityDescription *entityCharacterDesc = [NSEntityDescription entityForName:@"Character" inManagedObjectContext:context];	
				NSFetchRequest *requestRef1 = [[NSFetchRequest alloc] init];
				requestRef1.entity = entityCharacterDesc;
				
				NSString *value1 = row[10];
				NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"nameCharacter == %@", value1];
				requestRef1.predicate = pred1;
				
				NSArray *objectsRef1 = [context executeFetchRequest:requestRef1 error:&outError];
				
				if (objectsRef1.count == 0) {
//					NSLog(@"No matches for ant");
				} else {
                    [newText setValue:objectsRef1[0] forKey:@"antagonist"];
					
				}
				
				
			}
            
			[context assignObject:newText toPersistentStore:readOnlyStore];
		
		}
		
		count++;
		if (count == LOOP_LIMIT) {
			[context save:&outError];

			if (outError != nil) {
				NSLog(@"save:%@", outError);
				
			}
			[context reset];
			count = 0;
		}
		 
	}

	// Save any remaining records
	if (count != 0) {

		[context save:&outError];
		[context reset];
	}
				
	if (outError != nil) {
		NSLog(@"save:%@", outError);
		
	}
	
	
	
}

/**
 Implemenation:  Ensure that peristent store was populated correctly by outputting entire store.
 */
- (void) verifyData:(NSString *) filename {
    
    int rowCount = 0;
    
	NSManagedObjectContext *context = appDelegate.managedObjectContext;
    NSError *outError = nil;

	/*display results */    
	NSEntityDescription *entityAssetDesc = [NSEntityDescription entityForName:@"ConscienceAsset" inManagedObjectContext:context];
	NSEntityDescription *entityMoralDesc = [NSEntityDescription entityForName:@"Moral" inManagedObjectContext:context];
	NSEntityDescription *entityBeliefDesc = [NSEntityDescription entityForName:@"ReferenceBelief" inManagedObjectContext:context];
	NSEntityDescription *entityFigureDesc = [NSEntityDescription entityForName:@"ReferencePerson" inManagedObjectContext:context];
	NSEntityDescription *entityTextDesc = [NSEntityDescription entityForName:@"ReferenceText" inManagedObjectContext:context];
	NSEntityDescription *entityCharacterDesc = [NSEntityDescription entityForName:@"Character" inManagedObjectContext:context];
	NSEntityDescription *entityDilemmaDesc = [NSEntityDescription entityForName:@"Dilemma" inManagedObjectContext:context];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	if ([filename isEqualToString:@"tbl-assets"]) {
        
		request.entity = entityAssetDesc;
		
	}else if ([filename isEqualToString:@"tbl-morals"]) {
        
		request.entity = entityMoralDesc;
        
	}else if ([filename isEqualToString:@"tbl-figures"]) {
		
		request.entity = entityFigureDesc;
	}else if ([filename isEqualToString:@"tbl-beliefs"]) {
		
		request.entity = entityBeliefDesc;
		
	}else if ([filename isEqualToString:@"tbl-texts"]) {
		
		request.entity = entityTextDesc;
		
	}else if ([filename isEqualToString:@"tbl-texts-ref"]) {
		
		request.entity = entityTextDesc;
		
	}else if ([filename isEqualToString:@"tbl-characters"]) {
		
		request.entity = entityCharacterDesc;
		
	}else if ([filename isEqualToString:@"tbl-dilemmas"]) {
		
		request.entity = entityDilemmaDesc;
		
	}
    
	NSArray *objects = [context executeFetchRequest:request error:&outError];
	
	if (objects.count == 0) {
		NSLog(@"No matches");
	} else {
        
        
		if ([filename isEqualToString:@"tbl-assets"]) {
            [appDelegate.insertResults appendFormat:@"Beginning asset import.\n"];
            [appDelegate.insertResults appendFormat:@"-----------------------\n"];

			
			for (ConscienceAsset *matches in objects){
				[appDelegate.insertResults appendFormat:@"asset: %@, %@, %@, %@\n", matches.nameReference, matches.imageNameReference, matches.displayNameReference, matches.orientationAsset];
                rowCount++;

                				
			}
			
		}
		
		if ([filename isEqualToString:@"tbl-morals"]) {
			
            [appDelegate.insertResults appendFormat:@"Beginning moral import.\n"];
            [appDelegate.insertResults appendFormat:@"-----------------------\n"];

			for (Moral *matches in objects){
				[appDelegate.insertResults appendFormat:@"moral: %@, %@, %@, %@\n", matches.nameMoral, matches.component, matches.shortDescriptionMoral, matches.longDescriptionMoral];
                rowCount++;

				
			}			
		}
		
		if ([filename isEqualToString:@"tbl-figures"]) {
			
            [appDelegate.insertResults appendFormat:@"Beginning figure import.\n"];
            [appDelegate.insertResults appendFormat:@"-----------------------\n"];
            
			for (ReferencePerson *matches in objects){
				[appDelegate.insertResults appendFormat:@"figures: %@, %@, %@, %@, %@\n", matches.nameReference, matches.displayNameReference, matches.linkReference, matches.originYear, matches.deathYearPerson];
                rowCount++;

                
			}			

		}
		        
		if ([filename isEqualToString:@"tbl-beliefs"]) {
            
            [appDelegate.insertResults appendFormat:@"Beginning belief import.\n"];
            [appDelegate.insertResults appendFormat:@"-----------------------\n"];

            
            for (ReferenceText *matches in objects){
				[appDelegate.insertResults appendFormat:@"belief: %@, %@, %@, %@, %@\n", matches.nameReference, matches.displayNameReference, matches.linkReference, matches.originYear, matches.shortDescriptionReference];
                rowCount++;


            }			
                        
		}
        
		if ([filename isEqualToString:@"tbl-texts"]) {
            
            [appDelegate.insertResults appendFormat:@"Beginning text import.\n"];
            [appDelegate.insertResults appendFormat:@"-----------------------\n"];

			for (ReferenceText *matches in objects){
				[appDelegate.insertResults appendFormat:@"text: %@, %@, %@, %@, %@\n", matches.nameReference, matches.displayNameReference, matches.linkReference, matches.parentReference.nameReference, matches.shortDescriptionReference];
                rowCount++;

            }			
		}
		

		
        if ([filename isEqualToString:@"tbl-texts-ref"]) {
			
            [appDelegate.insertResults appendFormat:@"Beginning text RI import.\n"];
            [appDelegate.insertResults appendFormat:@"-----------------------\n"];

            
			for (ReferenceText *matches in objects){
                [appDelegate.insertResults appendFormat:@"book: %@, parent:%@, author:%@", matches.nameReference, matches.parentReference.nameReference, matches.author.nameReference];
                rowCount++;

				for (ReferenceText *children in matches.childrenReference) {
					NSLog(@"child:%@", children.nameReference);
				}
                
			}			
			
		}
        
        if ([filename isEqualToString:@"tbl-dilemmas"]) {
			
            [appDelegate.insertResults appendFormat:@"Beginning dilemma import.\n"];
            [appDelegate.insertResults appendFormat:@"-----------------------\n"];

			for (Dilemma *matches in objects){
				[appDelegate.insertResults appendFormat:@"dilemma: %@, %@\n", matches.nameDilemma, matches.choiceA];
                rowCount++;

			}			
			
		}
        
        if ([filename isEqualToString:@"tbl-characters"]) {
            
            [appDelegate.insertResults appendFormat:@"Beginning character import.\n"];
            [appDelegate.insertResults appendFormat:@"-----------------------\n"];

			
			for (Character *matches in objects){
				[appDelegate.insertResults appendFormat:@"character: %@\n", matches.nameCharacter];
                rowCount++;

			}			
			
		}        
        
	}
    
    [appDelegate.insertResults appendFormat:@"-----------------------\n"];
    [appDelegate.insertResults appendFormat:@"%d rows imported.\n\n", rowCount];

    
    
    
    entityAssetDesc = [NSEntityDescription entityForName:@"ConscienceAsset" inManagedObjectContext:context];
    request.entity = entityAssetDesc;
    
    
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == %@", @"nameReference", @"asse-faceichthus"];
    

    request.predicate = pred;
    
    
    
    objects = [context executeFetchRequest:request error:&outError];
    NSLog(@"objects:%@", objects);


}



@end
