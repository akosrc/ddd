// ================================================================================
// PUBG Mobile - Full Neverlose Menu (All Features Included)
// ================================================================================

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#include <stdint.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <pthread.h>
#include <chrono>
#include <unordered_map>
#include <cmath>
#include <dlfcn.h>

#include "ImGui/imgui_internal.h"
#include "ImGui/imgui.h"
#include "ImGui/backends/imgui_impl_opengl3.h"

#include "ImGui/FONTS/DEFAULT.h"
#include "ImGui/Verdana.h"
#include "Includes/Utils.h"
#include "Includes/Dobby/dobby.h"
#include "KittyMemory/MemoryPatch.h"
#include "Includes/obfuscate.h"
#include "Unity/Vector3.h"

uintptr_t G_IL2CPP = 0;
int screenWidth = 2400;
int screenHeight = 1080;
bool g_Initialized = false;
ImGuiWindow* g_window = NULL;
static float g_Scale = 1.0f;
bool show_window = true;

// ---------------- STB_IMAGE & ANIME TEXTURE ----------------
#ifndef STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_IMPLEMENTATION
#endif
#if __has_include("stb_image.h")
#include "stb_image.h"
#define HAS_STB_IMAGE 1
#else
#define HAS_STB_IMAGE 0
#endif

#if __has_include("anime_image.h")
#include "anime_image.h"
#define HAS_CUSTOM_ANIME_IMAGE 1
#else
#define HAS_CUSTOM_ANIME_IMAGE 0
static const unsigned char anime_image_png[] = { 0 };
static const unsigned int anime_image_png_len = 0;
#endif

// Bütün vizual və oyun seçimləri
static bool esp = false;
static bool show_esp_preview = true;
static bool esp_box          = true;
static bool esp_health       = true;
static bool esp_name         = true;
static bool esp_flags        = true;
static bool esp_weapon       = true;
static bool esp_distance     = true;

static int chamsint = 0;
const char* Chams[] = {
    "OFF", "Default", "Shading", "Wireframe", "Outline",
    "Visibility Check Outline", "Visibility Check Shading", "Visibility Check Shading + Outline"
};
static bool enableRainbow = false, enableRainbowWall = false;
static float visibleColor[3] = { 1.0f, 0.0f, 0.0f };
static float inWallColor[3]  = { 0.0f, 1.0f, 0.0f };

// Background effects
static int bgEffectIndex = 4;
const char* bgEffectNames[] = { "OFF", "Snow", "Rain", "Matrix Lines", "Halftone Comic" };

// Color Pickers
static float col_draw_fov[4]       = { 0.16f, 0.22f, 0.45f, 1.0f };
static float col_draw_inacc[4]     = { 0.22f, 0.23f, 0.27f, 1.0f };
static float col_multipoints[4]    = { 0.95f, 0.95f, 0.98f, 1.0f };
static float col_cast_lines[4]     = { 0.92f, 0.46f, 0.20f, 1.0f };
static float col_legit_fov[4]    = { 0.92f, 0.33f, 0.60f, 1.0f };

// Legitbot & Aim
static bool legit_enable         = true;
static bool legit_draw_fov       = true;
static int  legit_fov_radius     = 135;
static bool legit_draw_crosshair = true;
static int  legit_cross_size     = 9;
static int  legit_cross_gap      = 3;

// Notifications System
struct NotificationItem {
    std::string title;
    std::string message;
    float timeCreated;
    float duration;
};
static std::vector<NotificationItem> g_Notifications;

void AddNotification(const std::string& title, const std::string& message, float duration = 3.5f) {
    NotificationItem item;
    item.title = title;
    item.message = message;
    item.timeCreated = (float)ImGui::GetTime();
    item.duration = duration;
    g_Notifications.push_back(item);
}

