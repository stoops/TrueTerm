//
//  MainProc.m
//  TrueTerm
//
//  Created by jon on 2026-06-05.
//
// todo: colors, regx search, window style, window state, move tabs, multi tabs, multi windows, tab titles, sys stats live bar (ram, cpu, ssd, net, iot bps), double click highlight seperator, auto copy text select

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

//NS_ASSUME_NONNULL_BEGIN

@implementation MainProc

- (void)loop:(NSTimer *)timo {
    int last = 0;
    while (1) {
        int temp = self.wdrf.intValue;
        NSLog(@"TIME [%d][%d]", last, temp);
        if (temp > 0) {
            if (last == temp) {
                last = 0;
                self.wdrf = @0;
            } else { last = temp; }
        }
        sleep(1);
    }
}

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

- (int)gidx:(int)mode {
    int i = 0, j = 0, k = 0, z = 0;
    const unsigned char *q = [self.ansp bytes];
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
    if ((z >= self.ansi.length) || (z >= self.ansp.length)) {
        NSLog(@"INDX [%d] [%ld][%ld", z, self.ansi.length, self.ansp.length);
        z = 0;
    }
    return z;
}

- (NSString *)gout:(int)mode {
    int i = 0, j = 0;
    const unsigned char *p = [self.ansi bytes];
    const unsigned char *q = [self.ansp bytes];
    NSString *a = @"";
    if (self.ansi.length > (self.rows.intValue * self.cols.intValue)) {
        if (mode == 0) {
            for (int r = 0; r < (self.rows.intValue - 1); ++r) {
                for (int c = 0; c < (self.cols.intValue - 1); ++c) {
                    i = ((r * (self.cols.intValue - 1)) + c);
                    if ([self visi:p[i] extr:1] > 0) {
                        a = [NSString stringWithFormat:@"%@%c", a, p[i]];
                    } else {
                        a = [NSString stringWithFormat:@"%@ ", a];
                    }
                }
                a = [NSString stringWithFormat:@"%@\n", a];
            }
        }
        if (mode == 1) {
            for (int r = 0; r < (self.rows.intValue - 1); ++r) {
                for (int c = 0; c < (self.cols.intValue - 1); ++c) {
                    i = ((r * (self.cols.intValue - 1)) + c);
                    if ((q[i] != 0) && (q[i] != 1)) {
                        if ((j > 0) && ((j % (self.cols.intValue - 1)) == 0)) {
                            a = [NSString stringWithFormat:@"%@\n", a];
                        }
                        a = [NSString stringWithFormat:@"%@%c", a, q[i]];
                        ++j;
                    }
                }
            }
        }
    }
    return a;
}

- (int)ginc:(int)mode {
    int rowv = self.crow.intValue;
    int colv = self.ccol.intValue;
    colv = ((colv + 1) % (self.cols.intValue - 1));
    if (colv == 0) {
        if ((rowv == (self.rows.intValue - 2)) && (mode == 1)) {
            return 1;
        }
        rowv = ((rowv + 1) % (self.rows.intValue - 1));
        if ((rowv == 0) && (mode == 0)) {
            unsigned long leng = self.ansi.length;
            unsigned long last = (self.cols.intValue - 1);
            unsigned long diff = (leng - last);
            const unsigned char *pntr = [self.ansi bytes];
            unsigned char dest[leng];
            NSLog(@"ANSI SHIF [%ld][%ld] [%ld]", diff, last, leng);
            if (leng > last) {
                pntr += last;
                bzero(dest, leng); bcopy(pntr, dest, diff);
                [self.ansi replaceBytesInRange:NSMakeRange(0, leng) withBytes:dest length:leng];
            }
            rowv = ((self.rows.intValue - 1) - 1);
        }
    }
    self.crow = @(rowv);
    self.ccol = @(colv);
    return 0;
}

