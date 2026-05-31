//
//  ViewController.m
//  TrueTerm
//
//  Created by jon on 2026-05-30.
//

#import "ViewController.h"
#import "MainProc.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

- (unsigned long)gets {
    NSTimeInterval secs = [[NSDate date] timeIntervalSince1970];
    return (unsigned long)secs;
}

- (float)itof:(unsigned int)rgbv shif:(int)shif {
    int valu = ((rgbv >> shif) & 0xff);
    float retn = (float)valu;
    return (retn / 255.0);
}

- (CGFloat)tell:(char)kind indx:(int)indx {
    if (self.vobj != nil) {
        int iidx = self.indx.intValue;
        if (iidx < self.tabs.count) {
            NSStackView *allv = [self.allv objectAtIndex:iidx];
            NSScrollView *scro = [self.scri objectAtIndex:iidx];

            NSTextStorage *stor = [self.xxxx textStorage];
            NSAttributedString *atrs = [[NSAttributedString alloc] initWithString:@" "];
            [stor beginEditing];
            [stor setAttributedString:atrs];
            NSRange area = NSMakeRange(0, stor.length);
            [stor setAttributes:self.attr range:area];
            [stor endEditing];

            [self.xxxx.layoutManager ensureLayoutForTextContainer:self.xxxx.textContainer];

            CGFloat padd = (1.99 + 0.01);
            CGSize size = [self.xxxx.layoutManager usedRectForTextContainer:self.xxxx.textContainer].size;
            CGFloat padt = (self.xxxx.textContainer.lineFragmentPadding * padd);
            CGFloat pads = (scro.contentInsets.left + scro.contentInsets.right + scro.scrollerInsets.left + scro.scrollerInsets.right);
            CGFloat padl = self.xxxx.textContainer.lineFragmentPadding;
            CGFloat pada = allv.spacing;

            //CGFloat wide = [NSScroller scrollerWidthForControlSize:NSControlSizeRegular scrollerStyle:NSScrollerStyleLegacy];

            NSLog(@"TELL [%f][%f] [%f][%f] [%f][%f]", padt, pads, padl, pada, size.width, size.height);

            if (kind == 'w') {
                return (size.width - padt);
            } else {
                return size.height;
            }
        }
    }
    return 0.0;
}

