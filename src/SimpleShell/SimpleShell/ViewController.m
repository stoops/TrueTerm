//
//  ViewController.m
//  SimpleShell
//
//  Created by jon on 2026-05-30.
//

#import "ViewController.h"
#import "MainProc.h"
#import "AppDelegate.h"

@interface CursorText : NSTextView
@property (nonatomic, assign) CGFloat   wide;
@property (nonatomic, assign) CGFloat   high;
@property (nonatomic, strong) NSColor  *colh;
@property (nonatomic, assign) NSRange   rang;
@property (nonatomic, assign) NSInteger indx;
@property (nonatomic,   copy) NSString *sels;
@property (nonatomic, assign) BOOL      lock;
@property (nonatomic, strong) NSTimer  *time;
@end

@implementation CursorText

- (instancetype)initWithFrame:(NSRect)frameRect textContainer:(NSTextContainer *)container {
    self = [super initWithFrame:frameRect textContainer:container];
    if (self) {
        _lock = YES;
        _time = nil;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _lock = YES;
        _time = nil;
    }
    return self;
}

- (void)setLock {
    self.lock = NO;
    if (self.time) {
        [self.time invalidate];
    }
    __weak typeof(self) wslf = self;
    self.time = [NSTimer scheduledTimerWithTimeInterval:3.0 repeats:NO block:^(NSTimer * _Nonnull timer) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(wslf) sslf = wslf;
            if (sslf) {
                sslf.lock = YES;
                [sslf setNeedsDisplay:YES];
            }
        });
    }];
}

- (void)setNeedsDisplayInRect:(NSRect)invalidRect avoidAdditionalLayout:(BOOL)flag {
    if (invalidRect.size.width <= 3.1337) { if (self.lock == YES) { return; } }
    [super setNeedsDisplayInRect:self.bounds avoidAdditionalLayout:flag];
}

- (void)drawInsertionPointInRect:(NSRect)rect color:(NSColor *)color turnedOn:(BOOL)flag {
    if (self.wide > 0) { rect.size.width = self.wide; }
    if (self.high > 0) { rect.size.height = self.high; }
    [color set];
    NSRectFill(rect);
    [super drawInsertionPointInRect:rect color:color turnedOn:YES];
}

- (void)mouseDown:(NSEvent *)event {
    NSPoint nspt = [self convertPoint:[event locationInWindow] fromView:nil];
    CGFloat frac = 0.0;
    NSUInteger indx = [self.layoutManager characterIndexForPoint:nspt inTextContainer:self.textContainer fractionOfDistanceBetweenInsertionPoints:&frac];
    self.indx = indx;
    self.rang = NSMakeRange(indx, 0);
    NSLog(@"MODN [%ld][%@]", (long)self.indx, NSStringFromRange(self.rang));
}

- (void)mouseDragged:(NSEvent *)event {
    NSPoint nspt = [self convertPoint:[event locationInWindow] fromView:nil];
    CGFloat frac = 0.0;
    NSUInteger indx = [self.layoutManager characterIndexForPoint:nspt inTextContainer:self.textContainer fractionOfDistanceBetweenInsertionPoints:&frac];
    NSInteger bidx = MIN(self.indx, indx);
    NSInteger eidx = MAX(self.indx, indx);
    self.rang = NSMakeRange(bidx, eidx - bidx);
    NSLog(@"MOMO [%ld][%@]", (long)self.indx, NSStringFromRange(self.rang));
    [self applyHighlightToRange:self.rang];
}

- (void)mouseUp:(NSEvent *)event {
    NSLog(@"MOUP [%ld][%@]", (long)self.indx, NSStringFromRange(self.rang));
    [self processCustomSelection:self.rang];
}

- (void)applyHighlightToRange:(NSRange)range {
    if (range.length == 0) return;
    [self.textStorage beginEditing];
    [self.textStorage removeAttribute:NSBackgroundColorAttributeName range:NSMakeRange(0, self.textStorage.length)];
    [self.textStorage addAttribute:NSBackgroundColorAttributeName value:self.colh range:range];
    [self.textStorage endEditing];
}

- (void)processCustomSelection:(NSRange)range {
    self.sels = [self.string substringWithRange:range];
    NSLog(@"MOZZ [%@]", self.sels);
}

@end

@implementation ViewController

- (void)didChangeBgdColor:(NSColor *)color {
    self.bgdc = color;
    self.view.layer.backgroundColor = self.bgdc.CGColor;
}

