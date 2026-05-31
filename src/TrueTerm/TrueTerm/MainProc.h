//
//  MainProc.h
//  TrueTerm
//
//  Created by jon on 2026-06-05.
//

#import "ViewController.h"

#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>

//NS_ASSUME_NONNULL_BEGIN

@interface MainProc : NSObject

@property (strong) NSNumber *indx;
@property (strong) NSNumber *trys;

@property (strong) NSNumber *pidn;
@property (strong) NSNumber *mfdn;
@property (strong) NSNumber *sfdn;

@property (strong) NSNumber *rows;
@property (strong) NSNumber *cols;
@property (strong) NSNumber *wdrf;

@property (strong) NSNumber *mode;
@property (strong) NSNumber *bend;
@property (strong) NSNumber *bins;
@property (strong) NSNumber *last;
@property (strong) NSNumber *less;
@property (strong) NSNumber *endf;

@property (strong) NSNumber *crow;
@property (strong) NSNumber *ccol;
@property (strong) NSNumber *escs;

@property (strong) NSMutableData *escd;
@property (strong) NSMutableData *esci;
@property (strong) NSMutableData *ansi;
@property (strong) NSMutableData *ansp;
@property (strong) NSMutableArray<NSString *> *hist;
@property (strong) NSMutableArray<NSNumber *> *rets;

@property (strong) NSNumber *vidx;
@property (strong) ViewController *tcon;
@property (strong) ViewController *vcon;

- (int)outp:(NSTimer *)objc;
- (int)inpt:(NSEvent *)objc indx:(int)indx;
- (void)winf:(int)wdrf;
- (void)winz:(NSString *)text wide:(CGFloat)wide high:(CGFloat)high;
- (void)initProc:(ViewController *)vcon indx:(int)indx wide:(CGFloat)wide high:(CGFloat)high;

@end

#define ANSI_RETZ (0 <<  0)
#define ANSI_RETA (1 <<  0)
#define ANSI_RETB (1 <<  1)
#define ANSI_RETC (1 <<  2)
#define ANSI_RETD (1 <<  3)
#define ANSI_RETE (1 <<  4)
#define ANSI_DATA (1 <<  5)
#define ANSI_EEND (1 <<  6)
#define ANSI_BEND (1 <<  7)
#define ANSI_BINS (1 <<  8)
#define ANSI_BAUP (1 <<  9)

//NS_ASSUME_NONNULL_END
