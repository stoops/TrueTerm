//
//  AppDelegate.h
//  TrueTerm
//
//  Created by jon on 2026-05-30.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>

@property (strong) NSNumber *indx;

@property (strong) NSNumber *wide;
@property (strong) NSNumber *high;
@property (strong) NSNumber *wdrf;

@property (strong) NSWindow *wind;
@property (strong) NSArray<NSWindow *> *winl;
@property (strong) ViewController *vcon;

@property (strong) NSMutableArray<MainProc *> *proc;

- (int)loop;

@end
