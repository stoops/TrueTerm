//
//  SettingsController.h
//  SimpleShell
//
//  Created by jon on 2026-09-12.
//

#import <Foundation/Foundation.h>

#import <Cocoa/Cocoa.h>

@class ViewController;

@protocol SettingsDelegate <NSObject>
- (void)didChangeBgdColor:(NSColor *)color;
- (void)didChangeTabColor:(NSColor *)color;
- (void)didChangeTxtColor:(NSColor *)color;
- (void)didChangeSelColor:(NSColor *)color;
- (void)didChangeCsrColor:(NSColor *)color;
@end

@interface SettingsController : NSWindowController

@property (nonatomic, weak) id<SettingsDelegate> delegate;

@property (nonatomic, strong) NSColorWell *bgdColorWell;
@property (nonatomic, strong) NSColorWell *tabColorWell;
@property (nonatomic, strong) NSColorWell *txtColorWell;
@property (nonatomic, strong) NSColorWell *selColorWell;
@property (nonatomic, strong) NSColorWell *csrColorWell;

- (void)updateColors:(NSColor *)bgd tab:(NSColor *)tab txt:(NSColor *)txt sel:(NSColor *)sel csr:(NSColor *)csr;
- (void)loadColors:(NSColor *)bgd tab:(NSColor *)tab txt:(NSColor *)txt sel:(NSColor *)sel csr:(NSColor *)csr;

@end
