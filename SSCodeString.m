// SSCodeString.m
// NSString UIColor SSTest

#import "SSCodeString.h"
#import "Headers/ICTextView.h"
#import "Headers/ThemeManager.h"

@implementation SSCodeString {
  NSMutableString *_string;
}

- (id)init {
  self = [super init];
  if (self) {
    _string = [NSMutableString new];
  }
  return self;
}

- (NSUInteger)length {
  return _string.length;
}

- (unichar)characterAtIndex:(NSUInteger)index {
  return [_string characterAtIndex: index];
}

- (void)getCharacters:(unichar *)buffer range:(NSRange)aRange {
  [_string getCharacters:buffer range:aRange];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)aString {
  [_string replaceCharactersInRange:range withString:aString];
}

- (void)enumerateCodeInRange:(NSRange)range usingBlock:(void (^)(NSRange range, SSCodeType type))block {

  block(range, SSCodeTypeText);

  for (NSString *key in [[NSClassFromString(@"ThemeManager") sharedInstance] syntaxLanguage]) {
    NSDictionary *dict = [[NSClassFromString(@"ThemeManager") sharedInstance] syntaxLanguage][key];

    if (dict) {
      NSRegularExpressionOptions options = 0;
      // Untested
      if (dict[@"options"]) {
        options = [dict[@"options"] intValue];
      }
      NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:dict[@"regex"] options:0 error:nil];
      NSArray* matches = [regex matchesInString:self options:0 range:range];
      for (NSTextCheckingResult *match in matches) {
        NSRange finalRange = match.range;
        if (dict[@"group"]) {
          finalRange = [match rangeAtIndex:[dict[@"group"] intValue]];
        }
        if ([key isEqual:@"keywords"]) {
          block(finalRange, SSCodeTypeKeyword);
        } else if ([key isEqual:@"classes"]) {
          block(finalRange, SSCodeTypeClass);
        } else if ([key isEqual:@"preprocessors"]) {
          block(finalRange, SSCodeTypePragma);
        } else if ([key isEqual:@"numbers"]) {
          block(finalRange, SSCodeTypeNumber);
        } else if ([key isEqual:@"urls"]) {
          block(finalRange, SSCodeTypeURL);
        } else if ([key isEqual:@"attributes"]) {
          block(finalRange, SSCodeTypeAttribute);
        } else if ([key isEqual:@"strings"]) {
          block(finalRange, SSCodeTypeString);
        } else if ([key isEqual:@"comments"] || [key isEqual:@"documentation_markup"] || [key isEqual:@"documentation_markup_keywords"]) {
          block(finalRange, SSCodeTypeComment);
        }
      }
    }
  }
}

@end