- (int)sets:(NSString *)text indx:(int)indx wide:(CGFloat)wide high:(CGFloat)high {
    if (self.vobj != nil) {
        int iidx = self.indx.intValue;

        if ((indx == iidx) && (indx < self.tabs.count)) {
            CGFloat subs = 0.00;
            CGFloat line = 3.00;
            CGFloat padd = 10.0;
            CGFloat tbar = 30.0;
            CGFloat wsiz = (wide - (padd * (1.99 + 0.11)));
            CGFloat hsiz = (high - (padd * (1.99 + 0.11)));
            CGFloat hmax = (hsiz - tbar);

            NSTextView *outp = [self.outp objectAtIndex:indx];
            NSScrollView *scro = [self.scro objectAtIndex:indx];
            NSScrollView *scri = [self.scri objectAtIndex:indx];
            NSStackView *tabv = [self.tabv objectAtIndex:indx];
            NSStackView *allv = [self.allv objectAtIndex:indx];
            NSView *diva = [self.diva objectAtIndex:indx];
            NSView *divb = [self.divb objectAtIndex:indx];

            if (self.vobj != allv) { return 3; }

            NSLog(@"SETS [%d][%ld] [%f][%f]", indx, self.tabs.count, wide, high);

            NSRect dims = NSMakeRect(padd, padd, wsiz, hsiz);
            [allv setFrame:dims];

            [tabv.views makeObjectsPerformSelector:@selector(removeFromSuperview)];
            for (int z = 0; z < self.tabs.count; ++z) {
                NSButton *butt = [self.tabs objectAtIndex:z];
                if (z > 0) {
                    NSImage *imgo = [NSImage imageWithSystemSymbolName:@"slash.circle.fill" accessibilityDescription:nil];
                    NSImageSymbolConfiguration *conf = [NSImageSymbolConfiguration configurationWithHierarchicalColor:self.colr];
                    NSImage *imgf = [imgo imageWithSymbolConfiguration:conf];
                    NSImageView *imgv = [[NSImageView alloc] init];
                    imgv.image = imgf;
                    imgv.imageScaling = NSImageScaleProportionallyUpOrDown;
                    [imgv setWantsLayer:YES];
                    [imgv setTranslatesAutoresizingMaskIntoConstraints:NO];
                    [imgv.widthAnchor constraintEqualToConstant:15.0].active = YES;
                    [imgv.heightAnchor constraintEqualToConstant:15.0].active = YES;
                    [tabv addView:imgv inGravity:NSStackViewGravityCenter];
                    subs += 19.0;
                }
                [tabv addView:butt inGravity:NSStackViewGravityCenter];
            }
            NSButton *butt = [[NSButton alloc] init];
            NSImage *imgo = [NSImage imageWithSystemSymbolName:@"plus.circle.fill" accessibilityDescription:nil];
            NSImageSymbolConfiguration *conf = [NSImageSymbolConfiguration configurationWithHierarchicalColor:self.colr];
            NSImage *imgf = [imgo imageWithSymbolConfiguration:conf];
            [butt setWantsLayer:YES];
            [butt setTranslatesAutoresizingMaskIntoConstraints:NO];
            [butt setImageScaling:NSImageScaleProportionallyUpOrDown];
            [butt setImagePosition:NSImageOnly];
            [butt setBordered:NO];
            [butt.widthAnchor constraintEqualToConstant:21.0].active = YES;
            [butt.heightAnchor constraintEqualToConstant:21.0].active = YES;
            [butt setImage:imgf];
            subs += 25.0;
            butt.target = self;
            butt.action = @selector(addf:);
            [tabv addView:butt inGravity:NSStackViewGravityCenter];

            if (self.cons != nil) {
                [NSLayoutConstraint deactivateConstraints:self.cons];
                [self.view removeConstraints:self.cons];
                self.cons = nil;
            }

            if (self.cono != nil) {
                [NSLayoutConstraint deactivateConstraints:@[self.cono]];
                self.cono.active = NO;
                self.cono = nil;
            }

            if (self.coni != nil) {
                [NSLayoutConstraint deactivateConstraints:@[self.coni]];
                self.coni.active = NO;
                self.coni = nil;
            }

            if (self.view != nil) {
                [self.view setFrameSize:NSMakeSize(wide, high)];
            }

            NSArray<NSLayoutConstraint *> *cont = @[
                [allv.widthAnchor constraintEqualToConstant:wsiz],
                [allv.heightAnchor constraintEqualToConstant:hmax],
                [tabv.widthAnchor constraintEqualToConstant:wsiz],
                [scro.widthAnchor constraintEqualToConstant:wsiz],
                //[scro.heightAnchor constraintEqualToAnchor:outp.heightAnchor],
                [scri.widthAnchor constraintEqualToConstant:wsiz],
                //[scri.heightAnchor constraintEqualToAnchor:inpt.heightAnchor],
                [diva.widthAnchor constraintEqualToConstant:wsiz],
                [diva.heightAnchor constraintEqualToConstant:line],
                [divb.widthAnchor constraintEqualToConstant:wsiz],
                [divb.heightAnchor constraintEqualToConstant:line],
            ];
            self.cons = [cont mutableCopy];
            for (int z = 0; z < self.tabs.count; ++z) {
                NSButton *butt = [self.tabs objectAtIndex:z];
                [self.cons addObject:[butt.widthAnchor constraintEqualToConstant:(wsiz/self.tabs.count)-(padd*3.99)-subs]];
            }
            [NSLayoutConstraint activateConstraints:self.cons];
            [self.view addConstraints:self.cons];

            self.cono = [outp.heightAnchor constraintEqualToConstant:15.0];
            self.cono.active = YES;

            self.coni = [scri.heightAnchor constraintEqualToConstant:15.0];
            self.coni.active = YES;

            self.fntw = @([self tell:'w' indx:indx]);
            self.fnth = @([self tell:'h' indx:indx]);

            NSLog(@"FONT [%f][%f]", self.fntw.floatValue, self.fnth.floatValue);
        }
    }

    return 0;
}

