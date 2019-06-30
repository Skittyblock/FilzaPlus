// ICTextView.h

@interface ICTextView : UITextView <NSTextStorageDelegate>
@property (nonatomic, retain) NSDictionary *highlightDefinition;
@property (nonatomic, retain) NSDictionary *highlightTheme;
+ (NSDictionary *)defaultHighlightDefinition;
+ (NSDictionary *)defaultHighlightTheme;
- (void)setupHighlighting;
- (void)highlightText;
@end
