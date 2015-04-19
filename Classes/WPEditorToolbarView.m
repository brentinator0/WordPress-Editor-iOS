#import "WPEditorToolbarView.h"
#import "WPDeviceIdentification.h"
#import "WPEditorToolbarButton.h"
#import "ZSSBarButtonItem.h"

static int kDefaultToolbarItemPadding = 10;
static int kDefaultToolbarLeftPadding = 10;

static int kNegativeToolbarItemPadding = 12;
static int kNegativeSixToolbarItemPadding = 6;
static int kNegativeSixPlusToolbarItemPadding = 2;
static int kNegativeLeftToolbarLeftPadding = 3;
static int kNegativeSixPlusRightToolbarPadding = 24;

static const CGFloat WPEditorToolbarHeight = 40;
static const CGFloat WPEditorToolbarButtonHeight = 40;
static const CGFloat WPEditorToolbarButtonWidth = 25;
static const CGFloat WPIpadEditorToolbarButtonWidth = 80;
static const CGFloat WPEditorToolbarDividerLineHeight = 28;
static const CGFloat WPEditorToolbarDividerLineWidth = 0.6f;

@interface WPEditorToolbarView ()

#pragma mark - Properties: Toolbar
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UIView *topBorderView;
@property (nonatomic, weak) UIToolbar *leftToolbar;
@property (nonatomic, weak) UIToolbar *rightToolbar;
@property (nonatomic, weak) UIView *rightToolbarHolder;
@property (nonatomic, weak) UIView *rightToolbarDivider;
@property (nonatomic, weak) UIScrollView *toolbarScroll;

#pragma mark - Properties: Toolbar items
@property (nonatomic, strong, readwrite) UIBarButtonItem* htmlBarButtonItem;
@property (nonatomic, strong, readwrite) UIBarButtonItem* leftAngleBarButtonItem;
@property (nonatomic, strong, readwrite) UIBarButtonItem* rightAngleBarButtonItem;
@property (nonatomic, strong, readwrite) UIBarButtonItem* leftCurlyBraceBarButtonItem;
@property (nonatomic, strong, readwrite) UIBarButtonItem* rightCurlyBraceBarButtonItem;
@property (nonatomic, strong, readwrite) UIBarButtonItem* semiColonButtonItem;
@property (nonatomic, strong, readwrite) UIBarButtonItem* colonButtonItem;
@property (nonatomic, strong, readwrite) UIBarButtonItem* forwardSlashBarButtonItem;
@property (nonatomic, strong, readwrite) UIBarButtonItem* commaBarButtonItem;
@property (nonatomic, strong, readwrite) UIBarButtonItem* numberSignBarButtonItem;
@property (nonatomic, strong, readwrite) UIBarButtonItem* periodBarButtonItem;


/**
 *  Toolbar items to include
 */
@property (nonatomic, assign, readwrite) ZSSRichTextEditorToolbar enabledToolbarItems;

@end

@implementation WPEditorToolbarView

/**
 *  @brief      Initializer for the view with a certain frame.
 *
 *  @param      frame       The frame for the view.
 *
 *  @return     The initialized object.
 */
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _enabledToolbarItems = [self defaultToolbarItems];
        [self buildToolbar];
    }
    
    return self;
}

#pragma mark - Toolbar building

- (void)buildToolbar
{
    [self buildMainToolbarHolder];
    [self buildToolbarScroll];
    [self buildLeftToolbar];
    
    [self.toolbarScroll addSubview:[self rightToolbarHolder]];
    
}

- (void)reloadItems
{
    if (IS_IPAD) {
        [self reloadiPadItems];
    } else {
        [self reloadiPhoneItems];
    }
}

- (void)reloadiPhoneItems
{
    NSMutableArray *items = [self.items mutableCopy];
    CGFloat toolbarItemsSeparation = 0.0f;
    
    if ([WPDeviceIdentification isiPhoneSixPlus]) {
        toolbarItemsSeparation = kNegativeSixPlusToolbarItemPadding;
    } else if ([WPDeviceIdentification isiPhoneSix]) {
        toolbarItemsSeparation = kNegativeSixToolbarItemPadding;
    } else {
        toolbarItemsSeparation = kNegativeToolbarItemPadding;
    }
    
    CGFloat toolbarWidth = 0.0f;
    NSUInteger numberOfItems = items.count;
    if (numberOfItems > 0) {
        CGFloat finalPaddingBetweenItems = kDefaultToolbarItemPadding - toolbarItemsSeparation;
        
        toolbarWidth += (numberOfItems * WPEditorToolbarButtonWidth);
        toolbarWidth += (numberOfItems * finalPaddingBetweenItems);
    }
    
    UIBarButtonItem *negativeSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                       target:nil
                                                                                       action:nil];
    negativeSeparator.width = -toolbarItemsSeparation;
    
    // This code adds a negative separator between all the toolbar buttons
    for (NSInteger i = [items count]; i >= 0; i--) {
        [items insertObject:negativeSeparator atIndex:i];
    }
    
    UIBarButtonItem *negativeSeparatorForToolbar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                                 target:nil
                                                                                                 action:nil];
    CGFloat finalToolbarLeftPadding = kDefaultToolbarLeftPadding - kNegativeLeftToolbarLeftPadding;
    
    negativeSeparatorForToolbar.width = -kNegativeLeftToolbarLeftPadding;
    toolbarWidth += finalToolbarLeftPadding;
    self.leftToolbar.items = items;
    self.leftToolbar.frame = CGRectMake(0, 0, toolbarWidth, WPEditorToolbarHeight);
    self.toolbarScroll.contentSize = CGSizeMake(CGRectGetWidth(self.leftToolbar.frame),
                                                WPEditorToolbarHeight);
}