- (void)endl:(int)offs {
    int flag = 0;
    if (self.swap.intValue != 0) {
        self.ccol = @1;
    }
    int aidx = ((self.crow.intValue * (self.cols.intValue - 1)) + self.ccol.intValue);
    int zidx = (((self.rows.intValue - 1) * (self.cols.intValue - 1)) + ((self.cols.intValue - 1) - 1));
    for (int z = 0; z < self.rets.count; ++z) {
        int ridx = [self.rets objectAtIndex:z].intValue;
        int rrow = (ridx / 10000), rcol = (ridx % 10000);
        int cidx = ((rrow * (self.cols.intValue - 1)) + rcol);
        if (cidx > aidx) {
            zidx = cidx;
            flag = 1;
            break;
        }
    }
    if (aidx < 1) {
        aidx = 1;
    }
    int leng = ((zidx - aidx) - 1);
    NSLog(@"ENDL [%d][%d] [%d] [%d][%d] [%d]", self.crow.intValue, self.ccol.intValue, offs, aidx, zidx, leng);
    if (leng > 0) {
        unsigned char zero[leng];
        bzero(zero, leng);
        [self.ansp replaceBytesInRange:NSMakeRange(aidx, leng) withBytes:zero length:leng];
    }
    if (flag == 0) {
        if ((self.bins.intValue == 0) && (self.bend.intValue == 0)) {
            if (self.mode.intValue == 0) {
                self.crow = @0; self.ccol = @1;
            }
            if (self.mode.intValue == 1) {
                self.ccol = @0;
            }
        }
    }
    self.last = @-2;
}

- (void)zero:(int)mode {
    if (mode == 0) { // rta + lta + ent
        if ((self.bins.intValue == 1) || (self.bend.intValue == 1)) {
            if (self.rets.count > 0) {
                int ridx = [self.rets objectAtIndex:0].intValue;
                int rrow = (ridx / 10000), rcol = (ridx % 10000);
                int bidx = ((rrow * (self.cols.intValue - 1)) + rcol);
                int aidx = 1;
                if (bidx > aidx) {
                    int leng = ((bidx - aidx) + 1);
                    unsigned char q[leng];
                    bzero(q, leng);
                    [self.ansp replaceBytesInRange:NSMakeRange(aidx, leng) withBytes:q length:leng];
                }
            }
            self.crow = @1; self.ccol = @1;
            self.bins = @2; self.bend = @2;
        }
        self.last = @-2;
        self.newl = @0; self.swap = @0;
    }
    if (mode == 1) { // new + ctc
        self.crow = @0; self.ccol = @0;
        //[self.ansp resetBytesInRange:NSMakeRange(0, self.ansp.length)];
        self.bins = @0; self.bend = @0;
        [self.rets removeAllObjects];
        self.last = @-3;
        self.newl = @1; self.swap = @1;
    }
    if (mode == 3) { // upa + dna
        if (self.bins.intValue == 0) {
            [self.rets removeAllObjects];
            [self.rets addObject:@0];
            self.bend = @1;
        }
        self.last = @-1;
        self.newl = @0; self.swap = @0;
    }
    if (mode == 18) { // ctr
        if (self.bins.intValue == 0) {
            [self.rets removeAllObjects];
            [self.rets addObject:@10000];
            self.crow = @1; self.ccol = @1;
            self.bins = @1;
        }
        self.last = @-1;
        self.newl = @0; self.swap = @0;
    }
    if (mode == 99) { // any
        self.last = @-1;
        self.newl = @0; self.swap = @0;
    }
}

