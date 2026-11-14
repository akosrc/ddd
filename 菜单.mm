#import "菜单.h"
#import "OverlayView.h"

@implementation mi

@synthesize moduleControl;

- (instancetype)initWithFrame:(ModuleControl*)control {
    self = [super init];
    if (self) {
        moduleControl = control;
    }
    return self;
}

- (void)setOverlayView:(OverlayView*)ov {
    // Örtük pəncərəsini təyin edir
}

- (void)drawMenuWindow {
    // ImGui menyu interfeysinin render edildiyi yer
}

- (void)showSystemInfo {
    // Sistem məlumatları
}

- (void)showPlayerControl {
    // Oyunçu idarəetməsi
}

- (void)showAimbotControl {
    // Aimbot parametrləri
}

- (void)skins {
    // Skin dəyişdirmə
}

- (void)readIniConfig {
    // Konfiqurasiya faylını oxumaq
}

@end