- (void)reloadiPadItems
{
    NSMutableArray *items = [self.items mutableCopy];
    CGFloat toolbarWidth = CGRectGetWidth(self.toolbarScroll.frame);
    /*UIBarButtonItem *flexSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
     target:nil
     action:nil];
     UIBarButtonItem *buttonSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
     target:nil
     action:nil];*/
    self.leftToolbar.items = items;
    self.leftToolbar.frame = CGRectMake(0, 0, toolbarWidth, WPEditorToolbarHeight);
    self.toolbarScroll.contentSize = CGSizeMake(CGRectGetWidth(self.leftToolbar.frame),
                                                WPEditorToolbarHeight);
}

#pragma mark - Toolbar building helpers

- (void)buildLeftToolbar
{
    NSAssert(_leftToolbar == nil, @"This is supposed to be called only once.");
    
    UIToolbar* leftToolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    leftToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    leftToolbar.barTintColor = self.backgroundColor;
    leftToolbar.translucent = NO;
    
    // We had some issues with the left toolbar not resizing properly - and we didn't realize
    // immediately.  Clipping to bounds is a good way to realize sooner and not later.
    //
    leftToolbar.clipsToBounds = YES;
    
    [self.toolbarScroll addSubview:leftToolbar];
    self.leftToolbar = leftToolbar;
}

- (void)buildMainToolbarHolder
{
    CGRect subviewFrame = self.frame;
    subviewFrame.origin = CGPointZero;
    
    UIView* mainToolbarHolderContent = [[UIView alloc] initWithFrame:subviewFrame];
    mainToolbarHolderContent.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    subviewFrame.size.height = 1.0f;
    
    UIView* mainToolbarHolderTopBorder = [[UIView alloc] initWithFrame:subviewFrame];
    mainToolbarHolderTopBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    mainToolbarHolderTopBorder.backgroundColor = self.borderColor;
    
    [self addSubview:mainToolbarHolderContent];
    [self addSubview:mainToolbarHolderTopBorder];
    
    self.contentView = mainToolbarHolderContent;
    self.topBorderView = mainToolbarHolderTopBorder;
}

- (void)buildToolbarScroll
{
    NSAssert(_toolbarScroll == nil, @"This is supposed to be called only once.");
    
    CGFloat scrollviewHeight = CGRectGetWidth(self.frame);
    
    if (!IS_IPAD) {
        scrollviewHeight -= WPEditorToolbarButtonWidth;
    }
    
    CGRect toolbarScrollFrame = CGRectMake(0,
                                           0,
                                           scrollviewHeight,
                                           WPEditorToolbarHeight);
    
    UIScrollView* toolbarScroll = [[UIScrollView alloc] initWithFrame:toolbarScrollFrame];
    toolbarScroll.showsHorizontalScrollIndicator = NO;
    if (IS_IPAD) {
        toolbarScroll.scrollEnabled = NO;
    }
    toolbarScroll.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self.contentView addSubview:toolbarScroll];
    self.toolbarScroll = toolbarScroll;
}


#pragma mark - Toolbar size

+ (CGFloat)height
{
    return WPEditorToolbarHeight;
}

#pragma mark - Toolbar buttons

- (ZSSBarButtonItem*)barButtonItemWithTag:(WPEditorViewControllerElementTag)tag
                             htmlProperty:(NSString*)htmlProperty
                                imageName:(NSString*)imageName
                                   target:(id)target
                                 selector:(SEL)selector
                       accessibilityLabel:(NSString*)accessibilityLabel
{
    ZSSBarButtonItem *barButtonItem = [[ZSSBarButtonItem alloc] initWithImage:nil
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:nil
                                                                       action:nil];
    barButtonItem.tag = tag;
    barButtonItem.htmlProperty = htmlProperty;
    barButtonItem.accessibilityLabel = accessibilityLabel;
    
    UIImage* buttonImage = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    WPEditorToolbarButton* customButton = [[WPEditorToolbarButton alloc] initWithFrame:CGRectMake(0,
                                                                                                  0,
                                                                                                  WPEditorToolbarButtonWidth,
                                                                                                  WPEditorToolbarButtonHeight)];
    [customButton setImage:buttonImage forState:UIControlStateNormal];
    customButton.normalTintColor = self.itemTintColor;
    customButton.selectedTintColor = self.selectedItemTintColor;
    [customButton addTarget:target
                     action:selector
           forControlEvents:UIControlEventTouchUpInside];
    barButtonItem.customView = customButton;
    
    return barButtonItem;
}