- (void)didChangeTabColor:(NSColor *)color {
    self.tabc = color;
    self.diva.layer.backgroundColor = self.tabc.CGColor;
    self.divb.layer.backgroundColor = self.tabc.CGColor;
    for (NSButton *tabb in self.tabs) {
        tabb.layer.borderColor = self.tabc.CGColor;
        tabb.layer.backgroundColor = self.tabc.CGColor;
    }
}

- (void)didChangeTxtColor:(NSColor *)color {
    self.txtc = color;
    NSMutableParagraphStyle *wrap = [[NSMutableParagraphStyle alloc] init];
    wrap.lineBreakMode = NSLineBreakByCharWrapping;
    self.attr = @{
        NSFontAttributeName: self.font,
        NSForegroundColorAttributeName: self.txtc,
        NSParagraphStyleAttributeName: wrap,
    };
    for (NSTextView *tv in self.outp) {
        tv.textColor = self.txtc;
    }
    for (NSTextView *tv in self.inpt) {
        tv.textColor = self.txtc;
    }
}

- (void)didChangeSelColor:(NSColor *)color {
    self.selc = color;
    for (NSTextView *tv in self.inpt) {
        if ([tv isKindOfClass:[CursorText class]]) {
            CursorText *ct = (CursorText *)tv;
            ct.colh = self.selc;
            [ct setNeedsDisplay:YES];
        }
    }
}

- (void)didChangeCsrColor:(NSColor *)color {
    self.csrc = color;
    dispatch_async(dispatch_get_main_queue(), ^{
        for (NSTextView *tv in self.inpt) {
            if ([tv isKindOfClass:[CursorText class]]) {
                CursorText *ct = (CursorText *)tv;
                ct.insertionPointColor = self.csrc;
                if (ct.layoutManager) {
                    [ct.layoutManager invalidateDisplayForCharacterRange:NSMakeRange(0, ct.string.length)];
                }
                NSWindow *window = ct.window;
                if (window) {
                    [window makeKeyWindow];
                    [window makeFirstResponder:nil];
                    [window makeFirstResponder:ct];
                }
                //[ct setLock];
                [ct setNeedsDisplay:YES];
            }
        }
        if (self.view.window) {
            [self.view.window displayIfNeeded];
        }
    });
}

- (void)refc {
    [self didChangeBgdColor:self.bgdc];
    [self didChangeTabColor:self.tabc];
    [self didChangeTxtColor:self.txtc];
    [self didChangeSelColor:self.selc];
    [self didChangeCsrColor:self.csrc];
    [self.view setNeedsDisplay:YES];
}

- (unsigned long)gets {
    NSTimeInterval secs = [[NSDate date] timeIntervalSince1970];
    return (unsigned long)secs;
}

- (unsigned long long)getl {
    NSDate *date = [NSDate date];
    unsigned long long mill = (long long)([date timeIntervalSince1970] * 1000.0);
    return mill;
}

- (float)itof:(unsigned int)rgbv shif:(int)shif {
    int valu = ((rgbv >> shif) & 0xff);
    float retn = (float)valu;
    return (retn / 255.0);
}

- (CGFloat)tell:(char)kind indx:(int)indx {
    CGFloat chwi = [self.font advancementForGlyph:[self.font glyphWithName:@"x"]].width;
    CGFloat chhi = ((self.font.ascender + fabs(self.font.descender)) + self.font.leading);
    NSLog(@"FONT [%c] [%f][%f]", kind, chwi, chhi);
    if (kind == 'w') {
        return MAX( 4.0, chwi);
    } else {
        return MAX(12.0, chhi);
    }
}

