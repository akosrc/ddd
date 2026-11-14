// ================================================================================
// iOS Adapted Version - Neverlose UI for Standoff 2 / Unity
// ================================================================================

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#include <stdint.h>
#include <iostream>
#include <fstream>
#include <stdio.h>
#include <sstream>
#include <vector>
#include <pthread.h>
#include <chrono>
#include <unordered_map>
#include <queue>
#include <cstdlib>
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
#include "Includes/ByNameModding.h"
#include "Unity/Vector3.h"
#include "And64InlineHook/And64InlineHook.hpp"
#include "monostring.h"
#include "Includes/msg.h"

uintptr_t G_IL2CPP;
int screenWidth = 2400;
int screenHeight = 1080;
bool g_Initialized = false;
ImGuiWindow* g_window = NULL;
static float g_Scale = 1.0f;

// -------------------------------------------------------------
// STB_IMAGE FOR ANIME PNG TEXTURE
// -------------------------------------------------------------
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

const char* MineLib = OBFUSCATE("Frameworks/UnityFramework.framework/UnityFramework");
static bool enableRainbow = false, enableRainbowWall = false;
const char* Chams[] = {
    "OFF",
    "Default",
    "Shading",
    "Wireframe",
    "Outline",
    "Visibility Check Outline",
    "Visibility Check Shading",
    "Visibility Check Shading + Outline"
};

#include "RGB.h"
#include "Chams.h"

bool show_window = true;

// Цвета для колор-пикеров блока VISUALS
static float col_draw_fov[4]       = { 0.16f, 0.22f, 0.45f, 1.0f };
static float col_draw_inacc[4]     = { 0.22f, 0.23f, 0.27f, 1.0f };
static float col_multipoints[4]    = { 0.95f, 0.95f, 0.98f, 1.0f };
static float col_cast_lines[4]     = { 0.92f, 0.46f, 0.20f, 1.0f };

// Переключатель фона
static int bgEffectIndex = 4;
const char* bgEffectNames[] = { "OFF", "Snow", "Rain", "Matrix Lines", "Halftone Comic" };

// Переключатели ESP & ESP Preview
static bool show_esp_preview = true;
static bool esp_box          = true;
static bool esp_health       = true;
static bool esp_name         = true;
static bool esp_flags        = true;
static bool esp_weapon       = true;
static bool esp_distance     = true;

// ---------------- НАСТРОЙКИ LEGITBOT / AIM FOV / CROSSHAIR ----------------
static bool legit_enable         = true;
static bool legit_draw_fov       = true;
static int  legit_fov_radius     = 135;
static bool legit_draw_crosshair = true;
static int  legit_cross_size     = 9;
static int  legit_cross_gap      = 3;
static float col_legit_fov[4]    = { 0.92f, 0.33f, 0.60f, 1.0f };

// ---------------- СИСТЕМА УВЕДОМЛЕНИЙ (NOTIFICATIONS) ----------------
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
        int aTextMain = (int)(250 * alpha);
        int aTextSub = (int)(150 * alpha);
        int aBar = (int)(255 * alpha);

        fg->AddRectFilled(minP, maxP, IM_COL32(20, 21, 28, aBg), 7.0f * scale);
        fg->AddRect(minP, maxP, IM_COL32(36, 38, 50, aBorder), 7.0f * scale, 0, 1.0f * scale);

        fg->AddText(ImVec2(minP.x + 12.0f * scale, minP.y + 8.0f * scale), IM_COL32(245, 245, 250, aTextMain), g_Notifications[i].title.c_str());
        fg->AddText(ImVec2(minP.x + 12.0f * scale, minP.y + 24.0f * scale), IM_COL32(145, 150, 165, aTextSub), g_Notifications[i].message.c_str());

        float barMaxW = cardW - 24.0f * scale;
        float barCurW = barMaxW * (1.0f - progress);
        if (barCurW < 2.0f * scale) barCurW = 2.0f * scale;

        ImVec2 barMin(minP.x + 12.0f * scale, minP.y + cardH - 8.0f * scale);
        ImVec2 barMax(barMin.x + barCurW, barMin.y + 2.4f * scale);

        fg->AddRectFilled(barMin, barMax, IM_COL32(235, 85, 153, aBar), 1.2f * scale);

        startY += cardH + gapY;
        i++;
    }
}

static char luaCodeBuffer[4096] = 
    "-- Two dashes start a one-line comment.\n\n"
    "--[[\n"
    "    Adding two ['s and ]'s makes it a\n"
    "    multi-line comment.\n"
    "--]]\n\n"
    "--------------------------------------------------\n"
    "-- 1. Variables and flow control.\n"
    "--------------------------------------------------\n\n"
    "num = 42  -- Numbers can be integer or floating point.\n"
    "str = 'walternate'  -- Immutable strings like Python.\n\n"
    "function OnFrame()\n"
    "    -- Custom Lua logic\n"
    "end\n";

void RenderLuaCodeLine(const std::string& line, float scale) {
    ImVec4 colDefault  = ImVec4(0.88f, 0.89f, 0.92f, 1.0f);
    ImVec4 colComment  = ImVec4(0.48f, 0.52f, 0.60f, 1.0f);

    if (line.rfind("--", 0) == 0) {
        ImGui::TextColored(colComment, "%s", line.c_str());
        return;
    }

    size_t commentPos = line.find("--");
    if (commentPos != std::string::npos) {
        std::string codePart = line.substr(0, commentPos);
        std::string commentPart = line.substr(commentPos);

        ImGui::TextColored(colDefault, "%s", codePart.c_str());
        ImGui::SameLine(0, 0);
        ImGui::TextColored(colComment, "%s", commentPart.c_str());
    } else {
        ImGui::TextColored(colDefault, "%s", line.c_str());
    }
}

void RenderLuaTab(ImVec2 p, ImVec2 sz, float padX, float startY, float totalH, float scale) {
    float fullW = sz.x - padX * 2.0f;

    ImGui::SetCursorPos(ImVec2(padX, startY));
    ImGui::BeginChild("##Block_Lua_Editor", ImVec2(fullW, totalH), true, ImGuiWindowFlags_NoScrollbar);
    {
        ImDrawList* draw = ImGui::GetWindowDrawList();
        ImVec2 curPos = ImGui::GetCursorScreenPos();
        float availW = ImGui::GetContentRegionAvail().x;

        float gearX = curPos.x + 6.0f * scale;
        float gearY = curPos.y + 7.0f * scale;
        draw->AddCircle(ImVec2(gearX, gearY), 4.5f * scale, IM_COL32(235, 85, 153, 255), 8, 1.4f * scale);
        draw->AddCircleFilled(ImVec2(gearX, gearY), 1.5f * scale, IM_COL32(235, 85, 153, 255));

        ImGui::SetCursorPosX(ImGui::GetCursorPosX() + 18.0f * scale);
        ImGui::TextColored(ImVec4(0.92f, 0.92f, 0.95f, 1.0f), "Lua preview");
        ImGui::Spacing();

        float btnHeight = 28.0f * scale;
        float codeAreaHeight = totalH - 72.0f * scale;

        ImGui::PushStyleColor(ImGuiCol_ChildBg, ImVec4(0.045f, 0.048f, 0.058f, 1.0f));
        ImGui::PushStyleColor(ImGuiCol_Border, ImVec4(0.12f, 0.13f, 0.17f, 0.70f));
        ImGui::PushStyleVar(ImGuiStyleVar_ChildRounding, 6.0f * scale);
        ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(10.0f * scale, 10.0f * scale));

        ImGui::BeginChild("##CodeViewerChild", ImVec2(availW, codeAreaHeight), true, ImGuiWindowFlags_HorizontalScrollbar);
        {
            std::stringstream ss(luaCodeBuffer);
            std::string line;
            while (std::getline(ss, line)) {
                RenderLuaCodeLine(line, scale);
            }
        }
        ImGui::EndChild();

        ImGui::PopStyleVar(2);
        ImGui::PopStyleColor(2);

        ImGui::Spacing();
        ImGui::Spacing();

        float gapBtn = 8.0f * scale;
        float btnW = (availW - gapBtn * 2.0f) / 3.0f;

        ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0.080f, 0.085f, 0.105f, 1.0f));
        ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImVec4(0.15f, 0.11f, 0.18f, 1.0f));
        ImGui::PushStyleColor(ImGuiCol_ButtonActive, ImVec4(0.22f, 0.13f, 0.25f, 1.0f));
        ImGui::PushStyleColor(ImGuiCol_Border, ImVec4(0.18f, 0.19f, 0.24f, 0.80f));
        ImGui::PushStyleVar(ImGuiStyleVar_FrameBorderSize, 1.0f);
        ImGui::PushStyleVar(ImGuiStyleVar_FrameRounding, 5.0f * scale);

        if (ImGui::Button("Load", ImVec2(btnW, btnHeight))) {
            AddNotification("Lua Engine", "Script loaded successfully!", 3.5f);
        }

        ImGui::SameLine(0, gapBtn);

        if (ImGui::Button("Delete", ImVec2(btnW, btnHeight))) {
            luaCodeBuffer[0] = '\0';
            AddNotification("Lua Engine", "Script deleted from memory.", 3.5f);
        }

        ImGui::SameLine(0, gapBtn);

        if (ImGui::Button("Share?", ImVec2(btnW, btnHeight))) {
            AddNotification("Lua Cloud", "Script copied to clipboard!", 3.5f);
        }

        ImGui::PopStyleVar(2);
        ImGui::PopStyleColor(4);
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
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

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

struct SnowFlake {
    float x, y;
    float speed;
    float radius;
    float swayOffset;
};
static std::vector<SnowFlake> g_snow;

struct RainDrop {
    float x, y;
    float speed;
    float length;
};
static std::vector<RainDrop> g_rain;

struct MatrixLine {
    float x, y;
    float speed;
    float length;
    float alpha;
};
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

    if (bgEffectIndex == 1) {
        if (g_snow.empty()) {
            g_snow.resize(90);
            for (auto& s : g_snow) {
                s.x = (float)(rand() % (int)dispW);
                s.y = (float)(rand() % (int)dispH);
                s.speed = 40.0f + (rand() % 60);
                s.radius = (1.5f + (rand() % 25) / 10.0f) * scale;
                s.swayOffset = (float)(rand() % 100);
            }
        }
        float t = (float)ImGui::GetTime();
        for (auto& s : g_snow) {
            s.y += s.speed * dt * scale;
            s.x += sinf(t * 1.5f + s.swayOffset) * 20.0f * dt * scale;
            if (s.y > dispH) {
                s.y = -10.0f;
                s.x = (float)(rand() % (int)dispW);
            }
            if (s.x > dispW) s.x = 0;
            if (s.x < 0) s.x = dispW;
            bgDraw->AddCircleFilled(ImVec2(s.x, s.y), s.radius, IM_COL32(235, 240, 255, 175));
        }
    }
    else if (bgEffectIndex == 2) {
        if (g_rain.empty()) {
            g_rain.resize(130);
            for (auto& r : g_rain) {
                r.x = (float)(rand() % (int)dispW);
                r.y = (float)(rand() % (int)dispH);
                r.speed = 700.0f + (rand() % 450);
                r.length = (14.0f + (rand() % 12)) * scale;
            }
        }
        for (auto& r : g_rain) {
            r.y += r.speed * dt;
            r.x -= (r.speed * 0.22f) * dt;
            if (r.y > dispH || r.x < 0) {
                r.y = -20.0f;
                r.x = (float)(rand() % (int)dispW + 150);
            }
            ImVec2 pStart(r.x, r.y);
            ImVec2 pEnd(r.x - r.length * 0.22f, r.y + r.length);
            bgDraw->AddLine(pStart, pEnd, IM_COL32(165, 195, 235, 140), 1.3f * scale);
        }
    }
    else if (bgEffectIndex == 3) {
        if (g_matrix.empty()) {
            g_matrix.resize(75);
            for (auto& m : g_matrix) {
                m.x = (float)(rand() % (int)dispW);
                m.y = (float)(rand() % (int)dispH);
                m.speed = 180.0f + (rand() % 260);
                m.length = (50.0f + (rand() % 90)) * scale;
                m.alpha = 0.4f + (rand() % 60) / 100.0f;
            }
        }
        for (auto& m : g_matrix) {
            m.y += m.speed * dt * scale;
            if (m.y - m.length > dispH) {
                m.y = -10.0f;
                m.x = (float)(rand() % (int)dispW);
                m.speed = 180.0f + (rand() % 260);
            }
            ImVec2 botP(m.x, m.y);
            ImU32 headCol = IM_COL32(235, 85, 153, (int)(255 * m.alpha));
            ImU32 tailCol = IM_COL32(110, 30, 80, 0);
            bgDraw->AddRectFilledMultiColor(
                ImVec2(m.x - 1.2f * scale, m.y - m.length),
                ImVec2(m.x + 1.2f * scale, m.y),
                tailCol, tailCol, headCol, headCol
            );
            bgDraw->AddCircleFilled(botP, 2.0f * scale, IM_COL32(255, 255, 255, (int)(255 * m.alpha)));
        }
    }
    else if (bgEffectIndex == 4) {
        bgDraw->AddTriangleFilled(ImVec2(0, 0), ImVec2(dispW * 0.45f, 0), ImVec2(0, dispH * 0.55f), IM_COL32(50, 42, 38, 120));
        bgDraw->AddTriangleFilled(ImVec2(dispW, dispH), ImVec2(dispW * 0.65f, dispH), ImVec2(dispW, dispH * 0.60f), IM_COL32(45, 38, 35, 110));

        const float dotSpacing = 16.0f * scale;
        for (float y = 4.0f; y < dispH; y += dotSpacing) {
            for (float x = 4.0f; x < dispW; x += dotSpacing) {
                float fTopLeft = 1.0f - (x * 0.95f + y * 1.35f) / (dispW * 0.62f);
                float fBotRight = 1.0f - ((dispW - x) * 1.1f + (dispH - y) * 1.2f) / (dispW * 0.55f);

                float density = 0.0f;
                if (fTopLeft > density) density = fTopLeft;
                if (fBotRight > density) density = fBotRight;

                if (density > 0.05f) {
                    if (density > 1.0f) density = 1.0f;
                    float radius = (0.75f + density * 1.65f) * scale;
                    int alpha = (int)(25 + density * 165);
                    if (alpha > 200) alpha = 200;
                    bgDraw->AddCircleFilled(ImVec2(x, y), radius, IM_COL32(230, 230, 240, alpha), 12);
                }
            }
        }
    }
}