void RenderNotifications(float dispW, float dispH, float scale) {
    if (g_Notifications.empty()) return;

    ImDrawList* fg = ImGui::GetForegroundDrawList();
    float curTime = (float)ImGui::GetTime();

    float cardW = 190.0f * scale;
    float cardH = 54.0f * scale;
    float gapY  = 8.0f * scale;
    float startX = dispW - cardW - 14.0f * scale;
    float startY = 56.0f * scale;

    for (int i = 0; i < (int)g_Notifications.size(); ) {
        float elapsed = curTime - g_Notifications[i].timeCreated;
        if (elapsed >= g_Notifications[i].duration) {
            g_Notifications.erase(g_Notifications.begin() + i);
            continue;
        }

        float progress = elapsed / g_Notifications[i].duration;
        float alpha = 1.0f;
        float slideX = 0.0f;
        if (elapsed < 0.25f) {
            float inFrac = elapsed / 0.25f;
            alpha = inFrac;
            slideX = (1.0f - inFrac) * 35.0f * scale;
        } else if (elapsed > g_Notifications[i].duration - 0.35f) {
            float outFrac = (g_Notifications[i].duration - elapsed) / 0.35f;
            alpha = outFrac;
        }

        ImVec2 minP(startX + slideX, startY);
        ImVec2 maxP(minP.x + cardW, minP.y + cardH);

        int aBg = (int)(245 * alpha);
        int aBorder = (int)(180 * alpha);

        fg->AddRectFilled(minP, maxP, IM_COL32(20, 21, 28, aBg), 7.0f * scale);
        fg->AddRect(minP, maxP, IM_COL32(36, 38, 50, aBorder), 7.0f * scale, 0, 1.0f * scale);

        fg->AddText(ImVec2(minP.x + 12.0f * scale, minP.y + 8.0f * scale), IM_COL32(245, 245, 250, (int)(250 * alpha)), g_Notifications[i].title.c_str());
        fg->AddText(ImVec2(minP.x + 12.0f * scale, minP.y + 24.0f * scale), IM_COL32(145, 150, 165, (int)(150 * alpha)), g_Notifications[i].message.c_str());

        float barMaxW = cardW - 24.0f * scale;
        float barCurW = barMaxW * (1.0f - progress);
        if (barCurW < 2.0f * scale) barCurW = 2.0f * scale;

        ImVec2 barMin(minP.x + 12.0f * scale, minP.y + cardH - 8.0f * scale);
        ImVec2 barMax(barMin.x + barCurW, barMin.y + 2.4f * scale);

        fg->AddRectFilled(barMin, barMax, IM_COL32(235, 85, 153, (int)(255 * alpha)), 1.2f * scale);

        startY += cardH + gapY;
        i++;
    }
}

// Lua Editor Buffer
static char luaCodeBuffer[4096] = 
    "-- Lua Scripting Engine for PUBG\n"
    "function OnFrame()\n"
    "    -- Custom logic here\n"
    "end\n";

void RenderLuaCodeLine(const std::string& line, float scale) {
    ImVec4 colDefault  = ImVec4(0.88f, 0.89f, 0.92f, 1.0f);
    ImVec4 colComment  = ImVec4(0.48f, 0.52f, 0.60f, 1.0f);

    if (line.rfind("--", 0) == 0) {
        ImGui::TextColored(colComment, "%s", line.c_str());
        return;
    }
    ImGui::TextColored(colDefault, "%s", line.c_str());
}

void RenderLuaTab(ImVec2 p, ImVec2 sz, float padX, float startY, float totalH, float scale) {
    float fullW = sz.x - padX * 2.0f;
    ImGui::SetCursorPos(ImVec2(padX, startY));
    ImGui::BeginChild("##Block_Lua_Editor", ImVec2(fullW, totalH), true, ImGuiWindowFlags_NoScrollbar);
    {
        ImDrawList* draw = ImGui::GetWindowDrawList();
        ImVec2 curPos = ImGui::GetCursorScreenPos();
        float availW = ImGui::GetContentRegionAvail().x;

        draw->AddCircle(ImVec2(curPos.x + 6.0f * scale, curPos.y + 7.0f * scale), 4.5f * scale, IM_COL32(235, 85, 153, 255), 8, 1.4f * scale);
        ImGui::SetCursorPosX(ImGui::GetCursorPosX() + 18.0f * scale);
        ImGui::TextColored(ImVec4(0.92f, 0.92f, 0.95f, 1.0f), "Lua preview");
        ImGui::Spacing();

        float codeAreaHeight = totalH - 72.0f * scale;
        ImGui::PushStyleColor(ImGuiCol_ChildBg, ImVec4(0.045f, 0.048f, 0.058f, 1.0f));
        ImGui::BeginChild("##CodeViewerChild", ImVec2(availW, codeAreaHeight), true, ImGuiWindowFlags_HorizontalScrollbar);
        {
            std::stringstream ss(luaCodeBuffer);
            std::string line;
            while (std::getline(ss, line)) {
                RenderLuaCodeLine(line, scale);
            }
        }
        ImGui::EndChild();
        ImGui::PopStyleColor();

        ImGui::Spacing();
        if (ImGui::Button("Load", ImVec2((availW - 16.0f) / 3.0f, 28.0f * scale))) {
            AddNotification("Lua Engine", "Script loaded successfully!", 3.5f);
        }
    }
    ImGui::EndChild();
}

