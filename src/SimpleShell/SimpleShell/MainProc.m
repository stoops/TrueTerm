//
//  MainProc.m
//  SimpleShell
//
//  Created by jon on 2026-06-05.
//

#import <Foundation/Foundation.h>
#import <util.h>

#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <termios.h>
#include <unistd.h>
#include <sys/ioctl.h>

#import "ViewController.h"
#import "MainProc.h"
#import "AppDelegate.h"

#define MAGC 9753

//NS_ASSUME_NONNULL_BEGIN

@interface MainProc ()
- (NSString *)gout:(int)mode;
@end

static int screen_movecursor(VTermPos pos, VTermPos oldpos, int visible, void *user) {
    MainProc *self = (__bridge MainProc *)(user);
    self.crow = @(pos.row);
    self.ccol = @(pos.col);
    NSLog(@"CURS [%d][%d]", self.crow.intValue, self.ccol.intValue);
    [self inpt:nil indx:self.vidx.intValue];
    return 1;
}

static int screen_damage(VTermRect rect, void *user) {
    MainProc *self = (__bridge MainProc *)(user);
    if ((rect.start_col == 0) && (rect.start_row == self.crow.intValue)) {
        NSLog(@"CURK [%d][%d]", self.crow.intValue, self.ccol.intValue);
        /* ![K */
        // todo self.icol = @(0);
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.vcon != nil) {
            if (self.mode.intValue == 2) {
                int cidx = ((self.crow.intValue << 16) | (self.ccol.intValue + 0));
                NSString *outp = [self gout:2];
                [self.vcon show:outp indx:self.vidx.intValue sels:2 cidx:cidx rows:self.rows.intValue cols:self.cols.intValue];
            }
            [self inpt:nil indx:self.vidx.intValue];
        }
    });
    return 1;
}

static int screen_settermprop(VTermProp prop, VTermValue *val, void *user) {
    MainProc *self = (__bridge MainProc *)(user);
    if ((prop == VTERM_PROP_TITLE) || (prop == VTERM_PROP_ICONNAME)) {
        const char *cTitle = val->string.str;
        if (cTitle != NULL) {
            NSString *newTitle = [NSString stringWithUTF8String:cTitle];
            NSLog(@"TITL [%@]", newTitle);
            /*dispatch_async(dispatch_get_main_queue(), ^{
                if (prop == VTERM_PROP_TITLE) {
                    if (self.wino != nil) {
                        [self.wino setTitle:newTitle];
                    }
                }
                if (prop == VTERM_PROP_ICONNAME) {
                    if (self.tcon != nil) {
                        [self.tcon tabt:newTitle indx:self.vidx.intValue];
                    }
                }
            });*/
        }
    }
    return 1;
}

@implementation MainProc

- (int)chkf {
    if ((self.mfdn == nil) || (self.sfdn == nil)) { return 1; }
    if (self.mfdn.intValue < 1) { return 2; }
    return 0;
}

- (int)visi:(int)byte extr:(int)extr {
    if ((31 < byte) && (byte < 127)) {
        return 1;
    }
    if ((extr == 1) && (byte == 9)) {
        return 2;
    }
    return 0;
}

- (int)bite:(NSMutableData *)data indx:(int)indx item:(unsigned char)item repl:(int)repl leng:(int)leng {
    unsigned char spcr = ' ';
    while (indx >= [data length]) {
        [data appendBytes:&(spcr) length:1];
    }
    for (int z = 0; z < leng; ++z) {
        [data replaceBytesInRange:NSMakeRange(indx, repl) withBytes:&item length:1];
    }
    return indx + 1;
}

- (void)comp:(NSString *)outp {
    NSMutableString *outs = [@"" mutableCopy];
    NSArray *cmpl = [outp componentsSeparatedByString:@"\n"];
    if ([self.hist count] > 0) {
        [self.hist removeObjectAtIndex:0];
    }
    for (int y = 0; y < [cmpl count]; ++y) {
        NSString *bstr = [cmpl objectAtIndex:y];
        if (y >= [self.hist count]) {
            NSString *temp = [NSString stringWithFormat:@"\n%@", bstr];
            [outs appendString:[temp copy]];
            [self.hist addObject:[bstr copy]];
        } else {
            NSString *astr = [self.hist objectAtIndex:y];
            if (![bstr isEqualToString:astr]) {
                NSString *temp = [NSString stringWithFormat:@"\n%@", bstr];
                [outs appendString:[temp copy]];
                [self.hist replaceObjectAtIndex:y withObject:[bstr copy]];
            }
        }
    }
    if ([outs length] > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.vcon show:outs indx:self.vidx.intValue sels:1 cidx:0 rows:self.rows.intValue cols:self.cols.intValue];
        });
    }
}

