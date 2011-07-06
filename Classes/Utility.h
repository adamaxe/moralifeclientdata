/**
Core Data generation.  Used once before production build for creating Core Data store from raw data files.
 
@class Utility
@see mlCoreDataAppDelegate

@author Copyright 2010 Team Axe, LLC. All rights reserved. http://www.teamaxe.org
@date 07/20/2010
@file
 */

#define ISO_TIMEZONE_UTC_FORMAT @"Z"
#define ISO_TIMEZONE_OFFSET_FORMAT @"%+02d%02d"

@class mlcoredataAppDelegate;

@interface Utility : NSObject {
	
	mlcoredataAppDelegate *appDelegate;		/**< delegate for application level callbacks */
	NSMutableArray * csvDataImport;		/**< array of retrieved values from flat file */
}

/**
Accepts a file name to parse and build an NSString to be further inspected
@param filename NSString which will be populated
 */
-(void) readCSVData:(NSString *) filename;
/**
Builds the default information in the RW persistent store.
 */
-(void) buildReadWriteCoreData;
/**
Accepts a file name determine which type of data is being populated to RO persistent store
@param filename NSString which will determine destination of data
 */
-(void) buildReadOnlyCoreData:(NSString *) filename;
/**
 Implemenation:  Spin throw entire RO store and display results
 @param filename NSString which determines requested data
 */
- (void) verifyData:(NSString *) filename;


@end
