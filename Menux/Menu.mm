// ================================================================================
// Full Neverlose UI + Key System (Visual Preview Only)
// ================================================================================

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#include <stdint.h>
#include <iostream>
#include <vector>
#include <pthread.h>

#import "../imgui.h"
#import "../backends/imgui_impl_opengl3.h"
#import "Verdana.h"

int screenWidth = 2400;
int screenHeight = 1080;
bool g_Initialized = false;
static float g_Scale = 1.0f;
bool show_window = true;

// Key Sistemi və Menyu Statusu
bool show_key_system = true;
bool show_menu = false;
char keyInputBuffer[128] = "";

// Menyu Xüsusiyyətləri (Vizual)
static bool esp = false;
static bool esp_box = true;
static bool esp_health = true;
static bool esp_name = true;
static bool legit_enable = false;
static int legit_fov = 135;

void SetupNeverloseStyle(float scale) {
    ImGuiStyle &style = ImGui::GetStyle();
    style.WindowPadding     = ImVec2(10.0f * scale, 9.0f * scale);
    style.FramePadding      = ImVec2(6.0f * scale, 3.0f * scale);
    style.ItemSpacing       = ImVec2(5.0f * scale, 4.0f * scale);
    style.WindowRounding    = 12.0f * scale;
    style.ChildRounding     = 8.0f * scale;
    style.FrameRounding     = 4.5f * scale;

    ImVec4* colors = style.Colors;
    colors[ImGuiCol_Text]          = ImVec4(0.88f, 0.89f, 0.92f, 1.00f);
    colors[ImGuiCol_WindowBg]      = ImVec4(0.040f, 0.042f, 0.052f, 0.98f);
    colors[ImGuiCol_ChildBg]       = ImVec4(0.065f, 0.068f, 0.082f, 0.98f);
    colors[ImGuiCol_Border]        = ImVec4(0.12f, 0.13f, 0.17f, 0.85f);
    colors[ImGuiCol_FrameBg]       = ImVec4(0.085f, 0.090f, 0.110f, 1.00f);
    colors[ImGuiCol_CheckMark]     = ImVec4(0.92f, 0.33f, 0.60f, 1.00f);
    colors[ImGuiCol_SliderGrab]    = ImVec4(0.92f, 0.33f, 0.60f, 1.0f);
    colors[ImGuiCol_Button]        = ImVec4(0.080f, 0.085f, 0.105f, 1.0f);
}

// Key System Pəncərəsi
void RenderKeySystem(float dispW, float dispH, float scale) {
    if (!show_key_system) return;

    ImGui::SetNextWindowSize(ImVec2(320.0f * scale, 190.0f * scale), ImGuiCond_Always);
    ImGui::SetNextWindowPos(ImVec2((dispW - 320.0f * scale) * 0.5f, (dispH - 190.0f * scale) * 0.5f), ImGuiCond_Always);

    ImGuiWindowFlags flags = ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoTitleBar;
    ImGui::Begin("##KeySystem", NULL, flags);

    ImGui::TextColored(ImVec4(0.92f, 0.33f, 0.60f, 1.0f), "M7MD - AUTHENTICATION");
    ImGui::Spacing();
    ImGui::Text("Enter any key to enter menu:");

    ImGui::PushItemWidth(ImGui::GetContentRegionAvail().x);
    ImGui::InputText("##keyBox", keyInputBuffer, sizeof(keyInputBuffer));
    ImGui::PopItemWidth();

    ImGui::Spacing();
    if (ImGui::Button("LOGIN", ImVec2(ImGui::GetContentRegionAvail().x, 30.0f * scale))) {
        show_key_system = false;
        show_menu = true;
    }

    ImGui::End();
}

