//
//  ViewController.h
//  TrueTerm
//
//  Created by jon on 2026-05-30.
//

#import <Cocoa/Cocoa.h>

#import "ViewController.h"

@interface ViewController : NSViewController <NSTextViewDelegate, NSTableViewDelegate, NSTableViewDataSource>

@property (strong) IBOutlet NSNumber *wide;
@property (strong) IBOutlet NSNumber *high;
@property (strong) IBOutlet NSNumber *fntw;
@property (strong) IBOutlet NSNumber *fnth;
@property (strong) IBOutlet NSNumber *rows;
@property (strong) IBOutlet NSNumber *cols;

@property (strong) IBOutlet NSNumber *scrl;
@property (strong) IBOutlet NSNumber *last;
@property (strong) IBOutlet NSNumber *indx;

@property (strong) IBOutlet NSColor *bgcr;
@property (strong) IBOutlet NSColor *tabc;
@property (strong) IBOutlet NSFont *font;
@property (strong) IBOutlet NSColor *colr;
@property (strong) IBOutlet NSDictionary *attr;

@property (strong) IBOutlet NSTextView *xxxx;

@property (strong) IBOutlet NSMutableArray<NSNumber *> *crsa;
@property (strong) IBOutlet NSMutableArray<NSNumber *> *crsb;
@property (strong) IBOutlet NSMutableArray<NSNumber *> *crsc;

@property (strong) IBOutlet NSMutableArray<NSButton *> *tabs;
@property (strong) IBOutlet NSMutableArray<NSTextView *> *outp;
@property (strong) IBOutlet NSMutableArray<NSTextField *> *crso;
@property (strong) IBOutlet NSMutableArray<NSScrollView *> *scro;
@property (strong) IBOutlet NSMutableArray<NSTextView *> *inpt;
@property (strong) IBOutlet NSMutableArray<NSTextField *> *crsi;
@property (strong) IBOutlet NSMutableArray<NSScrollView *> *scri;
@property (strong) IBOutlet NSMutableArray<NSAttributedString *> *atrs;
@property (strong) IBOutlet NSMutableArray<NSLayoutConstraint *> *cons;

@property (strong) IBOutlet NSView *diva;
@property (strong) IBOutlet NSView *divb;
@property (strong) IBOutlet NSStackView *tabv;
@property (strong) IBOutlet NSStackView *allv;
@property (strong) IBOutlet NSLayoutConstraint *cono;
@property (strong) IBOutlet NSLayoutConstraint *coni;
@property (strong) IBOutlet NSNotification *noto;
@property (strong) IBOutlet NSNotification *noti;
@property (strong) IBOutlet NSView *vobj;

- (CGFloat)tell:(char)kind indx:(int)indx;
- (int)sets:(NSString *)text wide:(CGFloat)wide high:(CGFloat)high;
- (int)newt:(NSString *)text wide:(CGFloat)wide high:(CGFloat)high;
- (int)tabt:(NSString *)text indx:(int)indx;
- (int)show:(NSString *)text indx:(int)indx sels:(int)sels cidx:(int)cidx rows:(int)rows cols:(int)cols;

@end