- (void)remo:(NSTextStorage *)objc area:(NSRange)area {
    [objc removeAttribute:NSForegroundColorAttributeName range:area];
    [objc removeAttribute:NSFontAttributeName range:area];
}

- (CGFloat)scrp {
    CGFloat posy = 0.0;
    CGFloat maxy = 0.0;
    if (self.vobj != nil) {
        int indx = self.indx.intValue;
        if (indx < self.tabs.count) {
            NSScrollView *scro = [self.scro objectAtIndex:indx];
            NSRect rect = scro.contentView.documentVisibleRect;
            NSSize docs = scro.documentView.bounds.size;
            NSSize cons = scro.contentView.bounds.size;
            posy = rect.origin.y;
            maxy = MAX(0.0, (docs.height - cons.height));
            NSLog(@"SCRP [%f][%f]", posy, maxy);
        }
    }
    if (maxy < 1.0) {
        return 1.0;
    }
    return (maxy - posy);
}

- (int)show:(NSString *)text indx:(int)indx sels:(int)sels back:(int)back cidx:(int)cidx rows:(int)rows cols:(int)cols {
    if (self.vobj == nil) { return 1; }
    if ((rows < 1) || (cols < 1)) { return 2; }

    NSScrollView *scri = [self.scri objectAtIndex:indx];
    NSTextView *inpt = [self.inpt objectAtIndex:indx];
    NSTextView *outp = [self.outp objectAtIndex:indx];
    NSTextField *crsi = [self.crsi objectAtIndex:indx];
    NSTextField *crso = [self.crso objectAtIndex:indx];

    CGFloat padl = self.xxxx.textContainer.lineFragmentPadding;
    CGFloat fntw = self.fntw.floatValue;
    CGFloat fnth = self.fnth.floatValue;
    CGFloat fntx = (fntw * (cidx % (cols - 1)));
    CGFloat fnty = (fnth * (cidx / (cols - 1)));
    int iidx = self.indx.intValue;
    int stat = 0;

    //NSLog(@"SHOW [%d][%d] [%f][%f] [%f][%f] [%f] [%d][%d] [%d][%d] [%d][%ld]",indx,sels,fntx,fnty,fntw,fnth,padl,cidx / (cols - 1),cidx % (cols - 1),rows,cols,cidx, text == nil ? -1 : text.length );
    fntx += padl;

    if (sels == 0) {
        NSString *strs = text;
        if (text == nil) {
            strs = inpt.textStorage.string;
        }
        NSTextStorage *stor = [inpt textStorage];
        NSAttributedString *atrs = [[NSAttributedString alloc] initWithString:strs];
        [stor beginEditing];
        [stor setAttributedString:atrs];
        NSRange area = NSMakeRange(0, stor.length);
        [self remo:stor area:area];
        [stor setAttributes:self.attr range:area];
        [stor endEditing];
        if ((0 < cidx) && (cidx < text.length)) {
            [crsi setFrame:NSMakeRect(fntx, fnty, fntw, fnth)];
        } else {
            [crsi setFrame:NSMakeRect(-9000.0, -9000.0, fntw, fnth)];
        }
        if (indx == iidx) {
            [self controlTextDidChange:self.noti];
            [scri becomeFirstResponder];
        }
    } else if (sels == 1) {
        NSString *strs = text;
        if (text == nil) {
            strs = outp.textStorage.string;
        }
        NSTextStorage *stor = [outp textStorage];
        NSAttributedString *atrs = [[NSAttributedString alloc] initWithString:strs];
        [stor beginEditing];
        if (text == nil) {
            [stor setAttributedString:atrs];
        } else {
            [stor appendAttributedString:atrs];
        }
        NSRange area = NSMakeRange(0, stor.length);
        [self remo:stor area:area];
        [stor setAttributes:self.attr range:area];
        [stor endEditing];
        if (indx == iidx) {
            [self controlTextDidChange:self.noto];
            CGFloat diff = [self scrp];
            if (diff != 0.0) {
                stat = 5;
            }
        }
    } else if (sels == 2) {
        NSString *strs = text;
        if (text == nil) {
            strs = outp.textStorage.string;
        }
        NSTextStorage *stor = [outp textStorage];
        NSAttributedString *atrs = [[NSAttributedString alloc] initWithString:strs];
        [stor beginEditing];
        [stor setAttributedString:atrs];
        NSRange area = NSMakeRange(0, stor.length);
        [self remo:stor area:area];
        [stor setAttributes:self.attr range:area];
        [stor endEditing];
        if ((-1 < cidx) && (cidx < text.length)) {
            [crso setFrame:NSMakeRect(fntx, fnty, fntw, fnth)];
        } else {
            [crso setFrame:NSMakeRect(-9000.0, -9000.0, fntw, fnth)];
        }
        if (indx == iidx) {
            [self controlTextDidChange:self.noto];
        }
    }

    if (text != nil) {
        stat = 5;
    }

    return stat;
}

