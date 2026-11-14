#import "OverlayView.h"
#import "../Image/font.h"
#import "../Image/Icon.h"
#import "../Image/Iconcpp.h"
#import <objc/runtime.h>
@implementation OverlayView
    ImFont *_espFont;
    ImFont *_iconFont;
- (instancetype)initWithFrame:(CGRect)frame :(ModuleControl*)control :(mi*)menu {
    self.moduleControl = control;    
    self.mi = menu;

    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.preferredFramesPerSecond = 120;

        self.device = MTLCreateSystemDefaultDevice();
        if (!self.device) {
            return NULL;
        }
        self.delegate = self;
        
        self.commandQueue = [self.device newCommandQueue];
        self.loader = [[MTKTextureLoader alloc] initWithDevice: self.device];

    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO(); (void)io;
    ImFontConfig config;
        ImGuiStyle& style = ImGui::GetStyle();
        static const ImWchar icons_ranges[] = { 0xf000, 0xf3ff, 0 };
        ImFontConfig icons_config;
    config.FontDataOwnedByAtlas = false;
        icons_config.MergeMode = true;
        icons_config.PixelSnapH = true;
        ImGui::StyleColorsDark();      

            config.FontDataOwnedByAtlas = false;
            io.Fonts->AddFontFromMemoryTTF((void *)Fontdata, Fontsize, 30.0f, NULL,
            io.Fonts->GetGlyphRangesChineseFull());

    ImFont *_iconFont;
    _iconFont = io.Fonts->AddFontFromMemoryCompressedTTF(font_awesome_data, font_awesome_size, 20.f, &icons_config, icons_ranges);
    
    _iconFont->FontSize = 5;

        io.DisplaySize.x =  self.frame.size.width * UIScreen.mainScreen.nativeScale;
        io.DisplaySize.y =  self.frame.size.height * UIScreen.mainScreen.nativeScale;
        
        // Düzəldildi: StyleColorsDarkMode əvəzinə StyleColorsDark yazıldı
        ImGui::StyleColorsDark();     

        ImGui_ImplMetal_Init(self.device);
        [self.mi setOverlayView:self];
    }
    return self;
}

+ (void)load {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    });
}

- (bool)ishowM{
    return self.moduleControl->menuStatus;
}

- (void)drawInMTKView:(MTKView *)view {
    view.sampleCount = 4;
    view.clearColor = MTLClearColorMake(0.0f, 0.0f, 0.0f, 0.0f);
    
    struct timespec current_timespec;
    static double g_Time = 0.0;
    clock_gettime(CLOCK_MONOTONIC, &current_timespec);
    double current_time = (double)(current_timespec.tv_sec) + (current_timespec.tv_nsec / 1000000000.0);
    ImGui::GetIO().DeltaTime = g_Time > 0.0 ? (float)(current_time - g_Time) : (float)(1.0f / 120.0f);
    g_Time = current_time;

    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor != nil) {
        ImGui_ImplMetal_NewFrame(renderPassDescriptor);
        ImGui::NewFrame();
        
        if(self.moduleControl->menuStatus){
            [self.mi drawMenuWindow];
        }
   
        ImGui::Render();
        ImDrawData *drawData = ImGui::GetDrawData();
        id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        [renderEncoder pushDebugGroup:@"SwiftGUI"];
        ImGui_ImplMetal_RenderDrawData(drawData, commandBuffer, renderEncoder);
        
        [renderEncoder popDebugGroup];
        [renderEncoder endEncoding];
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    [commandBuffer commit];
}

-(void)mtkView:(MTKView*)view drawableSizeWillChange:(CGSize)size {
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self && !self.moduleControl->menuStatus) {
        return nil; 
    }
    return hitView;
}

-(void)updateIOWithTouchEvent:(UIEvent *)event {
    UITouch *anyTouch = event.allTouches.anyObject;
    CGPoint touchLocation = [anyTouch locationInView:self];
    ImGuiIO &io = ImGui::GetIO();
    io.AddMousePosEvent(touchLocation.x * UIScreen.mainScreen.nativeScale, touchLocation.y * UIScreen.mainScreen.nativeScale);

    BOOL hasActiveTouch = NO;
    for (UITouch *touch in event.allTouches) {
        if (touch.phase != UITouchPhaseEnded && touch.phase != UITouchPhaseCancelled) {
            hasActiveTouch = YES;
            break;
        }
    }
    io.AddMouseButtonEvent(0, hasActiveTouch);
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }
-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }

@end
