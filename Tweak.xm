// FilzaPlus, by Skitty
// Helpful Filza Tweaks

#import "Tweak.h"

static NSDictionary *settings;
static NSString *syntaxTheme;
static NSString *syntaxFont;

// Preference Updates
static void refreshPrefs() {
  settings = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/xyz.skitty.filzaplus.plist"];
  syntaxTheme = [settings objectForKey:@"syntax-theme"] ?: @"Dusk";
  syntaxFont = [settings objectForKey:@"syntax-font"] ?: @"Default";
}

// Custom Preferences
%hook TGPreferencesTableViewController
- (void)viewWillAppear:(bool)arg1 {
  // There's some weird array check in here that causes the app to crash
  // Overriding it might have undesirable side effects, but I haven't found any yet
  refreshPrefs();
  [self.tableView reloadData];
}
- (NSUInteger)tableView:(id)tableView numberOfRowsInSection:(NSUInteger)section {
  if (section == 4) {
    return %orig + 1;
  }
  return %orig;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 4 && indexPath.row == 1) {
    static NSString *MyIdentifier = @"CELL1";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    [cell.textLabel setText:@"Syntax"];
    [cell.detailTextLabel setText:syntaxTheme];
    return cell;
  }
  return %orig;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 4 && indexPath.row == 1) {
    SyntaxSelectorViewController *vc = [[%c(SyntaxSelectorViewController) alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:vc animated:YES];
  } else {
    %orig;
  }
}
%end

%hook TGFastTextEditViewController
%property (nonatomic, retain) SSCodeString *codeString;
%property (nonatomic, retain) SSTextStorage *textStorage;
// Detect Language
- (void)viewWillAppear:(bool)arg1 {
  %orig;
  NSString *path = @"/Library/Application Support/FilzaPlus/Languages/";
  NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];

  bool __block matched = NO;

  [files enumerateObjectsUsingBlock:^(NSString *filename, NSUInteger idx, BOOL *stop) {
    NSString *extension = [[filename pathExtension] lowercaseString];
    if ([extension isEqualToString:@"plist"]) {
      for (NSString *ex in [NSDictionary dictionaryWithContentsOfFile:[path stringByAppendingString:filename]][@"extensions"]) {
        NSString *fileEx = [[[[((TGTextEditorController *)[self.view.superview.superview.superview nextResponder]) fileItem] filePath] pathExtension] lowercaseString];
        if ([ex isEqual:fileEx]) {
          matched = YES;
          ((ThemeManager*)[%c(ThemeManager) sharedInstance]).syntaxLanguage = [NSDictionary dictionaryWithContentsOfFile:[path stringByAppendingString:filename]][@"components"];
        }
      }
    }
  }];

  if (!matched) {
    ((ThemeManager*)[%c(ThemeManager) sharedInstance]).syntaxLanguage = nil;
  }
}
- (void)setTextEditor:(ICTextView *)editor {
  // What does SS stand for, you ask?
  // Skitty Syntax of course!
  self.codeString = [SSCodeString new];
  self.codeString.string = @"Placeholder";

  self.textStorage = [SSTextStorage new];
  self.textStorage.content = self.codeString;
  // Fonts are still hardcoded. I might change that later.
  if ([syntaxFont isEqual:@"Consolas"]) {
    self.textStorage.font = [UIFont fontWithName:@"Consolas" size:[((ThemeManager *)[%c(ThemeManager) sharedInstance]) fontSize]];
  } else if ([syntaxFont isEqual:@"Source Code Pro"]) {
    self.textStorage.font = [UIFont fontWithName:@"SourceCodePro-Regular" size:[((ThemeManager *)[%c(ThemeManager) sharedInstance]) fontSize]];
  } else if ([syntaxFont isEqual:@"Menlo"]) {
    self.textStorage.font = [UIFont fontWithName:@"Menlo" size:[((ThemeManager *)[%c(ThemeManager) sharedInstance]) fontSize]];
  } else if ([syntaxFont isEqual:@"Monaco"]) {
    self.textStorage.font = [UIFont fontWithName:@"Monaco" size:[((ThemeManager *)[%c(ThemeManager) sharedInstance]) fontSize]];
  } else {
    self.textStorage.font = [UIFont systemFontOfSize:[((ThemeManager *)[%c(ThemeManager) sharedInstance]) fontSize]];
  }

  SSLayoutManager *layoutManager = [SSLayoutManager new];
  layoutManager.lineHeight = 1.1;
  [self.textStorage addLayoutManager: layoutManager];

  NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
  [layoutManager addTextContainer:textContainer];

  ICTextView *textView = [[%c(ICTextView) alloc] initWithFrame:CGRectInset(self.view.bounds, 10, 20) textContainer:textContainer];
  textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  textView.translatesAutoresizingMaskIntoConstraints = YES;
  textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
  textView.spellCheckingType = UITextSpellCheckingTypeNo;
  textView.autocorrectionType = UITextAutocorrectionTypeNo;
  %orig(textView);
}
- (void)viewDidLayoutSubviews {
  %orig;
  self.textEditor.backgroundColor = [[%c(ThemeManager) sharedInstance] background];
  self.textEditor.textColor = [[%c(ThemeManager) sharedInstance] text];
}
// Update File Modified Date
// Most important feature imo
- (void)saveClicked:(id)arg1 {
  %orig;

  NSError *error;
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *filePath = [[((TGTextEditorController *)[self.view.superview.superview.superview nextResponder]) fileItem] filePath];

  if (![fileManager setAttributes:@{NSFileModificationDate:[NSDate date]} ofItemAtPath:filePath error:&error]) {
    NSLog(@"[FILZAPLUS] \"Error:\" %@", error);
  }
}
%end

// Better Dark Mode
%hook UISearchBar
- (int)barStyle {
  if ([[%c(ThemeManager) sharedInstance] isBlackTheme]) {
    return 1;
  }
  return %orig;
}
%end

%hook UIKBRenderConfig
- (void)setLightKeyboard:(BOOL)light {
  if ([[%c(ThemeManager) sharedInstance] isBlackTheme]) {
    %orig(NO);
  } else {
    %orig;
  }
}
%end

// ThemeManager Additions
%hook ThemeManager
%property (nonatomic, retain) NSDictionary *syntaxLanguage;
%new
- (NSDictionary *)syntaxTheme {
  return [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/Library/Application Support/FilzaPlus/Themes/%@.plist", syntaxTheme]];
}
%new
- (NSString *)syntaxFont {
  return syntaxFont;
}
%new
- (void)refresh {
  refreshPrefs();
}
%end

%ctor {
  refreshPrefs();
}