- (int)sets:(NSString *)text wide:(CGFloat)wide high:(CGFloat)high {
    if (self.vobj != nil) {
        int iidx = (self.indx.intValue - 1);

        if ((-1 < iidx) && (iidx < [self.tabs count])) {
            NSView *view = self.view;
            NSView *diva = self.diva, *divb = self.divb;
            NSStackView *allv = self.allv;
            NSStackView *tabv = self.tabv;
            NSView *inpv = [self.inpv objectAtIndex:iidx];
            NSScrollView *oscr = [self.oscr objectAtIndex:iidx];
            NSScrollView *iscr = [self.iscr objectAtIndex:iidx];
            NSLayoutConstraint *coni = self.coni;

            tabv.distribution = NSStackViewDistributionFill;

            [NSLayoutConstraint activateConstraints:@[
                [allv.topAnchor constraintEqualToAnchor:view.topAnchor],
                [allv.bottomAnchor constraintEqualToAnchor:view.bottomAnchor],
                [allv.leadingAnchor constraintEqualToAnchor:view.leadingAnchor],
                [allv.trailingAnchor constraintEqualToAnchor:view.trailingAnchor],

                [tabv.heightAnchor constraintEqualToConstant:30.0],

                coni,

                [iscr.topAnchor constraintEqualToAnchor:inpv.topAnchor constant:0.0],
                [iscr.bottomAnchor constraintEqualToAnchor:inpv.bottomAnchor constant:0.0],
                [iscr.leadingAnchor constraintEqualToAnchor:inpv.leadingAnchor constant:0.0],
                [iscr.trailingAnchor constraintEqualToAnchor:inpv.trailingAnchor constant:0.0],

                [iscr.widthAnchor constraintEqualToAnchor:view.widthAnchor multiplier:0.98],
                [oscr.widthAnchor constraintEqualToAnchor:view.widthAnchor multiplier:0.98],

                [diva.heightAnchor constraintEqualToConstant:3.0],
                [diva.widthAnchor constraintEqualToAnchor:view.widthAnchor multiplier:0.99],
                [divb.heightAnchor constraintEqualToConstant:3.0],
                [divb.widthAnchor constraintEqualToAnchor:view.widthAnchor multiplier:0.99],
            ]];

            [[self.spcs objectAtIndex:0].widthAnchor constraintEqualToAnchor:[self.spcs objectAtIndex:1].widthAnchor].active = YES;

            NSInteger tabc = [self.tabs count];
            CGFloat padd = (3.0 * 11.0);
            CGFloat gaps = (tabc > 0) ? (tabc - 1) * tabv.spacing : 0.0;
            CGFloat mult = (wide * 0.91);
            CGFloat usea = ((mult - padd) - gaps);
            CGFloat asbw = (usea / MAX(1.0, (float)(tabc)));

            for (int x = 0; x < [self.tabs count]; ++x) {
                NSButton *tabb = [self.tabs objectAtIndex:x];
                if (x < [self.cons count]) {
                    NSLayoutConstraint *tabc = [self.cons objectAtIndex:x];
                    [NSLayoutConstraint deactivateConstraints:@[tabc]];
                }
                if ((x + 1) == self.indx.intValue) {
                    [tabb.layer setBorderColor:self.tabc.CGColor];
                    [tabb.layer setBackgroundColor:self.tabc.CGColor];
                    [tabb setNeedsDisplay:YES];
                } else {
                    NSColor *copy = [self.tabc colorWithAlphaComponent:0.05];
                    [tabb.layer setBorderColor:copy.CGColor];
                    [tabb.layer setBackgroundColor:copy.CGColor];
                    [tabb setNeedsDisplay:YES];
                }
            }
            [self.cons removeAllObjects];
            for (int x = 0; x < [self.tabs count]; ++x) {
                NSButton *tabb = [self.tabs objectAtIndex:x];
                NSLayoutConstraint *tabc = [tabb.widthAnchor constraintEqualToConstant:asbw];
                tabc.priority = NSLayoutPriorityRequired - 1;
                tabc.active = YES;
                //[tabb.heightAnchor constraintEqualToAnchor:tabv.heightAnchor constant:-6.0];
                [self.cons addObject:tabc];
            }

            [view layoutSubtreeIfNeeded];
        }
    }

    return 0;
}

- (void)remo:(NSTextStorage *)objc area:(NSRange)area {
    [objc removeAttribute:NSForegroundColorAttributeName range:area];
    [objc removeAttribute:NSFontAttributeName range:area];
}

- (void)textViewDidChangeSelection:(NSNotification *)notification {
    NSTextView *txtv = (NSTextView *)notification.object;
    NSArray<NSValue *> *rngl = [txtv selectedRanges];
    if ([rngl count] > 0) {
        NSRange selr = [rngl.firstObject rangeValue];
        NSString *txts = [txtv.string substringWithRange:selr];
        if ((txts != nil) && ([txts length] > 0)) {
            NSLog(@"SELS [%@]", txts);
        }
    }
}

- (void)scrollViewDidScroll:(NSNotification *)notification {
    NSClipView *cobj = (NSClipView *)[notification object];
    CGFloat maxd = cobj.documentView.frame.size.height;
    CGFloat maxv = cobj.bounds.size.height;
    int maxy = (int)(maxd - maxv);
    int ypos = (int)(cobj.bounds.origin.y);
    int ppos = (int)(self.scrp.intValue);
    int dpos = abs(maxy - ypos);
    //NSLog(@"SCRO [%d] [%d][%d] [%d] [%d]", maxy, ypos, ppos, dpos, self.scrl.intValue);
    unsigned long secs = [self gets];
    int diff = 15;
    if ((secs - self.last.intValue) > 1) {
        NSLog(@"SCRZ [%d] [%d][%d] [%d] [%d]", maxy, ypos, ppos, dpos, self.scrl.intValue);
        if ((self.scrl.intValue == 0) && (dpos > diff)) {
            self.scrl = @1;
            self.last = @(secs);
        }
        if ((self.scrl.intValue == 1) && (dpos < diff)) {
            self.scrl = @0;
            self.last = @(secs);
        }
    }
    self.scrp = @(ypos);
}

