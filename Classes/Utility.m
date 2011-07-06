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

- (id)init
{
    self = [super init];
    if (self) {
		
		appDelegate = (mlcoredataAppDelegate *)[[NSApplication sharedApplication] delegate];
        
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
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    //Retrieve readwrite Documents directory
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *userData =  [documentsDirectory stringByAppendingPathComponent:@"UserData.sqlite"];
//    NSURL *storeURL = [NSURL fileURLWithPath:userData];

    NSURL *momURLReadWrite = [NSURL fileURLWithPath:@"/Users/aaxe/Documents/teamaxe/code/moralife/Classes/Model/UserData.sqlite"];
    
    id readWriteStore = [[context persistentStoreCoordinator] persistentStoreForURL:momURLReadWrite];
	
    NSError *outError = nil;
	
    //Construct Unique Primary Key from dtstamp to millisecond
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmssSSS"];	
	
    NSString *currentDTS = [dateFormatter stringFromDate:[NSDate date]];
    
    [dateFormatter release];
	
    UserCharacter *currentUserCharacter = [NSEntityDescription insertNewObjectForEntityForName:@"UserCharacter" inManagedObjectContext:context];
	
    [currentUserCharacter setCharacterEye:kEyeFileNameResource];
    [currentUserCharacter setCharacterMouth:kMouthFileNameResource];
    [currentUserCharacter setCharacterFace:kSymbolFileNameResource];
    [currentUserCharacter setCharacterEyeColor:kEyeColor];
    [currentUserCharacter setCharacterBrowColor:kBrowColor];
    [currentUserCharacter setCharacterBubbleColor:kBubbleColor];
    [currentUserCharacter setCharacterBubbleType:[NSNumber numberWithInt:0]];
    [currentUserCharacter setCharacterAge:[NSNumber numberWithInt:0]];
    [currentUserCharacter setCharacterSize:[NSNumber numberWithFloat:1.0]];
    
    [currentUserCharacter setCharacterAccessoryPrimary:kPrimaryAccessoryFileNameResource];
    [currentUserCharacter setCharacterAccessorySecondary:kSecondaryAccessoryFileNameResource];
    [currentUserCharacter setCharacterAccessoryTop:kTopAccessoryFileNameResource];
    [currentUserCharacter setCharacterAccessoryBottom:kBottomAccessoryFileNameResource];
    [currentUserCharacter setCharacterName:currentDTS]; 
    [currentUserCharacter setCharacterEnthusiasm:[NSNumber numberWithFloat:kConscienceEnthusiasm]];   
    [currentUserCharacter setCharacterMood:[NSNumber numberWithFloat:kConscienceMood]];   

    [context assignObject:currentUserCharacter toPersistentStore:readWriteStore];
    
    //Create the default bank
    UserCollectable *currentUserCollectable = [NSEntityDescription insertNewObjectForEntityForName:@"UserCollectable" inManagedObjectContext:context];
    
    [currentUserCollectable setCollectableCreationDate:[NSDate date]];
    [currentUserCollectable setCollectableKey:[NSString stringWithFormat:@"%@%@", currentDTS, kCollectableEthicals]];
    [currentUserCollectable setCollectableName:kCollectableEthicals];
    [currentUserCollectable setCollectableValue:[NSNumber numberWithFloat:10.0]];
    
    [context assignObject:currentUserCollectable toPersistentStore:readWriteStore];
    
    currentUserCollectable = [NSEntityDescription insertNewObjectForEntityForName:@"UserCollectable" inManagedObjectContext:context];
    
    [currentUserCollectable setCollectableCreationDate:[NSDate date]];
    [currentUserCollectable setCollectableKey:[NSString stringWithFormat:@"%@%@", currentDTS, @"mora-responsibility"]];
    [currentUserCollectable setCollectableName:@"mora-responsibility"];
    [currentUserCollectable setCollectableValue:[NSNumber numberWithFloat:1.0]];
    
    [context assignObject:currentUserCollectable toPersistentStore:readWriteStore];
    
    currentUserCollectable = [NSEntityDescription insertNewObjectForEntityForName:@"UserCollectable" inManagedObjectContext:context];
    
    [currentUserCollectable setCollectableCreationDate:[NSDate date]];
    [currentUserCollectable setCollectableKey:[NSString stringWithFormat:@"%@%@", currentDTS, @"figu-you"]];
    [currentUserCollectable setCollectableName:@"figu-you"];
    [currentUserCollectable setCollectableValue:[NSNumber numberWithFloat:1.0]];
    
    currentUserCollectable = [NSEntityDescription insertNewObjectForEntityForName:@"UserCollectable" inManagedObjectContext:context];
    
    [currentUserCollectable setCollectableCreationDate:[NSDate date]];
    [currentUserCollectable setCollectableKey:[NSString stringWithFormat:@"%@%@", currentDTS, @"asse-eye2"]];
    [currentUserCollectable setCollectableName:@"asse-eye2"];
    [currentUserCollectable setCollectableValue:[NSNumber numberWithFloat:1.0]];
    [context assignObject:currentUserCollectable toPersistentStore:readWriteStore];

    currentUserCollectable = [NSEntityDescription insertNewObjectForEntityForName:@"UserCollectable" inManagedObjectContext:context];

    [currentUserCollectable setCollectableCreationDate:[NSDate date]];
    [currentUserCollectable setCollectableKey:[NSString stringWithFormat:@"%@%@", currentDTS, @"asse-eyecolorgreen"]];
    [currentUserCollectable setCollectableName:@"asse-eyecolorgreen"];
    [currentUserCollectable setCollectableValue:[NSNumber numberWithFloat:1.0]];
    [context assignObject:currentUserCollectable toPersistentStore:readWriteStore];

    currentUserCollectable = [NSEntityDescription insertNewObjectForEntityForName:@"UserCollectable" inManagedObjectContext:context];

    [currentUserCollectable setCollectableCreationDate:[NSDate date]];
    [currentUserCollectable setCollectableKey:[NSString stringWithFormat:@"%@%@", currentDTS, @"asse-mouth1"]];
    [currentUserCollectable setCollectableName:@"asse-mouth1"];
    [currentUserCollectable setCollectableValue:[NSNumber numberWithFloat:1.0]];
    [context assignObject:currentUserCollectable toPersistentStore:readWriteStore];

    currentUserCollectable = [NSEntityDescription insertNewObjectForEntityForName:@"UserCollectable" inManagedObjectContext:context];

    [currentUserCollectable setCollectableCreationDate:[NSDate date]];
    [currentUserCollectable setCollectableKey:[NSString stringWithFormat:@"%@%@", currentDTS, @"asse-bubblecolorblue"]];
    [currentUserCollectable setCollectableName:@"asse-bubblecolorblue"];
    [currentUserCollectable setCollectableValue:[NSNumber numberWithFloat:1.0]];
    [context assignObject:currentUserCollectable toPersistentStore:readWriteStore];

    currentUserCollectable = [NSEntityDescription insertNewObjectForEntityForName:@"UserCollectable" inManagedObjectContext:context];

    [currentUserCollectable setCollectableCreationDate:[NSDate date]];
    [currentUserCollectable setCollectableKey:[NSString stringWithFormat:@"%@%@", currentDTS, @"asse-blankside"]];
    [currentUserCollectable setCollectableName:@"asse-blankside"];
    [currentUserCollectable setCollectableValue:[NSNumber numberWithFloat:1.0]];
    [context assignObject:currentUserCollectable toPersistentStore:readWriteStore];
    
    currentUserCollectable = [NSEntityDescription insertNewObjectForEntityForName:@"UserCollectable" inManagedObjectContext:context];
    
    [currentUserCollectable setCollectableCreationDate:[NSDate date]];
    [currentUserCollectable setCollectableKey:[NSString stringWithFormat:@"%@%@", currentDTS, @"asse-facenothing"]];
    [currentUserCollectable setCollectableName:@"asse-facenothing"];
    [currentUserCollectable setCollectableValue:[NSNumber numberWithFloat:1.0]];
    [context assignObject:currentUserCollectable toPersistentStore:readWriteStore];
    
    currentUserCollectable = [NSEntityDescription insertNewObjectForEntityForName:@"UserCollectable" inManagedObjectContext:context];
    
    [currentUserCollectable setCollectableCreationDate:[NSDate date]];
    [currentUserCollectable setCollectableKey:[NSString stringWithFormat:@"%@%@", currentDTS, @"asse-blanktop"]];
    [currentUserCollectable setCollectableName:@"asse-blanktop"];
    [currentUserCollectable setCollectableValue:[NSNumber numberWithFloat:1.0]];
    [context assignObject:currentUserCollectable toPersistentStore:readWriteStore];
    
    currentUserCollectable = [NSEntityDescription insertNewObjectForEntityForName:@"UserCollectable" inManagedObjectContext:context];
    
    [currentUserCollectable setCollectableCreationDate:[NSDate date]];
    [currentUserCollectable setCollectableKey:[NSString stringWithFormat:@"%@%@", currentDTS, @"asse-blankbottom"]];
    [currentUserCollectable setCollectableName:@"asse-blankbottom"];
    [currentUserCollectable setCollectableValue:[NSNumber numberWithFloat:1.0]];
    [context assignObject:currentUserCollectable toPersistentStore:readWriteStore];
    
    currentUserCollectable = [NSEntityDescription insertNewObjectForEntityForName:@"UserCollectable" inManagedObjectContext:context];

    [currentUserCollectable setCollectableCreationDate:[NSDate date]];
    [currentUserCollectable setCollectableKey:[NSString stringWithFormat:@"%@%@", currentDTS, @"asse-browcolorbrown"]];
    [currentUserCollectable setCollectableName:@"asse-browcolorbrown"];
    [currentUserCollectable setCollectableValue:[NSNumber numberWithFloat:1.0]];
    
    [context assignObject:currentUserCollectable toPersistentStore:readWriteStore];

    currentUserCollectable = [NSEntityDescription insertNewObjectForEntityForName:@"UserCollectable" inManagedObjectContext:context];
    
    [currentUserCollectable setCollectableCreationDate:[NSDate date]];
    [currentUserCollectable setCollectableKey:[NSString stringWithFormat:@"%@%@", currentDTS, @"asse-bubbletypeaverage"]];
    [currentUserCollectable setCollectableName:@"asse-bubbletypeaverage"];
    [currentUserCollectable setCollectableValue:[NSNumber numberWithFloat:1.0]];
    
    [context assignObject:currentUserCollectable toPersistentStore:readWriteStore];
    
    UserChoice *currentUserChoice = [NSEntityDescription insertNewObjectForEntityForName:@"UserChoice" inManagedObjectContext:context];
    
    [currentUserChoice setEntryCreationDate:[NSDate date]];
    [context assignObject:currentUserChoice toPersistentStore:readWriteStore];    
    [currentUserChoice setEntryShortDescription:@"Downloaded MoraLife!"];
    [currentUserChoice setEntryLongDescription:@"Decided to give Ethical Accounting a try."];
    [currentUserChoice setEntrySeverity:[NSNumber numberWithFloat:1]];
    [currentUserChoice setEntryModificationDate:[NSDate date]];
    [currentUserChoice setEntryKey:[NSString stringWithFormat:@"%@%@", currentDTS, @"mora-responsibility"]];
    [currentUserChoice setChoiceMoral:@"mora-responsibility"];
    [currentUserChoice setChoiceJustification:@"Was moved by the MoraLife marketing campaign."];
    [currentUserChoice setChoiceInfluence:[NSNumber numberWithInt:1]];
    [currentUserChoice setEntryIsGood:[NSNumber numberWithBool:TRUE]];
    [currentUserChoice setChoiceConsequences:@"My wallet is a little lighter."];
    [currentUserChoice setChoiceWeight:[NSNumber numberWithFloat:1.0]];          
    
    [context assignObject:currentUserCollectable toPersistentStore:readWriteStore];
        	
    [context save:&outError];
	
    NSLog(@"writing userdata");
    
    if (outError != nil) {
        NSLog(@"save error:%@", outError);
    }
	
    [context reset];
    
}

/**
Implemenation:  Based upon the filename argument, determine which type of records are to be entered into the RO store.
 */
- (void) buildReadOnlyCoreData:(NSString *) filename {
	
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	
	[context setUndoManager:nil];
	NSError *outError = nil;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSUInteger count = 0, LOOP_LIMIT = 500;

	ConscienceAsset *newAsset = nil;
	Moral *newMoral = nil;
	ReferenceText *newText = nil;
	ReferencePerson *newPerson = nil;
	ReferenceBelief *newBelief = nil;
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy"];

    //Retrieve readwrite Documents directory
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
//	//Create pre-loaded SQLite db location
//	NSString *preloadDataReadOnly =  [documentsDirectory stringByAppendingPathComponent:@"SystemData.sqlite"];
//	NSURL *storeURLReadOnly = [NSURL fileURLWithPath:preloadDataReadOnly];

    NSURL *momURLReadOnly = [NSURL fileURLWithPath:@"/Users/aaxe/Documents/teamaxe/code/moralife/Classes/Model/SystemData.sqlite"];
    
	id readOnlyStore = [[context persistentStoreCoordinator] persistentStoreForURL:momURLReadOnly];
			
	for (NSArray *row in csvDataImport){
		
		if ([filename isEqualToString:@"tbl-assets"]) {
			
			newAsset = [NSEntityDescription insertNewObjectForEntityForName:@"ConscienceAsset" inManagedObjectContext:context];
			[newAsset setValue:[row objectAtIndex:0] forKey:@"nameReference"];
			[newAsset setValue:[row objectAtIndex:1] forKey:@"displayNameReference"];
			[newAsset setValue:[row objectAtIndex:2] forKey:@"imageNameReference"];
			[newAsset setValue:[row objectAtIndex:3] forKey:@"shortDescriptionReference"];
			[newAsset setValue:[row objectAtIndex:4] forKey:@"longDescriptionReference"];
			[newAsset setValue:[row objectAtIndex:5] forKey:@"orientationAsset"];
			[newAsset setValue:[NSNumber numberWithFloat:[[row objectAtIndex:6] floatValue]] forKey:@"costAsset"];
			[newAsset setValue:[NSNumber numberWithInt:[[row objectAtIndex:9] intValue]] forKey:@"moralValueAsset"];
            
            //Determine if moral lookup is necessary
			if (![[row objectAtIndex:8] isEqualToString:@""]) {
				
				//If parent found, find Moral that needs parent relationship
				NSEntityDescription *entityMoralDesc = [NSEntityDescription entityForName:@"Moral" inManagedObjectContext:context];	
				NSFetchRequest *requestRef1 = [[NSFetchRequest alloc] init];
				[requestRef1 setEntity:entityMoralDesc];
				
				NSString *value1 = [row objectAtIndex:8];
				NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"nameMoral == %@", value1];
				[requestRef1 setPredicate:pred1];
				
				NSArray *objectsRef1 = [context executeFetchRequest:requestRef1 error:&outError];
				
				if ([objectsRef1 count] == 0) {
                    //					NSLog(@"No matches for a row");
				} else {
                    //					NSLog(@"moral:%@", [[objectsRef1 objectAtIndex:0] nameMoral]);
                    [newAsset setValue:[objectsRef1 objectAtIndex:0] forKey:@"relatedMoral"];
//					NSLog(@"moral:%@", [[objectsRef1 objectAtIndex:0] imageNameMoral]);
				}
				
				[requestRef1 release];
				
			}
            
            [context assignObject:newAsset toPersistentStore:readOnlyStore];
            

		}else if([filename isEqualToString:@"tbl-morals"]){
			
			newMoral = [NSEntityDescription insertNewObjectForEntityForName:@"Moral" inManagedObjectContext:context];
			[newMoral setValue:[row objectAtIndex:0] forKey:@"nameMoral"];	
			[newMoral setValue:[row objectAtIndex:1] forKey:@"displayNameMoral"];
			[newMoral setValue:[row objectAtIndex:2] forKey:@"imageNameMoral"];
			[newMoral setValue:[row objectAtIndex:3] forKey:@"linkMoral"];
			[newMoral setValue:[row objectAtIndex:4] forKey:@"shortDescriptionMoral"];
			[newMoral setValue:[row objectAtIndex:5] forKey:@"longDescriptionMoral"];
			[newMoral setValue:[row objectAtIndex:6] forKey:@"component"];
			[newMoral setValue:[row objectAtIndex:7] forKey:@"colorMoral"];
			[newMoral setValue:[row objectAtIndex:8] forKey:@"definitionMoral"];            
			[context assignObject:newMoral toPersistentStore:readOnlyStore];
			
		}else if ([filename isEqualToString:@"tbl-figures"]) {

			newPerson = [NSEntityDescription insertNewObjectForEntityForName:@"ReferencePerson" inManagedObjectContext:context];
			[newPerson setValue:[row objectAtIndex:0] forKey:@"nameReference"];	
			[newPerson setValue:[row objectAtIndex:1] forKey:@"displayNameReference"];
			[newPerson setValue:[NSNumber numberWithInt:[[row objectAtIndex:2] intValue]] forKey:@"originYear"];
			[newPerson setValue:[NSNumber numberWithInt:[[row objectAtIndex:8] intValue]] forKey:@"deathYearPerson"];
			[newPerson setValue:[row objectAtIndex:3] forKey:@"originLocation"];
			[newPerson setValue:[row objectAtIndex:4] forKey:@"imageNameReference"];
			[newPerson setValue:[row objectAtIndex:5] forKey:@"linkReference"];
			[newPerson setValue:[row objectAtIndex:6] forKey:@"shortDescriptionReference"];
			[newPerson setValue:[row objectAtIndex:7] forKey:@"longDescriptionReference"];
            [newPerson setValue:[row objectAtIndex:9] forKey:@"quotePerson"];

            //Determine if moralA lookup is necessary
			if (![[row objectAtIndex:11] isEqualToString:@""]) {
				
				//If parent found, find Moral that needs parent relationship
				NSEntityDescription *entityMoralDesc = [NSEntityDescription entityForName:@"Moral" inManagedObjectContext:context];	
				NSFetchRequest *requestRef1 = [[NSFetchRequest alloc] init];
				[requestRef1 setEntity:entityMoralDesc];
				
				NSString *value1 = [row objectAtIndex:11];
				NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"nameMoral == %@", value1];
				[requestRef1 setPredicate:pred1];
				
				NSArray *objectsRef1 = [context executeFetchRequest:requestRef1 error:&outError];
				
				if ([objectsRef1 count] == 0) {
                    //					NSLog(@"No matches for a row");
				} else {
                    //					NSLog(@"moral:%@", [[objectsRef1 objectAtIndex:0] nameMoral]);
                    [newPerson setValue:[objectsRef1 objectAtIndex:0] forKey:@"relatedMoral"];
//					NSLog(@"moral:%@", [[objectsRef1 objectAtIndex:0] imageNameMoral]);
				}
				
				[requestRef1 release];
				
			}
            
			[context assignObject:newPerson toPersistentStore:readOnlyStore];

		}else if ([filename isEqualToString:@"tbl-beliefs"]) {

			newBelief = [NSEntityDescription insertNewObjectForEntityForName:@"ReferenceBelief" inManagedObjectContext:context];
			[newBelief setValue:[row objectAtIndex:0] forKey:@"nameReference"];	
			[newBelief setValue:[row objectAtIndex:1] forKey:@"displayNameReference"];
			[newBelief setValue:[NSNumber numberWithInt:[[row objectAtIndex:2] intValue]] forKey:@"originYear"];
			[newBelief setValue:[row objectAtIndex:3] forKey:@"originLocation"];
			[newBelief setValue:[row objectAtIndex:4] forKey:@"imageNameReference"];
			[newBelief setValue:[row objectAtIndex:5] forKey:@"linkReference"];
			[newBelief setValue:[row objectAtIndex:6] forKey:@"shortDescriptionReference"];
			[newBelief setValue:[row objectAtIndex:7] forKey:@"longDescriptionReference"];
			[newBelief setValue:[row objectAtIndex:8] forKey:@"typeBelief"];
			
			[context assignObject:newBelief toPersistentStore:readOnlyStore];

		}else if ([filename isEqualToString:@"tbl-texts"]) {
			
			newText = [NSEntityDescription insertNewObjectForEntityForName:@"ReferenceText" inManagedObjectContext:context];
			[newText setValue:[row objectAtIndex:0] forKey:@"nameReference"];	
			[newText setValue:[row objectAtIndex:1] forKey:@"displayNameReference"];
			[newText setValue:[NSNumber numberWithInt:[[row objectAtIndex:2] intValue]] forKey:@"originYear"];
			[newText setValue:[row objectAtIndex:3] forKey:@"originLocation"];
			[newText setValue:[row objectAtIndex:4] forKey:@"imageNameReference"];
			[newText setValue:[row objectAtIndex:5] forKey:@"linkReference"];
			[newText setValue:[row objectAtIndex:6] forKey:@"shortDescriptionReference"];
			[newText setValue:[row objectAtIndex:7] forKey:@"longDescriptionReference"];
			
			[context assignObject:newText toPersistentStore:readOnlyStore];
		}else if ([filename isEqualToString:@"tbl-texts-ref"]) {
			
			
			//Determine if text parent lookup is necessary
			if (![[row objectAtIndex:1] isEqualToString:@""]) {
				
				//If parent found, find ReferenceText that needs parent relationship
				NSEntityDescription *entityTextRef1Desc = [NSEntityDescription entityForName:@"ReferenceText" inManagedObjectContext:context];	
				NSFetchRequest *requestRef1 = [[NSFetchRequest alloc] init];
				[requestRef1 setEntity:entityTextRef1Desc];
				
				NSString *value1 = [row objectAtIndex:0];
				NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"nameReference == %@", value1];
				[requestRef1 setPredicate:pred1];
				
				NSArray *objectsRef1 = [context executeFetchRequest:requestRef1 error:&outError];
				
				if ([objectsRef1 count] == 0) {
//					NSLog(@"No matches for a row %@ with an author:%@", [row objectAtIndex:0], [row objectAtIndex:1]);
				} else {
					
					//Assign ReferenceText that needs author
					ReferenceText *match1 = [objectsRef1 objectAtIndex:0];
					
					//Find author reference
					NSEntityDescription *entityTextRef2Desc = [NSEntityDescription entityForName:@"ReferencePerson" inManagedObjectContext:context];	
					NSFetchRequest *requestRef2 = [[NSFetchRequest alloc] init];
					[requestRef2 setEntity:entityTextRef2Desc];
					
					NSString *value2 = [row objectAtIndex:1];
					NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"nameReference == %@", value2];
					[requestRef2 setPredicate:pred2];
					
					NSArray *objectsRef2 = [context executeFetchRequest:requestRef2 error:&outError];
					
					if ([objectsRef2 count] == 0) {
//						NSLog(@"No matches for author:%@", [row objectAtIndex:1]);
					} else {
						
						//Parent found
						ReferencePerson *author = [objectsRef2 objectAtIndex:0];
						//NSLog(@"author:%@", [author nameReference]);
						
						[match1 setValue:author forKey:@"author"];
						//NSLog(@"author loaded:%@, %@", [match1 nameReference], [[match1 author] nameReference]);
						
					}
					
					[requestRef2 release];
					
				}
				
				[requestRef1 release];
				
			}
			
			//Determine if text parent lookup is necessary
			if (![[row objectAtIndex:2] isEqualToString:@""]) {
				
				//If parent found, find ReferenceText that needs parent relationship
				NSEntityDescription *entityTextRef1Desc = [NSEntityDescription entityForName:@"ReferenceText" inManagedObjectContext:context];	
				NSFetchRequest *requestRef1 = [[NSFetchRequest alloc] init];
				[requestRef1 setEntity:entityTextRef1Desc];
				
				NSString *value1 = [row objectAtIndex:0];
				//NSString *wildcardedString2 = [NSString stringWithFormat:@"%@*", value2];
				//NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"nameReference == %@", wildcardedString2];
				NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"nameReference == %@", value1];
				[requestRef1 setPredicate:pred1];
				
				NSArray *objectsRef1 = [context executeFetchRequest:requestRef1 error:&outError];
				
				if ([objectsRef1 count] == 0) {
//					NSLog(@"No matches");
				} else {
					
					//Assign ReferenceText that needs parent
					ReferenceText *match1 = [objectsRef1 objectAtIndex:0];
					
					//Find parent reference
					NSEntityDescription *entityTextRef2Desc = [NSEntityDescription entityForName:@"ReferenceText" inManagedObjectContext:context];	
					NSFetchRequest *requestRef2 = [[NSFetchRequest alloc] init];
					[requestRef2 setEntity:entityTextRef2Desc];
					
					NSString *value2 = [row objectAtIndex:2];
					//NSString *wildcardedString2 = [NSString stringWithFormat:@"%@*", value2];
					//NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"nameReference == %@", wildcardedString2];
					NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"nameReference == %@", value2];
					[requestRef2 setPredicate:pred2];
					
					NSArray *objectsRef2 = [context executeFetchRequest:requestRef2 error:&outError];
					
					if ([objectsRef2 count] == 0) {
//						NSLog(@"No matches");
					} else {
						
						//Parent found
						ReferenceText *parent = [objectsRef2 objectAtIndex:0];
						//NSLog(@"parent:%@", [parent nameReference]);
						
						[match1 setValue:parent forKey:@"parentReference"];
						//NSLog(@"parent loaded:%@, %@", [match1 nameReference], [[match1 parentReference] nameReference]);
						
					}
					
					[requestRef2 release];
					
				}
				
				[requestRef1 release];
				
			}
			
			
		}else if ([filename isEqualToString:@"tbl-characters"]) {
            
            newText = [NSEntityDescription insertNewObjectForEntityForName:@"Character" inManagedObjectContext:context];
			[newText setValue:[row objectAtIndex:0] forKey:@"nameCharacter"];	
			[newText setValue:[row objectAtIndex:2] forKey:@"bubbleColor"];
			[newText setValue:[row objectAtIndex:3] forKey:@"eyeColor"];
			[newText setValue:[row objectAtIndex:4] forKey:@"browColor"];
			[newText setValue:[row objectAtIndex:5] forKey:@"eyeCharacter"];
			[newText setValue:[row objectAtIndex:6] forKey:@"mouthCharacter"];
            [newText setValue:[row objectAtIndex:7] forKey:@"faceCharacter"];
            [newText setValue:[NSNumber numberWithInt:[[row objectAtIndex:8] intValue]] forKey:@"ageCharacter"];
            [newText setValue:[NSNumber numberWithInt:[[row objectAtIndex:9] intValue]] forKey:@"sizeCharacter"];
            [newText setValue:[NSNumber numberWithInt:[[row objectAtIndex:10] intValue]] forKey:@"bubbleType"];
			[newText setValue:[row objectAtIndex:11] forKey:@"accessoryTopCharacter"];
			[newText setValue:[row objectAtIndex:12] forKey:@"accessoryBottomCharacter"];
			[newText setValue:[row objectAtIndex:13] forKey:@"accessoryPrimaryCharacter"];
			[newText setValue:[row objectAtIndex:14] forKey:@"accessorySecondaryCharacter"];
            
			[context assignObject:newText toPersistentStore:readOnlyStore];
            
		}else if ([filename isEqualToString:@"tbl-dilemmas"]) {
            
			newText = [NSEntityDescription insertNewObjectForEntityForName:@"Dilemma" inManagedObjectContext:context];
			[newText setValue:[row objectAtIndex:0] forKey:@"nameDilemma"];	
			[newText setValue:[row objectAtIndex:1] forKey:@"displayNameDilemma"];
			[newText setValue:[row objectAtIndex:2] forKey:@"dilemmaText"];
			[newText setValue:[row objectAtIndex:3] forKey:@"choiceA"];
			[newText setValue:[row objectAtIndex:4] forKey:@"choiceB"];
            [newText setValue:[row objectAtIndex:7] forKey:@"rewardADilemma"];
            [newText setValue:[row objectAtIndex:8] forKey:@"rewardBDilemma"];
			[newText setValue:[row objectAtIndex:9] forKey:@"surrounding"];
            [newText setValue:[NSNumber numberWithInt:[[row objectAtIndex:11] intValue]] forKey:@"moodDilemma"];
            [newText setValue:[NSNumber numberWithInt:[[row objectAtIndex:12] intValue]] forKey:@"enthusiasmDilemma"];
            
            //Determine if moralA lookup is necessary
			if (![[row objectAtIndex:5] isEqualToString:@""]) {
				
				//If parent found, find ReferenceText that needs parent relationship
				NSEntityDescription *entityMoralDesc = [NSEntityDescription entityForName:@"Moral" inManagedObjectContext:context];	
				NSFetchRequest *requestRef1 = [[NSFetchRequest alloc] init];
				[requestRef1 setEntity:entityMoralDesc];
				
				NSString *value1 = [row objectAtIndex:5];
				NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"nameMoral == %@", value1];
				[requestRef1 setPredicate:pred1];
				
				NSArray *objectsRef1 = [context executeFetchRequest:requestRef1 error:&outError];
				
				if ([objectsRef1 count] == 0) {
//					NSLog(@"No matches for a row");
				} else {
//					NSLog(@"moral:%@", [[objectsRef1 objectAtIndex:0] nameMoral]);
                    [newText setValue:[objectsRef1 objectAtIndex:0] forKey:@"moralChoiceA"];
					
				}
				
				[requestRef1 release];
				
			}
            
            //Determine if moralB lookup is necessary
			if (![[row objectAtIndex:6] isEqualToString:@""]) {
				
				//If parent found, find ReferenceText that needs parent relationship
				NSEntityDescription *entityMoralDesc = [NSEntityDescription entityForName:@"Moral" inManagedObjectContext:context];	
				NSFetchRequest *requestRef1 = [[NSFetchRequest alloc] init];
				[requestRef1 setEntity:entityMoralDesc];
				
				NSString *value1 = [row objectAtIndex:6];
				NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"nameMoral == %@", value1];
				[requestRef1 setPredicate:pred1];
				
				NSArray *objectsRef1 = [context executeFetchRequest:requestRef1 error:&outError];
				
				if ([objectsRef1 count] == 0) {
//					NSLog(@"No matches for a row");
				} else {
//					NSLog(@"moral:%@", [[objectsRef1 objectAtIndex:0] nameMoral]);
                    [newText setValue:[objectsRef1 objectAtIndex:0] forKey:@"moralChoiceB"];
					
				}
				
				[requestRef1 release];
				
			}
            
            //Determine if character lookup is necessary
			if (![[row objectAtIndex:10] isEqualToString:@""]) {

				//If parent found, find ReferenceText that needs parent relationship
				NSEntityDescription *entityCharacterDesc = [NSEntityDescription entityForName:@"Character" inManagedObjectContext:context];	
				NSFetchRequest *requestRef1 = [[NSFetchRequest alloc] init];
				[requestRef1 setEntity:entityCharacterDesc];
				
				NSString *value1 = [row objectAtIndex:10];
				NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"nameCharacter == %@", value1];
				[requestRef1 setPredicate:pred1];
				
				NSArray *objectsRef1 = [context executeFetchRequest:requestRef1 error:&outError];
				
				if ([objectsRef1 count] == 0) {
//					NSLog(@"No matches for ant");
				} else {
                    [newText setValue:[objectsRef1 objectAtIndex:0] forKey:@"antagonist"];
					
				}
				
				[requestRef1 release];
				
			}
            
			[context assignObject:newText toPersistentStore:readOnlyStore];
		
		}
		
		count++;
		if (count == LOOP_LIMIT) {
			[context save:&outError];
			if (outError != nil) {
//				NSLog(@"save:%@", outError);
				
			}
			[context reset];
			[pool drain];
			
			pool = [[NSAutoreleasePool alloc] init];
			count = 0;
		}
		 
	}

	// Save any remaining records
	if (count != 0) {
		[context save:&outError];
		[context reset];
	}
				
	if (outError != nil) {
//		NSLog(@"save:%@", outError);
		
	}
	
	[pool drain];
	
	[dateFormatter release];
	


}