- (void)textViewDidChangeSelection:(NSNotification *)notification {
    NSTextView *txtv = (NSTextView *)notification.object;
    NSArray<NSValue *> *rngl = [txtv selectedRanges];
    if (rngl.count > 0) {
        NSRange selr = [rngl.firstObject rangeValue];
        NSString *txts = [txtv.string substringWithRange:selr];
        if ((txts != nil) && (txts.length > 0)) {
            NSLog(@"SELS [%@]", txts);
        }
    }
}

- (void)scrollViewDidScroll:(NSNotification *)notification {
    unsigned long secs = [self gets];
    CGFloat difp = [self scrp];
    NSLog(@"SCRO [%f]", difp);
    if ((secs - self.last.intValue) > 1) {
        if ((self.scrl.intValue == 0) && (difp > 15.00)) {
            self.scrl = @1;
            self.last = @(secs);
        }
        if ((self.scrl.intValue == 1) && (difp < 15.00)) {
            self.scrl = @0;
            self.last = @(secs);
        }
    }
}

- (void)controlTextDidChange:(NSNotification *)notification {
    if (self.vobj != nil) {
        int indx = self.indx.intValue;
        if (indx < self.tabs.count) {
            NSTextView *txto = [self.outp objectAtIndex:indx];
            NSTextView *txti = [self.inpt objectAtIndex:indx];
            NSTextView *txtv = notification.object;
            if ((txtv == txti) && (self.coni != nil)) {
                //NSSize size = [scri contentSize];
                [txtv.layoutManager ensureLayoutForTextContainer:txtv.textContainer];
                CGFloat txtb = [txtv.layoutManager usedRectForTextContainer:txtv.textContainer].size.height;
                CGFloat txtc = txtv.textContainerInset.height;
                CGFloat high = (txtb + txtc);
                self.coni.constant = MAX(high, 15.0);
                NSLog(@"HIGH [I] [%f][%f] [%f]", txtb, txtc, high);
            }
            if ((txtv == txto) && (self.cono != nil)) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //NSSize size = [scri contentSize];
                    [txtv.layoutManager ensureLayoutForTextContainer:txtv.textContainer];
                    CGFloat txtb = [txtv.layoutManager usedRectForTextContainer:txtv.textContainer].size.height;
                    CGFloat txtc = txtv.textContainerInset.height;
                    CGFloat txtd = self.fnth.floatValue;
                    CGFloat high = ((txtb + txtc) + txtd);
                    self.cono.constant = MAX(high, 15.0);
                    NSLog(@"HIGH [O] [%f][%f][%f] [%f]", txtb, txtc, txtd, high);
                    if (self.scrl.intValue == 0) {
                        [txto scrollToEndOfDocument:nil];
                        //[[self.scro objectAtIndex:indx] reflectScrolledClipView:[[self.scro objectAtIndex:indx] contentView]];
                    }
                });
            }
        }
    }
}