void SetupNeverloseStyle(float scale)
{
    ImGuiStyle &style = ImGui::GetStyle();

    style.WindowPadding     = ImVec2(10.0f * scale, 9.0f * scale);
    style.FramePadding      = ImVec2(6.0f * scale, 3.0f * scale);
    style.ItemSpacing       = ImVec2(5.0f * scale, 4.0f * scale);
    style.ItemInnerSpacing  = ImVec2(5.0f * scale, 3.0f * scale);
    style.IndentSpacing     = 10.0f * scale;
    style.ScrollbarSize     = 3.0f * scale;

    style.WindowRounding    = 12.0f * scale;
    style.ChildRounding     = 8.0f * scale;
    style.FrameRounding     = 4.5f * scale;
    style.PopupRounding     = 12.0f * scale;
    style.ScrollbarRounding = 2.0f * scale;
    style.GrabRounding      = 4.0f * scale;

    style.WindowBorderSize  = 1.0f;
    style.ChildBorderSize   = 1.0f;
    style.PopupBorderSize   = 1.0f;
    style.FrameBorderSize   = 1.0f;

    ImVec4* colors = style.Colors;
    colors[ImGuiCol_Text]                  = ImVec4(0.88f, 0.89f, 0.92f, 1.00f);
    colors[ImGuiCol_TextDisabled]          = ImVec4(0.38f, 0.39f, 0.45f, 1.00f);
    colors[ImGuiCol_WindowBg]              = ImVec4(0.040f, 0.042f, 0.052f, 0.98f);
    colors[ImGuiCol_ChildBg]               = ImVec4(0.065f, 0.068f, 0.082f, 0.98f);
    colors[ImGuiCol_PopupBg]               = ImVec4(0.070f, 0.072f, 0.085f, 0.99f);
    colors[ImGuiCol_Border]                = ImVec4(0.12f, 0.13f, 0.17f, 0.85f);
    colors[ImGuiCol_BorderShadow]          = ImVec4(0.00f, 0.00f, 0.00f, 0.00f);
    colors[ImGuiCol_FrameBg]               = ImVec4(0.085f, 0.090f, 0.110f, 1.00f);
    colors[ImGuiCol_FrameBgHovered]        = ImVec4(0.12f, 0.13f, 0.16f, 1.00f);
    colors[ImGuiCol_FrameBgActive]         = ImVec4(0.16f, 0.17f, 0.21f, 1.00f);
    colors[ImGuiCol_ScrollbarBg]           = ImVec4(0.00f, 0.00f, 0.00f, 0.00f);
    colors[ImGuiCol_ScrollbarGrab]         = ImVec4(0.16f, 0.17f, 0.21f, 1.00f);
    colors[ImGuiCol_CheckMark]             = ImVec4(0.92f, 0.33f, 0.60f, 1.00f);
    colors[ImGuiCol_SliderGrab]            = ImVec4(0.92f, 0.33f, 0.60f, 1.00f);
    colors[ImGuiCol_SliderGrabActive]      = ImVec4(0.98f, 0.40f, 0.68f, 1.00f);
    colors[ImGuiCol_Button]                = ImVec4(0.080f, 0.085f, 0.105f, 1.00f);
    colors[ImGuiCol_ButtonHovered]         = ImVec4(0.12f, 0.13f, 0.16f, 1.00f);
    colors[ImGuiCol_ButtonActive]          = ImVec4(0.16f, 0.17f, 0.21f, 1.00f);
    colors[ImGuiCol_Header]                = ImVec4(0.10f, 0.11f, 0.14f, 1.00f);
    colors[ImGuiCol_HeaderHovered]         = ImVec4(0.14f, 0.15f, 0.19f, 1.00f);
    colors[ImGuiCol_HeaderActive]          = ImVec4(0.18f, 0.19f, 0.24f, 1.00f);
    colors[ImGuiCol_Separator]             = ImVec4(0.11f, 0.12f, 0.15f, 0.50f);
}

struct PickerInternalState {
    float H = 0.06f;
    float S = 0.78f;
    float V = 0.92f;
    char hexBuffer[16] = "#EA7533";
    bool init = false;
};
static std::unordered_map<std::string, PickerInternalState> g_pickerStates;