/**
 Implemenation:  Ensure that peristent store was populated correctly by outputting entire store.
 */
- (void) verifyData:(NSString *) filename {
    
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSError *outError = nil;

	/*display results */
	/** @todo move to mainwindow.xib display */
    
	NSEntityDescription *entityAssetDesc = [NSEntityDescription entityForName:@"ConscienceAsset" inManagedObjectContext:context];
	NSEntityDescription *entityMoralDesc = [NSEntityDescription entityForName:@"Moral" inManagedObjectContext:context];
	NSEntityDescription *entityBeliefDesc = [NSEntityDescription entityForName:@"ReferenceBelief" inManagedObjectContext:context];
	NSEntityDescription *entityFigureDesc = [NSEntityDescription entityForName:@"ReferencePerson" inManagedObjectContext:context];
	NSEntityDescription *entityTextDesc = [NSEntityDescription entityForName:@"ReferenceText" inManagedObjectContext:context];
	NSEntityDescription *entityCharacterDesc = [NSEntityDescription entityForName:@"Character" inManagedObjectContext:context];
	NSEntityDescription *entityDilemmaDesc = [NSEntityDescription entityForName:@"Dilemma" inManagedObjectContext:context];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	if ([filename isEqualToString:@"tbl-assets"]) {
        
		[request setEntity:entityAssetDesc];
		
	}else if ([filename isEqualToString:@"tbl-morals"]) {
        
		[request setEntity:entityMoralDesc];
        
	}else if ([filename isEqualToString:@"tbl-figures"]) {
		
		[request setEntity:entityFigureDesc];
	}else if ([filename isEqualToString:@"tbl-beliefs"]) {
		
		[request setEntity:entityBeliefDesc];
		
	}else if ([filename isEqualToString:@"tbl-texts"]) {
		
		[request setEntity:entityTextDesc];
		
	}else if ([filename isEqualToString:@"tbl-texts-ref"]) {
		
		[request setEntity:entityTextDesc];
		
	}else if ([filename isEqualToString:@"tbl-characters"]) {
		
		[request setEntity:entityCharacterDesc];
		
	}else if ([filename isEqualToString:@"tbl-dilemmas"]) {
		
		[request setEntity:entityDilemmaDesc];
		
	}
    
	NSArray *objects = [context executeFetchRequest:request error:&outError];
	
	if ([objects count] == 0) {
		NSLog(@"No matches");
	} else {
        
        
		if ([filename isEqualToString:@"tbl-assets"]) {
			
			for (ConscienceAsset *matches in objects){
				[[appDelegate insertResults] appendFormat:@"asset: %@, %@, %@, %@\n", [matches nameReference], [matches imageNameReference], [matches displayNameReference], [matches orientationAsset]];
                				
			}
			
		}
		
		if ([filename isEqualToString:@"tbl-morals"]) {
			
			for (Moral *matches in objects){
				[[appDelegate insertResults] appendFormat:@"moral: %@, %@, %@, %@\n", [matches nameMoral], [matches component], [matches shortDescriptionMoral], [matches longDescriptionMoral]];
				
			}			
		}
		
		if ([filename isEqualToString:@"tbl-figures"]) {
			
			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            
			for (ReferencePerson *matches in objects){
				[[appDelegate insertResults] appendFormat:@"figures: %@, %@, %@, %@, %@\n", [matches nameReference], [matches displayNameReference], [matches linkReference], [matches originYear], [matches deathYearPerson]];
                
			}			
			[dateFormatter release];
		}
		        
		if ([filename isEqualToString:@"tbl-beliefs"]) {
            
            
            for (ReferenceText *matches in objects){
				[[appDelegate insertResults] appendFormat:@"belief: %@, %@, %@, %@, %@\n", [matches nameReference], [matches displayNameReference], [matches linkReference], [matches originYear], [matches shortDescriptionReference]];

            }			
                        
		}
        
		if ([filename isEqualToString:@"tbl-texts"]) {
            
			for (ReferenceText *matches in objects){
				[[appDelegate insertResults] appendFormat:@"text: %@, %@, %@, %@, %@\n", [matches nameReference], [matches displayNameReference], [matches linkReference], [[matches parentReference] nameReference], [matches shortDescriptionReference]];
            }			
		}
		

		
        if ([filename isEqualToString:@"tbl-texts-ref"]) {
			
			for (ReferenceText *matches in objects){
                [[appDelegate insertResults] appendFormat:@"book: %@, parent:%@, author:%@", [matches nameReference], [[matches parentReference] nameReference], [[matches author] nameReference]];

				for (ReferenceText *children in [matches childrenReference]) {
					NSLog(@"child:%@", [children nameReference]);
				}
                
			}			
			
		}
        
        if ([filename isEqualToString:@"tbl-dilemmas"]) {
			
			for (Dilemma *matches in objects){
				[[appDelegate insertResults] appendFormat:@"dilemma: %@, %@\n", [matches nameDilemma], [matches choiceA]];

			}			
			
		}
        
        if ([filename isEqualToString:@"tbl-characters"]) {
			
			for (Character *matches in objects){
				[[appDelegate insertResults] appendFormat:@"character: %@\n", [matches nameCharacter]];
			}			
			
		}        
        
	}
    
	[request release];

}


- (void)dealloc {
	//[csvDataImport release];
    [super dealloc];
	
}

@end