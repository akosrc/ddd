#import <UIKit/UIKit.h>
#include "../utils/module_tools.h"

@interface mi : UIView {
    ModuleControl *pModuleControl;
}

- (instancetype)initWithFrame:(ModuleControl *)moduleControl;

@end
