// SSCodeString.h

typedef enum : NSUInteger {
  SSCodeTypeKeyword,
  SSCodeTypeClass,
  SSCodeTypePragma,
  SSCodeTypeNumber,
  SSCodeTypeURL,
  SSCodeTypeAttribute,
  SSCodeTypeString,
  SSCodeTypeComment,
  SSCodeTypeText
} SSCodeType;

@interface SSCodeString : NSMutableString
- (void)enumerateCodeInRange:(NSRange)range usingBlock:(void (^)(NSRange range, SSCodeType type))block;
@end
