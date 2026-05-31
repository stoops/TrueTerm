//
//  SettingsController.m
//  SimpleShell
//
//  Created by jon on 2026-09-12.
//

#import "SettingsController.h"

#import "ViewController.h"

@implementation SettingsController

- (instancetype)init {
    NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 360, 240)
                                                   styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable
                                                     backing:NSBackingStoreBuffered
                                                       defer:NO];
    [window setTitle:@"Preferences"];
    [window setMinSize:NSMakeSize(360, 240)];
    self = [super initWithWindow:window];
    if (self) {
        [self windowDidLoad];
        [window display];
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];

    NSWindow *win = self.window;
    NSView *contentView = win.contentView;

    [contentView setWantsLayer:YES];

    NSStackView *stackView = [[NSStackView alloc] init];
    stackView.orientation = NSUserInterfaceLayoutOrientationVertical;
    stackView.distribution = NSStackViewDistributionFill;
    stackView.alignment = NSLayoutAttributeCenterX;
    stackView.spacing = 12.0;
    stackView.edgeInsets = NSEdgeInsetsMake(20, 20, 20, 20);
    stackView.translatesAutoresizingMaskIntoConstraints = NO;

    [contentView addSubview:stackView];

    [NSLayoutConstraint activateConstraints:@[
        [stackView.topAnchor constraintEqualToAnchor:contentView.topAnchor],
        [stackView.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor],
        [stackView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor],
        [stackView.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor]
    ]];

    self.bgdColorWell = [self addRowToStack:stackView label:@"Background Color:" action:@selector(bgdChanged:)];
    self.tabColorWell = [self addRowToStack:stackView label:@"       Tab Color:" action:@selector(tabChanged:)];
    self.txtColorWell = [self addRowToStack:stackView label:@"      Text Color:" action:@selector(txtChanged:)];
    self.selColorWell = [self addRowToStack:stackView label:@" Highlight Color:" action:@selector(selChanged:)];
    self.csrColorWell = [self addRowToStack:stackView label:@"    Cursor Color:" action:@selector(csrChanged:)];

    [contentView layoutSubtreeIfNeeded];
    [win recalculateKeyViewLoop];
}

- (NSColorWell *)addRowToStack:(NSStackView *)stack label:(NSString *)title action:(SEL)selector {
    NSStackView *row = [[NSStackView alloc] init];
    row.orientation = NSUserInterfaceLayoutOrientationHorizontal;
    row.distribution = NSStackViewDistributionFill;
    row.spacing = 12.0;
    row.translatesAutoresizingMaskIntoConstraints = NO;

    NSTextField *label = [NSTextField labelWithString:title];
    [label setAlignment:NSTextAlignmentRight];
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];
    [label.widthAnchor constraintEqualToConstant:140].active = YES;

    NSColorWell *colorWell = [[NSColorWell alloc] init];
    colorWell.target = self;
    colorWell.action = selector;
    [colorWell setTranslatesAutoresizingMaskIntoConstraints:NO];

    [colorWell.widthAnchor constraintEqualToConstant:60].active = YES;
    [colorWell.heightAnchor constraintEqualToConstant:26].active = YES;

    [row addView:label inGravity:NSStackViewGravityLeading];
    [row addView:colorWell inGravity:NSStackViewGravityTrailing];

    [stack addView:row inGravity:NSStackViewGravityCenter];
    return colorWell;
}

- (void)saveColorPref:(NSColor *)color forKey:(NSString *)key {
    if (!color) return;
    NSError *error = nil;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:YES error:&error];
    if (!error && colorData) {
        [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:key];
    }
}

- (NSColor *)loadColorPref:(NSString *)key defaultColor:(NSColor *)defaultColor {
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (!colorData) return defaultColor;
    NSError *error = nil;
    NSColor *color = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:colorData error:&error];
    if (error || !color) return defaultColor;
    return color;
}

- (void)updateColors:(NSColor *)bgd tab:(NSColor *)tab txt:(NSColor *)txt sel:(NSColor *)sel csr:(NSColor *)csr {
    self.bgdColorWell.color = bgd;
    self.tabColorWell.color = tab;
    self.txtColorWell.color = txt;
    self.selColorWell.color = sel;
    self.csrColorWell.color = csr;
}

- (void)bgdChanged:(NSColorWell *)sender {
    if ([self.delegate respondsToSelector:@selector(didChangeBgdColor:)]) {
        [self.delegate didChangeBgdColor:sender.color];
    }
    [self saveColorPref:sender.color forKey:@"bgdc"];
}

- (void)tabChanged:(NSColorWell *)sender {
    if ([self.delegate respondsToSelector:@selector(didChangeTabColor:)]) {
        [self.delegate didChangeTabColor:sender.color];
    }
    [self saveColorPref:sender.color forKey:@"tabc"];
}

- (void)txtChanged:(NSColorWell *)sender {
    if ([self.delegate respondsToSelector:@selector(didChangeTxtColor:)]) {
        [self.delegate didChangeTxtColor:sender.color];
    }
    [self saveColorPref:sender.color forKey:@"txtc"];
}

- (void)selChanged:(NSColorWell *)sender {
    if ([self.delegate respondsToSelector:@selector(didChangeSelColor:)]) {
        [self.delegate didChangeSelColor:sender.color];
    }
    [self saveColorPref:sender.color forKey:@"selc"];
}

- (void)csrChanged:(NSColorWell *)sender {
    if ([self.delegate respondsToSelector:@selector(didChangeCsrColor:)]) {
        [self.delegate didChangeCsrColor:sender.color];
    }
    [self saveColorPref:sender.color forKey:@"csrc"];
}

- (void)loadColors:(NSColor *)bgd tab:(NSColor *)tab txt:(NSColor *)txt sel:(NSColor *)sel csr:(NSColor *)csr {
    if (self.delegate && [self.delegate isKindOfClass:[ViewController class]]) {
        ViewController *vcon = (ViewController *)self.delegate; // Now fully visible!
        vcon.bgdc = [self loadColorPref:@"bgdc" defaultColor:bgd];
        vcon.tabc = [self loadColorPref:@"tabc" defaultColor:tab];
        vcon.txtc = [self loadColorPref:@"txtc" defaultColor:txt];
        vcon.selc = [self loadColorPref:@"selc" defaultColor:sel];
        vcon.csrc = [self loadColorPref:@"csrc" defaultColor:csr];
        [vcon refc];
    }
}

@end