void RenderModernColorPicker(float col[4], const char* pickerId, float scale) {
    ImGui::PushID(pickerId);
    ImDrawList* draw = ImGui::GetWindowDrawList();
    float availW = ImGui::GetContentRegionAvail().x;

    PickerInternalState &st = g_pickerStates[pickerId];
    if (!st.init) {
        ImGui::ColorConvertRGBtoHSV(col[0], col[1], col[2], st.H, st.S, st.V);
        snprintf(st.hexBuffer, sizeof(st.hexBuffer), "#%02X%02X%02X",
            (int)(col[0]*255.0f), (int)(col[1]*255.0f), (int)(col[2]*255.0f));
        st.init = true;
    }

    float svW = availW;
    float svH = availW * 0.74f;
    ImVec2 svMin = ImGui::GetCursorScreenPos();
    ImVec2 svMax = ImVec2(svMin.x + svW, svMin.y + svH);

    float rH, gH, bH;
    ImGui::ColorConvertHSVtoRGB(st.H, 1.0f, 1.0f, rH, gH, bH);
    ImU32 colPureHue = IM_COL32((int)(rH * 255.0f), (int)(gH * 255.0f), (int)(bH * 255.0f), 255);

    draw->AddRectFilledMultiColor(svMin, svMax, IM_COL32_WHITE, colPureHue, colPureHue, IM_COL32_WHITE);
    draw->AddRectFilledMultiColor(svMin, svMax, 0, 0, IM_COL32_BLACK, IM_COL32_BLACK);
    draw->AddRect(svMin, svMax, IM_COL32(36, 38, 50, 255), 8.0f * scale, 0, 1.2f * scale);

    ImGui::InvisibleButton("##svArea", ImVec2(svW, svH));
    if (ImGui::IsItemActive() || (ImGui::IsItemHovered() && ImGui::GetIO().MouseDown[0])) {
        ImVec2 mPos = ImGui::GetIO().MousePos;
        st.S = ImClamp((mPos.x - svMin.x) / svW, 0.0f, 1.0f);
        st.V = 1.0f - ImClamp((mPos.y - svMin.y) / svH, 0.0f, 1.0f);
        ImGui::ColorConvertHSVtoRGB(st.H, st.S, st.V, col[0], col[1], col[2]);
        snprintf(st.hexBuffer, sizeof(st.hexBuffer), "#%02X%02X%02X",
            (int)(col[0]*255.0f), (int)(col[1]*255.0f), (int)(col[2]*255.0f));
    }

    ImVec2 curCenter = ImVec2(svMin.x + st.S * svW, svMin.y + (1.0f - st.V) * svH);
    draw->AddCircle(curCenter, 6.0f * scale, IM_COL32(255, 255, 255, 255), 20, 2.2f * scale);
    draw->AddCircle(curCenter, 7.2f * scale, IM_COL32(0, 0, 0, 160), 20, 1.0f * scale);

    ImGui::Spacing();
    ImGui::Spacing();

    float touchBarH = 20.0f * scale;
    float drawBarH  = 13.0f * scale;
    float iconW     = 22.0f * scale;
    float sliderW   = availW - iconW;

    ImVec2 hRow = ImGui::GetCursorScreenPos();
    ImVec2 pipCenter = ImVec2(hRow.x + 6.0f * scale, hRow.y + touchBarH * 0.5f);
    draw->AddLine(ImVec2(pipCenter.x - 3.5f * scale, pipCenter.y - 3.5f * scale), ImVec2(pipCenter.x + 3.0f * scale, pipCenter.y + 3.0f * scale), IM_COL32(185, 190, 205, 255), 1.6f * scale);
    draw->AddCircleFilled(ImVec2(pipCenter.x - 3.5f * scale, pipCenter.y - 3.5f * scale), 2.4f * scale, IM_COL32(185, 190, 205, 255));
    draw->AddLine(ImVec2(pipCenter.x + 2.0f * scale, pipCenter.y + 2.0f * scale), ImVec2(pipCenter.x + 5.0f * scale, pipCenter.y + 5.0f * scale), IM_COL32(185, 190, 205, 255), 1.2f * scale);

    ImVec2 hueMin = ImVec2(hRow.x + iconW, hRow.y + (touchBarH - drawBarH) * 0.5f);
    ImVec2 hueMax = ImVec2(hueMin.x + sliderW, hueMin.y + drawBarH);

    const ImU32 hueGradients[7] = {
        IM_COL32(255, 0, 0, 255), IM_COL32(255, 255, 0, 255), IM_COL32(0, 255, 0, 255),
        IM_COL32(0, 255, 255, 255), IM_COL32(0, 0, 255, 255), IM_COL32(255, 0, 255, 255),
        IM_COL32(255, 0, 0, 255)
    };
    float segW = sliderW / 6.0f;
    for (int i = 0; i < 6; i++) {
        draw->AddRectFilledMultiColor(
            ImVec2(hueMin.x + i * segW, hueMin.y),
            ImVec2(hueMin.x + (i + 1) * segW, hueMax.y),
            hueGradients[i], hueGradients[i+1], hueGradients[i+1], hueGradients[i]
        );
    }
    draw->AddRect(hueMin, hueMax, IM_COL32(32, 34, 44, 255), 6.0f * scale, 0, 1.0f * scale);

    ImGui::SetCursorScreenPos(ImVec2(hRow.x + iconW, hRow.y));
    ImGui::InvisibleButton("##hueSliderBtn", ImVec2(sliderW, touchBarH));
    if (ImGui::IsItemActive() || (ImGui::IsItemHovered() && ImGui::GetIO().MouseDown[0])) {
        float mX = ImGui::GetIO().MousePos.x;
        st.H = ImClamp((mX - hueMin.x) / sliderW, 0.0f, 0.999f);
        if (st.S < 0.08f) st.S = 0.85f;
        if (st.V < 0.08f) st.V = 0.92f;
        ImGui::ColorConvertHSVtoRGB(st.H, st.S, st.V, col[0], col[1], col[2]);
        snprintf(st.hexBuffer, sizeof(st.hexBuffer), "#%02X%02X%02X",
            (int)(col[0]*255.0f), (int)(col[1]*255.0f), (int)(col[2]*255.0f));
    }
    float hThumbX = hueMin.x + st.H * sliderW;
    draw->AddRectFilled(ImVec2(hThumbX - 4.5f * scale, hueMin.y - 2.0f * scale), ImVec2(hThumbX + 4.5f * scale, hueMax.y + 2.0f * scale), IM_COL32_WHITE, 3.5f * scale);
    draw->AddRect(ImVec2(hThumbX - 4.5f * scale, hueMin.y - 2.0f * scale), ImVec2(hThumbX + 4.5f * scale, hueMax.y + 2.0f * scale), IM_COL32(0, 0, 0, 140), 3.5f * scale);

    ImGui::Spacing();

    ImVec2 aRow = ImGui::GetCursorScreenPos();
    ImVec2 aMin = ImVec2(aRow.x + iconW, aRow.y + (touchBarH - drawBarH) * 0.5f);
    ImVec2 aMax = ImVec2(aMin.x + sliderW, aMin.y + drawBarH);

    draw->AddRectFilled(aMin, aMax, IM_COL32(38, 40, 48, 255), 6.0f * scale);
    for (float cx = aMin.x; cx < aMax.x; cx += 7.0f * scale) {
        draw->AddRectFilled(ImVec2(cx, aMin.y), ImVec2(ImMin(cx + 3.5f * scale, aMax.x), aMin.y + drawBarH * 0.5f), IM_COL32(65, 68, 80, 255));
        draw->AddRectFilled(ImVec2(ImMin(cx + 3.5f * scale, aMax.x), aMin.y + drawBarH * 0.5f), ImVec2(ImMin(cx + 7.0f * scale, aMax.x), aMax.y), IM_COL32(65, 68, 80, 255));
    }

    ImU32 colNoA = IM_COL32((int)(col[0]*255), (int)(col[1]*255), (int)(col[2]*255), 0);
    ImU32 colFullA = IM_COL32((int)(col[0]*255), (int)(col[1]*255), (int)(col[2]*255), 255);
    draw->AddRectFilledMultiColor(aMin, aMax, colNoA, colFullA, colFullA, colNoA);
    draw->AddRect(aMin, aMax, IM_COL32(32, 34, 44, 255), 6.0f * scale, 0, 1.0f * scale);

    ImGui::SetCursorScreenPos(ImVec2(aRow.x + iconW, aRow.y));
    ImGui::InvisibleButton("##alphaSliderBtn", ImVec2(sliderW, touchBarH));
    if (ImGui::IsItemActive() || (ImGui::IsItemHovered() && ImGui::GetIO().MouseDown[0])) {
        float mX = ImGui::GetIO().MousePos.x;
        col[3] = ImClamp((mX - aMin.x) / sliderW, 0.0f, 1.0f);
    }
    float aThumbX = aMin.x + col[3] * sliderW;
    draw->AddRectFilled(ImVec2(aThumbX - 4.5f * scale, aMin.y - 2.0f * scale), ImVec2(aThumbX + 4.5f * scale, aMax.y + 2.0f * scale), IM_COL32_WHITE, 3.5f * scale);
    draw->AddRect(ImVec2(aThumbX - 4.5f * scale, aMin.y - 2.0f * scale), ImVec2(aThumbX + 4.5f * scale, aMax.y + 2.0f * scale), IM_COL32(0, 0, 0, 140), 3.5f * scale);

    ImGui::Spacing();
    ImGui::Spacing();

    float boxH = 26.0f * scale;

    ImGui::PushStyleColor(ImGuiCol_FrameBg, ImVec4(0.07f, 0.075f, 0.10f, 1.0f));
    ImGui::PushStyleColor(ImGuiCol_Border, ImVec4(0.16f, 0.17f, 0.22f, 1.0f));
    ImGui::PushStyleVar(ImGuiStyleVar_FrameRounding, 5.0f * scale);
    ImGui::PushStyleVar(ImGuiStyleVar_FrameBorderSize, 1.0f);
    ImGui::PushStyleVar(ImGuiStyleVar_FramePadding, ImVec2(6.0f * scale, 3.0f * scale));

    ImGui::SetNextItemWidth(availW * 0.48f);
    if (ImGui::InputText("##hexInputBox", st.hexBuffer, sizeof(st.hexBuffer), ImGuiInputTextFlags_CharsUppercase)) {
        const char* hexStr = st.hexBuffer;
        if (hexStr[0] == '#') hexStr++;
        if (strlen(hexStr) == 6) {
            unsigned int rVal, gVal, bVal;
            if (sscanf(hexStr, "%02x%02x%02x", &rVal, &gVal, &bVal) == 3) {
                col[0] = rVal / 255.0f;
                col[1] = gVal / 255.0f;
                col[2] = bVal / 255.0f;
                ImGui::ColorConvertRGBtoHSV(col[0], col[1], col[2], st.H, st.S, st.V);
            }
        }
    }

    ImGui::SameLine(availW * 0.54f);
    char pctBuf[32];
    snprintf(pctBuf, sizeof(pctBuf), "%d%%", (int)(col[3] * 100.0f));
    ImGui::Button(pctBuf, ImVec2(availW * 0.46f, boxH));

    ImGui::PopStyleVar(3);
    ImGui::PopStyleColor(2);

    ImGui::Spacing();
    ImGui::Spacing();

    static ImVec4 savedPresets[4] = {
        ImVec4(0.92f, 0.46f, 0.20f, 1.0f),
        ImVec4(0.92f, 0.33f, 0.60f, 1.0f),
        ImVec4(0.95f, 0.55f, 0.58f, 1.0f),
        ImVec4(0.95f, 0.65f, 0.70f, 1.0f)
    };
    static int activePreset = 0;

    ImVec2 swRow = ImGui::GetCursorScreenPos();
    float rCircle = 13.0f * scale;
    float gapP = (availW - rCircle * 2.0f * 5.0f) / 4.0f;

    for (int i = 0; i < 4; i++) {
        ImVec2 cCenter = ImVec2(swRow.x + rCircle + i * (rCircle * 2.0f + gapP), swRow.y + rCircle);
        ImU32 pCol = ImGui::ColorConvertFloat4ToU32(savedPresets[i]);

        draw->AddCircleFilled(cCenter, rCircle, pCol, 24);

        if (activePreset == i) {
            draw->AddCircle(cCenter, rCircle + 2.5f * scale, IM_COL32_WHITE, 24, 2.0f * scale);
        }

        ImGui::SetCursorScreenPos(ImVec2(cCenter.x - rCircle, cCenter.y - rCircle));
        char pId[32];
        snprintf(pId, sizeof(pId), "##pBtn_%d", i);
        if (ImGui::InvisibleButton(pId, ImVec2(rCircle * 2.0f, rCircle * 2.0f))) {
            activePreset = i;
            col[0] = savedPresets[i].x;
            col[1] = savedPresets[i].y;
            col[2] = savedPresets[i].z;
            col[3] = savedPresets[i].w;
            ImGui::ColorConvertRGBtoHSV(col[0], col[1], col[2], st.H, st.S, st.V);
            snprintf(st.hexBuffer, sizeof(st.hexBuffer), "#%02X%02X%02X",
                (int)(col[0]*255.0f), (int)(col[1]*255.0f), (int)(col[2]*255.0f));
        }
    }

    ImVec2 plusCenter = ImVec2(swRow.x + rCircle + 4 * (rCircle * 2.0f + gapP), swRow.y + rCircle);
    draw->AddCircleFilled(plusCenter, rCircle, IM_COL32(18, 19, 25, 255), 24);
    draw->AddCircle(plusCenter, rCircle, IM_COL32(40, 42, 54, 255), 24, 1.3f * scale);
    draw->AddLine(ImVec2(plusCenter.x - 5.0f * scale, plusCenter.y), ImVec2(plusCenter.x + 5.0f * scale, plusCenter.y), IM_COL32_WHITE, 1.8f * scale);
    draw->AddLine(ImVec2(plusCenter.x, plusCenter.y - 5.0f * scale), ImVec2(plusCenter.x, plusCenter.y + 5.0f * scale), IM_COL32_WHITE, 1.8f * scale);

    ImGui::SetCursorScreenPos(ImVec2(plusCenter.x - rCircle, plusCenter.y - rCircle));
    if (ImGui::InvisibleButton("##addCurrentColorBtn", ImVec2(rCircle * 2.0f, rCircle * 2.0f))) {
        savedPresets[activePreset] = ImVec4(col[0], col[1], col[2], col[3]);
    }

    ImGui::SetCursorScreenPos(ImVec2(swRow.x, swRow.y + rCircle * 2.0f + 8.0f * scale));
    ImGui::PopID();
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

    if (hasDots) {
        float dotsX = switch_bb.Min.x - 17.0f * g_Scale;
        float dotsY = pos.y + (rowH - ImGui::GetTextLineHeight()) * 0.5f;
        window->DrawList->AddText(ImVec2(dotsX, dotsY), IM_COL32(75, 78, 92, 255), "...");
    }

    ImU32 bg_col = *v ? IM_COL32(235, 85, 153, 255) : IM_COL32(26, 27, 33, 255);
    window->DrawList->AddRectFilled(switch_bb.Min, switch_bb.Max, bg_col, radius);

    float circle_x = *v ? (switch_bb.Max.x - radius) : (switch_bb.Min.x + radius);
    float circle_y = switch_bb.Min.y + radius;
    window->DrawList->AddCircleFilled(ImVec2(circle_x, circle_y), radius - 1.8f * g_Scale, IM_COL32(245, 245, 250, 255));

    return pressed;
}

bool ToggleSwitchWithColor(const char* label, bool* v, float color[4], const char* colorId, bool hasTwoColor = false) {
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    if (window->SkipItems) return false;

    ImGuiContext& g = *GImGui;
    const ImGuiID id = window->GetID(label);
    const ImVec2 pos = window->DC.CursorPos;

    float height = 13.5f * g_Scale;
    float width = 25.0f * g_Scale;
    float radius = height * 0.5f;
    float boxW = 12.5f * g_Scale;
    float boxH = 12.5f * g_Scale;
    float boxGap = 7.0f * g_Scale;

    float availW = ImGui::GetContentRegionAvail().x;
    float rowH = 20.0f * g_Scale;
    const ImRect total_bb(pos, ImVec2(pos.x + availW, pos.y + rowH));

    ImGui::ItemSize(total_bb, 0.0f);
    if (!ImGui::ItemAdd(total_bb, id)) return false;

    const ImRect switch_bb(ImVec2(total_bb.Max.x - width, pos.y + (rowH - height) * 0.5f), ImVec2(total_bb.Max.x, pos.y + (rowH + height) * 0.5f));
    const ImRect color_bb(ImVec2(switch_bb.Min.x - boxGap - boxW, pos.y + (rowH - boxH) * 0.5f), ImVec2(switch_bb.Min.x - boxGap, pos.y + (rowH + boxH) * 0.5f));

    window->DrawList->AddText(ImVec2(pos.x, pos.y + (rowH - ImGui::GetTextLineHeight()) * 0.5f), ImGui::GetColorU32(ImGuiCol_Text), label);

    ImGuiID colBtnId = window->GetID(colorId);
    bool colHovered, colHeld;
    bool colPressed = ImGui::ButtonBehavior(color_bb, colBtnId, &colHovered, &colHeld);
    if (colPressed) {
        ImGui::OpenPopup(colorId);
    }

    ImU32 curColorU32 = ImGui::ColorConvertFloat4ToU32(ImVec4(color[0], color[1], color[2], color[3]));
    window->DrawList->AddRectFilled(color_bb.Min, color_bb.Max, curColorU32, 2.5f * g_Scale);

    if (hasTwoColor) {
        window->DrawList->AddTriangleFilled(
            ImVec2(color_bb.Min.x, color_bb.Max.y),
            ImVec2(color_bb.Min.x + 5.5f * g_Scale, color_bb.Max.y),
            ImVec2(color_bb.Min.x, color_bb.Max.y - 5.5f * g_Scale),
            IM_COL32(130, 205, 55, 255)
        );
    }

    window->DrawList->AddRect(color_bb.Min, color_bb.Max, colHovered ? IM_COL32(200, 200, 220, 255) : IM_COL32(45, 47, 58, 255), 2.5f * g_Scale, 0, 1.0f);

    ImGui::SetNextWindowSize(ImVec2(240.0f * g_Scale, 335.0f * g_Scale), ImGuiCond_Always);
    ImGui::PushStyleColor(ImGuiCol_PopupBg, ImVec4(0.08f, 0.085f, 0.10f, 0.99f));
    ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(10.0f * g_Scale, 10.0f * g_Scale));
    ImGui::PushStyleVar(ImGuiStyleVar_PopupRounding, 12.0f * g_Scale);

    ImGuiWindowFlags popFlags = ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoScrollWithMouse;
    if (ImGui::BeginPopup(colorId, popFlags)) {
        RenderModernColorPicker(color, colorId, g_Scale);
        ImGui::EndPopup();
    }
    ImGui::PopStyleVar(2);
    ImGui::PopStyleColor();

    bool swHovered, swHeld;
    bool swPressed = ImGui::ButtonBehavior(switch_bb, id, &swHovered, &swHeld);
    if (swPressed) {
        *v = !(*v);
        ImGui::MarkItemEdited(id);
    }

    ImU32 bg_col = *v ? IM_COL32(235, 85, 153, 255) : IM_COL32(26, 27, 33, 255);
    window->DrawList->AddRectFilled(switch_bb.Min, switch_bb.Max, bg_col, radius);

    float circle_x = *v ? (switch_bb.Max.x - radius) : (switch_bb.Min.x + radius);
    float circle_y = switch_bb.Min.y + radius;
    window->DrawList->AddCircleFilled(ImVec2(circle_x, circle_y), radius - 1.8f * g_Scale, IM_COL32(245, 245, 250, 255));

    return swPressed;
}