- (int)proc:(int)stat {
    int sync = 0;
    if ((stat & ANSI_RETD) != 0) {
        sync = 1;
    }
    if ((stat & ANSI_EEND) != 0) {
        int offs = 0;
        [self endl:offs];
    }
    if ((stat & ANSI_BEND) != 0) {
        NSString *buff = [NSString stringWithCString:[self.esci bytes] encoding:NSUTF8StringEncoding];
        int offs = [buff intValue];
        [self endl:offs];
        self.esci = [[NSMutableData alloc] init];
    }
    if ((stat & ANSI_BINS) != 0) {
        // todo check if last byte is not 0 and insert into beg of next row below call with function
        NSString *buff = [NSString stringWithCString:[self.esci bytes] encoding:NSUTF8StringEncoding];
        int offs = [buff intValue];
        NSLog(@"BINS [%d][%d] [%d]", self.crow.intValue, self.ccol.intValue, offs);
        if (offs >= 1) {
            int cidx = ((self.crow.intValue * (self.cols.intValue - 1)) + self.ccol.intValue);
            unsigned char q[offs];
            bzero(q, offs);
            [self.ansp replaceBytesInRange:NSMakeRange(cidx, 0) withBytes:q length:offs];
            for (int z = 0; z < self.rets.count; ++z) {
                int ridx = [self.rets objectAtIndex:z].intValue;
                int rrow = (ridx / 10000), rcol = (ridx % 10000);
                int aidx = ((rrow * (self.cols.intValue - 1)) + rcol);
                if (aidx >= cidx) {
                    if ((rcol + 1) < (self.cols.intValue - 1)) {
                        ++rcol;
                    } else if ((rrow + 1) < (self.rows.intValue - 1)) {
                        ++rrow; rcol = 0;
                    } else {
                        rrow = 0; rcol = 0;
                    }
                    ridx = ((rrow * 10000) + rcol);
                    [self.rets replaceObjectAtIndex:z withObject:@(ridx)];
                    NSLog(@"BINS RETS [%@]", self.rets);
                }
            }
        }
        self.esci = [[NSMutableData alloc] init];
    }
    if ((stat & ANSI_BAUP) != 0) {
        NSLog(@"BAUP [%d][%d]", self.crow.intValue, self.ccol.intValue);
        int bidx = ((self.crow.intValue * (self.cols.intValue - 1)) + self.ccol.intValue);
        int srow = self.crow.intValue, scol = self.ccol.intValue;
        int leng = (((int)self.rets.count) - 1);
        for (int z = leng; z >= 0; --z) {
            int ridx = [self.rets objectAtIndex:z].intValue;
            int rrow = (ridx / 10000), rcol = (ridx % 10000);
            int aidx = ((rrow * (self.cols.intValue - 1)) + rcol);
            if ((aidx < bidx) && (z > 0)) {
                int diff = (bidx - aidx);
                ridx = [self.rets objectAtIndex:z-1].intValue;
                rrow = (ridx / 10000); rcol = (ridx % 10000);
                int cidx = ((rrow * (self.cols.intValue - 1)) + rcol);
                int didx = (cidx + diff);
                srow = (didx / (self.cols.intValue - 1));
                scol = (didx % (self.cols.intValue - 1));
                break;
            }
        }
        if (srow == self.crow.intValue) {
            scol = 1;
        }
        NSLog(@"BAUP RETS [%d][%d] -> [%d][%d] [%@]", self.crow.intValue, self.ccol.intValue, srow, scol, self.rets);
        self.crow = @(srow); self.ccol = @(scol);
    }
    return sync;
}