#pragma mark - Toolbar items

- (BOOL)canShowToolbarOption:(ZSSRichTextEditorToolbar)toolbarOption
{
    return (self.enabledToolbarItems & toolbarOption
            || self.enabledToolbarItems & ZSSRichTextEditorToolbarAll);
}

- (ZSSRichTextEditorToolbar)defaultToolbarItems
{
    ZSSRichTextEditorToolbar defaultToolbarItems = (ZSSRichTextEditorToolbarBold
                                                    | ZSSRichTextEditorToolbarItalic);
    
    // iPad gets the HTML source button too
    if (IS_IPAD) {
        defaultToolbarItems = (defaultToolbarItems
                               | ZSSRichTextEditorToolbarStrikeThrough
                               | ZSSRichTextEditorToolbarViewSource);
    }
    
    return defaultToolbarItems;
}

- (void)enableToolbarItems:(BOOL)enable
    shouldShowSourceButton:(BOOL)showSource
{
    NSArray *items = self.leftToolbar.items;
    
    for (ZSSBarButtonItem *item in items) {
        if (item.tag == kWPEditorViewControllerElementShowSourceBarButton) {
            item.enabled = showSource;
        } else {
            item.enabled = enable;
            
            if (!enable) {
                [item setSelected:NO];
            }
        }
    }
}

- (void)clearSelectedToolbarItems
{
    for (ZSSBarButtonItem *item in self.leftToolbar.items) {
        if (item.tag != kWPEditorViewControllerElementShowSourceBarButton) {
            [item setSelected:NO];
        }
    }
}

- (BOOL)hasSomeEnabledToolbarItems
{
    return !(self.enabledToolbarItems & ZSSRichTextEditorToolbarNone);
}

- (void)selectToolbarItemsForStyles:(NSArray*)styles
{
    NSArray *items = self.leftToolbar.items;
    
    for (UIBarButtonItem *item in items) {
        // Since we're using UIBarItem as negative separators, we need to make sure we don't try to
        // use those here.
        //
        if ([item isKindOfClass:[ZSSBarButtonItem class]]) {
            ZSSBarButtonItem* zssItem = (ZSSBarButtonItem*)item;
            
            if ([styles containsObject:zssItem.htmlProperty]) {
                zssItem.selected = YES;
            } else {
                zssItem.selected = NO;
            }
        }
    }
}

#pragma mark - Getters

- (UIBarButtonItem*)htmlBarButtonItem
{
    if (!_htmlBarButtonItem) {
        UIBarButtonItem* htmlBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@"HTML"
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:nil
                                                                              action:nil];
        
        UIFont * font = [UIFont boldSystemFontOfSize:10];
        NSDictionary * attributes = @{NSFontAttributeName: font};
        [htmlBarButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
        //htmlBarButtonItem.accessibilityLabel = NSLocalizedString(@"Display HTML",
        //                                                         @"Accessibility label for display HTML button on formatting toolbar.");
        
        CGRect customButtonFrame = CGRectMake(0,
                                              0,
                                              WPEditorToolbarButtonWidth,
                                              WPEditorToolbarButtonHeight);
        
        WPEditorToolbarButton* customButton = [[WPEditorToolbarButton alloc] initWithFrame:customButtonFrame];
        [customButton setTitle:@"HTML" forState:UIControlStateNormal];
        customButton.normalTintColor = self.itemTintColor;
        customButton.selectedTintColor = self.selectedItemTintColor;
        customButton.reversesTitleShadowWhenHighlighted = YES;
        customButton.titleLabel.font = font;
        [customButton addTarget:self
                         action:@selector(showHTMLSource:)
               forControlEvents:UIControlEventTouchUpInside];
        
        htmlBarButtonItem.customView = customButton;
        
        _htmlBarButtonItem = htmlBarButtonItem;
    }
    
    return _htmlBarButtonItem;
}

