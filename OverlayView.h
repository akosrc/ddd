#import <UIKit/UIKit.h>
#include "utils/module_tools.h"
#import <MetalKit/MetalKit.h>
#import "菜单.h"

@interface OverlayView : MTKView <MTKViewDelegate> {
    ModuleControl *pModuleControl;
    mi *menuWindow;
}

@property (nonatomic, assign) ModuleControl *moduleControl;
@property (nonatomic, strong) mi *menu;

- (instancetype)initWithFrame:(CGRect)frame moduleControl:(ModuleControl *)moduleControl menuWindow:(mi *)menuWindow;

@end
