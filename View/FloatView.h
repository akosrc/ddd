#import <UIKit/UIKit.h>
#include "../utils/module_tools.h"

@interface mi : UIView {
    ModuleControl *pModuleControl;
}

- (instancetype)initWithModuleControl:(ModuleControl *)moduleControl;

@end
