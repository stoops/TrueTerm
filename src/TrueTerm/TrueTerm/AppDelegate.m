//
//  AppDelegate.m
//  TrueTerm
//
//  Created by jon on 2026-05-30.
//

#import "ViewController.h"
#import "MainProc.h"
#import "AppDelegate.h"

#import <Foundation/Foundation.h>
#import <util.h>

@implementation AppDelegate

- (int)loop {
    while (1) {
        if ((self.wide.floatValue > 1.0) && (self.high.floatValue > 1.0)) {
            if ((self.vcon != nil) && (self.proc.count < 1)) {
                for (int z = 0; z < 1; ++z) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        MainProc *proc = [[MainProc alloc] init];
                        NSLog(@"MAKE [%d][N] [%f][%f]", z, self.wide.floatValue, self.high.floatValue);
                        [proc initProc:self.vcon indx:z wide:self.wide.floatValue high:self.high.floatValue];
                        [self.proc addObject:proc];
                    });
                }
                return 1;
            }
        }
        usleep(357000);
    }
    return 0;
}

- (void)wins:(NSString *)text wide:(CGFloat)wide high:(CGFloat)high rsiz:(int)rsiz {
    if ((self.vcon != nil) && (self.winl != nil)) {
        if (self.winl.count > 0) {
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
                for (int z = 0; z < self.proc.count; ++z) {
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
        if (self.winl.count > 0) {
            NSWindow *wino = self.winl.firstObject;
            NSString *strf = [[NSUserDefaults standardUserDefaults] stringForKey:@"main"];
            [wino setMovable:YES];
            [wino setTitle:@"TrueTerm"];
            [wino setFrameAutosaveName:@"main"];
            [wino setMinSize:NSMakeSize(350.0, 150.0)];
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
    int indx = self.indx.intValue;
    unsigned long leng = [self.proc count];
    if ((leng > 0) && (indx < leng)) {
        MainProc *proc = [self.proc objectAtIndex:indx];
        [proc inpt:objc indx:1];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.indx = @0;
    self.wdrf = @0;
    self.wide = @0;
    self.high = @0;
    self.proc = [[NSMutableArray alloc] init];
    self.wind = [[NSApplication sharedApplication] mainWindow];
    self.winl = [NSApplication sharedApplication].windows;
    self.vcon = nil;

    NSLog(@"INIT");

    if (self.winl != nil) {
        if (self.winl.count > 0) {
            NSWindow *wino = self.winl.firstObject;
            if ([wino.contentViewController isKindOfClass:[ViewController class]]) {
                self.vcon = (ViewController *)wino.contentViewController;
            }
        }
    }

    NSImage *icon = [NSImage imageNamed:@"icon.png"];
    [NSApp setApplicationIconImage:icon];

    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:^NSEvent * _Nullable(NSEvent * _Nonnull event) {
        [self inpt:event];
        return event;
    }];

    [self iniw];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self loop];
    });
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
    self.wdrf = @(self.wdrf.intValue + 1);
    for (int z = 0; z < self.proc.count; ++z) {
        MainProc *proc = [self.proc objectAtIndex:z];
        [proc winf:self.wdrf.intValue];
    }
    [wino setFrame:frme display:YES];
    [self wins:@"rsiz" wide:frme.size.width high:frme.size.height rsiz:1];
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)fsiz {
    /*NSSize size;
    size.width = round(fsiz.width / 50.0) * 50.0;
    size.height = round(fsiz.height / 50.0) * 50.0;*/
    return fsiz;
}

@end
