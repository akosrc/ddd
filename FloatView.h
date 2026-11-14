#import <UIKit/UIKit.h>
#include "utils/module_tools.h"

@interface FloatView : UIView {
    ModuleControl *pModuleControl;
}

@property (nonatomic, assign) ModuleControl *moduleControl;

- (instancetype)initWithFrame:(CGRect)frame moduleControl:(ModuleControl *)moduleControl;

@end
