//
//  AppDelegate.m
//  SimpleShell
//
//  Created by jon on 2026-05-30.
//

#import <Foundation/Foundation.h>
#import <util.h>

#import "ViewController.h"
#import "MainProc.h"
#import "AppDelegate.h"

@implementation AppDelegate

- (void)menu {
    NSMenu *mainMenu = [NSApp mainMenu];
    if (!mainMenu) {
        mainMenu = [[NSMenu alloc] init];
        [NSApp setMainMenu:mainMenu];
    }
    NSMenuItem *appMenuItem = [mainMenu itemAtIndex:0];
    if (!appMenuItem) {
        appMenuItem = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
        [mainMenu addItem:appMenuItem];
    }
    NSMenu *appMenu = [appMenuItem submenu];
    if (!appMenu) {
        appMenu = [[NSMenu alloc] initWithTitle:@"SimpleShell"];
        [appMenuItem setSubmenu:appMenu];
    }
    BOOL hasPrefs = NO;
    for (NSMenuItem *item in appMenu.itemArray) {
        if (item.action == @selector(openPreferencesWindow:)) {
            hasPrefs = YES;
            break;
        }
    }
    if (!hasPrefs) {
        NSMenuItem *prefsItem = [[NSMenuItem alloc] initWithTitle:@"Settings" action:@selector(openPreferencesWindow:) keyEquivalent:@","];
        [prefsItem setKeyEquivalentModifierMask:NSEventModifierFlagCommand];
        [prefsItem setTarget:self];
        [appMenu insertItem:prefsItem atIndex:0];
    }
}

- (void)openPreferencesWindow:(id)sender {
    if (!self.settingsController) {
        self.settingsController = [[SettingsController alloc] init];
        if (self.vcon != nil) {
            self.settingsController.delegate = self.vcon;
        }
    }
    if (self.vcon != nil) {
        [self.settingsController updateColors:self.vcon.bgdc tab:self.vcon.tabc txt:self.vcon.txtc sel:self.vcon.selc csr:self.vcon.csrc];
    }
    [self.settingsController showWindow:sender];
    [NSApp activateIgnoringOtherApps:YES];
}

- (int)loop {
    while (1) {
        if ((self.wide.floatValue > 1.0) && (self.high.floatValue > 1.0)) {
            if (self.vcon != nil) {
                if (([self.proc count] < 1) || (self.vcon.flag.intValue == 1)) {
                    self.vcon.flag = @2;
                    for (int z = 0; z < 1; ++z) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSWindow *wino = [self.winl firstObject];
                            MainProc *proc = [[MainProc alloc] init];
                            NSLog(@"MAKE [%d][N] [%f][%f]", z, self.wide.floatValue, self.high.floatValue);
                            [proc initProc:self.vcon indx:z wide:self.wide.floatValue high:self.high.floatValue wino:wino];
                            [self.proc addObject:proc];
                        });
                        usleep(753000);
                    }
                   // return 0;
                }
                //return 0;
            }
        }
        usleep(357000);
    }
    return 0;
}

- (void)wins:(NSString *)text wide:(CGFloat)wide high:(CGFloat)high rsiz:(int)rsiz {
    if ((self.vcon != nil) && (self.winl != nil)) {
        if ([self.winl count] > 0) {
            NSWindow *wino = self.winl.firstObject;
            NSRect winf = [wino frame];
            NSRect scrn = [[wino screen] visibleFrame];
            CGFloat topz = ((scrn.size.height - high) + scrn.origin.y);
            CGFloat topy = ((scrn.size.height - winf.size.height) + scrn.origin.y);
            CGFloat offy = (topy - winf.origin.y);
            CGFloat adjx = winf.origin.x;
            CGFloat adjy = (topz - offy);
            self.wide = @(wide);
            self.high = @(high);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (rsiz != 1) {
                    [wino setFrame:NSMakeRect(adjx, adjy, wide, high) display:YES];
                }
                for (int z = 0; z < [self.proc count]; ++z) {
                    MainProc *proc = [self.proc objectAtIndex:z];
                    [proc winz:text wide:wide high:high];
                    NSLog(@"PROC [%d][U] [%d][%d]", z, proc.rows.intValue, proc.cols.intValue);
                }
            });
        }
    }
}

