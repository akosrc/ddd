#import "mi.h"

@implementation mi

- (instancetype)initWithFrame:(ModuleControl *)moduleControl {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        pModuleControl = moduleControl;
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        
        // Burada menyunun pəncərəsi, düymələri və digər UI elementləri yaradıla bilər
    }
    return self;
}

@end
