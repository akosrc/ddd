#import "FloatView.h"

@implementation FloatView

@synthesize moduleControl = pModuleControl;

- (instancetype)initWithFrame:(CGRect)frame moduleControl:(ModuleControl *)moduleControl {
    self = [super initWithFrame:frame];
    if (self) {
        pModuleControl = moduleControl;
        self.backgroundColor = [UIColor systemBlueColor];
        self.layer.cornerRadius = frame.size.width / 2;
        self.clipsToBounds = YES;
        
        // Toxunma (Tap) jesti əlavə edirik ki, menyunu açsın/bağlasın
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
    if (pModuleControl) {
        pModuleControl->menuStatus = !pModuleControl->menuStatus;
    }
}

@end
