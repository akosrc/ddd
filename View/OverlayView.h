#import <UIKit/UIKit.h>
#import <MetalKit/MetalKit.h>
#import "imgui.h"
#import "../utils/module_tools.h"
#import "../菜单.h"

@interface OverlayView : MTKView <MTKViewDelegate>

@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) MTKTextureLoader *loader;
@property (nonatomic, assign) ModuleControl *moduleControl;
@property (nonatomic, assign) mi *mi;

- (instancetype)initWithFrame:(CGRect)frame :(ModuleControl*)control :(mi*)menu;
- (bool)ishowM;

@end