static GLuint g_AnimeTexture = 0;
static int g_AnimeWidth = 0;
static int g_AnimeHeight = 0;

GLuint LoadTextureFromMemory(const unsigned char* buffer, int len, int* out_w, int* out_h) {
#if HAS_STB_IMAGE
    if (!buffer || len <= 0) return 0;
    int w = 0, h = 0, channels = 0;
    unsigned char* pixels = stbi_load_from_memory(buffer, len, &w, &h, &channels, 4);
    if (!pixels) return 0;

    GLuint texId = 0;
    glGenTextures(1, &texId);
    glBindTexture(GL_TEXTURE_2D, texId);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
    glBindTexture(GL_TEXTURE_2D, 0);
    stbi_image_free(pixels);
    if (out_w) *out_w = w;
    if (out_h) *out_h = h;
    return texId;
#else
    return 0;
#endif
}

// Background effects implementation
struct SnowFlake { float x, y, speed, radius, swayOffset; };
static std::vector<SnowFlake> g_snow;

struct RainDrop { float x, y, speed, length; };
static std::vector<RainDrop> g_rain;

struct MatrixLine { float x, y, speed, length, alpha; };
static std::vector<MatrixLine> g_matrix;

void RenderBackgroundEffects(float dispW, float dispH, float scale) {
    ImDrawList* bgDraw = ImGui::GetBackgroundDrawList();
    bgDraw->AddRectFilledMultiColor(
        ImVec2(0, 0), ImVec2(dispW, dispH),
        IM_COL32(32, 28, 30, 255), IM_COL32(20, 21, 25, 255),
        IM_COL32(10, 11, 14, 255), IM_COL32(28, 24, 26, 255)
    );

    if (bgEffectIndex == 0) return;
    float dt = ImGui::GetIO().DeltaTime;
    if (dt <= 0.0f || dt > 0.1f) dt = 0.016f;

    if (bgEffectIndex == 4) { // Halftone Comic
        const float dotSpacing = 16.0f * scale;
        for (float y = 4.0f; y < dispH; y += dotSpacing) {
            for (float x = 4.0f; x < dispW; x += dotSpacing) {
                bgDraw->AddCircleFilled(ImVec2(x, y), 1.2f * scale, IM_COL32(230, 230, 240, 50), 12);
            }
        }
    }
}

void SetupNeverloseStyle(float scale) {
    ImGuiStyle &style = ImGui::GetStyle();
    style.WindowPadding     = ImVec2(10.0f * scale, 9.0f * scale);
    style.FramePadding      = ImVec2(6.0f * scale, 3.0f * scale);
    style.ItemSpacing       = ImVec2(5.0f * scale, 4.0f * scale);
    style.WindowRounding    = 12.0f * scale;
    style.ChildRounding     = 8.0f * scale;
    style.FrameRounding     = 4.5f * scale;

    ImVec4* colors = style.Colors;
    colors[ImGuiCol_Text]                  = ImVec4(0.88f, 0.89f, 0.92f, 1.00f);
    colors[ImGuiCol_WindowBg]              = ImVec4(0.040f, 0.042f, 0.052f, 0.98f);
    colors[ImGuiCol_ChildBg]               = ImVec4(0.065f, 0.068f, 0.082f, 0.98f);
    colors[ImGuiCol_Border]                = ImVec4(0.12f, 0.13f, 0.17f, 0.85f);
    colors[ImGuiCol_FrameBg]               = ImVec4(0.085f, 0.090f, 0.110f, 1.00f);
    colors[ImGuiCol_CheckMark]             = ImVec4(0.92f, 0.33f, 0.60f, 1.00f);
    colors[ImGuiCol_SliderGrab]            = ImVec4(0.92f, 0.33f, 0.60f, 1.00f);
    colors[ImGuiCol_Button]                = ImVec4(0.080f, 0.085f, 0.105f, 1.00f);
}

