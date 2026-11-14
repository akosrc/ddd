#import <UIKit/UIKit.h>
#include "utils/module_tools.h"
#import <MetalKit/MetalKit.h>

@class mi;

@interface OverlayView : MTKView <MTKViewDelegate> {
    ModuleControl *pModuleControl;
    mi *menuWindow;
}

- (instancetype)initWithFrame:(CGRect)frame moduleControl:(ModuleControl *)moduleControl menuWindow:(mi *)menuWindow;

@end