bool NL_SliderInt(const char* label, int* v, int v_min, int v_max) {
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    if (window->SkipItems) return false;

    ImGuiContext& g = *GImGui;
    const ImGuiID id = window->GetID(label);
    const ImVec2 pos = window->DC.CursorPos;

    float availW = ImGui::GetContentRegionAvail().x;
    float rowH = 20.0f * g_Scale;
    const ImRect total_bb(pos, ImVec2(pos.x + availW, pos.y + rowH));

    ImGui::ItemSize(total_bb, 0.0f);
    if (!ImGui::ItemAdd(total_bb, id)) return false;

    window->DrawList->AddText(ImVec2(pos.x, pos.y + (rowH - ImGui::GetTextLineHeight()) * 0.5f), ImGui::GetColorU32(ImGuiCol_Text), label);

    float sliderW = 60.0f * g_Scale;
    float trackH = 2.8f * g_Scale;

    ImVec2 trackMin = ImVec2(total_bb.Max.x - sliderW, pos.y + (rowH - trackH) * 0.5f);
    ImVec2 trackMax = ImVec2(total_bb.Max.x, trackMin.y + trackH);
    const ImRect track_bb(ImVec2(trackMin.x - 5 * g_Scale, trackMin.y - 6 * g_Scale), ImVec2(trackMax.x + 5 * g_Scale, trackMax.y + 6 * g_Scale));

    char valBuf[32];
    snprintf(valBuf, sizeof(valBuf), "%d", *v);
    ImVec2 valSz = ImGui::CalcTextSize(valBuf);

    window->DrawList->AddText(ImVec2(trackMin.x - valSz.x - 22.0f * g_Scale, pos.y + (rowH - ImGui::GetTextLineHeight()) * 0.5f), IM_COL32(75, 78, 92, 255), "...");
    window->DrawList->AddText(ImVec2(trackMin.x - valSz.x - 6.0f * g_Scale, pos.y + (rowH - ImGui::GetTextLineHeight()) * 0.5f), ImGui::GetColorU32(ImGuiCol_TextDisabled), valBuf);

    bool hovered, held;
    ImGui::ButtonBehavior(track_bb, id, &hovered, &held);
    if (held) {
        float t = (g.IO.MousePos.x - trackMin.x) / sliderW;
        if (t < 0.0f) t = 0.0f;
        if (t > 1.0f) t = 1.0f;
        *v = v_min + (int)(t * (v_max - v_min) + 0.5f);
        ImGui::MarkItemEdited(id);
    }

    window->DrawList->AddRectFilled(trackMin, trackMax, IM_COL32(26, 27, 33, 255), 1.4f * g_Scale);

    float frac = (float)(*v - v_min) / (float)(v_max - v_min);
    if (frac < 0.0f) frac = 0.0f;
    if (frac > 1.0f) frac = 1.0f;

    ImVec2 activeMax = ImVec2(trackMin.x + frac * sliderW, trackMax.y);
    window->DrawList->AddRectFilled(trackMin, activeMax, IM_COL32(235, 85, 153, 255), 1.4f * g_Scale);
    window->DrawList->AddCircleFilled(ImVec2(activeMax.x, trackMin.y + trackH * 0.5f), 4.2f * g_Scale, IM_COL32(245, 245, 250, 255));

    return held;
}

void NL_RowCombo(const char* label, int* current_item, const char* const items[], int items_count, float comboWidth = 92.0f) {
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    if (window->SkipItems) return;

    ImVec2 pos = window->DC.CursorPos;
    float availW = ImGui::GetContentRegionAvail().x;
    float rowH = 21.0f * g_Scale;
    float cWidth = comboWidth * g_Scale;

    ImRect total_bb(pos, ImVec2(pos.x + availW, pos.y + rowH));
    ImGui::ItemSize(total_bb, 0.0f);
    const ImGuiID id = window->GetID(label);
    if (!ImGui::ItemAdd(total_bb, id)) return;

    window->DrawList->AddText(ImVec2(pos.x, pos.y + (rowH - ImGui::GetTextLineHeight()) * 0.5f), ImGui::GetColorU32(ImGuiCol_Text), label);

    ImGui::SameLine(availW - cWidth);
    ImGui::SetCursorPosY(ImGui::GetCursorPosY() - 2.0f * g_Scale);

    ImGui::PushStyleColor(ImGuiCol_FrameBg, ImVec4(0.080f, 0.085f, 0.105f, 1.0f));
    ImGui::PushStyleColor(ImGuiCol_Border, ImVec4(0.13f, 0.14f, 0.18f, 0.8f));
    ImGui::PushStyleVar(ImGuiStyleVar_FrameBorderSize, 1.0f);
    ImGui::PushStyleVar(ImGuiStyleVar_FrameRounding, 4.0f * g_Scale);

    char cId[32];
    snprintf(cId, sizeof(cId), "##combo_%s", label);
    ImGui::SetNextItemWidth(cWidth);
    ImGui::Combo(cId, current_item, items, items_count);

    ImGui::PopStyleVar(2);
    ImGui::PopStyleColor(2);
}

void NL_CardTitle(const char* title) {
    ImGui::TextColored(ImVec4(0.38f, 0.39f, 0.46f, 1.00f), "%s", title);
    ImGui::Spacing();
}

void RenderLegitOverlay(float dispW, float dispH, float scale) {
    if (!legit_draw_fov && !legit_draw_crosshair) return;

    ImDrawList* fg = ImGui::GetForegroundDrawList();
    ImVec2 center(dispW * 0.5f, dispH * 0.5f);

    ImU32 baseCol = ImGui::ColorConvertFloat4ToU32(ImVec4(col_legit_fov[0], col_legit_fov[1], col_legit_fov[2], col_legit_fov[3]));
    ImU32 glowCol = ImGui::ColorConvertFloat4ToU32(ImVec4(col_legit_fov[0], col_legit_fov[1], col_legit_fov[2], col_legit_fov[3] * 0.28f));

    if (legit_draw_fov) {
        float r = (float)legit_fov_radius * scale;
        fg->AddCircle(center, r + 0.8f * scale, glowCol, 64, 3.2f * scale);
        fg->AddCircle(center, r, baseCol, 64, 1.4f * scale);
        fg->AddCircle(center, r - 1.0f * scale, IM_COL32(15, 15, 20, 160), 64, 0.9f * scale);
    }

    if (legit_draw_crosshair) {
        float size = (float)legit_cross_size * scale;
        float gap  = (float)legit_cross_gap * scale;
        float th   = 1.5f * scale;

        fg->AddLine(ImVec2(center.x - size - 1, center.y), ImVec2(center.x - gap + 1, center.y), IM_COL32_BLACK, th + 1.2f);
        fg->AddLine(ImVec2(center.x + gap - 1, center.y), ImVec2(center.x + size + 1, center.y), IM_COL32_BLACK, th + 1.2f);
        fg->AddLine(ImVec2(center.x, center.y - size - 1), ImVec2(center.x, center.y - gap + 1), IM_COL32_BLACK, th + 1.2f);
        fg->AddLine(ImVec2(center.x, center.y + gap - 1), ImVec2(center.x, center.y + size + 1), IM_COL32_BLACK, th + 1.2f);

        fg->AddLine(ImVec2(center.x - size, center.y), ImVec2(center.x - gap, center.y), baseCol, th);
        fg->AddLine(ImVec2(center.x + gap, center.y), ImVec2(center.x + size, center.y), baseCol, th);
        fg->AddLine(ImVec2(center.x, center.y - size), ImVec2(center.x, center.y - gap), baseCol, th);
        fg->AddLine(ImVec2(center.x, center.y + gap), ImVec2(center.x, center.y + size), baseCol, th);
    }
}