- (void)adji:(int)indx {
    if (self.vobj != nil) {
        if ((-1 < indx) && (indx < [self.tabs count])) {
            NSTextView *inpt = [self.inpt objectAtIndex:indx];
            NSLayoutManager *laym = inpt.layoutManager;
            NSTextContainer *txtc = inpt.textContainer;

            [laym ensureLayoutForTextContainer:txtc];

            CGFloat cohi = [laym usedRectForTextContainer:txtc].size.height;
            CGFloat lihi = (cohi / 1.99);
            CGFloat tahi = (cohi + lihi);

            //NSLog(@"ADJI [%f][%f][%f]", cohi, lihi, tahi);

            if (tahi < 35.0) { tahi = 35.0; }
            if (tahi > 95.0) { tahi = 95.0; }

            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.coni.constant != tahi) {
                    self.coni.constant = tahi;
                    [self.view layoutSubtreeIfNeeded];
                }
            });
        }
    }
}

- (void)adjt:(NSTimer *)timer {
    if (self.vobj != nil) {
        int iidx = (self.indx.intValue - 1);
        if ((-1 < iidx) && (iidx < [self.tabs count])) {
            [self adji:iidx];
        }
    }
}

- (void)textDidChange:(NSNotification *)notification {
    if (self.vobj != nil) {
        int iidx = (self.indx.intValue - 1);
        if ((-1 < iidx) && (iidx < [self.tabs count])) {
            if ([self.inpt containsObject:notification.object]) {
                [self adji:iidx];
            }
        }
    }
}

- (NSArray<NSValue *> *)textView:(NSTextView *)textView willChangeSelectionFromCharacterRanges:(NSArray<NSValue *> *)oldRanges toCharacterRanges:(NSArray<NSValue *> *)newRanges {
    NSArray<NSValue *> *retRange = newRanges;
    if (self.vobj != nil) {
        int iidx = (self.indx.intValue - 1);
        if ((-1 < iidx) && (iidx < [self.tabs count])) {
            if ([self.inpt containsObject:textView]) {
                int didx = [self.crsa objectAtIndex:iidx].intValue;
                int rnum = (didx >> 16), cnum = (didx & 0xffff);
                int curs = ((rnum * self.cols.intValue) + cnum);
                NSUInteger totalLength = [textView textStorage].length;
                if (curs < totalLength) { totalLength = curs; }
                NSRange lockRange = NSMakeRange(totalLength, 0);
                retRange = @[[NSValue valueWithRange:lockRange]];
                if (newRanges.count > 0) {
                    if (newRanges.count > 0) {
                        NSRange proposedRange = [newRanges.firstObject rangeValue];
                        if (proposedRange.length > 0) {
                            return newRanges;
                        }
                        if (proposedRange.location < totalLength) {
                            return retRange;
                        }
                    }
                }
            }
        }
    }
    return retRange;
}

