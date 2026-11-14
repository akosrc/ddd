#import "OverlayView.h"
#import "../Image/font.h"
#import "../Image/Icon.h"
#import "../Image/Iconcpp.h"
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import "imgui_impl_opengl3.h"
#import <objc/runtime.h>

@implementation OverlayView
    ImFont *_espFont;
    ImFont *_iconFont;
    bool g_Initialized_Overlay = false;

- (instancetype)initWithFrame:(CGRect)frame :(ModuleControl*)control :(mi*)menu {
    self.moduleControl = control;    
    self.mi = menu;

    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.preferredFramesPerSecond = 120;
        
        // OpenGL üçün mühit (MTKView əvəzinə GLKView və ya standart UIView + CAEAGLLayer istifadə olunursa)
        // Əgər class GLKView-dən miras alırsa və ya OpenGL ES render edirsə:
        
        if (!g_Initialized_Overlay) {
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

            _iconFont = io.Fonts->AddFontFromMemoryCompressedTTF(font_awesome_data, font_awesome_size, 20.f, &icons_config, icons_ranges);
            if (_iconFont) {
                _iconFont->FontSize = 5;
            }

            io.DisplaySize.x = self.frame.size.width * UIScreen.mainScreen.nativeScale;
            io.DisplaySize.y = self.frame.size.height * UIScreen.mainScreen.nativeScale;

            ImGui::StyleColorsDarkMode();     

            // OpenGL3 Backend başladılır
            ImGui_ImplOpenGL3_Init("#version 300 es");
            g_Initialized_Overlay = true;
        }

        [self.mi setOverlayView:self];
    }
    return self;
}

+ (void)load {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Başlanğıc bildirişi
    });
}

- (bool)ishowM {
    return self.moduleControl->menuStatus;
}

// Hər kadrda (Frame) çağrılan OpenGL render funksiyası
- (void)drawView {
    struct timespec current_timespec;
    static double g_Time = 0.0;
    clock_gettime(CLOCK_MONOTONIC, &current_timespec);
    double current_time = (double)(current_timespec.tv_sec) + (current_timespec.tv_nsec / 1000000000.0);
    ImGui::GetIO().DeltaTime = g_Time > 0.0 ? (float)(current_time - g_Time) : (float)(1.0f / 120.0f);
    g_Time = current_time;

    ImGui_ImplOpenGL3_NewFrame();
    ImGui::NewFrame();
    
    if (self.moduleControl->menuStatus) {
        [self.mi drawMenuWindow];
    }

    ImGui::Render();
    ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
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