- (int)gidx:(int)mode {
    int i = 0, j = 0, k = 0, z = 0;
    const unsigned char *q = [self.ansi bytes];
    if (mode == 0) {
        z = ((self.crow.intValue * (self.cols.intValue - 1)) + self.ccol.intValue);
        goto last;
    }
    if (mode == 1) {
        for (int r = 0; r < (self.rows.intValue - 1); ++r) {
            for (int c = 0; c < (self.cols.intValue - 1); ++c) {
                i = ((r * (self.cols.intValue - 1)) + c);
                if (q[i] == 1) {
                    ++k;
                }
                if ((q[i] != 0) && (q[i] != 1)) {
                    if ((r == self.crow.intValue) && (c == self.ccol.intValue)) {
                        z = (j + k);
                        goto last;
                    }
                    ++j;
                }
            }
        }
        z = (j + k);
        goto last;
    }
last:
    if ((z >= [self.ansi length]) || (z >= [self.ansp length])) {
        NSLog(@"INDX [%d] [%ld][%ld", z, [self.ansi length], [self.ansp length]);
        z = 0;
    }
    return z;
}

- (NSString *)gout:(int)mode {
    if ((mode == 0) || (mode == 1) || (mode == 2)) {
        NSMutableString *line = [NSMutableString string];
        NSMutableString *cstr = [NSMutableString string];
        NSMutableString *outp = [NSMutableString string];
        NSMutableArray *list = [NSMutableArray array];
        NSMutableString *inpt = [@"" mutableCopy];
        NSMutableString *join = [@"\n" mutableCopy];
        int maxr = self.rows.intValue;
        int maxc = self.cols.intValue;
        if ((maxr < 1) || (maxc < 1)) {
            return @"";
        }
        [line setString:@""];
        for (int r = 0; r < maxr; ++r) {
            /*if (r == (maxr - 1)) {
                maxc = MAGC;
            }*/
            [cstr setString:@""];
            for (int c = 0; c < maxc; ++c) {
                VTermScreenCell cell;
                VTermPos pos = { .row = r, .col = c };
                if (vterm_screen_get_cell(self.vtsc, pos, &cell)) {
                    if (cell.chars[0] != 0) {
                        [cstr appendFormat:@"%C", (unsigned short)cell.chars[0]];
                    }
                }
            }
            if ((mode == 0) || (mode == 2)) {
                [list addObject:[cstr copy]];
            } else {
                [line appendString:cstr];
                if ([cstr length] < self.cols.intValue) {
                    [list addObject:[line copy]];
                    [line setString:@""];
                }
            }
        }
        if (mode == 1) {
            if ([line length] > 0) {
                [list addObject:[line copy]];
            }
            //NSLog(@"LIST [%@]", list);
            if ([list count] > 0) {
                [list removeLastObject];
            }
        }
        outp = [[list componentsJoinedByString:join] mutableCopy];
        if (mode == 0) {
            int irow = 0;
            for (int x = ((int)([list count]) - 1); x > -1; --x) {
                NSMutableString *item = [list objectAtIndex:x];
                if ((irow == 0) && ([item length] == 1) && ([item UTF8String][0] == ' ')) {
                    continue;
                }
                if ((irow == 0) || ([item length] == self.cols.intValue)) {
                    inpt = [[NSMutableString alloc] initWithFormat:@"%@%@", item, inpt];
                    irow += 1;
                } else {
                    break;
                }
            }
            inpt = [[NSMutableString alloc] initWithFormat:@"%@%@", @"\n", inpt];
            [self.ansp setData:[inpt dataUsingEncoding:NSUTF8StringEncoding]];
            self.irow = @(MAX(0, (self.rows.intValue - self.crow.intValue) - 1));
            self.icol = @(self.ccol.intValue);
        }
        if (mode == 0) {
            return [inpt copy];
        } else {
            return [outp copy];
        }
    }
    return @"";
}