- (UIBarButtonItem*)leftAngleBracketBarButtonItem
{
    if (!_leftAngleBarButtonItem) {
        UIBarButtonItem* leftAngleBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@"<"
                                                                                    style:UIBarButtonItemStylePlain
                                                                                   target:nil
                                                                                   action:nil];
        
        UIFont * font = [UIFont boldSystemFontOfSize:16];
        NSDictionary * attributes = @{NSFontAttributeName: font};
        [leftAngleBarButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
        
        CGRect customButtonFrame = CGRectMake(0,
                                              0,
                                              WPEditorToolbarButtonWidth,
                                              WPEditorToolbarButtonHeight);
        
        WPEditorToolbarButton* customButton = [[WPEditorToolbarButton alloc] initWithFrame:customButtonFrame];
        [customButton setTitle:@"<" forState:UIControlStateNormal];
        customButton.normalTintColor = self.itemTintColor;
        customButton.selectedTintColor = self.selectedItemTintColor;
        customButton.reversesTitleShadowWhenHighlighted = YES;
        customButton.titleLabel.font = font;
        [customButton addTarget:self
                         action:@selector(addLeftAngleBracket:)
               forControlEvents:UIControlEventTouchUpInside];
        
        leftAngleBarButtonItem.customView = [self createCustomButtonWithTitle:@"<" andSelector:@selector(addLeftAngleBracket:) andBarButtonItem:leftAngleBarButtonItem];
        
        _leftAngleBarButtonItem = leftAngleBarButtonItem;
    }
    
    return _leftAngleBarButtonItem;
}

- (UIBarButtonItem*)rightAngleBracketBarButtonItem
{
    if (!_rightAngleBarButtonItem) {
        UIBarButtonItem* rightAngleBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@">"
                                                                                     style:UIBarButtonItemStylePlain
                                                                                    target:nil
                                                                                    action:nil];
        
        rightAngleBarButtonItem.customView = [self createCustomButtonWithTitle:@">" andSelector:@selector(addRightAngleBracket:) andBarButtonItem:rightAngleBarButtonItem];
        
        
        _rightAngleBarButtonItem = rightAngleBarButtonItem;
    }
    
    return _rightAngleBarButtonItem;
}

- (UIBarButtonItem*)leftCurlyBraceBarButtonItem
{
    if (!_leftCurlyBraceBarButtonItem) {
        UIBarButtonItem* rightAngleBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@"{"
                                                                                     style:UIBarButtonItemStylePlain
                                                                                    target:nil
                                                                                    action:nil];
        
        rightAngleBarButtonItem.customView = [self createCustomButtonWithTitle:@"{" andSelector:@selector(addLeftCurlyBrace:) andBarButtonItem:rightAngleBarButtonItem];
        
        
        _leftCurlyBraceBarButtonItem = rightAngleBarButtonItem;
    }
    
    return _leftCurlyBraceBarButtonItem;
}

- (UIBarButtonItem*)rightCurlyBraceBarButtonItem
{
    if (!_rightCurlyBraceBarButtonItem) {
        UIBarButtonItem* rightAngleBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@"}"
                                                                                     style:UIBarButtonItemStylePlain
                                                                                    target:nil
                                                                                    action:nil];
        
        rightAngleBarButtonItem.customView = [self createCustomButtonWithTitle:@"}" andSelector:@selector(addRightCurlyBrace:) andBarButtonItem:rightAngleBarButtonItem];
        
        
        _rightCurlyBraceBarButtonItem = rightAngleBarButtonItem;
    }
    
    return _rightCurlyBraceBarButtonItem;
}

- (UIBarButtonItem*)semiColonBarButtonItem
{
    if (!_semiColonButtonItem) {
        UIBarButtonItem* rightAngleBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@";"
                                                                                     style:UIBarButtonItemStylePlain
                                                                                    target:nil
                                                                                    action:nil];
        
        rightAngleBarButtonItem.customView = [self createCustomButtonWithTitle:@";" andSelector:@selector(addSemiColon:) andBarButtonItem:rightAngleBarButtonItem];
        
        _semiColonButtonItem = rightAngleBarButtonItem;
    }
    
    return _semiColonButtonItem;
}

- (UIBarButtonItem*)colonBarButtonItem
{
    if (!_colonButtonItem) {
        UIBarButtonItem* rightAngleBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@":"
                                                                                     style:UIBarButtonItemStylePlain
                                                                                    target:nil
                                                                                    action:nil];
        
        rightAngleBarButtonItem.customView = [self createCustomButtonWithTitle:@":" andSelector:@selector(addColon:) andBarButtonItem:rightAngleBarButtonItem];
        
        _colonButtonItem = rightAngleBarButtonItem;
    }
    
    return _colonButtonItem;
}

- (UIBarButtonItem*)forwardSlashBarButtonItem
{
    if (!_forwardSlashBarButtonItem) {
        UIBarButtonItem* rightAngleBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@"/"
                                                                                     style:UIBarButtonItemStylePlain
                                                                                    target:nil
                                                                                    action:nil];
        
        rightAngleBarButtonItem.customView = [self createCustomButtonWithTitle:@"/" andSelector:@selector(addForwardSlash:) andBarButtonItem:rightAngleBarButtonItem];
        
        _forwardSlashBarButtonItem = rightAngleBarButtonItem;
    }
    
    return _forwardSlashBarButtonItem;
}

