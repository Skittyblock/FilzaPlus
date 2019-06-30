#import "SyntaxSelectorViewController.h"
#import "Headers/ThemeManager.h"

%subclass SyntaxSelectorViewController : ThemeSelectorViewController
%property (nonatomic, retain) NSArray *themes;
%property (nonatomic, retain) NSArray *fonts;

- (id)init {
  self = %orig;
  if (self) {
  }
  return self;
}

- (void)viewWillAppear:(bool)animated {
  NSString *themePath = @"/Library/Application Support/FilzaPlus/Themes/";
  NSArray *themeFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:themePath error:NULL];
  NSMutableArray *themes = [[NSMutableArray alloc] init];

  [themeFiles enumerateObjectsUsingBlock:^(NSString *filename, NSUInteger idx, BOOL *stop) {
    NSString *extension = [[filename pathExtension] lowercaseString];
    if ([extension isEqualToString:@"plist"]) {
      [themes addObject:[filename stringByDeletingPathExtension]];
    }
  }];

  self.themes = [themes copy];

  NSString *fontPath = @"/Library/Application Support/FilzaPlus/Fonts/";
  NSArray *fontFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fontPath error:NULL];

  [fontFiles enumerateObjectsUsingBlock:^(NSString *filename, NSUInteger idx, BOOL *stop) {
    NSString *extension = [[filename pathExtension] lowercaseString];
    if ([extension isEqualToString:@"ttf"]) {
      CGDataProviderRef dataProvider = CGDataProviderCreateWithFilename([[NSString stringWithFormat:@"/Library/Application Support/FilzaPlus/Fonts/%@", filename] UTF8String]);
      CGFontRef font = CGFontCreateWithDataProvider(dataProvider);
      CGDataProviderRelease(dataProvider);
      CTFontManagerRegisterGraphicsFont(font, nil);
      CGFontRelease(font);
    }
  }];

  self.fonts = @[@"Default", @"Consolas", @"Source Code Pro", @"Menlo", @"Monaco"];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    return @"Theme";
  } else if (section == 1) {
    return @"Font";
  }
  return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
 return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0) {
   return self.themes.count;
  }
  return self.fonts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *MyIdentifier = @"MyIdentifier";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
  }
  cell.backgroundColor = [[NSClassFromString(@"ThemeManager") sharedInstance] background];
  cell.textLabel.textColor = [[NSClassFromString(@"ThemeManager") sharedInstance] text];

  if (indexPath.section == 0) {
    [cell.textLabel setText:self.themes[indexPath.row]];

    if ([[[%c(ThemeManager) sharedInstance] syntaxTheme] isEqual:[NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/Library/Application Support/FilzaPlus/Themes/%@.plist", self.themes[indexPath.row]]]]) {
      cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
      cell.accessoryType = UITableViewCellAccessoryNone;
    }
  } else {
    [cell.textLabel setText:self.fonts[indexPath.row]];

    if ([[[%c(ThemeManager) sharedInstance] syntaxFont] isEqual:self.fonts[indexPath.row]]) {
      cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
      cell.accessoryType = UITableViewCellAccessoryNone;
    }
  }

  if ([[%c(ThemeManager) sharedInstance] isBlackTheme]) {
    UIView *bg = [[UIView alloc] init];
    bg.backgroundColor = [[%c(ThemeManager) sharedInstance] selected];
    [cell setSelectedBackgroundView:bg];
  }

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/xyz.skitty.filzaplus.plist"]];

  if (indexPath.section == 0) {
    [prefs setValue:self.themes[indexPath.row] forKey:@"syntax-theme"];
      [prefs writeToFile:@"/var/mobile/Library/Preferences/xyz.skitty.filzaplus.plist" atomically:TRUE];
  } else {
    [prefs setValue:self.fonts[indexPath.row] forKey:@"syntax-font"];
    [prefs writeToFile:@"/var/mobile/Library/Preferences/xyz.skitty.filzaplus.plist" atomically:TRUE];
  }

  [[%c(ThemeManager) sharedInstance] refresh];
  [tableView reloadData];
}

%end
