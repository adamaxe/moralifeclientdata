/**
Global Constants.  Centralized location of constants used in code.

@class Constants
@author Copyright 2010 Team Axe, LLC. All rights reserved. http://www.teamaxe.org
@date 06/27/2010
 */

/**
Filenames of resources to be rendered
*/
extern NSString* const kEyeColor;
extern NSString* const kBrowColor;
extern NSString* const kBubbleColor;
extern NSString* const kEyeFileNameResource;
extern NSString* const kMouthFileNameResource;
extern NSString* const kSymbolFileNameResource;
extern NSString* const kAccessoryFileNameResource;
extern NSString* const kPrimaryAccessoryFileNameResource;
extern NSString* const kSecondaryAccessoryFileNameResource;
extern NSString* const kTopAccessoryFileNameResource;
extern NSString* const kBottomAccessoryFileNameResource;
extern NSString* const kLuckImageNameGood;
extern NSString* const kLuckImageNameBad;
extern NSString* const kChoiceListSortDate;
extern NSString* const kChoiceListSortWeight;
extern NSString* const kChoiceListSortSeverity;
extern NSString* const kChoiceListSortName;
extern NSString* const kCollectableEthicals;
extern NSString* const kDefaultFontFamily;
extern NSString* const kFallbackFontFamily;
extern NSString* const kDefaultFontName;
extern NSString* const kFallbackFontName;

/**
File metadata descriptions
*/
extern NSString* const kConscienceFileType;
extern NSString* const kConscienceDefaultTextEncoding;
extern NSString* const kConscienceDefaultMimeType;
extern NSString* const kConscienceEyeHorizontalJS;

/**
Conscience feature sizes and orientation
*/
extern float const kConscienceEnthusiasm;
extern float const kConscienceMood;
extern float const kConscienceSize;
extern float const kConscienceLargeSizeX;
extern float const kConscienceLargeSizeY;
extern float const kConscienceLargestSize;
extern int const kBubbleType;
extern int const kThoughtIterations;
extern int const kConscienceAge;
extern int const kDirectionFacingLeft;
extern int const kDirectionFacingRight;
extern int const kEyeHeight;
extern int const kEyeWidth;
extern int const kMouthHeight;
extern int const kMouthWidth;
extern int const kSymbolHeight;
extern int const kSymbolWidth;
extern int const kSideAccessoryHeight;
extern int const kSideAccessoryWidth;
extern int const kTopBottomAccessoryHeight;
extern int const kTopBottomAccessoryWidth;
extern int const kEyeLeftIndex;
extern int const kEyeRightIndex;
extern int const kEyeBothIndex;
extern int const kEyeRandomIndex;
extern int const kEyeCloseIndex;
extern int const kEyeOpenIndex;
extern int const kConscienceLowerLeftX;
extern int const kConscienceLowerLeftY;
extern int const kConscienceCenterX;
extern int const kConscienceCenterY;
extern int const kConscienceHomeX;
extern int const kConscienceHomeY;
extern int const kConscienceActionX;
extern int const kConscienceActionY;
extern float const kBlinkInterval;
extern float const kThoughtInterval;
extern float const kTransientInterval;
extern float const kLookDirectionDuration;
extern int const kExpressionInterval;
extern float const kMovementInterval;
extern int const kChoiceTextFieldLength;
extern int const kLuckTextFieldLength;
extern int const kConscienceOffscreenBottomX;
extern int const kConscienceOffscreenBottomY;
extern int const kConscienceAntagonistX;
extern int const kConscienceAntagonistY;
extern int const kConscienceReferenceX;
extern int const kConscienceReferenceY;
extern int const kConscienceAntagonistWidth;
extern int const kConscienceAntagonistHeight;

/*
extern int const kEyeRightWebViewTag;	
extern int const kEyeLeftWebViewTag;
extern int const kMouthWebViewTag;	
extern int const kSymbolWebViewTag;	
*/