- (UIBarButtonItem*)commaBarButtonItem
{
    if (!_commaBarButtonItem) {
        UIBarButtonItem* rightAngleBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@","
                                                                                     style:UIBarButtonItemStylePlain
                                                                                    target:nil
                                                                                    action:nil];
        
        rightAngleBarButtonItem.customView = [self createCustomButtonWithTitle:@"," andSelector:@selector(addComma:) andBarButtonItem:rightAngleBarButtonItem];
        
        _commaBarButtonItem = rightAngleBarButtonItem;
    }
    
    return _commaBarButtonItem;
}

- (UIBarButtonItem*)numberSignBarButtonItem
{
    if (!_commaBarButtonItem) {
        UIBarButtonItem* rightAngleBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@"#"
                                                                                     style:UIBarButtonItemStylePlain
                                                                                    target:nil
                                                                                    action:nil];
        
        rightAngleBarButtonItem.customView = [self createCustomButtonWithTitle:@"#" andSelector:@selector(addNumberSign:) andBarButtonItem:rightAngleBarButtonItem];
        
        _numberSignBarButtonItem = rightAngleBarButtonItem;
    }
    
    return _numberSignBarButtonItem;
}

- (UIBarButtonItem*)periodBarButtonItem
{
    if (!_periodBarButtonItem) {
        UIBarButtonItem* rightAngleBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@"."
                                                                                     style:UIBarButtonItemStylePlain
                                                                                    target:nil
                                                                                    action:nil];
        
        rightAngleBarButtonItem.customView = [self createCustomButtonWithTitle:@"." andSelector:@selector(addPeriod:) andBarButtonItem:rightAngleBarButtonItem];
        
        _periodBarButtonItem = rightAngleBarButtonItem;
    }
    
    return _periodBarButtonItem;
}

- (WPEditorToolbarButton* )createCustomButtonWithTitle:(NSString *) title
                                           andSelector:(SEL)selector
                                      andBarButtonItem: (UIBarButtonItem *) barButtonItem
{
    UIFont * font = [UIFont boldSystemFontOfSize:16];
    NSDictionary * attributes = @{NSFontAttributeName: font};
    [barButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    CGRect customButtonFrame;
    
    if (IS_IPAD) {
        customButtonFrame = CGRectMake(0,0,WPIpadEditorToolbarButtonWidth,WPEditorToolbarButtonHeight);
        
    }else{
        customButtonFrame = CGRectMake(0,0,WPEditorToolbarButtonWidth,WPEditorToolbarButtonHeight);
    }
    
    WPEditorToolbarButton* customButton = [[WPEditorToolbarButton alloc] initWithFrame:customButtonFrame];
    [customButton setTitle:title forState:UIControlStateNormal];
    customButton.normalTintColor = self.itemTintColor;
    customButton.selectedTintColor = self.selectedItemTintColor;
    customButton.reversesTitleShadowWhenHighlighted = YES;
    customButton.titleLabel.font = font;
    [customButton addTarget:self
                     action:selector
           forControlEvents:UIControlEventTouchUpInside];
    
    return customButton;
}

- (UIView*)rightToolbarHolder
{
    UIView* rightToolbarHolder = _rightToolbarHolder;
    
    if (!rightToolbarHolder) {
        
        UIView* rightToolbarDivider = _rightToolbarDivider;
        if (!rightToolbarDivider) {
            CGRect dividerLineFrame = CGRectMake(0.0f,
                                                 floorf((WPEditorToolbarHeight - WPEditorToolbarDividerLineHeight) / 2),
                                                 WPEditorToolbarDividerLineWidth,
                                                 WPEditorToolbarDividerLineHeight);
            rightToolbarDivider = [[UIView alloc] initWithFrame:dividerLineFrame];
            rightToolbarDivider.backgroundColor = self.borderColor;
            rightToolbarDivider.alpha = 0.7f;
            _rightToolbarDivider = rightToolbarDivider;
        }
        
        //        CGRect rightSpacerFrame = CGRectMake(CGRectGetMaxX(self.rightToolbarDivider.frame),
        //                                             0.0f,
        //                                             kNegativeRightToolbarPadding / 2,
        //                                             WPEditorToolbarHeight);
        //        UIView *rightSpacer = [[UIView alloc] initWithFrame:rightSpacerFrame];
        
        CGRect screenBound = [[UIScreen mainScreen] bounds];
        CGSize screenSize = screenBound.size;
        CGFloat screenWidth = screenSize.width;
        
        CGRect rightToolbarHolderFrame = CGRectMake(0,
                                                    0.0f,
                                                    screenWidth ,
                                                    WPEditorToolbarHeight);
        rightToolbarHolder = [[UIView alloc] initWithFrame:rightToolbarHolderFrame];
        rightToolbarHolder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        rightToolbarHolder.clipsToBounds = YES;
        
        CGRect toolbarFrame = CGRectMake(CGRectGetMaxX(self.rightToolbarDivider.frame),
                                         0.0f,
                                         CGRectGetWidth(rightToolbarHolder.frame),
                                         CGRectGetHeight(rightToolbarHolder.frame));
        
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:toolbarFrame];
        self.rightToolbar = toolbar;
        
        //[rightToolbarHolder addSubview:rightSpacer];
        [rightToolbarHolder addSubview:self.rightToolbarDivider];
        [rightToolbarHolder addSubview:toolbar];
        
        UIBarButtonItem *negativeSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                           target:nil
                                                                                           action:nil];
        // Negative separator needs to be different on 6+
        if ([WPDeviceIdentification isiPhoneSixPlus]) {
            negativeSeparator.width = -kNegativeSixPlusRightToolbarPadding;
        } else {
            negativeSeparator.width = 40;
        }
        
        //toolbar.items = @[negativeSeparator, [self htmlBarButtonItem]];
        toolbar.items = @[[self leftAngleBracketBarButtonItem],[self rightAngleBracketBarButtonItem],[self leftCurlyBraceBarButtonItem],[self rightCurlyBraceBarButtonItem], [self semiColonBarButtonItem], [self colonBarButtonItem], [self forwardSlashBarButtonItem], [self numberSignBarButtonItem]];
        toolbar.barTintColor = self.backgroundColor;
    }
    [self.toolbarScroll addSubview:rightToolbarHolder];
    return rightToolbarHolder;
}