- (int)show:(NSString *)text indx:(int)indx sels:(int)sels cidx:(int)cidx rows:(int)rows cols:(int)cols {
    int iidx = (indx - 1);
    long leng = ([self.tabs count] - 1);

    if (self.vobj == nil) { return 1; }
    if ((iidx < 0) || (iidx > leng)) { return -2; }
    if ((rows < 5) || (cols < 5)) { return 3; }

    self.rows = @(rows);
    self.cols = @(cols);

    int didx = cidx;
    if (didx < 1) {
        if (sels == 0) { didx = [self.crsa objectAtIndex:iidx].intValue; }
        if (sels == 1) { didx = [self.crsb objectAtIndex:iidx].intValue; }
        if (sels == 2) { didx = [self.crsc objectAtIndex:iidx].intValue; }
    } else {
        if (sels == 0) { [self.crsa replaceObjectAtIndex:iidx withObject:@(didx)]; }
        if (sels == 1) { [self.crsb replaceObjectAtIndex:iidx withObject:@(didx)]; }
        if (sels == 2) { [self.crsc replaceObjectAtIndex:iidx withObject:@(didx)]; }
    }

    if (([self.tabs count] < 1) || (iidx < 0) || ([self.tabs count] <= iidx)) {
        NSLog(@"ERRO show");
        return 0;
    }

    NSNumber *shol = [self.shol objectAtIndex:sels];
    unsigned long long mill = [self getl];
    unsigned long long last = shol.unsignedLongLongValue;

    if ((mill - last) < 159) {
        NSLog(@"WARN show [%d][%llu]", sels, mill);
        return 0;
    }
    shol = @(mill);

    NSScrollView *iscr = [self.iscr objectAtIndex:iidx];
    NSScrollView *oscr = [self.oscr objectAtIndex:iidx];
    NSTextView *inpt = [self.inpt objectAtIndex:iidx];
    NSTextView *outp = [self.outp objectAtIndex:iidx];
    NSTextStorage *itxt = [self.itxt objectAtIndex:iidx];
    NSTextStorage *otxt = [self.otxt objectAtIndex:iidx];

    int stat = 0;
    int jidx = (self.indx.intValue - 1);

    //NSLog(@"SHOW [%d][%d] [%d] [%f][%f] [%d][%d] [%d] [%d][%d] [%ld]",iidx,jidx,sels,fntw,fnth,rows,cols,cidx,didx>>16,didx&0xffff, text == nil ? -1 : [text length] );

    if (sels == 0) {
        NSString *strs = text;
        NSTextStorage *stor = [inpt textStorage];
        if (text != nil) {
            NSAttributedString *atrs = [[NSAttributedString alloc] initWithString:strs attributes:self.attr];
            [stor beginEditing];
            [stor setAttributedString:atrs];
            [stor endEditing];
        }
        if (iidx == jidx) {
            NSNotification *noti = [NSNotification notificationWithName:@"TextDidChange" object:inpt];
            [self textDidChange:noti];
            //[iscr becomeFirstResponder];
            if ((iscr.window != nil) && ([iscr.window firstResponder] != inpt)) {
                [iscr.window makeFirstResponder:inpt];
            }
        }
    } else if (sels == 1) {
        NSString *strs = text;
        NSTextStorage *stor = [outp textStorage];
        if (text != nil) {
            NSAttributedString *atrs = [[NSAttributedString alloc] initWithString:strs attributes:self.attr];
            [stor beginEditing];
            [stor appendAttributedString:atrs];
            [stor endEditing];
            NSAttributedString *save = [stor attributedSubstringFromRange:NSMakeRange(0, [stor length])];
            [self.atrs replaceObjectAtIndex:iidx withObject:save];
            otxt = [[NSTextStorage alloc] initWithAttributedString:stor];
            if (self.scrl.intValue == 0) {
                [outp scrollToEndOfDocument:nil];
            }
        }
    } else if (sels == 2) {
        NSString *strs = text;
        NSTextStorage *stor = [outp textStorage];
        if (text != nil) {
            NSAttributedString *atrs = [[NSAttributedString alloc] initWithString:strs attributes:self.attr];
            [stor beginEditing];
            [stor setAttributedString:atrs];
            [stor endEditing];
            NSAttributedString *save = [stor attributedSubstringFromRange:NSMakeRange(0, [stor length])];
            [self.atrs replaceObjectAtIndex:iidx withObject:save];
        }
    }

    if (text != nil) {
        stat = 5;
    }

    return stat;
}

- (void)colt:(NSButton *)butt {
    NSMutableAttributedString *tita = [[NSMutableAttributedString alloc] initWithAttributedString:[butt attributedTitle]];
    NSRange titr = NSMakeRange(0, [tita length]);
    [tita addAttribute:NSForegroundColorAttributeName value:self.txtc range:titr];
    [butt setAttributedTitle:tita];
}

- (int)tabt:(NSString *)text indx:(int)indx {
    int iidx = (indx - 1);
    if (self.vobj != nil) {
        if ((-1 < iidx) && (iidx < [self.tabs count])) {
            NSButton *butt = [self.tabs objectAtIndex:iidx];
            NSString *head = [NSString stringWithFormat:@"%@  [#%ld]", text, [butt tag]];
            [butt setTitle:head];
            [butt setAlignment:NSTextAlignmentLeft];
            [self colt:butt];
        }
        return 1;
    }
    return 0;
}

- (void)addf:(id)sender {
    NSLog(@"ADDF");
    if (self.flag.intValue == 0) {
        self.flag = @1;
    }
}

