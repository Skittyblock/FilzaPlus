// Tweak.h

#import "SSCodeString.h"
#import "SSLayoutManager.h"
#import "SSTextStorage.h"
#import "SyntaxSelectorViewController.h"
#import "Headers/ICTextView.h"
#import "Headers/ThemeManager.h"

// Functions
UIColor *colorFromHex(NSString *hexString) {
  if (hexString) {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
  }
  return [UIColor blueColor];
}

// Headers
@interface TGPreferencesTableViewController : UITableViewController
@end

@interface TGFastTextEditViewController : UIViewController
@property (nonatomic, retain) ICTextView *textEditor;
@property (nonatomic, retain) SSCodeString *codeString;
@property (nonatomic, retain) SSTextStorage *textStorage;
@end

@interface FileItem : NSObject
- (NSString *)filePath;
@end

@interface TGTextEditorController : UIViewController
- (FileItem *)fileItem;
@end

@interface NSTextStorage (FilzaPlus)
- (void)highlight;
@end

@interface UIView (FilzaPlus)
+ (void)crash;
@end
