/**
NSString CSV Parsing Category.  Used for parsing csv to load Coredata by adding csvRows method to NSString.
 
@class NSString+ParsingExtensions.h

@author Copyright 2010 Team Axe, LLC. All rights reserved. http://www.teamaxe.org
@date 07/20/2010
 */

@interface NSString (ParsingExtensions)

/**
Separate each CSV by delimiter and then CRLF
@return IBAction NSMutableArray of each row from CVS
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSMutableArray *csvRows;

@end

