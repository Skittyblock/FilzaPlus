// SSTextStorage.h

@class SSCodeString;

@interface SSTextStorage : NSTextStorage
@property (nonatomic, retain) SSCodeString *content;
@property (nonatomic, retain) UIFont *font;
@end
