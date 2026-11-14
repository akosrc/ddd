#import <UIKit/UIKit.h>
#include "utils/module_tools.h"
#import "mi.h"

@interface OverlayView : UIView {
    ModuleControl *pModuleControl;
    mi *menuWindow;
}

- (instancetype)initWithFrame:(CGRect)frame moduleControl:(ModuleControl *)moduleControl menuWindow:(mi *)menuWindow;

@end