- (int)pars:(unsigned char)inpt {
    int retn = ANSI_RETZ;
    unsigned char byte = inpt;
    if ((self.escs.intValue == ANSI_SNOP) && (byte == 0x1b)) {
        //NSLog(@"ANSI beg");
        [self.escd appendBytes:&(byte) length:1]; self.escs = @(ANSI_SBEG);
        retn |= ANSI_RETA;
    } else if ((self.escs.intValue == ANSI_SBEG) && ((byte == 0x3d) || (byte == 0x5b) || (byte == 0x5d))) {
        if (byte == 0x3d) {
            self.crow = @0; self.ccol = @0;
            NSLog(@"ANSI less_reset_row_col");
            self.less = @1;
            self.escs = @(ANSI_SNOP);
            self.escd = [[NSMutableData alloc] init];
        }
        if (byte== 0x5b) {
            self.escs = @(ANSI_SARG);
            [self.escd appendBytes:&(byte) length:1];
        }
        if (byte== 0x5d) {
            self.escs = @(ANSI_SDAT);
            [self.escd appendBytes:&(byte) length:1];
        }
        retn |= ANSI_RETB;
    } else if (((self.escs.intValue == ANSI_SARG) || (self.escs.intValue == ANSI_SDAT)) && (((byte== ';') || (byte == '?') || (byte == '=') || (byte == '@') || (byte == '<') || (byte == '>')) || (('0' <= byte) && (byte <= '9')))) {
        [self.escd appendBytes:&(byte) length:1];
        const unsigned char *clrs = self.escd.bytes;
        long clen = self.escd.length;
        if ((clen > 3) && (clrs[clen-1] == '@')) {
            self.esci = [[self.escd subdataWithRange:NSMakeRange(2, clen-3)] mutableCopy];
            NSString *subs = [NSString stringWithCString:[self.esci bytes] encoding:NSUTF8StringEncoding];
            NSLog(@"ANSI bash_cursor_insert_bytes [%@] [%c] [%@]", self.escd, byte, subs);
            self.escs = @(ANSI_SNOP);
            self.escd = [[NSMutableData alloc] init];
            retn |= ANSI_BINS;
        }
        retn |= ANSI_RETC;
    } else if (((self.escs.intValue == ANSI_SARG) || (self.escs.intValue == ANSI_SEND)) && ((('a' <= byte) && (byte <= 'z')) || (('A' <= byte) && (byte <= 'Z')))) {
        [self.escd appendBytes:&(byte) length:1];
        const unsigned char *clrs = self.escd.bytes;
        long clen = self.escd.length;
        if (byte == 'l') {
            self.mode = @0;
            self.less = @0;
            NSLog(@"ANSI screen_set_reset_mode");
        } else if (byte != 'm') {
            NSLog(@"ANSI last [%ld][%@] [%c]", clen, self.escd, byte);
        }
        if ((clen > 2) && (clrs[0] == 0x1b) && (clrs[1] == 0x5b)) {
            if (clrs[2] == 'A') {
                NSLog(@"ANSI bash_cursor_move_up");
                retn |= ANSI_BAUP;
            } else if (clrs[2] == 'H') {
                self.crow = @0; self.ccol = @0;
                NSLog(@"ANSI move_cursor_home_position");
                self.mode = @1;
            } else if (clrs[2] == 'J') {
                NSLog(@"ANSI erase_display_screen_end");
                [self.ansi resetBytesInRange:NSMakeRange(0, [self.ansi length])];
                self.mode = @1;
            } else if (clrs[2] == 'K') {
                int rowv = self.crow.intValue, colv = self.ccol.intValue;
                int indx = [self gidx:0];
                NSLog(@"ANSI erase_display_line_end [%d][%d]:[%d]", rowv, colv, indx);
                retn |= ANSI_EEND;
            }
            if ((clen > 3) && (clrs[clen-1] == 'A')) {
                NSLog(@"ANSI move_cursor_up_lines");
                self.mode = @1;
            } else if ((clen > 3) && (clrs[clen-1] == 'B')) {
                NSLog(@"ANSI move_cursor_down_lines");
                self.mode = @1;
            } else if ((clen > 3) && (clrs[clen-1] == 'C')) {
                NSLog(@"ANSI move_cursor_right_columns");
                self.mode = @1;
            } else if ((clen > 3) && (clrs[clen-1] == 'D')) {
                NSLog(@"ANSI move_cursor_left_columns");
                self.mode = @1;
            } else if ((clen > 3) && (clrs[clen-1] == 'E')) {
                NSLog(@"ANSI move_cursor_beg_lsdown");
                self.mode = @1;
            } else if ((clen > 3) && (clrs[clen-1] == 'F')) {
                NSLog(@"ANSI move_cursor_beg_lsup");
                self.mode = @1;
            } else if ((clen > 3) && (clrs[clen-1] == 'G')) {
                NSLog(@"ANSI move_cursor_col_number");
                self.mode = @1;
            } else if ((clen > 3) && (clrs[clen-1] == 'H')) {
                NSData *subd = [self.escd subdataWithRange:NSMakeRange(2, clen-3)];
                NSString *subs = [NSString stringWithCString:[subd bytes] encoding:NSUTF8StringEncoding];
                NSArray *subl = [subs componentsSeparatedByString:@";"];
                int rown = 0, coln = 0;
                if (subl.count > 1) { rown = [subl[0] intValue]; coln = [subl[1] intValue]; }
                int rowv = (MIN(MAX(1, rown), self.rows.intValue) - 1);
                int colv = (MIN(MAX(1, coln), self.cols.intValue) - 1);
                self.crow = @(rowv); self.ccol = @(colv);
                int indx = [self gidx:0];
                NSLog(@"ANSI move_cursor_r_c [%d][%d]:[%d]", rowv, colv, indx);
                self.mode = @1;
            } else if ((clen > 3) && (clrs[clen-1] == 'J')) {
                if (clrs[2] == '0') {
                    NSLog(@"ANSI erase_display_screen_end");
                    self.mode = @1;
                } else if (clrs[2] == '1') {
                    NSLog(@"ANSI erase_display_screen_beg");
                    self.mode = @1;
                } else if (clrs[2] == '2') {
                    NSLog(@"ANSI erase_display_screen_clear");
                    self.mode = @1;
                } else {
                    NSLog(@"ANSI erase_display_screen_???");
                    self.mode = @1;
                }
            } else if ((clen > 3) && (clrs[clen-1] == 'K')) {
                if (clrs[2] == '0') {
                    NSLog(@"ANSI erase_display_line_end");
                    self.mode = @1;
                } else if (clrs[2] == '1') {
                    NSLog(@"ANSI erase_display_line_beg");
                    self.mode = @1;
                } else if (clrs[2] == '2') {
                    NSLog(@"ANSI erase_display_line_clear");
                    self.mode = @1;
                } else {
                    NSLog(@"ANSI erase_display_line_???");
                    self.mode = @1;
                }
            } else if ((clen > 3) && (clrs[clen-1] == 'P')) {
                self.esci = [[self.escd subdataWithRange:NSMakeRange(2, clen-3)] mutableCopy];
                NSString *subs = [NSString stringWithCString:[self.esci bytes] encoding:NSUTF8StringEncoding];
                NSLog(@"ANSI bash_erase_line_ending [%@]", subs);
                retn |= ANSI_BEND;
            }
        }
        self.escs = @(ANSI_SNOP);
        self.escd = [[NSMutableData alloc] init];
        retn |= ANSI_RETD;
    } else if (((self.escs.intValue == ANSI_SDAT) || (self.escs.intValue == ANSI_SMOR)) && (self.escd.length > 2)) {
        const unsigned char *pntr = self.escd.bytes;
        if (self.escs.intValue == ANSI_SDAT) {
            self.escs = @(ANSI_SMOR);
        }
        if (byte != 0x07) {
            [self.esci appendBytes:&(byte) length:1];
        } else {
            [self.esci appendBytes:&(pntr[2]) length:1];
            self.escs = @(ANSI_SNOP);
            self.escd = [[NSMutableData alloc] init];
            retn |= ANSI_DATA;
        }
        retn |= ANSI_RETE;
    }
    return retn;
}