- (void)iniw {
    if (self.winl != nil) {
        if ([self.winl count] > 0) {
            NSWindow *wino = self.winl.firstObject;
            NSString *strf = [[NSUserDefaults standardUserDefaults] stringForKey:@"main"];
            [wino setMovable:YES];
            [wino setTitle:@"SimpleShell"];
            [wino setFrameAutosaveName:@"main"];
            [wino setMinSize:NSMakeSize(750.0, 350.0)];
            [wino setOpaque:NO];
            [wino setBackgroundColor:[NSColor clearColor]];
            [wino setDelegate:self];
            if (strf) {
                NSRect frme = NSRectFromString(strf);
                [wino setFrame:frme display:YES];
                [self wins:@"iniw" wide:frme.size.width high:frme.size.height rsiz:0];
                NSLog(@"RELO [%@]", strf);
            }
        }
    }
}

- (void)inpt:(NSEvent *)objc {
    if (self.vcon != nil) {
        int indx = (self.vcon.indx.intValue - 1);
        unsigned long leng = [self.proc count];
        if ((-1 < indx) && (indx < leng)) {
            MainProc *proc = [self.proc objectAtIndex:indx];
            [proc inpt:objc indx:1];
        }
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    ViewController *vcon;

    self.wide = @0;
    self.high = @0;
    self.proc = [[NSMutableArray alloc] init];
    self.wind = [[NSApplication sharedApplication] mainWindow];
    self.winl = [NSApplication sharedApplication].windows;
    self.vcon = nil;

    NSLog(@"INIT");

    if (self.winl != nil) {
        if ([self.winl count] > 0) {
            NSWindow *wino = self.winl.firstObject;
            if ([wino.contentViewController isKindOfClass:[ViewController class]]) {
                vcon = (ViewController *)wino.contentViewController;
                if (vcon != nil) {
                    if (!self.settingsController) {
                        self.settingsController = [[SettingsController alloc] init];
                        self.settingsController.delegate = vcon;
                    }
                    NSColor *defBgd = [NSColor colorWithRed:0.01 green:0.11 blue:0.19 alpha:0.91];
                    NSColor *defTab = [NSColor colorWithRed:0.01 green:0.55 blue:0.55 alpha:0.31];
                    NSColor *defTxt = [NSColor colorWithRed:0.99 green:0.79 blue:0.59 alpha:0.91];
                    NSColor *defSel = [NSColor colorWithRed:0.99 green:0.79 blue:0.59 alpha:0.35];
                    NSColor *defCsr = [NSColor colorWithRed:0.99 green:0.79 blue:0.59 alpha:0.35];
                    [self.settingsController loadColors:defBgd tab:defTab txt:defTxt sel:defSel csr:defCsr];
                }
                self.vcon = vcon;
            }
        }
    }

    NSImage *icon = [NSImage imageNamed:@"icon.png"];
    [NSApp setApplicationIconImage:icon];

    // todo dereg for settings window
    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:^NSEvent * _Nullable(NSEvent * _Nonnull event) {
        [self inpt:event];
        return event;
    }];

    [self iniw];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self loop];
    });

    [self menu];
}

- (void)restoreWindowWithIdentifier:(NSUserInterfaceItemIdentifier)identifier state:(NSCoder *)state completionHandler:(void (^)(NSWindow * _Nullable, NSError * _Nullable))completionHandler {
    NSLog(@"REWN");
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return NO;
}

- (void)windowWillClose:(NSNotification *)notification {
    NSWindow *wino = notification.object;
    NSString *strf = NSStringFromRect(wino.frame);
    [[NSUserDefaults standardUserDefaults] setObject:strf forKey:@"main"];
    NSLog(@"SAVE [%@]", strf);
}

- (void)windowDidResize:(NSNotification *)notification {
    NSWindow *wino = notification.object;
    NSRect frme = [wino frame];
    CGFloat wide = frme.size.width;
    CGFloat high = frme.size.height;
    if (self.wide.floatValue > 1.0) {
        wide = self.wide.floatValue;
    }
    if (self.high.floatValue > 1.0) {
        high = self.high.floatValue;
    }
    int flag = 0;
    NSEvent *evnt = [NSApp currentEvent];
    BOOL user = ((evnt != nil) && (evnt.type == NSEventTypeLeftMouseDragged));
    if (user) {
        wide = frme.size.width;
        high = frme.size.height;
        NSLog(@"WINR [%f][%f]", wide, high);
        flag = 1;
    }
    [wino setFrame:frme display:YES];
    [self wins:@"rsiz" wide:wide high:high rsiz:flag];
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)fsiz {
    /*NSSize size;
    size.width = round(fsiz.width / 50.0) * 50.0;
    size.height = round(fsiz.height / 50.0) * 50.0;*/
    return fsiz;
}

@end
