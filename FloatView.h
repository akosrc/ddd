#import <UIKit/UIKit.h>
#include "../utils/module_tools.h"

@interface FloatView : UIView {
    ModuleControl *pModuleControl;
}

- (instancetype)initWithFrame:(CGRect)frame moduleControl:(ModuleControl *)moduleControl;

@end