/**
Tag Numbers for webViews in order to reference them
*/
enum webViewTags{
	kEyeRightViewTag = 3000,
	kEyeLeftViewTag = 3001,
	kMouthWebViewTag = 3002,	
	kSymbolWebViewTag = 3003,
	kBubbleImageViewTag = 3004,
	kPrimaryAccessoryViewTag = 3005,
	kSecondaryAccessoryViewTag = 3006,
	kTopAccessoryViewTag = 3007,	
	kBottomAccessoryViewTag = 3008,
	kEyeLeftSleepImageViewTag = 3009,
	kEyeLeftBrowViewTag = 3010,
	kEyeRightBrowViewTag = 3011,
	kBubbleViewTag = 3012,
	kEyeLeftBagViewTag = 3013,
	kEyeRightBagViewTag = 3014,
	kSymbolViewTag = 3015,
	kMouthViewTag = 3016,
	kConscienceViewTag = 3017,
	kConscienceCustomizeViewTag = 3018,
	kAnimatedBubbleViewTag = 3019,
	kConscienceAntagonistViewTag = 3020,
	kConscienceProtagonistViewTag = 3021,
	kChoiceCancelButtonTag = 3022,
	kChoiceMoralButtonTag = 3023,
	kDeckCard1ButtonTag = 3024,
	kDeckCard2ButtonTag = 3025,
	kDeckCard3ButtonTag = 3026,
	kDeckCard4ButtonTag = 3027,
	kDeckCard5ButtonTag = 3028,
	kDeckCard6ButtonTag = 3029,
    kHomeVirtueButtonTag = 3030,
    kHomeViceButtonTag = 3031,
    kHomeRankButtonTag = 3032

};

/**
Possible positions of Extensions
typedef utilized to avoid having to use enum declaration
*/
typedef enum extensionPositionEnum{
	kExtensionsPositionLeft,
	kExtensionsPositionRight,
	kExtensionsPositionTop,
	kExtensionsPositionBottom
}extensionPositionEnum;

/**
Possible expression states of Lips
*/
typedef enum expressionLipsEnum{
	kExpressionLipsSadShock,
	kExpressionLipsSadOpenAlt1,
	kExpressionLipsSadOpen,
	kExpressionLipsSadAlt1,
	kExpressionLipsSad,
	kExpressionLipsSadSmirk,
	kExpressionLipsSadSilly,
	kExpressionLipsNormal,
	kExpressionLipsHappySmirk,
	kExpressionLipsHappy,
	kExpressionLipsHappyAlt1,
	kExpressionLipsHappySilly,
	kExpressionLipsHappyOpen,
	kExpressionLipsHappyOpenAlt1,
	kExpressionLipsHappyShock
}expressionLipsEnum;

/**
Possible expression states of Dimples
*/
typedef enum expressionDimplesEnum{
	kExpressionDimplesSad,
	kExpressionDimplesNormal,
	kExpressionDimplesHappy
}expressionDimplesEnum;

/**
Possible expression states of Teeth
*/
typedef enum expressionTeethEnum{
	kExpressionTeethSadOpenAlt1,
	kExpressionTeethSadOpen,
	kExpressionTeethHappyOpen,
	kExpressionTeethHappyOpenAlt1
}expressionTeethEnum;

/**
Possible expression states of Tongue
*/
typedef enum expressionTongueEnum{
	kExpressionTongueSadCenter,
	kExpressionTongueSadLeft,
	kExpressionTongueSadRight,
	kExpressionTongueHappyCenter,
	kExpressionTongueHappyLeft,
	kExpressionTongueHappyRight
}expressionTongueEnum;

/**
Possible expression states of Brow
*/
typedef enum expressionBrowEnum{
	kExpressionBrowAngry,
	kExpressionBrowNormal,
	kExpressionBrowConfused,
	kExpressionBrowExcited
}expressionBrowEnum;

/**
Possible expression states of Lashes
*/
typedef enum expressionLashesEnum{
	kExpressionLashesUp,
	kExpressionLashesDown
}expressionLashesEnum;

/**
Possible expression states of Lid
*/
typedef enum expressionLidEnum{
	kExpressionLidAngry,
	kExpressionLidSleepy,
	kExpressionLidNormal,
	kExpressionLidUnder
}expressionLidEnum;


/**
Possible look direction of Eye
*/
typedef enum expressionLookEnum{
	kExpressionLookCenter,
	kExpressionLookDown,
	kExpressionLookUp,
	kExpressionLookLeft,
	kExpressionLookRight,
	kExpressionLookCross,
	kExpressionLookCrazy
}expressionLookEnum;

/**
Possible expression states of Bags
*/
typedef enum expressionBagsEnum{
	kExpressionBagsNormal,
	kExpressionBagsOld,
	kExpressionBagsOlder,
	kExpressionBagsOldest
}expressionBagsEnum;

/**
 Possible referenceTypes
 */
typedef enum referenceTypeEnum{
	kReferenceTypeAccessories,
	kReferenceTypeBeliefs,
	kReferenceTypeBooks,
	kReferenceTypePeople,
	kReferenceTypePlaces,
	kReferenceTypeReports
}refereneTypeEnum;