- (int)outp:(NSTimer *)objc {
    int plen = 0, last = 0, stat = 0, sync = 0;
    unsigned long hlen = 0;
    unsigned char swap = 1;
    unsigned char buff[9000], prep[9000];
    const unsigned char *pntr;
    while (1) {
        if ([self chkf] != 0) { return 1; }
        if (self.vcon == nil) { usleep(357000); continue; }
        int fdes = self.mfdn.intValue;
        fd_set rfds;
        struct timeval timo;
        FD_ZERO(&rfds);
        FD_SET(fdes, &rfds);
        timo.tv_sec = 0;
        timo.tv_usec = 35700;
        select(fdes + 1, &rfds, NULL, NULL, &timo);
        if ([self chkf] != 0) { return 3; }
        if (!FD_ISSET(fdes, &rfds)) {
            if (self.mode.intValue == 0) {
                if (self.trys.intValue != 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        int retn = [self.vcon show:nil indx:self.vidx.intValue sels:1 cidx:0 rows:self.rows.intValue cols:self.cols.intValue];
                        if (self.trys.intValue > 0) {
                            self.trys = @(self.trys.intValue - 1);
                        }
                        self.trys = @(self.trys.intValue + retn);
                    });
                }
            }
            continue;
        }
        ssize_t leng = read(fdes, buff, 8192);
        if (leng < 1) {
            close(self.mfdn.intValue);
            self.mfdn = nil;
            NSLog(@"OUTP fin");
            return 2;
        }
        plen = 0; sync = 0;
        hlen = self.hist.count;
        for (int x = 0; x < leng; ++x) {
            plen = 0;
            stat = [self pars:buff[x]];
            if ((stat & ANSI_DATA) != 0) {
                if (self.esci.length > 0) {
                    const unsigned char *pntr = self.esci.bytes;
                    long leng = (self.esci.length - 1);
                    NSString *strs = [NSString stringWithCString:[self.esci bytes] encoding:NSUTF8StringEncoding];
                    if ((1 < strs.length) && (strs.length < 96)) {
                        strs = [strs substringToIndex:strs.length - 1];
                        if (self.vcon != nil) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (pntr[leng] == 0x30) {
                                    NSLog(@"WINT [%@]", strs);
                                    [self.wino setTitle:strs];
                                }
                                if (pntr[leng] == 0x31) {
                                    [self.vcon tabt:strs indx:self.vidx.intValue];
                                }
                            });
                        }
                    }
                    self.esci = [[NSMutableData alloc] init];
                }
            } else if (stat != ANSI_RETZ) {
                sync |= [self proc:stat];
            } else {
                pntr = self.escd.bytes;
                if (self.escd.length > 0) {
                    for (int y = 0; y < self.escd.length; ++y) {
                        NSLog(@"PREP [%d][%d]-[%d]", y, pntr[y], buff[x]);
                        prep[plen] = pntr[y]; ++plen;
                    }
                    self.escs = @(ANSI_SNOP);
                    self.escd = [[NSMutableData alloc] init];
                }
                prep[plen] = buff[x]; ++plen;
                for (int y = 0; y < plen; ++y) {
                    unsigned char byte = prep[y];
                    if (self.mode.intValue == 1) { // ansi
                        if (byte == 8) {
                            if (self.ccol.intValue > 0) {
                                self.ccol = @(self.ccol.intValue - 1);
                            } else if (self.crow.intValue > 0) {
                                self.crow = @(self.crow.intValue - 1);
                                self.ccol = @(self.cols.intValue - 2);
                            } else {
                                self.crow = @0;
                                self.ccol = @0;
                            }
                            NSLog(@"ANSI BACK [%d][%d]", self.crow.intValue, self.ccol.intValue);
                            continue;
                        }
                        if (byte == 10) {
                            NSLog(@"ANSI NEWL [%d][%d]", self.crow.intValue, self.ccol.intValue);
                            if (self.crow.intValue < ((self.rows.intValue - 1) - 1)) {
                                self.crow = @(self.crow.intValue + 1);
                            }
                            self.ccol = @0;
                            continue;
                        }
                        if (byte == 13) {
                            NSLog(@"ANSI SWAP [%d][%d]", self.crow.intValue, self.ccol.intValue);
                            continue;
                        }
                        if ([self visi:byte extr:1] > 0) {
                            int indx = [self gidx:0];
                            //NSLog(@"ANSI READ [%d][%d] [%d][%c]", self.crow.intValue, self.ccol.intValue, indx, byte);
                            [self.ansi replaceBytesInRange:NSMakeRange(indx, 1) withBytes:&(byte) length:1];
                            [self ginc:0];
                            sync = 1;
                        } else {
                            int indx = [self gidx:0];
                            NSLog(@"ANSI XCHR [%d][%d]", indx, byte);
                        }
                    } else { // line
                        if (byte == 8) { // bsp
                            if (self.ccol.intValue > 0) {
                                self.ccol = @(self.ccol.intValue - 1);
                            } else if (self.crow.intValue > 0) {
                                self.crow = @(self.crow.intValue - 1);
                                self.ccol = @0;
                            } else {
                                self.crow = @0;
                                self.ccol = @0;
                            }
                            if ((self.crow.intValue == 0) && (self.ccol.intValue == 0)) {
                                self.ccol = @1;
                            }
                            NSLog(@"BACK [%d][%d]", self.crow.intValue, self.ccol.intValue);
                            self.newl = @0; self.swap = @0;
                            continue;
                        }
                        if (byte == 10) { // new
                            NSLog(@"NEWL [%d][%d] [%d][%d]-[%d]", self.crow.intValue, self.ccol.intValue, self.bins.intValue, self.bend.intValue, self.last.intValue);
                            self.newl = @1;
                            if ((self.bins.intValue == 1) || (self.bend.intValue == 1)) {
                                int leng = (((int)self.rets.count) - 1);
                                int cidx = ((self.crow.intValue * 10000) + self.ccol.intValue);
                                for (int z = leng; z >=0 ; --z) {
                                    int ridx = [self.rets objectAtIndex:z].intValue;
                                    if (ridx > cidx) {
                                        [self.rets removeObjectAtIndex:z];
                                        NSLog(@"NEWL RETS [%@]", self.rets);
                                    }
                                }
                                if (self.last.intValue == -2) {
                                    self.last = @-3;
                                }
                                continue;
                            }
                            NSString *buff = [self gout:1];
                            [self.hist addObject:buff];
                            [self zero:1];
                            int indx = [self gidx:0];
                            [self.ansp replaceBytesInRange:NSMakeRange(indx, 1) withBytes:&(byte) length:1];
                            [self ginc:1];
                            continue;
                        }
                        if (byte == 13) { // ret
                            NSLog(@"SWAP [%d][%d] [%d][%d]-[%d]", self.crow.intValue, self.ccol.intValue, self.bins.intValue, self.bend.intValue, self.last.intValue);
                            int indx = [self gidx:0];
                            int rrow = self.crow.intValue, rcol = self.ccol.intValue;
                            self.swap = @1;
                            if ((self.bins.intValue == 2) || (self.bins.intValue == 3)) {
                                continue;
                            }
                            int flag = 0;
                            if ((self.last.intValue != -2) && (self.last.intValue != -3)) {
                                if (rcol > 0) {
                                    --rcol;
                                } else if (rrow > 0) {
                                    --rrow; rcol = ((self.cols.intValue - 1) - 1);
                                } else {
                                    rrow = 0; rcol = 0;
                                }
                            }
                            int retn = ((rrow * 10000) + rcol);
                            for (int z = 0; z < self.rets.count; ++z) {
                                int ridx = [self.rets objectAtIndex:z].intValue;
                                int rchk = (ridx / 10000), cchk = (ridx % 10000);
                                if ((rchk == rrow) && (cchk == rcol)) {
                                    flag = 1;
                                }
                            }
                            if (self.last.intValue == -1) {
                                self.crow = @1; self.ccol = @1;
                                //self.last = @0; // note ??
                            } else if (indx > 3) {
                                if (flag == 0) {
                                    [self.rets addObject:@(retn)];
                                    NSArray *sort = [self.rets sortedArrayUsingSelector:@selector(compare:)];
                                    self.rets = [sort mutableCopy];
                                    NSLog(@"RETS [%d][%d] [%d][%d] [%@]", self.crow.intValue, self.ccol.intValue, rrow, rcol, self.rets);
                                    int reti = ((rrow * (self.cols.intValue - 1)) + rcol);
                                    [self.ansp replaceBytesInRange:NSMakeRange(reti, 1) withBytes:&(swap) length:1];
                                }
                            }
                            continue;
                        }
                        if ([self visi:byte extr:1] > 0) { // vis
                            int indx = [self gidx:0];
                            for (int z = 0; z < self.rets.count; ++z) {
                                int ridx = [self.rets objectAtIndex:z].intValue;
                                int rrow = (ridx / 10000), rcol = (ridx % 10000);
                                if ((rrow == self.crow.intValue) && (rcol == self.ccol.intValue)) {
                                    if ((rcol + 1) < (self.cols.intValue - 1)) {
                                        ++rcol;
                                    } else if ((rrow + 1) < (self.rows.intValue - 1)) {
                                        ++rrow; rcol = 0;
                                    } else {
                                        rrow = 0; rcol = 0;
                                    }
                                    if (self.bins.intValue != 2) {
                                        if (indx > 3) {
                                            NSLog(@"READ RETS [%d] [%d][%d] -> [%d][%d] [%@]", z, self.crow.intValue, self.ccol.intValue, rrow, rcol, self.rets);
                                            [self.ansp replaceBytesInRange:NSMakeRange(indx, 1) withBytes:&(swap) length:1];
                                            self.crow = @(rrow); self.ccol = @(rcol);
                                        }
                                    }
                                }
                            }
                            last = ((self.crow.intValue * 10000) + self.ccol.intValue);
                            indx = [self gidx:0];
                            NSLog(@"READ [%d][%d] [%d][%c]", self.crow.intValue, self.ccol.intValue, indx, byte);
                            [self.ansp replaceBytesInRange:NSMakeRange(indx, 1) withBytes:&(byte) length:1];
                            [self ginc:1];
                            self.last = @(indx);
                            self.newl = @0; self.swap = @0;
                        } else { // all
                            int indx = [self gidx:0];
                            NSLog(@"XCHR [%d][%d]", indx, byte);
                            self.last = @(indx);
                            self.newl = @0; self.swap = @0;
                        }
                    }
                }
            }
        }
        if (hlen < self.hist.count) {
            NSString *buff = @"";
            for (unsigned long z = hlen; z < self.hist.count; ++z) {
                buff = [NSString stringWithFormat:@"%@%@", buff, self.hist[z]];
            }
            hlen = self.hist.count;
            //NSLog(@"OUTP [%@]", buff);
            dispatch_async(dispatch_get_main_queue(), ^{
                int retn = [self.vcon show:buff indx:self.vidx.intValue sels:1 cidx:0 rows:self.rows.intValue cols:self.cols.intValue];
                self.trys = @(self.trys.intValue + retn);
            });
        }
        if (self.mode.intValue == 1) {
            if (sync == 1) {
                int indx = [self gidx:0];
                NSString *disp = [self gout:0];
                //NSLog(@"ANSI [%d][%ld]", indx, disp.length);
                dispatch_async(dispatch_get_main_queue(), ^{
                    int retn = [self.vcon show:disp indx:self.vidx.intValue sels:2 cidx:indx rows:self.rows.intValue cols:self.cols.intValue];
                    self.trys = @(self.trys.intValue + retn);
                });
            }
        }
        int indx = [self gidx:1];
        [self inpt:nil indx:indx];
    }
    return 0;
}