#pragma mark - Setters

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    if (self.backgroundColor != backgroundColor) {
        super.backgroundColor = backgroundColor;
        
        self.leftToolbar.barTintColor = backgroundColor;
        self.rightToolbar.barTintColor = backgroundColor;
    }
}

- (void)setBorderColor:(UIColor *)borderColor
{
    if (_borderColor != borderColor) {
        _borderColor = borderColor;
        
        self.topBorderView.backgroundColor = borderColor;
        self.rightToolbarDivider.backgroundColor = borderColor;
    }
}

- (void)setItems:(NSArray*)items
{
    if (_items != items) {
        _items = [items copy];
        
        [self reloadItems];
    }
}

- (void)setItemTintColor:(UIColor *)itemTintColor
{
    _itemTintColor = itemTintColor;
    
    for (UIBarButtonItem *item in self.leftToolbar.items) {
        item.tintColor = _itemTintColor;
    }
    
    if (self.htmlBarButtonItem) {
        WPEditorToolbarButton* htmlButton = (WPEditorToolbarButton*)self.htmlBarButtonItem.customView;
        NSAssert([htmlButton isKindOfClass:[WPEditorToolbarButton class]],
                 @"Expected to have an HTML button of class WPEditorToolbarButton here.");
        
        htmlButton.normalTintColor = itemTintColor;
        self.htmlBarButtonItem.tintColor = itemTintColor;
    }
    
    if (self.leftAngleBarButtonItem) {
        WPEditorToolbarButton* htmlButton = (WPEditorToolbarButton*)self.leftAngleBarButtonItem.customView;
        NSAssert([htmlButton isKindOfClass:[WPEditorToolbarButton class]],
                 @"Expected to have an < button of class WPEditorToolbarButton here.");
        
        htmlButton.normalTintColor = itemTintColor;
        self.leftAngleBarButtonItem.tintColor = itemTintColor;
    }
    
    if (self.rightAngleBarButtonItem) {
        WPEditorToolbarButton* htmlButton = (WPEditorToolbarButton*)self.rightAngleBarButtonItem.customView;
        NSAssert([htmlButton isKindOfClass:[WPEditorToolbarButton class]],
                 @"Expected to have an > button of class WPEditorToolbarButton here.");
        
        htmlButton.normalTintColor = itemTintColor;
        self.rightAngleBarButtonItem.tintColor = itemTintColor;
    }
    
    if (self.leftCurlyBraceBarButtonItem) {
        WPEditorToolbarButton* toolBarButton = (WPEditorToolbarButton*)self.leftCurlyBraceBarButtonItem.customView;
        NSAssert([toolBarButton isKindOfClass:[WPEditorToolbarButton class]],
                 @"Expected to have an { button of class WPEditorToolbarButton here.");
        
        toolBarButton.normalTintColor = itemTintColor;
        self.leftCurlyBraceBarButtonItem.tintColor = itemTintColor;
    }
    
    if (self.rightCurlyBraceBarButtonItem) {
        WPEditorToolbarButton* toolBarButton = (WPEditorToolbarButton*)self.rightCurlyBraceBarButtonItem.customView;
        NSAssert([toolBarButton isKindOfClass:[WPEditorToolbarButton class]],
                 @"Expected to have an } button of class WPEditorToolbarButton here.");
        
        toolBarButton.normalTintColor = itemTintColor;
        self.rightCurlyBraceBarButtonItem.tintColor = itemTintColor;
    }
    
    if (self.semiColonButtonItem) {
        WPEditorToolbarButton* toolBarButton = (WPEditorToolbarButton*)self.semiColonButtonItem.customView;
        NSAssert([toolBarButton isKindOfClass:[WPEditorToolbarButton class]],
                 @"Expected to have an ; button of class WPEditorToolbarButton here.");
        
        toolBarButton.normalTintColor = itemTintColor;
        self.semiColonButtonItem.tintColor = itemTintColor;
    }
    
    if (self.colonButtonItem) {
        WPEditorToolbarButton* toolBarButton = (WPEditorToolbarButton*)self.colonButtonItem.customView;
        NSAssert([toolBarButton isKindOfClass:[WPEditorToolbarButton class]],
                 @"Expected to have an ; button of class WPEditorToolbarButton here.");
        
        toolBarButton.normalTintColor = itemTintColor;
        self.colonButtonItem.tintColor = itemTintColor;
    }
    
    if (self.forwardSlashBarButtonItem) {
        WPEditorToolbarButton* toolBarButton = (WPEditorToolbarButton*)self.forwardSlashBarButtonItem.customView;
        NSAssert([toolBarButton isKindOfClass:[WPEditorToolbarButton class]],
                 @"Expected to have an forward slash button of class WPEditorToolbarButton here.");
        
        toolBarButton.normalTintColor = itemTintColor;
        self.forwardSlashBarButtonItem.tintColor = itemTintColor;
    }
    
    if (self.commaBarButtonItem) {
        WPEditorToolbarButton* toolBarButton = (WPEditorToolbarButton*)self.commaBarButtonItem.customView;
        NSAssert([toolBarButton isKindOfClass:[WPEditorToolbarButton class]],
                 @"Expected to have a , button of class WPEditorToolbarButton here.");
        
        toolBarButton.normalTintColor = itemTintColor;
        self.commaBarButtonItem.tintColor = itemTintColor;
    }
    
    if (self.numberSignBarButtonItem) {
        WPEditorToolbarButton* toolBarButton = (WPEditorToolbarButton*)self.numberSignBarButtonItem.customView;
        NSAssert([toolBarButton isKindOfClass:[WPEditorToolbarButton class]],
                 @"Expected to have a # button of class WPEditorToolbarButton here.");
        
        toolBarButton.normalTintColor = itemTintColor;
        self.numberSignBarButtonItem.tintColor = itemTintColor;
    }
    
    if (self.periodBarButtonItem) {
        WPEditorToolbarButton* toolBarButton = (WPEditorToolbarButton*)self.periodBarButtonItem.customView;
        NSAssert([toolBarButton isKindOfClass:[WPEditorToolbarButton class]],
                 @"Expected to have a . button of class WPEditorToolbarButton here.");
        
        toolBarButton.normalTintColor = itemTintColor;
        self.periodBarButtonItem.tintColor = itemTintColor;
    }
}