void RenderESPPreviewWindow(ImVec2 mainPos, ImVec2 mainSz, float scale) {
    if (!show_esp_preview) return;

    float cardW = 210.0f * scale;
    float cardH = mainSz.y;

    float cardX = mainPos.x + mainSz.x + 12.0f * scale;
    if (cardX + cardW > (float)screenWidth - 6.0f * scale) {
        cardX = mainPos.x - cardW - 12.0f * scale;
        if (cardX < 6.0f * scale) cardX = 10.0f * scale;
    }
    float cardY = mainPos.y;

    ImGuiWindowFlags prevFlags = ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoScrollbar;
    ImGui::PushStyleColor(ImGuiCol_WindowBg, ImVec4(0.055f, 0.058f, 0.072f, 0.98f));
    ImGui::PushStyleColor(ImGuiCol_Border, ImVec4(0.18f, 0.14f, 0.24f, 0.90f));
    ImGui::PushStyleVar(ImGuiStyleVar_WindowRounding, 12.0f * scale);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowBorderSize, 1.2f * scale);

    if (ImGui::Begin("##ESP_Preview_Card", NULL, prevFlags)) {
        ImDrawList* draw = ImGui::GetWindowDrawList();
        ImVec2 p = ImGui::GetWindowPos();
        ImVec2 sz = ImGui::GetWindowSize();

        draw->AddLine(ImVec2(p.x + 14.0f * scale, p.y + 6.0f * scale), ImVec2(p.x + sz.x - 14.0f * scale, p.y + 6.0f * scale), IM_COL32(235, 85, 153, 230), 2.0f * scale);
        draw->AddText(ImVec2(p.x + 14.0f * scale, p.y + 14.0f * scale), IM_COL32(245, 245, 250, 255), "Preview");
        draw->AddText(ImVec2(p.x + sz.x - 28.0f * scale, p.y + 14.0f * scale), IM_COL32(110, 115, 130, 255), "...");

        ImVec2 gridMin(p.x + 10.0f * scale, p.y + 38.0f * scale);
        ImVec2 gridMax(p.x + sz.x - 10.0f * scale, p.y + sz.y - 12.0f * scale);
        float gStep = 32.0f * scale;

        for (float gx = gridMin.x; gx <= gridMax.x; gx += gStep) {
            draw->AddLine(ImVec2(gx, gridMin.y), ImVec2(gx, gridMax.y), IM_COL32(24, 25, 34, 180), 1.0f);
        }
        for (float gy = gridMin.y; gy <= gridMax.y; gy += gStep) {
            draw->AddLine(ImVec2(gridMin.x, gy), ImVec2(gridMax.x, gy), IM_COL32(24, 25, 34, 180), 1.0f);
        }

        float boxW = 88.0f * scale;
        float boxH = 220.0f * scale;
        ImVec2 boxMin(p.x + (sz.x - boxW) * 0.5f, p.y + 74.0f * scale);
        ImVec2 boxMax(boxMin.x + boxW, boxMin.y + boxH);

        float t = (float)ImGui::GetTime();
        float breathY = sinf(t * 2.2f) * 1.6f * scale;

#if HAS_CUSTOM_ANIME_IMAGE
        if (g_AnimeTexture == 0 && anime_image_png_len > 0) {
            g_AnimeTexture = LoadTextureFromMemory(anime_image_png, anime_image_png_len, &g_AnimeWidth, &g_AnimeHeight);
        }
#endif

        if (g_AnimeTexture != 0) {
            ImVec2 imgMin(boxMin.x + 3.0f * scale, boxMin.y + 6.0f * scale + breathY);
            ImVec2 imgMax(boxMax.x - 3.0f * scale, boxMax.y - 6.0f * scale + breathY);
            draw->AddImage((ImTextureID)(intptr_t)g_AnimeTexture, imgMin, imgMax);
        } else {
            float hairSway = sinf(t * 1.6f) * 1.5f * scale;
            ImVec2 modelCenter(boxMin.x + boxW * 0.5f, boxMin.y + 36.0f * scale + breathY);

            draw->AddTriangleFilled(
                ImVec2(modelCenter.x - 18.0f * scale + hairSway, modelCenter.y + 76.0f * scale),
                ImVec2(modelCenter.x + 18.0f * scale + hairSway, modelCenter.y + 76.0f * scale),
                ImVec2(modelCenter.x, modelCenter.y - 14.0f * scale),
                IM_COL32(26, 25, 36, 255)
            );

            float legTop = modelCenter.y + 82.0f * scale;
            float legBot = boxMax.y - 10.0f * scale;
            draw->AddRectFilled(ImVec2(modelCenter.x - 11.0f * scale, legTop), ImVec2(modelCenter.x - 2.5f * scale, legBot), IM_COL32(18, 18, 22, 255), 2.0f * scale);
            draw->AddRectFilled(ImVec2(modelCenter.x + 2.5f * scale, legTop), ImVec2(modelCenter.x + 11.0f * scale, legBot), IM_COL32(18, 18, 22, 255), 2.0f * scale);
            draw->AddCircleFilled(ImVec2(modelCenter.x - 6.5f * scale, legBot + 3.0f * scale), 4.2f * scale, IM_COL32(12, 12, 16, 255));
            draw->AddCircleFilled(ImVec2(modelCenter.x + 6.5f * scale, legBot + 3.0f * scale), 4.2f * scale, IM_COL32(12, 12, 16, 255));

            ImVec2 skirtTop(modelCenter.x, modelCenter.y + 54.0f * scale);
            draw->AddTriangleFilled(
                ImVec2(skirtTop.x - 18.0f * scale, skirtTop.y + 26.0f * scale),
                ImVec2(skirtTop.x + 18.0f * scale, skirtTop.y + 26.0f * scale),
                skirtTop,
                IM_COL32(175, 30, 48, 255)
            );
            for (int s = -2; s <= 2; s++) {
                draw->AddLine(
                    ImVec2(skirtTop.x + s * 4.0f * scale, skirtTop.y + 4.0f * scale),
                    ImVec2(skirtTop.x + s * 8.0f * scale, skirtTop.y + 26.0f * scale),
                    IM_COL32(85, 12, 24, 255),
                    1.3f * scale
                );
            }

            draw->AddRectFilled(
                ImVec2(modelCenter.x - 13.0f * scale, modelCenter.y + 14.0f * scale),
                ImVec2(modelCenter.x + 13.0f * scale, modelCenter.y + 55.0f * scale),
                IM_COL32(32, 33, 46, 255),
                4.0f * scale
            );
            draw->AddTriangleFilled(
                ImVec2(modelCenter.x - 6.0f * scale, modelCenter.y + 14.0f * scale),
                ImVec2(modelCenter.x + 6.0f * scale, modelCenter.y + 14.0f * scale),
                ImVec2(modelCenter.x, modelCenter.y + 24.0f * scale),
                IM_COL32(245, 245, 250, 255)
            );
            draw->AddTriangleFilled(
                ImVec2(modelCenter.x - 2.5f * scale, modelCenter.y + 20.0f * scale),
                ImVec2(modelCenter.x + 2.5f * scale, modelCenter.y + 20.0f * scale),
                ImVec2(modelCenter.x, modelCenter.y + 36.0f * scale),
                IM_COL32(235, 45, 80, 255)
            );

            draw->AddLine(ImVec2(modelCenter.x - 12.0f * scale, modelCenter.y + 18.0f * scale), ImVec2(modelCenter.x - 6.0f * scale, modelCenter.y + 46.0f * scale), IM_COL32(32, 33, 46, 255), 3.2f * scale);
            draw->AddLine(ImVec2(modelCenter.x + 12.0f * scale, modelCenter.y + 18.0f * scale), ImVec2(modelCenter.x + 6.0f * scale, modelCenter.y + 46.0f * scale), IM_COL32(32, 33, 46, 255), 3.2f * scale);
            draw->AddCircleFilled(ImVec2(modelCenter.x, modelCenter.y + 48.0f * scale), 4.0f * scale, IM_COL32(250, 222, 208, 255));

            draw->AddCircleFilled(ImVec2(modelCenter.x, modelCenter.y), 15.0f * scale, IM_COL32(28, 26, 38, 255));
            draw->AddCircleFilled(ImVec2(modelCenter.x, modelCenter.y + 1.0f * scale), 10.5f * scale, IM_COL32(250, 222, 208, 255));

            draw->AddCircleFilled(ImVec2(modelCenter.x - 4.2f * scale, modelCenter.y + 1.0f * scale), 2.2f * scale, IM_COL32(40, 50, 85, 255));
            draw->AddCircleFilled(ImVec2(modelCenter.x + 4.2f * scale, modelCenter.y + 1.0f * scale), 2.2f * scale, IM_COL32(40, 50, 85, 255));
            draw->AddCircleFilled(ImVec2(modelCenter.x - 4.6f * scale, modelCenter.y + 0.4f * scale), 0.9f * scale, IM_COL32_WHITE);
            draw->AddCircleFilled(ImVec2(modelCenter.x + 3.8f * scale, modelCenter.y + 0.4f * scale), 0.9f * scale, IM_COL32_WHITE);

            draw->AddCircleFilled(ImVec2(modelCenter.x - 6.5f * scale, modelCenter.y + 4.5f * scale), 2.0f * scale, IM_COL32(245, 150, 160, 130));
            draw->AddCircleFilled(ImVec2(modelCenter.x + 6.5f * scale, modelCenter.y + 4.5f * scale), 2.0f * scale, IM_COL32(245, 150, 160, 130));

            draw->AddTriangleFilled(
                ImVec2(modelCenter.x - 11.0f * scale, modelCenter.y - 7.0f * scale),
                ImVec2(modelCenter.x - 3.0f * scale, modelCenter.y + 4.0f * scale),
                ImVec2(modelCenter.x - 14.0f * scale + hairSway, modelCenter.y + 24.0f * scale),
                IM_COL32(32, 30, 42, 255)
            );
            draw->AddTriangleFilled(
                ImVec2(modelCenter.x + 11.0f * scale, modelCenter.y - 7.0f * scale),
                ImVec2(modelCenter.x + 3.0f * scale, modelCenter.y + 4.0f * scale),
                ImVec2(modelCenter.x + 14.0f * scale + hairSway, modelCenter.y + 24.0f * scale),
                IM_COL32(32, 30, 42, 255)
            );
        }

        if (esp_box) {
            draw->AddRect(ImVec2(boxMin.x - 1.5f * scale, boxMin.y - 1.5f * scale), ImVec2(boxMax.x + 1.5f * scale, boxMax.y + 1.5f * scale), IM_COL32(235, 85, 153, 50), 0.0f, 0, 2.5f * scale);
            draw->AddRect(boxMin, boxMax, IM_COL32(235, 85, 153, 255), 0.0f, 0, 1.8f * scale);
            draw->AddRect(ImVec2(boxMin.x + 1.2f * scale, boxMin.y + 1.2f * scale), ImVec2(boxMax.x - 1.2f * scale, boxMax.y - 1.2f * scale), IM_COL32(10, 10, 14, 180), 0.0f, 0, 1.0f);
        }

        if (esp_name) {
            const char* pName = "FIXNEY";
            ImVec2 nSz = ImGui::CalcTextSize(pName);
            draw->AddText(ImVec2(boxMin.x + (boxW - nSz.x) * 0.5f, boxMin.y - nSz.y - 4.0f * scale), IM_COL32(245, 245, 250, 255), pName);
        }

        if (esp_health) {
            float barW = 3.2f * scale;
            float barGap = 6.0f * scale;
            ImVec2 hMin(boxMin.x - barGap - barW, boxMin.y);
            ImVec2 hMax(boxMin.x - barGap, boxMax.y);

            draw->AddRectFilled(hMin, hMax, IM_COL32(14, 15, 20, 230));
            draw->AddRect(hMin, hMax, IM_COL32(0, 0, 0, 190), 0.0f, 0, 1.0f);

            float fillRatio = 0.75f;
            float filledY = hMax.y - (hMax.y - hMin.y) * fillRatio;
            draw->AddRectFilled(ImVec2(hMin.x, filledY), hMax, IM_COL32(75, 210, 105, 255));

            const char* hpTxt = "75";
            ImVec2 hpSz = ImGui::CalcTextSize(hpTxt);
            draw->AddText(ImVec2(hMin.x - hpSz.x - 2.5f * scale, filledY - hpSz.y * 0.5f), IM_COL32(75, 210, 105, 255), hpTxt);
        }

        if (esp_flags) {
            float flagX = boxMax.x + 6.0f * scale;
            float flagY = boxMin.y + 4.0f * scale;
            float fGap = 13.0f * scale;

            draw->AddText(ImVec2(flagX, flagY), IM_COL32(85, 215, 115, 255), "1337$");
            draw->AddText(ImVec2(flagX, flagY + fGap), IM_COL32(235, 65, 65, 255), "HOST");
            draw->AddText(ImVec2(flagX, flagY + fGap * 2.0f), IM_COL32(235, 235, 245, 255), "IOS");
            draw->AddText(ImVec2(flagX, flagY + fGap * 3.0f), IM_COL32(215, 215, 225, 255), "HK");
        }

        float botY = boxMax.y + 5.0f * scale;

        draw->AddRectFilled(ImVec2(boxMin.x + 10.0f * scale, botY), ImVec2(boxMin.x + 42.0f * scale, botY + 2.5f * scale), IM_COL32(95, 135, 235, 255), 1.0f);
        draw->AddRectFilled(ImVec2(boxMin.x + 42.0f * scale, botY), ImVec2(boxMax.x - 10.0f * scale, botY + 2.5f * scale), IM_COL32(22, 23, 30, 255), 1.0f);

        if (esp_distance) {
            const char* distTxt = "13FT";
            ImVec2 dSz = ImGui::CalcTextSize(distTxt);
            draw->AddText(ImVec2(boxMin.x + (boxW - dSz.x) * 0.5f, botY + 4.0f * scale), IM_COL32(245, 245, 250, 255), distTxt);
        }

        if (esp_weapon) {
            float gunY = botY + 20.0f * scale;
            float gunX = boxMin.x + (boxW - 54.0f * scale) * 0.5f;

            ImU32 gunCol = IM_COL32(245, 245, 250, 255);

            draw->AddRectFilled(ImVec2(gunX + 32.0f * scale, gunY + 3.0f * scale), ImVec2(gunX + 54.0f * scale, gunY + 5.5f * scale), gunCol, 1.0f);
            draw->AddRectFilled(ImVec2(gunX + 13.0f * scale, gunY + 2.0f * scale), ImVec2(gunX + 33.0f * scale, gunY + 6.5f * scale), gunCol, 1.0f);
            draw->AddRectFilled(ImVec2(gunX, gunY + 1.0f * scale), ImVec2(gunX + 13.0f * scale, gunY + 7.5f * scale), gunCol, 1.0f);
            draw->AddTriangleFilled(ImVec2(gunX + 23.0f * scale, gunY + 6.0f * scale), ImVec2(gunX + 27.5f * scale, gunY + 6.0f * scale), ImVec2(gunX + 25.0f * scale, gunY + 13.0f * scale), gunCol);
            draw->AddRectFilled(ImVec2(gunX + 14.5f * scale, gunY + 6.0f * scale), ImVec2(gunX + 18.0f * scale, gunY + 12.0f * scale), gunCol, 1.0f);
            draw->AddRectFilled(ImVec2(gunX + 18.0f * scale, gunY - 1.0f * scale), ImVec2(gunX + 28.0f * scale, gunY + 2.0f * scale), gunCol, 1.0f);
        }
    }
    ImGui::End();

    ImGui::PopStyleVar(2);
    ImGui::PopStyleColor(2);
}

/* --- ESP & HOOKS --- */
bool esp = false;
ImVec4 espLineColor = ImVec4(0.0f, 1.0f, 0.0f, 1.0f);
static float espMaxDistance = 999.0f;
static float linePositionX = 0.5f;
static float linePositionY = 1.0f;
static float hue = 0.0f;
static bool autoChangeColor = true;

std::vector<Vector3> espPoints;
void (*setpitchyaw)(float, float);
Vector3 (*WorldToScreenPoint)(void *instance, Vector3);
Vector3 (*get_position)(void *instance);
void *(*get_main)();
void *(*get_transform)(void *instance);
void (*old_Player_update)(void *player);
void Player_update(void* player) {
    if (player) {
        Vector3 pos = get_position(get_transform(player));
        Vector3 screen = WorldToScreenPoint(get_main(), {pos.x, pos.y, pos.z});
        if (screen.y >= 5.0f) {
            screen.y = screenHeight - screen.y;
            espPoints.push_back(screen);
        }
    }
    old_Player_update(player);
}

bool IsGold = false;
int (*old_Gold)(void *instance);
int Gold(void *instance) {
    if (instance != NULL && IsGold) return 999999999;
    return old_Gold(instance);
}

bool IsGggg = false;
int (*old_Gggg)(void *instance);
int Gggg(void *instance) {
    if (instance != NULL && IsGggg) return 89899898;
    return old_Gggg(instance);
}

bool IsKeys = false;
int (*old_Keys)(void *instance);
int Keys(void *instance) {
    if (instance != NULL && IsKeys) return 9999999;
    return old_Keys(instance);
}

bool damage1 = false;
bool bulletsLeft1 = false;
bool fireRate1 = true;
static bool autoStop = false;
static bool slowWalk = false;
static bool prediction = true;
static bool modelDesync = false;
static bool drawFake = false;
static bool drawFov = false;
static bool drawInacc = false;
static bool multipoints = false;
static bool castLines = false;

DWORD damage, bulletsLeft, fireRate = 0;

void (*old_WeaponU)(void *instance);
void WeaponU(void *instance) {
    if (instance != NULL) {
        if (damage1) *(int *)((uint64_t)instance + damage ) = 999999999;
        if (bulletsLeft1) *(int *)((uint64_t)instance + bulletsLeft ) = 999999999;
        if (fireRate1) *(float *)((uint64_t)instance + fireRate ) = 0.09f;
    }
    return old_WeaponU(instance);
}