- (int)outp:(NSTimer *)objc {
    ssize_t maxl = 9753;
    ssize_t leng, dlen, alen = 0;
    unsigned char *buff = malloc(maxl), *data = malloc(maxl), *ansi = malloc(maxl);
    while (1) {
        ssize_t maxr = (self.cols.intValue - 9);
        ssize_t maxa = (self.cols.intValue + 9);
        if (maxa > maxl) {
            NSLog(@"OUTP REAL [%ld][%ld]", maxl, maxa);
            buff = realloc(buff, maxa); data = realloc(data, maxa); ansi = realloc(ansi, maxa);
            maxl = maxa;
        }
        if ([self chkf] != 0) { return 1; }
        if (self.vcon == nil) { usleep(357000); continue; }
        if (self.term == nil) { usleep(357000); continue; }
        int fdes = self.mfdn.intValue;
        fd_set rfds;
        struct timeval timo;
        FD_ZERO(&rfds);
        FD_SET(fdes, &rfds);
        timo.tv_sec = 0;
        timo.tv_usec = 159000;
        select(fdes + 1, &rfds, NULL, NULL, &timo);
        if ([self chkf] != 0) { return 3; }
        if (FD_ISSET(fdes, &rfds)) {
            dlen = 0;
            leng = read(fdes, buff, maxr);
            if (leng < 1) {
                close(self.mfdn.intValue);
                self.mfdn = nil;
                NSLog(@"OUTP fin");
                return 2;
            }
            if (self.mode.intValue != 9) {
                for (int x = 0; x < leng; ++x) {
                    //NSLog(@"OUTP [%d] [%d][%c]", x, buff[x], buff[x]);
                    if (buff[x] == 27) {
                        self.skip = @(1);
                        self.flag = @(0);
                        alen = 0;
                        [self.info setLength:0];
                        NSLog(@"ANSI [%d][%d] [%d][%d]", x, buff[x], self.skip.intValue, self.flag.intValue);
                    } else if (self.flag.intValue == 3) {
                        if ((31 < buff[x]) && (buff[x] < 127)) {
                            [self.info appendBytes:(const char *)&(buff[x]) length:1];
                        } else {
                            if ([self.info length] > 1) {
                                const unsigned char *byte = (const unsigned char *)[self.info bytes];
                                NSRange rngl = NSMakeRange(1, [self.info length] - 1);
                                NSData *subd = [self.info subdataWithRange:rngl];
                                NSString *strs = [[NSString alloc] initWithData:subd encoding:NSUTF8StringEncoding];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (byte[0] == '0') {
                                        if (self.wino != nil) {
                                            [self.wino setTitle:strs];
                                        }
                                    }
                                    if (byte[0] == '1') {
                                        if (self.tcon != nil) {
                                            [self.tcon tabt:strs indx:self.vidx.intValue];
                                        }
                                    }
                                });
                            }
                            self.flag = @(9);
                            NSLog(@"AEND [%d][%d] [%d][%d]", x, buff[x], self.skip.intValue, self.flag.intValue);
                        }
                        //NSLog(@"ALET [%d][%d] [%d][%d]", x, buff[x], self.skip.intValue, self.flag.intValue);
                    } else if (self.skip.intValue == 3) {
                        if (('0' <= buff[x]) && (buff[x] <= '9')) {
                            /* ![?01234h */
                        } else {
                            self.skip = @(9);
                        }
                        [self.info appendBytes:(const char *)&(buff[x]) length:1];
                        NSLog(@"SKIP [%d][%d] [%d][%d]", x, buff[x], self.skip.intValue, self.flag.intValue);
                    } else if (self.flag.intValue == 2) {
                        if (buff[x] == ';') {
                            self.flag = @(3);
                        } else if (('0' <= buff[x]) && (buff[x] <= '9')) {
                            /* !]0;... */
                            [self.info appendBytes:(const char *)&(buff[x]) length:1];
                        } else {
                            NSLog(@"AERR [%d][%d] [%d][%d]", x, buff[x], self.skip.intValue, self.flag.intValue);
                            self.flag = @(0);
                            self.skip = @(9);
                        }
                        if (self.flag.intValue != 0) {
                            NSLog(@"ABEG [%d][%d] [%d][%d]", x, buff[x], self.skip.intValue, self.flag.intValue);
                        }
                    } else if (self.skip.intValue == 2) {
                        if (('?' <= buff[x]) && (buff[x] <= '~')) {
                            if (buff[x] == '?') {
                                self.skip = @(3);
                            } else {
                                NSLog(@"ENDS [%d][%d] [%d][%d]", x, buff[x], self.skip.intValue, self.flag.intValue);
                                self.skip = @(9);
                            }
                        }
                    } else if (self.skip.intValue == 1) {
                        if (buff[x] == ']') {
                            self.flag = @(2);
                        }
                        self.skip = @(2);
                        NSLog(@"AMOD [%d][%d] [%d][%d]", x, buff[x], self.skip.intValue, self.flag.intValue);
                    } else if (buff[x] == 7) {
                        NSLog(@"BELL [%d][%d] [%d][%d]", x, buff[x], self.skip.intValue, self.flag.intValue);
                        self.flag = @(9);
                        self.skip = @(9);
                    }
                    if ((self.skip.intValue == 0) && (self.flag.intValue == 0)) {
                        if (alen > 0) {
                            for (int y = 0; y < alen; ++y) {
                                if (dlen > maxr) {
                                    NSLog(@"OUTP DLEN [%ld[%ld]", dlen, maxr);
                                } else {
                                    data[dlen] = ansi[y]; ++dlen;
                                }
                            }
                            NSLog(@"HOLD [%ld] [%d][%d] [%d][%d]", alen, x, buff[x], self.skip.intValue, self.flag.intValue);
                            alen = 0;
                        }
                        if (dlen > maxr) {
                            NSLog(@"OUTP DLEN [%ld[%ld]", dlen, maxr);
                        } else {
                            data[dlen] = buff[x]; ++dlen;
                        }
                        if (buff[x] == 10) {
                            @synchronized (self) {
                                vterm_input_write(self.term, (const char *)data, dlen);
                                dlen = 0;
                            }
                            NSString *info = [self gout:1];
                            [self comp:info];
                        }
                    } else {
                        if (alen > maxr) {
                            NSLog(@"OUTP ALEN [%ld[%ld]", alen, maxr);
                            self.flag = @(9);
                        } else {
                            ansi[alen] = buff[x]; ++alen;
                        }
                    }
                    if (self.flag.intValue >= 9) {
                        self.flag = @(0);
                        self.skip = @(0);
                        alen = 0;
                    }
                    if (self.skip.intValue >= 9) {
                        NSLog(@"ANSI COMD [%@]", self.info);
                        NSString *acmd = [[NSString alloc] initWithData:self.info encoding:NSUTF8StringEncoding];
                        if ([acmd isEqualToString:@"1049h"]) {
                            NSLog(@"ANSI MODE");
                            self.mode = @(2);
                        }
                        self.skip = @(0);
                    }
                }
            } else {
                bcopy(buff, data, leng); dlen = leng;
            }
            if (alen > 0) {
                for (int y = 0; y < alen; ++y) {
                    if (dlen > maxr) {
                        NSLog(@"OUTP DLEN [%ld[%ld]", dlen, maxr);
                    } else {
                        data[dlen] = ansi[y]; ++dlen;
                    }
                }
                NSLog(@"HOLD [%ld] [%d][%d]", alen, self.skip.intValue, self.flag.intValue);
                alen = 0;
            }
            if (dlen > 0) {
                @synchronized (self) {
                    vterm_input_write(self.term, (const char *)data, dlen);
                    dlen = 0;
                }
            }
        }
    }
    return 0;
}