// Neverlose Menyu
void RenderNeverloseMenu(float dispW, float dispH, float scale) {
    if (!show_menu || !show_window) return;

    float winWidth = 720.0f * scale;
    float winHeight = 415.0f * scale;
    ImVec2 winPos = ImVec2((dispW - winWidth) * 0.5f, (dispH - winHeight) * 0.44f);

    ImGui::SetNextWindowPos(winPos, ImGuiCond_Once);
    ImGui::SetNextWindowSize(ImVec2(winWidth, winHeight), ImGuiCond_Always);

    ImGuiWindowFlags flags = ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize;
    ImGui::Begin("##NL_Main", NULL, flags);

    ImDrawList* draw = ImGui::GetWindowDrawList();
    ImVec2 p = ImGui::GetWindowPos();
    ImVec2 sz = ImGui::GetWindowSize();

    const float padX = 12.0f * scale;
    const float gapX = 10.0f * scale;
    const float colW = (sz.x - padX * 2.0f - gapX * 2.0f) / 3.0f;
    const float totalH = sz.y - 82.0f * scale;
    const float startY = 37.0f * scale;

    static int currentTab = 0;

    if (currentTab == 0) {
        ImGui::SetCursorPos(ImVec2(padX, startY));
        ImGui::BeginChild("##Block_ESP", ImVec2(colW, totalH), true, ImGuiWindowFlags_NoScrollbar);
        {
            ImGui::TextColored(ImVec4(0.38f, 0.39f, 0.46f, 1.00f), "ESP ENEMY");
            ImGui::Spacing();
            ImGui::Checkbox("ESP Enabled", &esp);
            ImGui::Checkbox("Box", &esp_box);
            ImGui::Checkbox("Health Bar", &esp_health);
            ImGui::Checkbox("Name", &esp_name);
        }
        ImGui::EndChild();
    }
    else if (currentTab == 2) {
        ImGui::SetCursorPos(ImVec2(padX, startY));
        ImGui::BeginChild("##Block_Legit", ImVec2(colW, totalH), true, ImGuiWindowFlags_NoScrollbar);
        {
            ImGui::TextColored(ImVec4(0.38f, 0.39f, 0.46f, 1.00f), "LEGITBOT");
            ImGui::Spacing();
            ImGui::Checkbox("Enabled", &legit_enable);
            ImGui::SliderInt("FOV", &legit_fov, 1, 180);
        }
        ImGui::EndChild();
    }

    const char* tabsLabels[] = { "Visuals", "Rage", "Legit", "Skins", "Misc", "Exploits", "</> Lua" };
    const int tabCount = 7;
    float navW = sz.x - 24.0f * scale;
    float navH = 26.0f * scale;
    ImVec2 navMin = ImVec2(p.x + 12 * scale, p.y + sz.y - 34.0f * scale);
    ImVec2 navMax = ImVec2(navMin.x + navW, navMin.y + navH);

    draw->AddRectFilled(navMin, navMax, IM_COL32(11, 11, 14, 255), 7.0f * scale);

    float itemW = navW / tabCount;
    for (int i = 0; i < tabCount; i++) {
        ImVec2 itMin = ImVec2(navMin.x + i * itemW, navMin.y);
        ImVec2 itMax = ImVec2(itMin.x + itemW, navMin.y + navH);

        bool isSel = (currentTab == i);
        if (isSel) {
            draw->AddRectFilled(ImVec2(itMin.x + 2, itMin.y + 2), ImVec2(itMax.x - 2, itMax.y - 2), IM_COL32(24, 25, 32, 255), 5.5f * scale);
        }

        ImGui::SetCursorScreenPos(itMin);
        char tId[32];
        snprintf(tId, sizeof(tId), "##nav_tab_%d", i);
        if (ImGui::InvisibleButton(tId, ImVec2(itemW, navH))) {
            currentTab = i;
        }

        ImVec2 txtSz = ImGui::CalcTextSize(tabsLabels[i]);
        float startContentX = itMin.x + (itemW - txtSz.x) * 0.5f;
        float centerY = itMin.y + navH * 0.5f;
        ImU32 colTab = isSel ? IM_COL32(245, 245, 250, 255) : IM_COL32(95, 98, 112, 255);

        draw->AddText(ImVec2(startContentX, centerY - txtSz.y * 0.5f), colTab, tabsLabels[i]);
    }

    ImGui::End();
}

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
    // Təmiz və təhlükəsiz konstruktor
}
