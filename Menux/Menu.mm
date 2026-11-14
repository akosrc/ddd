// ================================================================================
// Clean Neverlose Menu + Key System for iOS Tweak
// ================================================================================

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#include <stdint.h>
#include <iostream>
#include <vector>
#include <pthread.h>

#include "ImGui/imgui.h"
#include "ImGui/backends/imgui_impl_opengl3.h"
#include "ImGui/Verdana.h"

int screenWidth = 2400;
int screenHeight = 1080;
bool g_Initialized = false;
static float g_Scale = 1.0f;

// Status dəyişənləri
bool show_key_system = true;
bool show_menu = false;
char keyInputBuffer[128] = "";
char statusMessage[128] = "";

void SetupNeverloseStyle(float scale) {
    ImGuiStyle &style = ImGui::GetStyle();
    style.WindowPadding     = ImVec2(12.0f * scale, 12.0f * scale);
    style.WindowRounding    = 12.0f * scale;
    style.ChildRounding     = 8.0f * scale;
    style.FrameRounding     = 5.0f * scale;

    ImVec4* colors = style.Colors;
    colors[ImGuiCol_Text]          = ImVec4(0.88f, 0.89f, 0.92f, 1.00f);
    colors[ImGuiCol_WindowBg]      = ImVec4(0.040f, 0.042f, 0.052f, 0.98f);
    colors[ImGuiCol_ChildBg]       = ImVec4(0.065f, 0.068f, 0.082f, 0.98f);
    colors[ImGuiCol_Border]        = ImVec4(0.12f, 0.13f, 0.17f, 0.85f);
    colors[ImGuiCol_FrameBg]       = ImVec4(0.085f, 0.090f, 0.110f, 1.00f);
    colors[ImGuiCol_CheckMark]     = ImVec4(0.92f, 0.33f, 0.60f, 1.00f);
    colors[ImGuiCol_Button]        = ImVec4(0.92f, 0.33f, 0.60f, 1.00f);
    colors[ImGuiCol_ButtonHovered] = ImVec4(0.98f, 0.40f, 0.68f, 1.00f);
}

// Key System pəncərəsi
void RenderKeySystem(float dispW, float dispH, float scale) {
    if (!show_key_system) return;

    ImGui::SetNextWindowSize(ImVec2(320.0f * scale, 180.0f * scale), ImGuiCond_Always);
    ImGui::SetNextWindowPos(ImVec2((dispW - 320.0f * scale) * 0.5f, (dispH - 180.0f * scale) * 0.5f), ImGuiCond_Always);

    ImGuiWindowFlags flags = ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoTitleBar;
    ImGui::Begin("##KeySystem", NULL, flags);

    ImGui::TextColored(ImVec4(0.92f, 0.33f, 0.60f, 1.0f), "M7MD - AUTHENTICATION");
    ImGui::Spacing();
    ImGui::Text("Enter your license key:");

    ImGui::PushItemWidth(ImGui::GetContentRegionAvail().x);
    ImGui::InputText("##keyBox", keyInputBuffer, sizeof(keyInputBuffer));
    ImGui::PopItemWidth();

    ImGui::Spacing();
    if (ImGui::Button("LOGIN", ImVec2(ImGui::GetContentRegionAvail().x, 30.0f * scale))) {
        // Bura istədiyin keçid şərtini yaza bilərsən (məsələn, boş deyilse və ya xüsusi açardırsa)
        if (strlen(keyInputBuffer) > 3) {
            show_key_system = false;
            show_menu = true;
        } else {
            snprintf(statusMessage, sizeof(statusMessage), "Invalid Key!");
        }
    }

    if (strlen(statusMessage) > 0) {
        ImGui::Spacing();
        ImGui::TextColored(ImVec4(1.0f, 0.2f, 0.2f, 1.0f), "%s", statusMessage);
    }

    ImGui::End();
}

// Əsas Neverlose Menyu (Sadə və təmiz)
void RenderNeverloseMenu(float dispW, float dispH, float scale) {
    if (!show_menu) return;

    ImGui::SetNextWindowSize(ImVec2(500.0f * scale, 320.0f * scale), ImGuiCond_FirstUseEver);
    ImGuiWindowFlags flags = ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoTitleBar;
    
    ImGui::Begin("Neverlose UI", &show_menu, flags);
    
    ImGui::TextColored(ImVec4(0.92f, 0.33f, 0.60f, 1.0f), "Neverlose Menu - Successfully Logged In");
    ImGui::Separator();
    ImGui::Spacing();

    static bool toggle1 = false;
    static bool toggle2 = false;
    
    ImGui::Checkbox("Enable Feature 1", &toggle1);
    ImGui::Checkbox("Enable Feature 2", &toggle2);

    ImGui::End();
}

// Render Frame
void RenderImGuiFrame() {
    if (!g_Initialized) {
        IMGUI_CHECKVERSION();
        ImGui::CreateContext();
        ImGuiIO& io = ImGui::GetIO();
        io.DisplaySize = ImVec2((float)screenWidth, (float)screenHeight);
        
        ImGui_ImplOpenGL3_Init("#version 300 es");
        g_Initialized = true;
        
        g_Scale = (float)screenHeight / 720.0f;
        if (g_Scale < 1.0f) g_Scale = 1.0f;
        if (g_Scale > 2.2f) g_Scale = 2.2f;

        SetupNeverloseStyle(g_Scale);
        io.Fonts->Clear();
        io.Fonts->AddFontFromMemoryTTF(Verdana, sizeof(Verdana), 15.0f * g_Scale);
        ImGui_ImplOpenGL3_CreateFontsTexture();
    }

    ImGuiIO& io = ImGui::GetIO();
    ImGui_ImplOpenGL3_NewFrame();
    ImGui::NewFrame();

    float dispW = io.DisplaySize.x > 100.0f ? io.DisplaySize.x : (float)screenWidth;
    float dispH = io.DisplaySize.y > 100.0f ? io.DisplaySize.y : (float)screenHeight;

    RenderKeySystem(dispW, dispH, g_Scale);
    RenderNeverloseMenu(dispW, dispH, g_Scale);

    ImGui::Render();
    ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
}

__attribute__((constructor)) void initialize() {
    // İşə düşmə məntiqi
}