- (void)setSelectedItemTintColor:(UIColor *)selectedItemTintColor
{
    _selectedItemTintColor = selectedItemTintColor;
    
    if (self.htmlBarButtonItem) {
        WPEditorToolbarButton* htmlButton = (WPEditorToolbarButton*)self.htmlBarButtonItem.customView;
        NSAssert([htmlButton isKindOfClass:[WPEditorToolbarButton class]],
                 @"Expected to have an HTML button of class WPEditorToolbarButton here.");
        
        htmlButton.selectedTintColor = selectedItemTintColor;
    }
    
    if (self.leftAngleBarButtonItem) {
        WPEditorToolbarButton* htmlButton = (WPEditorToolbarButton*)self.leftAngleBarButtonItem.customView;
        NSAssert([htmlButton isKindOfClass:[WPEditorToolbarButton class]],
                 @"Expected to have an HTML button of class WPEditorToolbarButton here.");
        
        htmlButton.selectedTintColor = selectedItemTintColor;
    }
    
    if (self.rightAngleBarButtonItem) {
        WPEditorToolbarButton* htmlButton = (WPEditorToolbarButton*)self.rightAngleBarButtonItem.customView;
        NSAssert([htmlButton isKindOfClass:[WPEditorToolbarButton class]],
                 @"Expected to have an HTML button of class WPEditorToolbarButton here.");
        
        htmlButton.selectedTintColor = selectedItemTintColor;
    }
    
    if (self.leftCurlyBraceBarButtonItem) {
        WPEditorToolbarButton* htmlButton = (WPEditorToolbarButton*)self.leftCurlyBraceBarButtonItem.customView;
        NSAssert([htmlButton isKindOfClass:[WPEditorToolbarButton class]],
                 @"Expected to have an HTML button of class WPEditorToolbarButton here.");
        
        htmlButton.selectedTintColor = selectedItemTintColor;
    }
    
    if (self.rightCurlyBraceBarButtonItem) {
        WPEditorToolbarButton* toolBarButton = (WPEditorToolbarButton*)self.rightCurlyBraceBarButtonItem.customView;
        NSAssert([toolBarButton isKindOfClass:[WPEditorToolbarButton class]],
                 @"Expected to have an HTML button of class WPEditorToolbarButton here.");
        
        toolBarButton.selectedTintColor = selectedItemTintColor;
    }
    
    if (self.semiColonButtonItem) {
        WPEditorToolbarButton* toolBarButton = (WPEditorToolbarButton*)self.semiColonButtonItem.customView;
        NSAssert([toolBarButton isKindOfClass:[WPEditorToolbarButton class]],
                 @"Expected to have an HTML button of class WPEditorToolbarButton here.");
        
        toolBarButton.selectedTintColor = selectedItemTintColor;
    }
    
    if (self.colonButtonItem) {
        WPEditorToolbarButton* toolBarButton = (WPEditorToolbarButton*)self.colonButtonItem.customView;
        NSAssert([toolBarButton isKindOfClass:[WPEditorToolbarButton class]],
                 @"Expected to have an HTML button of class WPEditorToolbarButton here.");
        
        toolBarButton.selectedTintColor = selectedItemTintColor;
    }
    
    if (self.forwardSlashBarButtonItem) {
        WPEditorToolbarButton* toolBarButton = (WPEditorToolbarButton*)self.forwardSlashBarButtonItem.customView;
        NSAssert([toolBarButton isKindOfClass:[WPEditorToolbarButton class]],
                 @"Expected to have an HTML button of class WPEditorToolbarButton here.");
        
        toolBarButton.selectedTintColor = selectedItemTintColor;
    }
    
    if (self.commaBarButtonItem) {
        WPEditorToolbarButton* toolBarButton = (WPEditorToolbarButton*)self.commaBarButtonItem.customView;
        NSAssert([toolBarButton isKindOfClass:[WPEditorToolbarButton class]],
                 @"Expected to have an HTML button of class WPEditorToolbarButton here.");
        
        toolBarButton.selectedTintColor = selectedItemTintColor;
    }
    
    if (self.numberSignBarButtonItem) {
        WPEditorToolbarButton* toolBarButton = (WPEditorToolbarButton*)self.numberSignBarButtonItem.customView;
        NSAssert([toolBarButton isKindOfClass:[WPEditorToolbarButton class]],
                 @"Expected to have an HTML button of class WPEditorToolbarButton here.");
        
        toolBarButton.selectedTintColor = selectedItemTintColor;
    }
    
    if (self.periodBarButtonItem) {
        WPEditorToolbarButton* toolBarButton = (WPEditorToolbarButton*)self.periodBarButtonItem.customView;
        NSAssert([toolBarButton isKindOfClass:[WPEditorToolbarButton class]],
                 @"Expected to have an HTML button of class WPEditorToolbarButton here.");
        
        toolBarButton.selectedTintColor = selectedItemTintColor;
    }
}