- (int)inpt:(NSEvent *)objc indx:(int)indx {
    if ([self chkf] != 0) { return 1; }
    if (self.vcon == nil) { return 2; }

    int zidx, iidx = self.indx.intValue;
    char byte;
    NSString *chrs = @"";

    // todo limit inpt length to 5 * self.cols.int and drop chars

    if ((objc != nil) && ([objc.characters length] > 0)) {
        chrs = objc.characters;
        NSEventModifierFlags flag = [objc modifierFlags];
        int code = [chrs characterAtIndex:0];
        int codc = objc.keyCode;
        int comd = (flag & NSEventModifierFlagCommand) ? 1 : 0;
        NSLog(@"INPT [%@][%ld] [%d][%d] [%d] [%d]{%d}", chrs, [chrs length], comd, codc, indx, iidx, code);
        VTermModifier mods = VTERM_MOD_NONE;
        if (flag & NSEventModifierFlagShift)   mods |= VTERM_MOD_SHIFT;
        if (flag & NSEventModifierFlagControl) mods |= VTERM_MOD_CTRL;
        if (flag & NSEventModifierFlagOption)  mods |= VTERM_MOD_ALT;
        VTermKey keyc = VTERM_KEY_NONE;
        switch (codc) {
            case 126: keyc = VTERM_KEY_UP;    break;
            case 125: keyc = VTERM_KEY_DOWN;  break;
            case 124: keyc = VTERM_KEY_RIGHT; break;
            case 123: keyc = VTERM_KEY_LEFT;  break;
        }
        size_t leng = [chrs length];
        if (code == 3) {
            NSLog(@"INPT int");
            //kill(self.pidn.intValue, SIGINT);
            byte = code;
            write(self.mfdn.intValue, &byte, 1);
            self.skip = @(0);
        } else if (code == 27) {
            NSLog(@"INPT esc");
            byte = code;
            write(self.mfdn.intValue, &byte, 1);
            self.skip = @(0);
        } else if (code == 9) {
            NSLog(@"INPT tab");
            byte = code;
            write(self.mfdn.intValue, &byte, 1);
            self.skip = @(0);
        } else if ((flag & NSEventModifierFlagControl) && (code == 4)) {
            NSLog(@"INPT eot");
            byte = code;
            write(self.mfdn.intValue, &byte, 1);
        } else if ((flag & NSEventModifierFlagControl) && (code == 18)) {
            NSLog(@"INPT rev");
            byte = code;
            write(self.mfdn.intValue, &byte, 1);
        } else if ((flag & NSEventModifierFlagControl) && (code == 26)) {
            NSLog(@"INPT bgp");
            byte = code;
            write(self.mfdn.intValue, &byte, 1);
        } else if (keyc != VTERM_KEY_NONE) {
            NSLog(@"TERM KEYC");
            vterm_keyboard_key(self.term, keyc, mods);
        } else {
            for (int i = 0; i < leng; ++i) {
                byte = [chrs characterAtIndex:i];
                if ((byte == 8) || (byte == 127)) {
                    NSLog(@"INPT backspace");
                }
                vterm_keyboard_unichar(self.term, byte, mods);
            }
        }
        if (code == 13) {
            self.irow = @(0); self.icol = @(0);
        }
        leng = vterm_output_get_buffer_remaining(self.term);
        if (leng > 0) {
            char *data = malloc(leng);
            if (data != NULL) {
                size_t rlen = vterm_output_read(self.term, data, leng);
                write(self.mfdn.intValue, data, rlen);
                free(data);
            }
        }
    }
    int cidx = ((self.irow.intValue << 16) | (self.ccol.intValue + 0));
    NSString *disp = [self gout:0];
    NSString *subs = ([disp length] > 1) ? [disp substringFromIndex:1] : @"";
    //subs = [NSString stringWithFormat:@"%@ ", subs];
    if (self.mode.intValue == 2) {
        subs = [NSMutableString stringWithFormat:@""];
    }
    //NSLog(@"INPS [%d] [%d][%d] [%d][%d] [%ld]", self.vidx.intValue, self.irow.intValue, self.icol.intValue, self.crow.intValue, self.ccol.intValue, [subs length]);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.vcon show:subs indx:self.vidx.intValue sels:0 cidx:cidx rows:self.rows.intValue cols:self.cols.intValue];
    });
    return 0;
}

