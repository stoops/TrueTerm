//
//  MainProc.h
//  SimpleShell
//
//  Created by jon on 2026-06-05.
//

#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>

#import "MainProc.h"

#import "vterm.h"

@interface MainProc : NSObject

@property (strong) NSNumber *vidx;
@property (strong) NSNumber *indx;
@property (strong) NSNumber *trys;

@property (strong) NSNumber *pidn;
@property (strong) NSNumber *mfdn;
@property (strong) NSNumber *sfdn;

@property (strong) NSNumber *rows;
@property (strong) NSNumber *cols;

@property (strong) NSNumber *mode;
@property (strong) NSNumber *skip;
@property (strong) NSNumber *flag;

@property (strong) NSNumber *crow;
@property (strong) NSNumber *ccol;
@property (strong) NSNumber *irow;
@property (strong) NSNumber *icol;

@property (strong) NSMutableData *ansi;
@property (strong) NSMutableData *ansp;
@property (strong) NSMutableData *info;

@property (strong) NSMutableArray<NSString *> *hist;

@property (strong) NSWindow *wino;
@property (strong) ViewController *tcon;
@property (strong) ViewController *vcon;

@property VTerm *term;
@property VTermScreen *vtsc;

- (int)outp:(NSTimer *)objc;
- (int)inpt:(NSEvent *)objc indx:(int)indx;
- (void)winz:(NSString *)text wide:(CGFloat)wide high:(CGFloat)high;
- (void)initProc:(ViewController *)vcon indx:(int)indx wide:(CGFloat)wide high:(CGFloat)high wino:(NSWindow *)wino;

@end