#pragma mark - Temporary: added to make the refactor easier, but should be removed at some point

- (void)addPeriod:(UIBarButtonItem *)barButtonItem
{
    
    [self.delegate editorToolbarView:self addPeriod:barButtonItem];
}

- (void)addNumberSign:(UIBarButtonItem *)barButtonItem
{
    
    [self.delegate editorToolbarView:self addNumberSign:barButtonItem];
}

- (void)addComma:(UIBarButtonItem *)barButtonItem
{
    
    [self.delegate editorToolbarView:self addComma:barButtonItem];
}

- (void)addForwardSlash:(UIBarButtonItem *)barButtonItem
{
    
    [self.delegate editorToolbarView:self addForwardSlash:barButtonItem];
}

- (void)addColon:(UIBarButtonItem *)barButtonItem
{
    
    [self.delegate editorToolbarView:self addColon:barButtonItem];
}

- (void)addSemiColon:(UIBarButtonItem *)barButtonItem
{
    
    [self.delegate editorToolbarView:self addSemiColon:barButtonItem];
}

- (void)addRightCurlyBrace:(UIBarButtonItem *)barButtonItem
{
    
    [self.delegate editorToolbarView:self addRightCurlyBrace:barButtonItem];
}

- (void)addLeftCurlyBrace:(UIBarButtonItem *)barButtonItem
{
    
    [self.delegate editorToolbarView:self addLeftCurlyBrace:barButtonItem];
}

- (void)addLeftAngleBracket:(UIBarButtonItem *)barButtonItem
{
    
    [self.delegate editorToolbarView:self addLeftAngleBracket:barButtonItem];
}
- (void)addRightAngleBracket:(UIBarButtonItem *)barButtonItem
{
    
    [self.delegate editorToolbarView:self addRightAngleBracket:barButtonItem];
}

- (void)showHTMLSource:(UIBarButtonItem *)barButtonItem
{
    [self.delegate editorToolbarView:self showHTMLSource:barButtonItem];
}

@end