- (void)winz:(NSString *)text wide:(CGFloat)wide high:(CGFloat)high {
    int indx = self.indx.intValue;
    int fdes = self.mfdn.intValue;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tcon sets:text wide:wide high:high];
        CGFloat pixw = MAX( 4.0, self.tcon.fntw.floatValue);
        CGFloat pixh = MAX(12.0, self.tcon.fnth.floatValue);
        int rows = ((int)((high / pixh) - 7)); rows = MAX(9, rows);
        int cols = ((int)((wide / pixw) - 7)); cols = MAX(9, cols);
        int size = ((rows + 3) * (cols + 3));
        struct winsize wsiz;
        wsiz.ws_row = rows;
        wsiz.ws_col = cols;
        //wsiz.ws_col = MAGC;
        wsiz.ws_xpixel = 0;
        wsiz.ws_ypixel = 0;
        ioctl(fdes, TIOCSWINSZ, &wsiz);
        self.rows = @(rows);
        self.cols = @(cols);
        NSLog(@"WINZ [%d][%@] [%f][%f] [%d][%d] [%f][%f] [%d]", indx, text, wide, high, cols, rows, pixw, pixh, size);
        @synchronized (self) {
            if (self.term == nil) {
                self.term = vterm_new(rows, cols);
                vterm_set_utf8(self.term, 1);
                self.vtsc = vterm_obtain_screen(self.term);
                vterm_screen_reset(self.vtsc, 1);
                static VTermScreenCallbacks cb = {
                    .damage     = screen_damage,
                    .movecursor = screen_movecursor,
                    .settermprop = screen_settermprop,
                };
                vterm_screen_set_callbacks(self.vtsc, &cb, (__bridge void *)(self));
            }
            vterm_set_size(self.term, rows, cols);
            //vterm_set_size(self.term, rows, MAGC);
        }
        if (size > [self.ansi length]) {
            [self.ansi setLength:size];
        }
        if (size > [self.ansp length]) {
            [self.ansp setLength:size];
        }
        self.vcon = self.tcon;
        [self inpt:nil indx:indx];
    });
}