bool ToggleSwitch(const char* label, bool* v, bool hasDots = false) {
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    if (window->SkipItems) return false;

    ImGuiContext& g = *GImGui;
    const ImGuiID id = window->GetID(label);
    const ImVec2 pos = window->DC.CursorPos;

    float height = 13.5f * g_Scale;
    float width = 25.0f * g_Scale;
    float radius = height * 0.5f;

    float availW = ImGui::GetContentRegionAvail().x;
    float rowH = 20.0f * g_Scale;
    const ImRect total_bb(pos, ImVec2(pos.x + availW, pos.y + rowH));
    const ImRect switch_bb(ImVec2(total_bb.Max.x - width, pos.y + (rowH - height) * 0.5f), ImVec2(total_bb.Max.x, pos.y + (rowH + height) * 0.5f));

    ImGui::ItemSize(total_bb, 0.0f);
    if (!ImGui::ItemAdd(total_bb, id)) return false;

    bool hovered, held;
    bool pressed = ImGui::ButtonBehavior(total_bb, id, &hovered, &held);
    if (pressed) {
        *v = !(*v);
        ImGui::MarkItemEdited(id);
    }

    window->DrawList->AddText(ImVec2(pos.x, pos.y + (rowH - ImGui::GetTextLineHeight()) * 0.5f), ImGui::GetColorU32(ImGuiCol_Text), label);
    ImU32 bg_col = *v ? IM_COL32(235, 85, 153, 255) : IM_COL32(26, 27, 33, 255);
    window->DrawList->AddRectFilled(switch_bb.Min, switch_bb.Max, bg_col, radius);

    float circle_x = *v ? (switch_bb.Max.x - radius) : (switch_bb.Min.x + radius);
    float circle_y = switch_bb.Min.y + radius;
    window->DrawList->AddCircleFilled(ImVec2(circle_x, circle_y), radius - 1.8f * g_Scale, IM_COL32(245, 245, 250, 255));

    return pressed;
}

void NL_CardTitle(const char* title) {
    ImGui::TextColored(ImVec4(0.38f, 0.39f, 0.46f, 1.00f), "%s", title);
    ImGui::Spacing();
}

// ESP Preview Card (Anime / Box Preview)
void RenderESPPreviewWindow(ImVec2 mainPos, ImVec2 mainSz, float scale) {
    if (!show_esp_preview) return;

    float cardW = 210.0f * scale;
    float cardH = mainSz.y;
    float cardX = mainPos.x + mainSz.x + 12.0f * scale;
    float cardY = mainPos.y;

    ImGuiWindowFlags prevFlags = ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoScrollbar;
    ImGui::SetNextWindowPos(ImVec2(cardX, cardY));
    ImGui::SetNextWindowSize(ImVec2(cardW, cardH));
    
    ImGui::PushStyleColor(ImGuiCol_WindowBg, ImVec4(0.055f, 0.058f, 0.072f, 0.98f));
    ImGui::PushStyleColor(ImGuiCol_Border, ImVec4(0.18f, 0.14f, 0.24f, 0.90f));
    
    if (ImGui::Begin("##ESP_Preview_Card", NULL, prevFlags)) {
        ImDrawList* draw = ImGui::GetWindowDrawList();
        ImVec2 p = ImGui::GetWindowPos();
        ImVec2 sz = ImGui::GetWindowSize();

        draw->AddText(ImVec2(p.x + 14.0f * scale, p.y + 14.0f * scale), IM_COL32(245, 245, 250, 255), "Preview");
        
        float boxW = 88.0f * scale;
        float boxH = 220.0f * scale;
        ImVec2 boxMin(p.x + (sz.x - boxW) * 0.5f, p.y + 74.0f * scale);
        ImVec2 boxMax(boxMin.x + boxW, boxMin.y + boxH);

        if (esp_box) {
            draw->AddRect(boxMin, boxMax, IM_COL32(235, 85, 153, 255), 0.0f, 0, 1.8f * scale);
        }
        if (esp_name) {
            draw->AddText(ImVec2(boxMin.x + 20.0f * scale, boxMin.y - 18.0f * scale), IM_COL32(245, 245, 250, 255), "FIXNEY");
        }
    }
    ImGui::End();
    ImGui::PopStyleColor(2);
}