void DrawTabIcon(ImDrawList* draw, int tabIndex, ImVec2 pos, ImU32 col, float scale) {
    switch (tabIndex) {
        case 0:
            draw->AddCircle(pos, 4.0f * scale, col, 12, 1.2f * scale);
            draw->AddCircleFilled(pos, 1.6f * scale, col);
            break;
        case 1:
            draw->AddCircle(pos, 4.2f * scale, col, 12, 1.2f * scale);
            draw->AddLine(ImVec2(pos.x - 5.5f * scale, pos.y), ImVec2(pos.x + 5.5f * scale, pos.y), col, 1.2f * scale);
            draw->AddLine(ImVec2(pos.x, pos.y - 5.5f * scale), ImVec2(pos.x, pos.y + 5.5f * scale), col, 1.2f * scale);
            break;
        case 2:
            draw->AddCircle(pos, 4.2f * scale, col, 12, 1.2f * scale);
            draw->AddCircle(pos, 2.2f * scale, col, 12, 1.0f * scale);
            break;
        case 3:
            draw->AddLine(ImVec2(pos.x - 4.5f * scale, pos.y - 1.5f * scale), ImVec2(pos.x + 4.5f * scale, pos.y - 1.5f * scale), col, 1.8f * scale);
            draw->AddLine(ImVec2(pos.x - 2.5f * scale, pos.y - 1.5f * scale), ImVec2(pos.x - 4.0f * scale, pos.y + 3.5f * scale), col, 1.5f * scale);
            break;
        case 4:
            draw->AddCircle(pos, 2.5f * scale, col, 12, 1.4f * scale);
            for (int a = 0; a < 4; a++) {
                float ang = a * 0.785f;
                draw->AddLine(
                    ImVec2(pos.x + cosf(ang) * 3.5f * scale, pos.y + sinf(ang) * 3.5f * scale),
                    ImVec2(pos.x + cosf(ang) * 5.0f * scale, pos.y + sinf(ang) * 5.0f * scale),
                    col, 1.3f * scale
                );
            }
            break;
        case 5:
            draw->AddLine(ImVec2(pos.x + 1.0f * scale, pos.y - 5.0f * scale), ImVec2(pos.x - 2.5f * scale, pos.y + 0.5f * scale), col, 1.3f * scale);
            draw->AddLine(ImVec2(pos.x - 2.5f * scale, pos.y + 0.5f * scale), ImVec2(pos.x + 0.5f * scale, pos.y + 0.5f * scale), col, 1.3f * scale);
            draw->AddLine(ImVec2(pos.x + 0.5f * scale, pos.y + 0.5f * scale), ImVec2(pos.x - 1.5f * scale, pos.y + 5.0f * scale), col, 1.3f * scale);
            break;
        case 6:
            break;
    }
}

void RenderTopRightWatermark(float dispW, float dispH, float scale) {
    ImDrawList* draw = ImGui::GetForegroundDrawList();

    float barW = 395.0f * scale;
    float barH = 34.0f * scale;
    float posX = dispW - barW - 16.0f * scale;
    float posY = 14.0f * scale;

    ImVec2 minP = ImVec2(posX, posY);
    ImVec2 maxP = ImVec2(posX + barW, posY + barH);

    draw->AddRectFilled(minP, maxP, IM_COL32(11, 12, 18, 240), barH * 0.5f);
    draw->AddRect(minP, maxP, IM_COL32(38, 32, 52, 255), barH * 0.5f, 0, 1.2f * scale);

    ImU32 accentCol  = IM_COL32(235, 85, 153, 255);
    ImU32 accentGlow = IM_COL32(235, 85, 153, 75);
    ImU32 textWhite  = IM_COL32(245, 245, 250, 255);
    ImU32 textGray   = IM_COL32(155, 158, 175, 255);

    float logoR = barH * 0.5f + 3.0f * scale;
    ImVec2 logoCenter = ImVec2(posX + barH * 0.5f, posY + barH * 0.5f);

    draw->AddCircle(logoCenter, logoR + 2.5f * scale, accentGlow, 32, 2.5f * scale);
    draw->AddCircleFilled(logoCenter, logoR, IM_COL32(14, 15, 22, 255), 32);
    draw->AddCircle(logoCenter, logoR, accentCol, 32, 2.0f * scale);

    draw->AddLine(ImVec2(logoCenter.x - 5.0f * scale, logoCenter.y - 6.0f * scale), ImVec2(logoCenter.x - 1.5f * scale, logoCenter.y + 5.0f * scale), IM_COL32_WHITE, 2.2f * scale);
    draw->AddLine(ImVec2(logoCenter.x + 4.0f * scale, logoCenter.y - 6.0f * scale), ImVec2(logoCenter.x + 1.0f * scale, logoCenter.y + 2.0f * scale), IM_COL32_WHITE, 2.2f * scale);

    ImVec2 m = ImGui::GetIO().MousePos;
    if (ImGui::GetIO().MouseClicked[0]) {
        float dx = m.x - logoCenter.x;
        float dy = m.y - logoCenter.y;
        if (dx * dx + dy * dy <= (logoR + 6.0f * scale) * (logoR + 6.0f * scale)) {
            show_window = !show_window;
        }
    }

    static auto lastPingTime = std::chrono::high_resolution_clock::now();
    static float smoothedPing = 16.0f;
    auto nowPingTime = std::chrono::high_resolution_clock::now();
    float dtMs = std::chrono::duration<float, std::milli>(nowPingTime - lastPingTime).count();
    lastPingTime = nowPingTime;
    if (dtMs > 1.0f && dtMs < 500.0f) {
        smoothedPing = smoothedPing * 0.96f + dtMs * 0.04f;
    }

    char pingBuf[16];
    snprintf(pingBuf, sizeof(pingBuf), "%d", (int)smoothedPing);

    float g1X = posX + 76.0f * scale;
    float gaugeR = 12.5f * scale;
    ImVec2 g1Center = ImVec2(g1X, posY + barH * 0.5f);

    draw->AddCircleFilled(g1Center, gaugeR, IM_COL32(16, 17, 24, 255), 24);
    draw->AddCircle(g1Center, gaugeR, IM_COL32(36, 32, 50, 255), 24, 1.4f * scale);
    draw->PathArcTo(g1Center, gaugeR, -2.4f, 0.4f, 16);
    draw->PathStroke(accentCol, false, 2.2f * scale);

    ImVec2 pSz = ImGui::CalcTextSize(pingBuf);
    draw->AddText(ImVec2(g1Center.x - pSz.x * 0.5f, g1Center.y - pSz.y * 0.5f), textWhite, pingBuf);

    float w1X = g1X + gaugeR + 9.0f * scale;
    ImVec2 wfCenter = ImVec2(w1X, posY + barH * 0.5f + 1.0f * scale);
    draw->PathArcTo(ImVec2(wfCenter.x, wfCenter.y + 3.0f * scale), 5.5f * scale, -2.4f, -0.7f, 12);
    draw->PathStroke(accentCol, false, 1.4f * scale);
    draw->PathArcTo(ImVec2(wfCenter.x, wfCenter.y + 3.0f * scale), 3.2f * scale, -2.4f, -0.7f, 12);
    draw->PathStroke(accentCol, false, 1.4f * scale);
    draw->AddCircleFilled(ImVec2(wfCenter.x, wfCenter.y + 2.5f * scale), 1.0f * scale, accentCol);
    draw->AddText(ImVec2(w1X + 9.0f * scale, posY + (barH - ImGui::GetTextLineHeight()) * 0.5f), textGray, "PING");

    static float fpsTimer = 0.0f;
    static int frameCounter = 0;
    static int realFPS = 60;
    frameCounter++;
    fpsTimer += ImGui::GetIO().DeltaTime;
    if (fpsTimer >= 0.5f) {
        realFPS = (int)(frameCounter / fpsTimer + 0.5f);
        frameCounter = 0;
        fpsTimer = 0.0f;
    }

    char fpsBuf[16];
    snprintf(fpsBuf, sizeof(fpsBuf), "%d", realFPS > 0 ? realFPS : 60);

    float g2X = posX + 180.0f * scale;
    ImVec2 g2Center = ImVec2(g2X, posY + barH * 0.5f);

    draw->AddCircleFilled(g2Center, gaugeR, IM_COL32(16, 17, 24, 255), 24);
    draw->AddCircle(g2Center, gaugeR, IM_COL32(36, 32, 50, 255), 24, 1.4f * scale);
    draw->PathArcTo(g2Center, gaugeR, -2.8f, 1.8f, 24);
    draw->PathStroke(accentCol, false, 2.2f * scale);

    ImVec2 fpsSz = ImGui::CalcTextSize(fpsBuf);
    draw->AddText(ImVec2(g2Center.x - fpsSz.x * 0.5f, g2Center.y - fpsSz.y * 0.5f), textWhite, fpsBuf);

    float w2X = g2X + gaugeR + 9.0f * scale;
    ImVec2 spCenter = ImVec2(w2X, posY + barH * 0.5f);
    draw->AddCircle(spCenter, 4.5f * scale, accentCol, 14, 1.3f * scale);
    draw->AddLine(spCenter, ImVec2(spCenter.x + 3.0f * scale, spCenter.y - 3.0f * scale), accentCol, 1.4f * scale);
    draw->AddText(ImVec2(w2X + 9.0f * scale, posY + (barH - ImGui::GetTextLineHeight()) * 0.5f), textGray, "FPS");

    static float tpsTimer = 0.0f;
    static int tpsCounter = 0;
    static int realTPS = 60;
    tpsCounter++;
    tpsTimer += ImGui::GetIO().DeltaTime;
    if (tpsTimer >= 0.5f) {
        realTPS = (int)(tpsCounter / tpsTimer + 0.5f);
        tpsCounter = 0;
        tpsTimer = 0.0f;
    }

    char tpsBuf[16];
    snprintf(tpsBuf, sizeof(tpsBuf), "%d", realTPS > 0 ? realTPS : 60);

    float g3X = posX + 286.0f * scale;
    ImVec2 g3Center = ImVec2(g3X, posY + barH * 0.5f);

    draw->AddCircleFilled(g3Center, gaugeR, IM_COL32(16, 17, 24, 255), 24);
    draw->AddCircle(g3Center, gaugeR, IM_COL32(36, 32, 50, 255), 24, 1.4f * scale);
    draw->PathArcTo(g3Center, gaugeR, -2.4f, 1.5f, 24);
    draw->PathStroke(accentCol, false, 2.2f * scale);

    ImVec2 dotPos1 = ImVec2(g3Center.x + cosf(0.0f) * gaugeR, g3Center.y + sinf(0.0f) * gaugeR);
    draw->AddCircleFilled(dotPos1, 2.2f * scale, IM_COL32(255, 255, 255, 255));

    ImVec2 dotPos2 = ImVec2(g3Center.x + 3.0f * scale, g3Center.y + gaugeR + 3.5f * scale);
    draw->AddCircleFilled(dotPos2, 1.6f * scale, IM_COL32(210, 215, 235, 220));

    ImVec2 tpsSz = ImGui::CalcTextSize(tpsBuf);
    draw->AddText(ImVec2(g3Center.x - tpsSz.x * 0.5f, g3Center.y - tpsSz.y * 0.5f), textWhite, tpsBuf);

    float w3X = g3X + gaugeR + 10.0f * scale;
    ImVec2 rtCenter = ImVec2(w3X, posY + barH * 0.5f);
    draw->PathArcTo(rtCenter, 4.2f * scale, -2.5f, 1.8f, 16);
    draw->PathStroke(accentCol, false, 1.4f * scale);
    draw->AddTriangleFilled(
        ImVec2(rtCenter.x + 4.2f * scale, rtCenter.y - 4.5f * scale),
        ImVec2(rtCenter.x + 7.5f * scale, rtCenter.y - 2.0f * scale),
        ImVec2(rtCenter.x + 2.5f * scale, rtCenter.y - 1.5f * scale),
        accentCol
    );
    draw->AddText(ImVec2(w3X + 10.0f * scale, posY + (barH - ImGui::GetTextLineHeight()) * 0.5f), textGray, "TPS");
}

