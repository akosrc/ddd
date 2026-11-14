#import "OverlayView.h"

@implementation OverlayView

@synthesize moduleControl = pModuleControl;
@synthesize menu = menuWindow;

- (instancetype)initWithFrame:(CGRect)frame moduleControl:(ModuleControl *)moduleControl menuWindow:(mi *)menu {
    self = [super initWithFrame:frame];
    if (self) {
        pModuleControl = moduleControl;
        menuWindow = menu;
        self.delegate = self;
        self.enableSetNeedsDisplay = YES;
        self.backgroundColor = [UIColor clearColor];
        
        if (menuWindow) {
            [menuWindow setOverlayView:self];
        }
    }
    return self;
}

// MTKViewDelegate metodları (Xətanı aradan qaldırmaq üçün mütləqdir)
- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    // Ekran ölçüsü dəyişdikdə ediləcək əməliyyatlar
}

- (void)drawInMTKView:(nonnull MTKView *)view {
    // Render əməliyyatları
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self && pModuleControl && !pModuleControl->menuStatus) {
        return nil; // Menyu açıq deyilsə toxunmaları alt oyun pəncərəsinə ötürür
    }
    return hitView;
}

@end
