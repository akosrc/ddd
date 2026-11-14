#import "mi.h"

@implementation mi

- (instancetype)initWithModuleControl:(ModuleControl *)moduleControl {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        pModuleControl = moduleControl;
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
    }
    return self;
}

@end
