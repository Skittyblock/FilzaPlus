// SSLayoutManager.m

#import "SSLayoutManager.h"
#import "SSTextStorage.h"

@implementation SSLayoutManager

- (id)init {
  self = [super init];
  if (self) {
    self.delegate = self;
    _lineHeight = 1;
  }
  return self;
}

- (void)setLineHeight:(CGFloat)lineHeight {
  _lineHeight = lineHeight;
  [self invalidateLayoutForCharacterRange:NSMakeRange(0, self.textStorage.length) actualCharacterRange:NULL];
}

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect {
  return (MAX(_lineHeight, 1) - 1) * rect.size.height;
}

- (void)drawBackgroundForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin {
  [super drawBackgroundForGlyphRange:glyphsToShow atPoint:origin];
}

@end