- (int)inpt:(NSEvent *)objc indx:(int)indx {
    if ([self chkf] != 0) { return 1; }
    if (self.vcon == nil) { return 2; }
    NSString *chrs = @"";
    int iidx = self.indx.intValue;
    if ((objc != nil) && (objc.characters.length > 0)) {
        chrs = objc.characters;
        NSEventModifierFlags flag = [objc modifierFlags];
        int code = [chrs characterAtIndex:0];
        int codc = objc.keyCode;
        int mods = (flag & NSEventModifierFlagCommand) ? 1 : 0;
        NSLog(@"INPT [%@][%ld] [%d][%d] [%d] [%d]{%d}", chrs, chrs.length, mods, codc, indx, iidx, code);
        // todo page up down
        if (mods == 1) { // cmd
            chrs = @"";
        } else if (codc == 126) { // upa
            chrs = @"\e[A";
            if ((self.bins.intValue == 0) && (self.bend.intValue == 0)) {
                [self zero:3];
            }
            if (self.less.intValue > 0) {
                chrs = @"k";
            }
            if (self.bins.intValue > 0) {
                [self zero:0];
            }
        } else if (codc == 125) { // dna
            chrs = @"\e[B";
            if ((self.bins.intValue == 0) && (self.bend.intValue == 0)) {
                [self zero:3];
            }
            if (self.less.intValue > 0) {
                chrs = @"j";
            }
            if (self.bins.intValue > 0) {
                [self zero:0];
            }
        } else if (codc == 124) { // rta
            chrs = @"\e[C";
            if (self.less.intValue > 0) {
                chrs = @"\e)";
            }
            [self zero:0];
        } else if (codc == 123) { // lta
            chrs = @"\e[D";
            if (self.less.intValue > 0) {
                chrs = @"\e(";
            }
            [self zero:0];
        } else if (code == 3) { // ctc
            NSLog(@"CTRL +C [%d] [%@]", self.pidn.intValue, chrs);
            // todo add input str to hist list
            /*chrs = @"";
            kill(self.pidn.intValue, SIGINT);*/
            [self zero:1];
        } else if ((code == 8) || (code == 127)) { // bsp
            self.bend = @1;
        } else if ((code == 10) || (code == 13)) { // new
            chrs = @"\n";
            [self zero:0];
        } else if (code == 18) { // ctr
            [self zero:18];
        } else { // any
            [self zero:99];
        }
        if (chrs.length > 0) {
            if ([self chkf] != 0) { return 3; }
            const unsigned char *ustr = (const unsigned char *)[chrs UTF8String];
            write(self.mfdn.intValue, ustr, chrs.length);
        }
    }
    int cidx = (indx - 1);
    NSString *disp = [self gout:1];
    NSString *subs = (disp.length > 1) ? [disp substringFromIndex:1] : @"";
    subs = [NSString stringWithFormat:@"%@ ", subs];
    if (self.mode.intValue == 1) {
        subs = [NSMutableString stringWithFormat:@""];
    }
    //NSLog(@"INPT [%@]", subs);
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
        CGFloat pixw = self.tcon.fntw.floatValue;
        CGFloat pixh = self.tcon.fnth.floatValue;
        int rows = ((int)((high / pixh) - 9)); rows = MAX(6, rows);
        int cols = ((int)((wide / pixw) - 9)); cols = MAX(6, cols);
        int size = ((rows + 1) * (cols + 1));
        struct winsize wsiz;
        wsiz.ws_row = (rows - 1);
        wsiz.ws_col = (cols - 1);
        wsiz.ws_xpixel = 0;
        wsiz.ws_ypixel = 0;
        ioctl(fdes, TIOCSWINSZ, &wsiz);
        self.rows = @(rows);
        self.cols = @(cols);
        if (size > self.ansi.length) {
            [self.ansi setLength:size];
        }
        if (size > self.ansp.length) {
            [self.ansp setLength:size];
        }
        self.vcon = self.tcon;
        [self inpt:nil indx:indx];
        NSLog(@"WINZ [%d][%@] [%f][%f] [%d][%d] [%f][%f] [%d]", indx, text, wide, high, cols, rows, pixw, pixh, size);
    });
}

- (void)winf:(int)wdrf {
    self.wdrf = @(wdrf);
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
    self.wdrf = @0;

    self.mode = @0;
    self.bend = @0;
    self.bins = @0;
    self.last = @0;
    self.less = @0;
    self.newl = @0;
    self.swap = @0;

    self.crow = @0;
    self.ccol = @0;
    self.escs = @0;

    self.escd = [[NSMutableData alloc] init];
    self.esci = [[NSMutableData alloc] init];
    self.ansi = [[NSMutableData alloc] init];
    self.ansp = [[NSMutableData alloc] init];
    self.hist = [[NSMutableArray alloc] init];
    self.rets = [[NSMutableArray alloc] init];

    self.wino = wino;
    self.tcon = vcon;
    self.vcon = nil;

    [self opty];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self loop:nil];
    });

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

    NSLog(@"PROC [%d][%d] [%d]", self.sfdn.intValue, self.mfdn.intValue, self.pidn.intValue);
}

- (instancetype)init {
    self = [super init];
    return self;
}

@end

//NS_ASSUME_NONNULL_END