- (void)tabf:(id)sender {
    NSButton *tabb = (NSButton *)sender;
    if (self.vobj != nil) {
        unsigned long tagn = [tabb tag];
        int indx = ((int)(tagn) - 1);
        int iidx = (self.indx.intValue - 1);
        if ((indx != iidx) && (-1 < indx) && (indx < [self.tabs count])) {
            NSLog(@"VIEW [%d][%d]", indx, iidx);
            self.indx = @(indx + 1);
            NSScrollView *oscr = [self.oscr objectAtIndex:indx];
            NSView *inpv = [self.inpv objectAtIndex:indx];
            [self.allv setViews:@[self.tabv, self.diva, oscr, self.divb, inpv] inGravity:NSStackViewGravityBottom];
            [self sets:nil wide:self.wide.floatValue high:self.high.floatValue];
            if (indx < [self.outp count]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSTextView *outp = [self.outp objectAtIndex:indx];
                    [outp scrollToEndOfDocument:nil];
                });
            }
            NSTextView *inpt = [self.inpt objectAtIndex:indx];
            if (inpt.window != nil) {
                [inpt.window makeFirstResponder:inpt];
            }
            [self didChangeCsrColor:self.csrc];
        }
    }
}

- (int)newt:(NSString *)text wide:(CGFloat)wide high:(CGFloat)high {
    unsigned long leng = [self.tabs count];
    int indx = (((int)leng) + 1);

    self.wide = @(wide);
    self.high = @(high);

    NSColor *bgcr = [NSColor colorWithRed:0.01 green:0.11 blue:0.19 alpha:0.91];
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = bgcr.CGColor;

    NSButton *tabb = [[NSButton alloc] init];
    [tabb setAlignment:NSTextAlignmentLeft];
    [tabb setTag:indx];
    [tabb setBezelStyle:NSBezelStyleRounded];
    [tabb setWantsLayer:YES];
    [tabb setTranslatesAutoresizingMaskIntoConstraints:NO];
    [tabb.layer setBorderWidth:1.0];
    [tabb.layer setCornerRadius:9.0];
    [tabb.layer setBorderColor:self.tabc.CGColor];
    [tabb.layer setBackgroundColor:self.tabc.CGColor];
    [tabb setTarget:self];
    [tabb setAction:@selector(tabf:)];
    [tabb setFont:self.font];
    [self.tabs addObject:tabb];

    NSView *spcl = [[NSView alloc] init];
    [spcl setTranslatesAutoresizingMaskIntoConstraints:NO];
    [spcl setContentHuggingPriority:NSLayoutPriorityDefaultLow forOrientation:NSLayoutConstraintOrientationHorizontal];
    [self.spcs addObject:spcl];
    NSView *spcr = [[NSView alloc] init];
    [spcr setTranslatesAutoresizingMaskIntoConstraints:NO];
    [spcr setContentHuggingPriority:NSLayoutPriorityDefaultLow forOrientation:NSLayoutConstraintOrientationHorizontal];
    [self.spcs addObject:spcr];

    if (self.vobj == nil) {
        NSButton *butt = [[NSButton alloc] init];
        NSImage *imgo = [NSImage imageWithSystemSymbolName:@"plus.circle.fill" accessibilityDescription:nil];
        NSImageSymbolConfiguration *conf = [NSImageSymbolConfiguration configurationWithHierarchicalColor:self.txtc];
        NSImage *imgf = [imgo imageWithSymbolConfiguration:conf];
        [butt setWantsLayer:YES];
        [butt setTranslatesAutoresizingMaskIntoConstraints:NO];
        [butt setImageScaling:NSImageScaleProportionallyUpOrDown];
        [butt setImagePosition:NSImageOnly];
        [butt setBordered:NO];
        [butt.widthAnchor constraintEqualToConstant:21.0].active = YES;
        [butt.heightAnchor constraintEqualToConstant:21.0].active = YES;
        [butt setImage:imgf];
        butt.target = self;
        butt.action = @selector(addf:);
        [self.tabv addView:butt inGravity:NSStackViewGravityCenter];
        [self.tabv addView:spcl inGravity:NSStackViewGravityCenter];
    }

    if (self.vobj == nil) {
        NSImage *imgo = [NSImage imageWithSystemSymbolName:@"slash.circle.fill" accessibilityDescription:nil];
        NSImageSymbolConfiguration *conf = [NSImageSymbolConfiguration configurationWithHierarchicalColor:self.txtc];
        NSImage *imgf = [imgo imageWithSymbolConfiguration:conf];
        NSImageView *imgv = [[NSImageView alloc] init];
        imgv.image = imgf;
        imgv.imageScaling = NSImageScaleProportionallyUpOrDown;
        [imgv setWantsLayer:YES];
        [imgv setTranslatesAutoresizingMaskIntoConstraints:NO];
        [imgv.widthAnchor constraintEqualToConstant:21.0].active = YES;
        [imgv.heightAnchor constraintEqualToConstant:21.0].active = YES;
        [self.tabv addView:spcr inGravity:NSStackViewGravityCenter];
        [self.tabv addView:imgv inGravity:NSStackViewGravityCenter];
    }

    if ([self.tabs count] < 1) {
        [self.tabv addView:tabb inGravity:NSStackViewGravityCenter];
    } else {
        [self.tabv insertView:tabb atIndex:([self.tabv.views count] - 2) inGravity:NSStackViewGravityCenter];
    }

    NSScrollView *oscr = [[NSScrollView alloc] init];
    [oscr setHasVerticalScroller:YES];
    [oscr setHasHorizontalScroller:NO];
    [oscr setDrawsBackground:NO];
    [oscr setTranslatesAutoresizingMaskIntoConstraints:NO];
    [oscr setFindBarPosition:NSScrollViewFindBarPositionAboveHorizontalRuler];
    [oscr.contentView setAutoresizesSubviews:YES];
    [self.oscr addObject:oscr];

    NSClipView *oclp = oscr.contentView;
    oclp.drawsBackground = NO;
    [self.oclp addObject:oclp];

    NSTextView *outp = [[NSTextView alloc] init];
    outp.font = self.font;
    outp.textColor = self.txtc;
    outp.backgroundColor = [NSColor clearColor];
    [outp setVerticallyResizable:YES];
    [outp setHorizontallyResizable:NO];
    [outp setEditable:NO];
    [outp setSelectable:YES];
    [outp setBackgroundColor:[NSColor clearColor]];
    [outp setTranslatesAutoresizingMaskIntoConstraints:YES];
    [outp.textContainer setWidthTracksTextView:YES];
    [outp.textContainer setHeightTracksTextView:NO];
    [outp.layoutManager setTypesetterBehavior:NSTypesetterLatestBehavior];
    outp.textContainer.lineFragmentPadding = 1.0;
    outp.textContainerInset = NSMakeSize(0.0, 7.0);
    [self.outp addObject:outp];
    [self.otxt addObject:[[NSTextStorage alloc] init]];

    [oscr setDocumentView:outp];

    NSView *inpv = [[NSView alloc] init];
    inpv.wantsLayer = YES;
    inpv.layer.backgroundColor = [NSColor clearColor].CGColor;
    inpv.translatesAutoresizingMaskIntoConstraints = NO;
    [self.inpv addObject:inpv];

    NSScrollView *iscr = [[NSScrollView alloc] init];
    [iscr setHasVerticalScroller:NO];
    [iscr setHasHorizontalScroller:NO];
    [iscr setWantsLayer:YES];
    [iscr setTranslatesAutoresizingMaskIntoConstraints:NO];
    [iscr setAutohidesScrollers:YES];
    [iscr setDrawsBackground:NO];
    [iscr setAutomaticallyAdjustsContentInsets:NO];
    [iscr.contentView setDrawsBackground:NO];
    [iscr.contentView setPostsBoundsChangedNotifications:NO];
    [inpv addSubview:iscr];
    [self.iscr addObject:iscr];

    //NSTextView *inpt = [[NSTextView alloc] init];
    CursorText *inpt = [[CursorText alloc] init];
    inpt.font = self.font;
    inpt.textColor = self.txtc;
    inpt.backgroundColor = [NSColor clearColor];
    [inpt setDrawsBackground:NO];
    [inpt setEditable:YES];
    [inpt setSelectable:YES];
    [inpt setVerticallyResizable:YES];
    [inpt setHorizontallyResizable:NO];
    [inpt setTranslatesAutoresizingMaskIntoConstraints:YES];
    [inpt.textContainer setWidthTracksTextView:YES];
    [inpt.textContainer setHeightTracksTextView:NO];
    inpt.textContainer.lineFragmentPadding = 1.0;
    inpt.textContainerInset = NSMakeSize(0.0, 7.0);
    inpt.delegate = self;
    [self.inpt addObject:inpt];

    CGFloat chwi = [self.font advancementForGlyph:[self.font glyphWithName:@"x"]].width;
    CGFloat chhi = ((self.font.ascender + fabs(self.font.descender)) + self.font.leading);
    inpt.insertionPointColor = self.csrc;
    inpt.wide = chwi;
    inpt.high = chhi;
    inpt.colh = self.selc;

    [iscr setDocumentView:inpt];
    [self.itxt addObject:[[NSTextStorage alloc] init]];

    NSTextStorage *stor = [outp textStorage];
    [self.atrs addObject:(NSAttributedString *)stor];

    self.coni = [inpv.heightAnchor constraintEqualToConstant:5.0];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollViewDidScroll:) name:NSViewBoundsDidChangeNotification object:oclp];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlTextDidChange:) name:NSControlTextDidChangeNotification object:outp];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlTextDidChange:) name:NSControlTextDidChangeNotification object:inpt];

    [self.crsa addObject:@(0)];
    [self.crsb addObject:@(0)];
    [self.crsc addObject:@(0)];

    if (self.vobj == nil) {
        [self.allv setViews:@[self.tabv, self.diva, oscr, self.divb, inpv] inGravity:NSStackViewGravityBottom];
        [self.view addSubview:self.allv];
        self.indx = @(indx);
        self.vobj = self.view;
    }

    [self tabt:@"Tab" indx:indx];
    self.fntw = @([self tell:'w' indx:0]);
    self.fnth = @([self tell:'h' indx:0]);

    self.flag = @0;

    return indx;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewBoundsDidChangeNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"LOAD");

    NSMutableParagraphStyle *wrap = [[NSMutableParagraphStyle alloc] init];
    wrap.lineBreakMode = NSLineBreakByCharWrapping;

    self.vobj = nil;

    self.wide = @0.0;
    self.high = @0.0;
    self.fntw = @0.0;
    self.fnth = @0.0;
    self.rows = @0;
    self.cols = @0;

    self.scrp = @0;
    self.scrl = @0;
    self.last = @0;
    self.indx = @0;
    self.flag = @0;

    self.bgdc = [NSColor clearColor];
    self.tabc = [NSColor clearColor];
    self.txtc = [NSColor clearColor];
    self.selc = [NSColor clearColor];
    self.csrc = [NSColor clearColor];

    self.font = [[NSFontManager sharedFontManager] convertFont:[NSFont fontWithName:@"Monaco" size:13.0] toHaveTrait:NSBoldFontMask];
    self.attr = @{
        NSFontAttributeName:self.font,
        NSForegroundColorAttributeName:self.txtc,
        NSParagraphStyleAttributeName: wrap,
    };

    self.shol = [[NSMutableArray alloc] init];
    [self.shol addObject:@(0)];
    [self.shol addObject:@(0)];
    [self.shol addObject:@(0)];

    self.cons = [[NSMutableArray alloc] init];
    self.cono = nil;
    self.coni = nil;

    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = self.bgdc.CGColor;

    self.crsa = [[NSMutableArray alloc] init];
    self.crsb = [[NSMutableArray alloc] init];
    self.crsc = [[NSMutableArray alloc] init];

    self.outp = [[NSMutableArray alloc] init];
    self.otxt = [[NSMutableArray alloc] init];
    self.oclp = [[NSMutableArray alloc] init];
    self.oscr = [[NSMutableArray alloc] init];
    self.outv = [[NSMutableArray alloc] init];
    self.inpt = [[NSMutableArray alloc] init];
    self.itxt = [[NSMutableArray alloc] init];
    self.iclp = [[NSMutableArray alloc] init];
    self.iscr = [[NSMutableArray alloc] init];
    self.inpv = [[NSMutableArray alloc] init];

    self.tabs = [[NSMutableArray alloc] init];
    self.spcs = [[NSMutableArray alloc] init];
    self.atrs = [[NSMutableArray alloc] init];

    self.diva = [[NSView alloc] init];
    self.diva.wantsLayer = YES;
    self.diva.layer.backgroundColor = self.tabc.CGColor;

    self.divb = [[NSView alloc] init];
    self.divb.wantsLayer = YES;
    self.divb.layer.backgroundColor = self.tabc.CGColor;

    NSRect dimt = NSMakeRect(1.0, 1.0, 1.0, 1.0);
    self.tabv = [[NSStackView alloc] initWithFrame:dimt];
    self.tabv.distribution = NSStackViewDistributionFill;
    self.tabv.orientation = NSUserInterfaceLayoutOrientationHorizontal;
    self.tabv.spacing = 4.0;
    self.tabv.wantsLayer = YES;
    self.tabv.layer.masksToBounds = YES;
    self.tabv.edgeInsets = NSEdgeInsetsMake(0.0, 11.0, 0.0, 11.0);
    [self.tabv setWantsLayer:YES];
    [self.tabv setTranslatesAutoresizingMaskIntoConstraints:NO];

    NSRect dimv = NSMakeRect(1.0, 1.0, 1.0, 1.0);
    self.allv = [[NSStackView alloc] initWithFrame:dimv];
    self.allv.distribution = NSStackViewDistributionFill;
    self.allv.orientation = NSUserInterfaceLayoutOrientationVertical;
    self.allv.spacing = 0.0;
    self.allv.layer.masksToBounds = YES;
    [self.allv setWantsLayer:YES];
    [self.allv setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.allv setDistribution:NSStackViewDistributionFill];
    [self.allv setContentHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationVertical];
}

@end