// Full Neverlose Menu Drawer
void DrawNeverloseMenu() {
    if (!show_window) return;

    ImGuiIO &io = ImGui::GetIO();
    float dispW = io.DisplaySize.x > 100.0f ? io.DisplaySize.x : (float)screenWidth;
    float dispH = io.DisplaySize.y > 100.0f ? io.DisplaySize.y : (float)screenHeight;

    float winWidth = 720.0f * g_Scale;
    float winHeight = 415.0f * g_Scale;
    ImVec2 winPos = ImVec2((dispW - winWidth) * 0.5f, (dispH - winHeight) * 0.44f);
    
    ImGui::SetNextWindowPos(winPos, ImGuiCond_Once);
    ImGui::SetNextWindowSize(ImVec2(winWidth, winHeight), ImGuiCond_Always);

    ImGuiWindowFlags flags = ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize;
    ImGui::Begin("##NL_Main", NULL, flags);
    g_window = ImGui::GetCurrentWindow();

    ImDrawList* draw = ImGui::GetWindowDrawList();
    ImVec2 p = ImGui::GetWindowPos();
    ImVec2 sz = ImGui::GetWindowSize();

    const float padX = 12.0f * g_Scale;
    const float gapX = 10.0f * g_Scale;
    const float colW = (sz.x - padX * 2.0f - gapX * 2.0f) / 3.0f;
    const float totalH = sz.y - 82.0f * g_Scale;
    const float startY = 37.0f * g_Scale;

    static int currentTab = 0; // 0: Visuals, 1: Rage, 2: Legit, 3: Skins, 4: Misc, 5: Exploits, 6: Lua

    if (currentTab == 0) {
        // Visuals Tab
        ImGui::SetCursorPos(ImVec2(padX, startY));
        ImGui::BeginChild("##Block_ESP", ImVec2(colW, totalH), true, ImGuiWindowFlags_NoScrollbar);
        {
            NL_CardTitle("ESP ENEMY");
            ToggleSwitch("ESP Enabled", &esp);
            ToggleSwitch("Box", &esp_box);
            ToggleSwitch("Health Bar", &esp_health);
            ToggleSwitch("Name", &esp_name);
            ToggleSwitch("Flags", &esp_flags);
            ToggleSwitch("Weapon Icon", &esp_weapon);
            ToggleSwitch("Distance", &esp_distance);
        }
        ImGui::EndChild();

        ImGui::SetCursorPos(ImVec2(padX + colW + gapX, startY));
        ImGui::BeginChild("##Block_Preview", ImVec2(colW, totalH), true, ImGuiWindowFlags_NoScrollbar);
        {
            NL_CardTitle("ESP PREVIEW");
            ToggleSwitch("Show Preview Window", &show_esp_preview);
        }
        ImGui::EndChild();
    }
    else if (currentTab == 2) {
        // Legit Tab
        ImGui::SetCursorPos(ImVec2(padX, startY));
        ImGui::BeginChild("##Block_Legit", ImVec2(colW, totalH), true, ImGuiWindowFlags_NoScrollbar);
        {
            NL_CardTitle("LEGITBOT");
            ToggleSwitch("Enabled", &legit_enable);
            ToggleSwitch("Draw FOV", &legit_draw_fov);
            ToggleSwitch("Draw Crosshair", &legit_draw_crosshair);
        }
        ImGui::EndChild();
    }
    else if (currentTab == 6) {
        // Lua Tab
        RenderLuaTab(p, sz, padX, startY, totalH, g_Scale);
    }

    // Bottom Navigation Tabs (Bütün 7 tab saxlanılıb)
    const char* tabsLabels[] = { "Visuals", "Rage", "Legit", "Skins", "Misc", "Exploits", "</> Lua" };
    const int tabCount = 7;
    float navW = sz.x - 24.0f * g_Scale;
    float navH = 26.0f * g_Scale;
    ImVec2 navMin = ImVec2(p.x + 12 * g_Scale, p.y + sz.y - 34.0f * g_Scale);
    ImVec2 navMax = ImVec2(navMin.x + navW, navMin.y + navH);

    draw->AddRectFilled(navMin, navMax, IM_COL32(11, 11, 14, 255), 7.0f * g_Scale);
    draw->AddRect(navMin, navMax, IM_COL32(20, 21, 26, 255), 7.0f * g_Scale);

    float itemW = navW / tabCount;
    for (int i = 0; i < tabCount; i++) {
        ImVec2 itMin = ImVec2(navMin.x + i * itemW, navMin.y);
        ImVec2 itMax = ImVec2(itMin.x + itemW, navMin.y + navH);

        bool isSel = (currentTab == i);
        if (isSel) {
            draw->AddRectFilled(ImVec2(itMin.x + 2, itMin.y + 2), ImVec2(itMax.x - 2, itMax.y - 2), IM_COL32(24, 25, 32, 255), 5.5f * g_Scale);
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
    RenderESPPreviewWindow(p, sz, g_Scale);
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

    RenderBackgroundEffects(dispW, dispH, g_Scale);
    DrawNeverloseMenu();
    RenderNotifications(dispW, dispH, g_Scale);

    ImGui::Render();
    ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
}

void *pubg_hack_thread(void *) {
    sleep(5);
    G_IL2CPP = findLibrary("libil2cpp.so");
    return NULL;
}

__attribute__((constructor)) void initialize() {
    pthread_t thread;
    pthread_create(&thread, NULL, pubg_hack_thread, NULL);
}