void DrawNeverloseMenu() {
    if (!show_window) return;

    ImGuiIO &io = ImGui::GetIO();
    float dispW = io.DisplaySize.x > 100.0f ? io.DisplaySize.x : (float)screenWidth;
    float dispH = io.DisplaySize.y > 100.0f ? io.DisplaySize.y : (float)screenHeight;

    float winWidth = 720.0f * g_Scale;
    float winHeight = 415.0f * g_Scale;

    if (winWidth > dispW * 0.94f) winWidth = dispW * 0.94f;
    if (winHeight > dispH * 0.94f) winHeight = dispH * 0.94f;

    ImVec2 winPos = ImVec2((dispW - winWidth) * 0.5f, (dispH - winHeight) * 0.44f);
    ImGui::SetNextWindowPos(winPos, ImGuiCond_Once);
    ImGui::SetNextWindowSize(ImVec2(winWidth, winHeight), ImGuiCond_Always);

    ImGuiWindowFlags flags = ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize;
    ImGui::Begin("##NL_Main", NULL, flags);
    g_window = ImGui::GetCurrentWindow();

    ImDrawList* draw = ImGui::GetWindowDrawList();
    ImVec2 p = ImGui::GetWindowPos();
    ImVec2 sz = ImGui::GetWindowSize();

    static bool globalMenuOpen = false;
    static bool addMenuOpen = false;
    static int subTab = 0;
    {
        float lx = p.x + 22.0f * g_Scale;
        float ly = p.y + 19.0f * g_Scale;
        draw->AddLine(ImVec2(lx - 5 * g_Scale, ly - 5 * g_Scale), ImVec2(lx + 5 * g_Scale, ly + 5 * g_Scale), IM_COL32(245, 245, 250, 255), 1.6f * g_Scale);
        draw->AddLine(ImVec2(lx - 5 * g_Scale, ly + 5 * g_Scale), ImVec2(lx + 5 * g_Scale, ly - 5 * g_Scale), IM_COL32(245, 245, 250, 255), 1.6f * g_Scale);
        draw->AddLine(ImVec2(lx - 7 * g_Scale, ly), ImVec2(lx + 7 * g_Scale, ly), IM_COL32(235, 85, 153, 255), 1.5f * g_Scale);
        draw->AddLine(ImVec2(lx, ly - 7 * g_Scale), ImVec2(lx, ly + 7 * g_Scale), IM_COL32(235, 85, 153, 255), 1.5f * g_Scale);

        ImGui::SetCursorPos(ImVec2(40 * g_Scale, 9 * g_Scale));
        ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0.080f, 0.085f, 0.105f, 0.9f));
        ImGui::PushStyleColor(ImGuiCol_Border, ImVec4(0.13f, 0.14f, 0.18f, 0.7f));
        ImGui::PushStyleVar(ImGuiStyleVar_FrameBorderSize, 1.0f);
        ImGui::PushStyleVar(ImGuiStyleVar_FrameRounding, 4.0f * g_Scale);

        ImGui::Button("##sqBtn", ImVec2(24 * g_Scale, 21 * g_Scale));
        draw->AddRect(ImVec2(p.x + 46 * g_Scale, p.y + 14 * g_Scale), ImVec2(p.x + 58 * g_Scale, p.y + 25 * g_Scale), IM_COL32(175, 178, 192, 255), 1.8f);

        ImGui::SameLine(0, 5 * g_Scale);
        ImGui::Button("gs v", ImVec2(48 * g_Scale, 21 * g_Scale));

        ImGui::SameLine(0, 5 * g_Scale);
        if (ImGui::Button(globalMenuOpen ? "Global v" : "Global ^", ImVec2(76 * g_Scale, 21 * g_Scale))) {
            globalMenuOpen = !globalMenuOpen;
            addMenuOpen = false;
        }

        ImGui::PopStyleVar(2);
        ImGui::PopStyleColor(2);

        ImVec2 mainTextPos = ImVec2(p.x + sz.x - 150 * g_Scale, p.y + 12 * g_Scale);
        ImU32 colMain = (subTab == 0) ? IM_COL32(245, 245, 250, 255) : IM_COL32(90, 92, 105, 255);
        draw->AddText(mainTextPos, colMain, "Main");
        if (ImGui::IsMouseHoveringRect(mainTextPos, ImVec2(mainTextPos.x + 45 * g_Scale, mainTextPos.y + 20 * g_Scale)) && ImGui::IsMouseClicked(0)) subTab = 0;

        ImVec2 antiTextPos = ImVec2(p.x + sz.x - 85 * g_Scale, p.y + 12 * g_Scale);
        ImU32 colAnti = (subTab == 1) ? IM_COL32(245, 245, 250, 255) : IM_COL32(90, 92, 105, 255);
        draw->AddText(antiTextPos, colAnti, "Anti-aim");
        if (ImGui::IsMouseHoveringRect(antiTextPos, ImVec2(antiTextPos.x + 65 * g_Scale, antiTextPos.y + 20 * g_Scale)) && ImGui::IsMouseClicked(0)) subTab = 1;
    }

    const float padX = 12.0f * g_Scale;
    const float gapX = 10.0f * g_Scale;
    const float gapY = 8.0f * g_Scale;
    const float colW = (sz.x - padX * 2.0f - gapX * 2.0f) / 3.0f;
    const float totalH = sz.y - 82.0f * g_Scale;
    const float startY = 37.0f * g_Scale;

    static int currentTab = 2;

    if (currentTab == 0) {
        ImGui::SetCursorPos(ImVec2(padX, startY));
        ImGui::BeginChild("##Block_ESP_Enemy", ImVec2(colW, totalH), true, ImGuiWindowFlags_NoScrollbar);
        {
            NL_CardTitle("ESP ENEMY");
            ToggleSwitch("ESP Enabled", &esp);
            ToggleSwitch("Box", &esp_box);
            ToggleSwitch("Health Bar", &esp_health);
            ToggleSwitch("Name", &esp_name);
            ToggleSwitch("Flags (Host/Money)", &esp_flags);
            ToggleSwitch("Weapon Icon", &esp_weapon);
            ToggleSwitch("Distance", &esp_distance);
        }
        ImGui::EndChild();

        ImGui::SetCursorPos(ImVec2(padX + colW + gapX, startY));
        ImGui::BeginChild("##Block_ESP_Preview_Controls", ImVec2(colW, totalH), true, ImGuiWindowFlags_NoScrollbar);
        {
            NL_CardTitle("ESP PREVIEW");
            ToggleSwitch("Show Preview Window", &show_esp_preview);
            ImGui::Spacing();
            NL_CardTitle("WORLD VISUALS");
            ToggleSwitchWithColor("Draw FOV", &drawFov, col_draw_fov, "##picker_fov_v");
            ToggleSwitchWithColor("Draw Inaccuracy", &drawInacc, col_draw_inacc, "##picker_inacc_v");
            ToggleSwitchWithColor("Multipoints", &multipoints, col_multipoints, "##picker_multipoints_v");
            ToggleSwitchWithColor("Cast Lines", &castLines, col_cast_lines, "##picker_castlines_v", true);
        }
        ImGui::EndChild();

        ImGui::SetCursorPos(ImVec2(padX + (colW + gapX) * 2.0f, startY));
        ImGui::BeginChild("##Block_Chams_Bg", ImVec2(colW, totalH), true, ImGuiWindowFlags_NoScrollbar);
        {
            NL_CardTitle("MODELS & BACKGROUND");
            NL_RowCombo("Chams Mode", &chamsint, Chams, IM_ARRAYSIZE(Chams), 88.0f);
            if (chamsint > 1) {
                ToggleSwitch("RGB Visible", &enableRainbow);
                ImGui::ColorEdit3("##VisCol2", (float*)&visibleColor, ImGuiColorEditFlags_NoInputs);
            }
            if (chamsint == 6 || chamsint == 7) {
                ToggleSwitch("RGB Wall", &enableRainbowWall);
                ImGui::ColorEdit3("##WallCol2", (float*)&inWallColor, ImGuiColorEditFlags_NoInputs);
            }
            ImGui::Spacing();
            NL_RowCombo("Background", &bgEffectIndex, bgEffectNames, IM_ARRAYSIZE(bgEffectNames), 108.0f);
        }
        ImGui::EndChild();
    }
    else if (currentTab == 1) {
        float col1X = padX;
        float blockMainH = 106.0f * g_Scale;
        float blockSelH = totalH - blockMainH - gapY;

        ImGui::SetCursorPos(ImVec2(col1X, startY));
        ImGui::BeginChild("##Block_Main", ImVec2(colW, blockMainH), true, ImGuiWindowFlags_NoScrollbar);
        {
            NL_CardTitle("MAIN");
            ToggleSwitch("Enabled", &damage1);
            ToggleSwitch("Trigger Bot", &bulletsLeft1);
            ToggleSwitch("Auto Scope", &fireRate1, true);
        }
        ImGui::EndChild();

        ImGui::SetCursorPos(ImVec2(col1X, startY + blockMainH + gapY));
        ImGui::BeginChild("##Block_Selection", ImVec2(colW, blockSelH), true, ImGuiWindowFlags_NoScrollbar);
        {
            NL_CardTitle("SELECTION");
            static int preferIdx = 0;
            const char* preferItems[] = { "Head", "Body", "Arms", "Pelvis" };
            NL_RowCombo("Prefer", &preferIdx, preferItems, IM_ARRAYSIZE(preferItems), 88.0f);

            static int hitboxesIdx = 1;
            const char* hitboxesItems[] = { "1 selected", "3 selected", "All" };
            NL_RowCombo("Hitboxes", &hitboxesIdx, hitboxesItems, IM_ARRAYSIZE(hitboxesItems), 96.0f);

            static int hitChance = 60;
            NL_SliderInt("Hit Chance", &hitChance, 0, 100);

            static int minDamage = 1;
            NL_SliderInt("Min Damage", &minDamage, 1, 100);

            {
                ImVec2 fovPos = ImGui::GetCursorScreenPos();
                float availW = ImGui::GetContentRegionAvail().x;
                float rowH = 20.0f * g_Scale;
                draw->AddText(ImVec2(fovPos.x, fovPos.y + (rowH - ImGui::GetTextLineHeight()) * 0.5f), ImGui::GetColorU32(ImGuiCol_Text), "Field Of View");

                ImGui::SetCursorScreenPos(ImVec2(fovPos.x + availW - 78.0f * g_Scale, fovPos.y - 2.0f * g_Scale));
                static int fovItem = 0;
                const char* fovItems[] = { "Off", "Static", "Dynamic" };
                ImGui::PushStyleColor(ImGuiCol_FrameBg, ImVec4(0.080f, 0.085f, 0.105f, 1.0f));
                ImGui::PushStyleColor(ImGuiCol_Border, ImVec4(0.13f, 0.14f, 0.18f, 0.8f));
                ImGui::PushStyleVar(ImGuiStyleVar_FrameBorderSize, 1.0f);
                ImGui::PushStyleVar(ImGuiStyleVar_FrameRounding, 4.0f * g_Scale);
                ImGui::SetNextItemWidth(48.0f * g_Scale);
                ImGui::Combo("##fovCombo", &fovItem, fovItems, IM_ARRAYSIZE(fovItems));
                ImGui::PopStyleVar(2);
                ImGui::PopStyleColor(2);

                ImVec2 swPos = ImVec2(fovPos.x + availW - 25.0f * g_Scale, fovPos.y + (rowH - 13.5f * g_Scale) * 0.5f);
                static bool fovToggle = false;
                if (ImGui::InvisibleButton("##fovTgl", ImVec2(25.0f * g_Scale, 13.5f * g_Scale))) {
                    fovToggle = !fovToggle;
                }
                ImU32 fovBg = fovToggle ? IM_COL32(235, 85, 153, 255) : IM_COL32(26, 27, 33, 255);
                draw->AddRectFilled(swPos, ImVec2(swPos.x + 25.0f * g_Scale, swPos.y + 13.5f * g_Scale), fovBg, 6.75f * g_Scale);
                float fovCircleX = fovToggle ? (swPos.x + 25.0f * g_Scale - 6.75f * g_Scale) : (swPos.x + 6.75f * g_Scale);
                draw->AddCircleFilled(ImVec2(fovCircleX, swPos.y + 6.75f * g_Scale), 5.0f * g_Scale, IM_COL32(245, 245, 250, 255));

                ImGui::SetCursorScreenPos(ImVec2(fovPos.x, fovPos.y + rowH));
            }

            static bool safePoint = false;
            ToggleSwitch("Safe Point", &safePoint, true);
        }
        ImGui::EndChild();

        float col2X = padX + colW + gapX;
        float blockWeaponH = 158.0f * g_Scale;
        float blockDesyncH = totalH - blockWeaponH - gapY;

        ImGui::SetCursorPos(ImVec2(col2X, startY));
        ImGui::BeginChild("##Block_Weapon", ImVec2(colW, blockWeaponH), true, ImGuiWindowFlags_NoScrollbar);
        {
            NL_CardTitle("WEAPON ACTIONS");
            ToggleSwitch("Lag Peek", &IsGold);
            ToggleSwitch("Remove Spread", &bulletsLeft1);
            ToggleSwitch("Auto Stop", &autoStop);
            ToggleSwitch("Slow Walk", &slowWalk, true);
            ToggleSwitch("Prediction", &prediction, true);
        }
        ImGui::EndChild();

        ImGui::SetCursorPos(ImVec2(col2X, startY + blockWeaponH + gapY));
        ImGui::BeginChild("##Block_Desync", ImVec2(colW, blockDesyncH), true, ImGuiWindowFlags_NoScrollbar);
        {
            NL_CardTitle("DESYNC");
            ToggleSwitch("Model Desync", &modelDesync, true);

            static int tpSides = 0;
            const char* sides[] = { "Random", "Left", "Right" };
            NL_RowCombo("Teleport Sides", &tpSides, sides, IM_ARRAYSIZE(sides), 88.0f);

            ToggleSwitch("Draw Fake", &drawFake, true);
        }
        ImGui::EndChild();

        float col3X = padX + (colW + gapX) * 2.0f;
        ImGui::SetCursorPos(ImVec2(col3X, startY));
        ImGui::BeginChild("##Block_Visuals", ImVec2(colW, totalH), true, ImGuiWindowFlags_NoScrollbar);
        {
            NL_CardTitle("VISUALS");
            ToggleSwitch("ESP Preview", &show_esp_preview);
            ToggleSwitchWithColor("Draw FOV", &drawFov, col_draw_fov, "##picker_fov");
            ToggleSwitchWithColor("Draw Inaccuracy", &drawInacc, col_draw_inacc, "##picker_inacc");
            ToggleSwitchWithColor("Multipoints", &multipoints, col_multipoints, "##picker_multipoints");
            ToggleSwitchWithColor("Cast Lines", &castLines, col_cast_lines, "##picker_castlines", true);

            ImGui::Spacing();
            NL_RowCombo("Chams Mode", &chamsint, Chams, IM_ARRAYSIZE(Chams), 88.0f);

            if (chamsint > 1) {
                ToggleSwitch("RGB Visible", &enableRainbow);
                ImGui::ColorEdit3("##VisCol", (float*)&visibleColor, ImGuiColorEditFlags_NoInputs);
            }
            if (chamsint == 6 || chamsint == 7) {
                ToggleSwitch("RGB Wall", &enableRainbowWall);
                ImGui::ColorEdit3("##WallCol", (float*)&inWallColor, ImGuiColorEditFlags_NoInputs);
            }

            ImGui::Spacing();
            NL_RowCombo("Background", &bgEffectIndex, bgEffectNames, IM_ARRAYSIZE(bgEffectNames), 108.0f);
        }
        ImGui::EndChild();
    }
    else if (currentTab == 2) {
        ImGui::SetCursorPos(ImVec2(padX, startY));
        ImGui::BeginChild("##Block_Legit_Main", ImVec2(colW, totalH), true, ImGuiWindowFlags_NoScrollbar);
        {
            NL_CardTitle("LEGITBOT");
            ToggleSwitch("Enabled", &legit_enable);

            static bool legitAutoFire = false;
            ToggleSwitch("Auto Fire", &legitAutoFire);

            static int smoothVal = 12;
            NL_SliderInt("Smooth", &smoothVal, 1, 30);

            static int legitHitbox = 0;
            const char* hitboxes[] = { "Head", "Neck", "Chest", "Nearest" };
            NL_RowCombo("Hitbox", &legitHitbox, hitboxes, IM_ARRAYSIZE(hitboxes), 88.0f);

            static bool rcsEnabled = true;
            ToggleSwitch("Recoil Control (RCS)", &rcsEnabled);
        }
        ImGui::EndChild();

        ImGui::SetCursorPos(ImVec2(padX + colW + gapX, startY));
        ImGui::BeginChild("##Block_Legit_Visuals", ImVec2(colW, totalH), true, ImGuiWindowFlags_NoScrollbar);
        {
            NL_CardTitle("AIM FOV & CROSSHAIR");
            ToggleSwitchWithColor("Draw FOV Circle", &legit_draw_fov, col_legit_fov, "##picker_legit_fov");
            NL_SliderInt("FOV Radius", &legit_fov_radius, 20, 450);

            ImGui::Spacing();
            ImGui::Separator();
            ImGui::Spacing();

            ToggleSwitch("Draw Crosshair", &legit_draw_crosshair);
            NL_SliderInt("Crosshair Size", &legit_cross_size, 4, 25);
            NL_SliderInt("Center Gap", &legit_cross_gap, 0, 10);
        }
        ImGui::EndChild();

        ImGui::SetCursorPos(ImVec2(padX + (colW + gapX) * 2.0f, startY));
        ImGui::BeginChild("##Block_Legit_Targeting", ImVec2(colW, totalH), true, ImGuiWindowFlags_NoScrollbar);
        {
            NL_CardTitle("TARGETING");
            static int targetPriority = 0;
            const char* priorities[] = { "Crosshair", "Distance", "Lowest HP" };
            NL_RowCombo("Priority", &targetPriority, priorities, IM_ARRAYSIZE(priorities), 96.0f);

            static int reactionTime = 120;
            NL_SliderInt("Reaction (ms)", &reactionTime, 0, 400);

            static bool checkWall = true;
            ToggleSwitch("Visibility Check", &checkWall);

            ImGui::Spacing();
            ImGui::Separator();
            ImGui::Spacing();

            NL_CardTitle("NOTIFICATIONS");
            ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0.12f, 0.09f, 0.15f, 1.0f));
            ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImVec4(0.18f, 0.12f, 0.22f, 1.0f));
            ImGui::PushStyleColor(ImGuiCol_ButtonActive, ImVec4(0.24f, 0.14f, 0.28f, 1.0f));
            ImGui::PushStyleColor(ImGuiCol_Border, ImVec4(0.92f, 0.33f, 0.60f, 0.70f));
            ImGui::PushStyleVar(ImGuiStyleVar_FrameBorderSize, 1.0f);
            ImGui::PushStyleVar(ImGuiStyleVar_FrameRounding, 5.0f * g_Scale);

            if (ImGui::Button("Show Notification", ImVec2(ImGui::GetContentRegionAvail().x, 26.0f * g_Scale))) {
                AddNotification("The new hotkey has", "The operation was successful!", 3.5f);
            }

            ImGui::PopStyleVar(2);
            ImGui::PopStyleColor(4);
        }
        ImGui::EndChild();
    }
    else if (currentTab == 6) {
        RenderLuaTab(p, sz, padX, startY, totalH, g_Scale);
    }

    if (globalMenuOpen) {
        ImDrawList* fg = ImGui::GetForegroundDrawList();
        ImVec2 pop1Pos = ImVec2(p.x + 130 * g_Scale, p.y + 36 * g_Scale);

        fg->AddRectFilled(pop1Pos, ImVec2(pop1Pos.x + 110 * g_Scale, pop1Pos.y + 68 * g_Scale), IM_COL32(14, 15, 18, 255), 6.0f * g_Scale);
        fg->AddRect(pop1Pos, ImVec2(pop1Pos.x + 110 * g_Scale, pop1Pos.y + 68 * g_Scale), IM_COL32(32, 34, 44, 255), 6.0f * g_Scale);

        fg->AddText(ImVec2(pop1Pos.x + 12 * g_Scale, pop1Pos.y + 10 * g_Scale), IM_COL32(230, 230, 240, 255), "Global");
        
        ImVec2 addPos = ImVec2(pop1Pos.x + 12 * g_Scale, pop1Pos.y + 38 * g_Scale);
        fg->AddText(addPos, IM_COL32(230, 230, 240, 255), "Add");
        fg->AddText(ImVec2(pop1Pos.x + 92 * g_Scale, addPos.y), IM_COL32(160, 160, 175, 255), ">");

        if (ImGui::IsMouseHoveringRect(ImVec2(pop1Pos.x, pop1Pos.y + 30 * g_Scale), ImVec2(pop1Pos.x + 110 * g_Scale, pop1Pos.y + 68 * g_Scale))) {
            addMenuOpen = true;
        }

        if (addMenuOpen) {
            ImVec2 pop2Pos = ImVec2(pop1Pos.x + 114 * g_Scale, pop1Pos.y - 10 * g_Scale);
            fg->AddRectFilled(pop2Pos, ImVec2(pop2Pos.x + 110 * g_Scale, pop2Pos.y + 215 * g_Scale), IM_COL32(14, 15, 18, 255), 6.0f * g_Scale);
            fg->AddRect(pop2Pos, ImVec2(pop2Pos.x + 110 * g_Scale, pop2Pos.y + 215 * g_Scale), IM_COL32(32, 34, 44, 255), 6.0f * g_Scale);

            const char* weapons[] = { "G22", "USP", "P350", "TEC9", "FiveSeven", "Berettas", "Deagle", "UMP45" };
            for (int w = 0; w < 8; w++) {
                fg->AddText(ImVec2(pop2Pos.x + 12 * g_Scale, pop2Pos.y + 8 * g_Scale + w * 25 * g_Scale), IM_COL32(230, 230, 240, 255), weapons[w]);
            }
        }
    }

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
            draw->AddRect(ImVec2(itMin.x + 2, itMin.y + 2), ImVec2(itMax.x - 2, itMax.y - 2), IM_COL32(35, 37, 48, 255), 5.5f * g_Scale);
        }

        ImGui::SetCursorScreenPos(itMin);
        char tId[32];
        snprintf(tId, sizeof(tId), "##nav_tab_%d", i);
        if (ImGui::InvisibleButton(tId, ImVec2(itemW, navH))) {
            currentTab = i;
        }

        ImVec2 txtSz = ImGui::CalcTextSize(tabsLabels[i]);
        float totalContentW = txtSz.x + (i < 6 ? 14.0f * g_Scale : 0.0f);
        float startContentX = itMin.x + (itemW - totalContentW) * 0.5f;
        float centerY = itMin.y + navH * 0.5f;

        ImU32 colTab = isSel ? IM_COL32(245, 245, 250, 255) : IM_COL32(95, 98, 112, 255);

        if (i < 6) {
            DrawTabIcon(draw, i, ImVec2(startContentX + 4.5f * g_Scale, centerY), colTab, g_Scale);
            draw->AddText(ImVec2(startContentX + 13.0f * g_Scale, centerY - txtSz.y * 0.5f), colTab, tabsLabels[i]);
        } else {
            draw->AddText(ImVec2(startContentX, centerY - txtSz.y * 0.5f), colTab, tabsLabels[i]);
        }
    }

    ImGui::End();
    RenderESPPreviewWindow(p, sz, g_Scale);
}