- (void)colt:(NSButton *)butt {
    NSMutableAttributedString *tita = [[NSMutableAttributedString alloc] initWithAttributedString:[butt attributedTitle]];
    NSRange titr = NSMakeRange(0, [tita length]);
    [tita addAttribute:NSForegroundColorAttributeName value:self.colr range:titr];
    [butt setAttributedTitle:tita];
}

- (int)tabt:(NSString *)text indx:(int)indx {
    if (self.vobj != nil) {
        if (indx < self.tabs.count) {
            NSButton *butt = [self.tabs objectAtIndex:indx];
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
}

- (void)tabf:(id)sender {
    NSButton *tabb = (NSButton *)sender;
    if (self.vobj != nil) {
        unsigned long tagn = [tabb tag];
        int indx = ((int)tagn);
        int iidx = self.indx.intValue;
        NSLog(@"TAPB [%d]", indx);
        if ((indx != iidx) && (indx < self.tabs.count)) {
            NSView *vobj = self.vobj;
            NSStackView *allv = [self.allv objectAtIndex:indx];
            NSScrollView *scro = [self.scro objectAtIndex:indx];
            NSTextView *outp = [self.outp objectAtIndex:indx];
            NSTextView *inpt = [self.inpt objectAtIndex:indx];
            self.vobj = nil;
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewBoundsDidChangeNotification object:nil];
            [vobj removeFromSuperview];
            //[[NSNotificationCenter defaultCenter] removeObserver:self name:NSControlTextDidChangeNotification object:nil];
            //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlTextDidChange:) name:NSControlTextDidChangeNotification object:inpt];
            self.noto = [[NSNotification alloc] initWithName:@"*" object:outp userInfo:nil];
            self.noti = [[NSNotification alloc] initWithName:@"*" object:inpt userInfo:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollViewDidScroll:) name:NSViewBoundsDidChangeNotification object:scro.contentView];
            [self.view addSubview:allv];
            self.indx = @(indx);
            self.vobj = allv;
            [self sets:@"tabf" indx:indx wide:self.wide.floatValue high:self.high.floatValue];
        }
    }
}