- (int)opty {
    int mfdn, sfdn;
    char name[128];
    char *args[] = {"/bin/bash", "-i", "-l", NULL};
    char *cmds[] = {"stty raw isig echo \n", NULL};
    pid_t pidn;
    struct termios ttys;
    setenv("TERM", "xterm-256color", 1);
    if (openpty(&mfdn, &sfdn, name, NULL, NULL) < 0) {
        NSLog(@"ERRO opty");
        return 0;
    }
    pidn = fork();
    self.mfdn = @(mfdn);
    self.sfdn = @(sfdn);
    self.pidn = @(pidn);
    if (pidn == 0) {
        close(mfdn);
        setsid();
        ioctl(sfdn, TIOCSCTTY, 1);
        dup2(sfdn, STDIN_FILENO);
        dup2(sfdn, STDOUT_FILENO);
        dup2(sfdn, STDERR_FILENO);
        close(sfdn);
        execv(args[0], args);
    } else {
        close(sfdn);
        tcgetattr(mfdn, &ttys);
        ttys.c_iflag &= ~(IGNBRK | IGNCR | IGNPAR | INLCR | INPCK | ISTRIP | PARMRK | IXOFF);
        ttys.c_iflag |=  (BRKINT | ICRNL | IXON | IUTF8);
        ttys.c_lflag &= ~(ECHO);
        ttys.c_lflag |=  (ECHO | ICANON | IEXTEN | ISIG);
        ttys.c_oflag &= ~(OPOST);
        ttys.c_oflag |=  (OPOST);
        ttys.c_cflag &= ~(CSIZE | PARENB);
        ttys.c_cflag |=  (CS8);
        tcsetattr(mfdn, TCSANOW, &ttys);
        for (int x = 0; x < 9; ++x) {
            if (cmds[x] == NULL) { break; }
        }
        //close(mfdn);
    }
    return 1;
}

- (void)initProc:(ViewController *)vcon indx:(int)indx wide:(CGFloat)wide high:(CGFloat)high wino:(NSWindow *)wino {
    self.vidx = @-1;
    self.indx = @(indx);
    self.trys = @0;

    self.pidn = @0;
    self.mfdn = @0;
    self.sfdn = @0;
    self.rows = @0;
    self.cols = @0;

    self.mode = @0;
    self.skip = @0;
    self.flag = @0;

    self.crow = @0;
    self.ccol = @0;
    self.irow = @0;
    self.icol = @0;

    self.ansi = [[NSMutableData alloc] init];
    self.ansp = [[NSMutableData alloc] init];
    self.info = [[NSMutableData alloc] init];

    self.hist = [[NSMutableArray alloc] init];

    self.wino = wino;
    self.tcon = vcon;
    self.vcon = nil;

    self.term = nil;
    self.vtsc = nil;

    [self opty];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self outp:nil];
    });

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self inpt:nil indx:1];
    });

    dispatch_async(dispatch_get_main_queue(), ^{
        self.vidx = @([self.tcon newt:nil wide:wide high:high]);
        [self winz:@"newt" wide:wide high:high];
    });

    NSLog(@"PROC [%d][%d] [%d] [%f][%f]", self.sfdn.intValue, self.mfdn.intValue, self.pidn.intValue, wide, high);
}

- (instancetype)init {
    self = [super init];
    return self;
}

@end

//NS_ASSUME_NONNULL_END
