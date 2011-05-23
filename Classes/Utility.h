/**
Core Data generation.  Used once before production build for creating Core Data store.
 
@class Utility
@see MoraLifeAppDelegate

@author Copyright 2010 Team Axe, LLC. All rights reserved. http://www.teamaxe.org
@date 07/20/2010
@file
 */

#define ISO_TIMEZONE_UTC_FORMAT @"Z"
#define ISO_TIMEZONE_OFFSET_FORMAT @"%+02d%02d"

@class mlcoredataAppDelegate;

@interface Utility : NSObject {
	
	mlcoredataAppDelegate *appDelegate;
	NSMutableArray * csvDataImport;
	
}

//+ (NSObject*)classVariable;
-(void) readCSVData:(NSString *) filename;
-(void) buildReadWriteCoreData;
-(void) buildReadOnlyCoreData:(NSString *) filename;

@end