- (int)newt:(NSString *)text wide:(CGFloat)wide high:(CGFloat)high {
    unsigned long leng = [self.tabs count];
    int indx = ((int)leng);

    self.wide = @(wide);
    self.high = @(high);

    NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
    para.lineBreakMode = NSLineBreakByCharWrapping;

    NSRect dimt = NSMakeRect(1.0, 1.0, 1.0, 1.0);
    NSStackView *tabv = [[NSStackView alloc] initWithFrame:dimt];
    tabv.orientation = NSUserInterfaceLayoutOrientationHorizontal;
    tabv.spacing = 1.99;
    tabv.wantsLayer = YES;
    tabv.layer.masksToBounds = YES;
    [tabv setWantsLayer:YES];
    [tabv setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.tabv addObject:tabv];

    NSString *tabt = [NSString stringWithFormat:@"Tab  [#%d]", indx];
    NSButton *tabb = [[NSButton alloc] init];
    [tabb setTitle:tabt];
    [tabb setAlignment:NSTextAlignmentLeft];
    [tabb setTag:indx];
    [tabb setBezelStyle:NSBezelStyleRounded];
    [tabb setTarget:self];
    [tabb setAction:@selector(tabf:)];
    [tabb setFont:self.font];
    [tabb setWantsLayer:YES];
    [tabb setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self colt:tabb];

    [tabb.layer setBorderWidth:1.0];
    [tabb.layer setCornerRadius:5.0];
    [tabb.layer setBorderColor:self.tabc.CGColor];
    [tabb.layer setBackgroundColor:self.tabc.CGColor];
    [self.tabs addObject:tabb];

    NSTextView *outp = [[NSTextView alloc] init];
    outp.delegate = self;
    [outp setVerticallyResizable:YES];
    [outp setHorizontallyResizable:NO];
    [outp setEditable:NO];
    [outp setRichText:NO];
    [outp setSelectable:YES];
    [outp setBackgroundColor:[NSColor clearColor]];
    [outp setDefaultParagraphStyle:para];
    [outp setWantsLayer:YES];
    [outp setTranslatesAutoresizingMaskIntoConstraints:NO];
    [outp.textContainer setHeightTracksTextView:NO];
    [outp.textContainer setWidthTracksTextView:YES];
    [outp resignFirstResponder];
    [self.outp addObject:outp];

    NSTextField *crso = [[NSTextField alloc] init];
    crso.bordered = NO;
    crso.font = self.font;
    crso.textColor = self.colr;
    crso.backgroundColor = self.colr;
    crso.stringValue = @" ";
    [outp addSubview:crso];
    [self.crso addObject:crso];

    NSScrollView *scro = [[NSScrollView alloc] init];
    [scro setHasVerticalScroller:YES];
    [scro setHasHorizontalScroller:NO];
    [scro setWantsLayer:YES];
    [scro setTranslatesAutoresizingMaskIntoConstraints:NO];
    //[scro.verticalScroller setHidden:NO];
    //[scro.horizontalScroller setHidden:YES];
    [scro setDrawsBackground:NO];
    [scro setAutohidesScrollers:NO];
    [scro setAutomaticallyAdjustsContentInsets:NO];
    [scro.contentView setDrawsBackground:NO];
    [scro.contentView setPostsBoundsChangedNotifications:YES];
    [scro resignFirstResponder];
    [scro setDocumentView:outp];
    [self.scro addObject:scro];

    NSTextView *inpt = [[NSTextView alloc] init];
    //inpt.delegate = self;
    [inpt setVerticallyResizable:YES];
    [inpt setHorizontallyResizable:NO];
    [inpt setWantsLayer:YES];
    [inpt setTranslatesAutoresizingMaskIntoConstraints:NO];
    [inpt setEditable:NO];
    [inpt setRichText:NO];
    [inpt setSelectable:YES];
    [inpt setDefaultParagraphStyle:para];
    [inpt setBackgroundColor:[NSColor clearColor]];
    [inpt.textContainer setHeightTracksTextView:NO];
    [inpt.textContainer setWidthTracksTextView:YES];
    [inpt becomeFirstResponder];
    [self.inpt addObject:inpt];

    NSTextField *crsi = [[NSTextField alloc] init];
    crsi.bordered = NO;
    crsi.font = self.font;
    crsi.textColor = self.colr;
    crsi.backgroundColor = self.colr;
    crsi.stringValue = @" ";
    [inpt addSubview:crsi];
    [self.crsi addObject:crsi];

    NSScrollView *scri = [[NSScrollView alloc] init];
    [scri setHasVerticalScroller:NO];
    [scri setHasHorizontalScroller:NO];
    [scri setWantsLayer:YES];
    [scri setTranslatesAutoresizingMaskIntoConstraints:NO];
    //[scri.verticalScroller setHidden:YES];
    //[scri.horizontalScroller setHidden:YES];
    [scri setAutohidesScrollers:YES];
    [scri setDrawsBackground:NO];
    [scri setAutomaticallyAdjustsContentInsets:NO];
    [scri.contentView setDrawsBackground:NO];
    [scri.contentView setPostsBoundsChangedNotifications:NO];
    [scri becomeFirstResponder];
    [scri setDocumentView:inpt];
    [self.scri addObject:scri];

    NSView *diva = [[NSView alloc] init];
    diva.wantsLayer = YES;
    diva.layer.backgroundColor = self.tabc.CGColor;
    [self.diva addObject:diva];

    NSView *divb = [[NSView alloc] init];
    divb.wantsLayer = YES;
    divb.layer.backgroundColor = self.tabc.CGColor;
    [self.divb addObject:divb];

    NSRect dimv = NSMakeRect(1.0, 1.0, 1.0, 1.0);
    NSStackView *allv = [[NSStackView alloc] initWithFrame:dimv];
    allv.orientation = NSUserInterfaceLayoutOrientationVertical;
    allv.spacing = 1.99;
    allv.layer.masksToBounds = YES;
    [allv setWantsLayer:YES];
    [allv setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.allv addObject:allv];

    [allv setViews:@[tabv, diva, scro, divb, scri] inGravity:NSStackViewGravityBottom];
    if (indx == self.indx.intValue) {
        NSLog(@"VIEW [%d]", indx);
        self.noto = [[NSNotification alloc] initWithName:@"*" object:outp userInfo:nil];
        self.noti = [[NSNotification alloc] initWithName:@"*" object:inpt userInfo:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollViewDidScroll:) name:NSViewBoundsDidChangeNotification object:scro.contentView];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlTextDidChange:) name:NSControlTextDidChangeNotification object:inpt];
        [self.view addSubview:allv];
        self.vobj = allv;
        [self sets:text indx:indx wide:wide high:high];
    }

    return indx;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewBoundsDidChangeNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"LOAD");

    self.vobj = nil;

    self.indx = @0;
    self.wide = @0.0;
    self.high = @0.0;
    self.fntw = @0.0;
    self.fnth = @0.0;

    self.scrl = @0;
    self.last = @0;

    self.bgcr = [NSColor colorWithRed:0.01 green:0.11 blue:0.19 alpha:0.91];
    self.tabc = [NSColor colorWithRed:0.01 green:0.55 blue:0.55 alpha:0.91];
    self.font = [[NSFontManager sharedFontManager] convertFont:[NSFont fontWithName:@"Monaco" size:13.0] toHaveTrait:NSBoldFontMask];
    self.colr = [NSColor colorWithRed:0.99 green:0.79 blue:0.59 alpha:0.91];
    self.attr = @{ NSFontAttributeName:self.font, NSForegroundColorAttributeName:self.colr };

    self.cons = nil;
    self.cono = nil;
    self.coni = nil;

    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = self.bgcr.CGColor;

    self.xxxx = [[NSTextView alloc] init];
    self.xxxx.horizontallyResizable = YES;
    self.xxxx.verticallyResizable = YES;
    self.xxxx.textContainer.widthTracksTextView = NO;
    self.xxxx.textContainer.heightTracksTextView = NO;
    self.xxxx.wantsLayer = YES;
    self.xxxx.layer.masksToBounds = YES;
    self.xxxx.translatesAutoresizingMaskIntoConstraints = NO;
    self.xxxx.maxSize = NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX);
    self.xxxx.textContainer.size = NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX);
    //self.xxxx.textContainer.lineFragmentPadding = 0.0;
    [self.xxxx setEditable:NO];
    [self.xxxx setRichText:NO];
    [self.xxxx setSelectable:YES];

    self.tabs = [[NSMutableArray alloc] init];
    self.outp = [[NSMutableArray alloc] init];
    self.crso = [[NSMutableArray alloc] init];
    self.scro = [[NSMutableArray alloc] init];
    self.inpt = [[NSMutableArray alloc] init];
    self.crsi = [[NSMutableArray alloc] init];
    self.scri = [[NSMutableArray alloc] init];
    self.diva = [[NSMutableArray alloc] init];
    self.divb = [[NSMutableArray alloc] init];
    self.tabv = [[NSMutableArray alloc] init];
    self.allv = [[NSMutableArray alloc] init];
}

@end