// -------------------------------------------------------------
// iOS RENDER & INIT HOOKS (THEOS COMPATIBLE)
// -------------------------------------------------------------
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
        float fontSize = 15.0f * g_Scale;
        io.Fonts->AddFontFromMemoryTTF(Verdana, sizeof(Verdana), fontSize);
        ImGui_ImplOpenGL3_CreateFontsTexture();
    }

    ImGuiIO& io = ImGui::GetIO();
    ImGui_ImplOpenGL3_NewFrame();
    ImGui::NewFrame();

    float dispW = io.DisplaySize.x > 100.0f ? io.DisplaySize.x : (float)screenWidth;
    float dispH = io.DisplaySize.y > 100.0f ? io.DisplaySize.y : (float)screenHeight;

    RenderBackgroundEffects(dispW, dispH, g_Scale);
    RenderLegitOverlay(dispW, dispH, g_Scale);
    DrawNeverloseMenu();
    RenderTopRightWatermark(dispW, dispH, g_Scale);
    RenderNotifications(dispW, dispH, g_Scale);

    ImGui::Render();
    ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
}

void *hack_thread(void *) {
    sleep(5);
    G_IL2CPP = findLibrary("libil2cpp.so");
    
    auto PlayerGold = new LoadClass("", OBFUSCATE("ArchiveData"));
    DWORD GetGold = PlayerGold->GetMethodOffsetByName(OBFUSCATE("GetPlayerMoney"), 0);
    if (GetGold) DobbyHook((void *)GetGold, (void *)Gold, (void **) &old_Gold);
	
    auto PlayerGggg = new LoadClass("", OBFUSCATE("ArchiveData"));
    DWORD GetGggg = PlayerGggg->GetMethodOffsetByName(OBFUSCATE("GetPlayerTickets"), 0);
    if (GetGggg) DobbyHook((void *)GetGggg, (void *)Gggg, (void **) &old_Gggg);

    auto PlayerKeys = new LoadClass("", OBFUSCATE("ArchiveData"));
    DWORD GetKeys = PlayerKeys->GetMethodOffsetByName(OBFUSCATE("GetPlayerKeys"), 0);
    if (GetKeys) DobbyHook((void *)GetKeys, (void *)Keys, (void **) &old_Keys);

    auto WeaponC = new LoadClass("", OBFUSCATE("WeaponBehavior"));
    damage = WeaponC->GetFieldOffset(OBFUSCATE("damage"));
    bulletsLeft = WeaponC->GetFieldOffset(OBFUSCATE("bulletsLeft"));
    fireRate = WeaponC->GetFieldOffset(OBFUSCATE("fireRate"));
    DWORD WUpdate = WeaponC->GetMethodOffsetByName(OBFUSCATE("Update"), 0);
    if (WUpdate) DobbyHook((void *)WUpdate, (void *)WeaponU, (void **) &old_WeaponU);

    return NULL;
}

__attribute__((constructor)) void initialize() {
    pthread_t thread;
    pthread_create(&thread, NULL, hack_thread, NULL);
}
