// ThemeManager.h

@interface ThemeManager : NSObject
@property (nonatomic, retain) NSDictionary *syntaxLanguage;
@property (nonatomic, retain) NSDictionary *syntaxTheme;
@property (nonatomic, retain) NSDictionary *syntaxFont;
+ (id)sharedInstance;
- (id)text;
- (id)selected;
- (id)background;
- (double)fontSize;
- (bool)isBlackTheme;
- (void)refresh;
@end