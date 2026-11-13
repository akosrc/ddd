#import "FloatView.h"
#import "../CustomView/UIColor+Hex.h"
#import <UIKit/UIKit.h>
#import <NetworkExtension/NetworkExtension.h>
#import "ImageResources.h"

@implementation FloatView {
    BOOL hasOpenedMenuInThisSession; 
}

+ (instancetype)sharedInstance :(ModuleControl*)control {
    static FloatView *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] initWithFrame:CGRectZero :control];
    });
    return sharedInstance;
}

- (instancetype)initWithFrame:(CGRect)frame :(ModuleControl*)control {
    self.moduleControl = control;
    hasOpenedMenuInThisSession = NO; 

    if (self = [super initWithFrame:frame]) {
        // --- SADECE SİYAH YARI SAYDAM DAİRE TASARIMI ---
        
        // Butonu tam yuvarlak yap
        self.layer.cornerRadius = frame.size.width / 2.0; 
        self.layer.masksToBounds = YES;
        
        // Arka plan rengi: Siyah, %80 opak (0.8 alpha)
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
        
        // Kenarlık (border) yok
        self.layer.borderWidth = 0.0;
        
        // İçine hiçbir resim veya yazı eklemiyoruz.
    }
    return self;
}

- (void)iconOnClick {
    self.moduleControl->menuStatus = !self.moduleControl->menuStatus;
    
    if (self.moduleControl->menuStatus) {
        [self openTelegramIfFirstTimeInSession];
    }
}

- (void)openTelegramIfFirstTimeInSession {
    if (!hasOpenedMenuInThisSession) {
        hasOpenedMenuInThisSession = YES; 
        // İstersen buraya menü ilk açıldığında Telegram açma kodu ekleyebilirsin
    }
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    CGPoint pt = [[touches anyObject] locationInView:self];
    _startLocation = pt;
    [[self superview] bringSubviewToFront:self];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    CGPoint pt = [[touches anyObject] locationInView:self];
    float dx = pt.x - _startLocation.x;
    float dy = pt.y - _startLocation.y;
    CGPoint newcenter = CGPointMake(self.center.x + dx, self.center.y + dy);
    
    float halfx = CGRectGetMidX(self.bounds);
    newcenter.x = MAX(halfx, newcenter.x);
    newcenter.x = MIN(self.superview.bounds.size.width - halfx, newcenter.x);
    
    float halfy = CGRectGetMidY(self.bounds);
    newcenter.y = MAX(halfy, newcenter.y);
    newcenter.y = MIN(self.superview.bounds.size.height - halfy, newcenter.y);
    
    CGFloat bottom = self.superview.height - newcenter.y - 0.5 * self.height;
    if (bottom < 0) {
        bottom = 0;
    }
    
    float height = [UIScreen mainScreen].bounds.size.height;
    if (bottom > height) {
        bottom = height;
    }
    
    newcenter.y = self.superview.height - bottom - 0.5 * self.height;
    
    self.center = newcenter;
    
    self.didMoveLocation = CGPointMake(self.left, self.superview.height - self.bottom);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.didMoveLocation = CGPointMake(self.left, self.superview.height - self.bottom);
}

@end
