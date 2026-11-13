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
        // --- GÖRÜNÜM AYARLARI ---
        self.layer.cornerRadius = frame.size.width / 2.0; 
        self.layer.masksToBounds = YES;
        
        // Arka plan rengi: Test için Kırmızı. (Çalışınca siyah yapacağız)
        self.backgroundColor = [UIColor redColor]; 
        self.layer.borderWidth = 0.0;
        
        // --- TIKLAMA ÖZELLİĞİ BURADA EKLENİYOR ---
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconOnClick)];
        [self addGestureRecognizer:tapGesture];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)iconOnClick {
    // Menüyü aç/kapa
    self.moduleControl->menuStatus = !self.moduleControl->menuStatus;
    
    if (self.moduleControl->menuStatus) {
        [self openTelegramIfFirstTimeInSession];
    }
}

- (void)openTelegramIfFirstTimeInSession {
    if (!hasOpenedMenuInThisSession) {
        hasOpenedMenuInThisSession = YES; 
    }
}

// Butonu sürükleme özelliği
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
    
    self.center = newcenter;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {}

@end
