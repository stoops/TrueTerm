//
//  AppDelegate.h
//  SimpleShell
//
//  Created by jon on 2026-05-30.
//

#import <Cocoa/Cocoa.h>

#import "ViewController.h"
#import "AppDelegate.h"

#import "SettingsController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>

@property (strong) NSNumber *wide;
@property (strong) NSNumber *high;

@property (strong) NSWindow *wind;
@property (strong) NSArray<NSWindow *> *winl;
@property (strong) ViewController *vcon;

@property (strong) NSMutableArray<MainProc *> *proc;

@property (strong) SettingsController *settingsController;

- (int)loop;

- (void)openPreferencesWindow:(id)sender;

@end
