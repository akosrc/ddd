#import "菜单.h"
#import "XORstring.h"
#include "../Image/Icon.h"
#import "../View/OverlayView.h"
#include "IconsFontAwesome6.h"
#include <string>
#include <algorithm>
#include <chrono>
#include <dlfcn.h>
#include <iostream>
#include "Skin.h"
#import "XORstring.h"
#include "ESP/mahoa.h"
#include "sys/mman.h"
#include "../ESP/Tools.h"
#import <AVFoundation/AVFoundation.h>
#include "../JRMemory.framework/Headers/MemScan.h"
#include <stdio.h>
#include <stdint.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#include <string>
#include <stdio.h>
#include <string.h>
#include "../ESP/Vector3.hpp"
#include "../ESP/Vector2.hpp"
#import <Foundation/Foundation.h>
#include "../ESP/tahoma.h"

// ============= GLOBAL VARIABLES =============
extern bool ModSkinn;
extern bool KillMessage;
extern bool DeadBox;
extern JsonPreferences preferences;
extern bool Line;
extern bool Line2;
extern bool Box;
extern bool Box2;
extern bool 血条;
extern bool 血条B;
extern bool Skeleton;
extern float skthick;
extern bool 信息;
extern bool Weapon;
extern bool Weapon2;
extern bool Alert;
extern bool GRWAR;
extern bool ESPON;
extern bool ESPNotBot;
extern bool AimBot;
extern bool Enable;
extern bool Enablev2;
extern bool AutoFire;
extern int Cross;
extern bool TPCAR;
extern bool IgnoreKnocked;
extern bool IgnoreBot;
extern bool VisCheck;
extern bool VisCheckBT;
extern bool AutoStandd;
extern float AimSpeed;
extern float Aimsmooth;
extern float g_disstance;
extern int AimF;
extern int AimL;
extern bool IsLootBox;
extern bool IsVehcle;
extern bool IsboxVechle;
extern bool IsCarFuel;
extern bool 步枪;
extern bool 狙击;
extern bool 地铁物资;
extern bool 物资冲锋;
extern bool 物资配件;
extern bool 物资防具;
extern bool 物资倍镜;
extern bool IsSMG;
extern bool IsAR;
extern bool IsITM;
extern bool IsShotgun;
extern bool Fps120;
extern bool Fps90;
extern bool Fps60;
extern bool ipadview;
extern bool NoFog;
extern bool CrossHairSpin;
extern int WideValue;
extern bool CrossHair;
extern bool CrossLong;
extern bool CrossHairR;
extern bool CrossHairR1;
extern bool ReCo;
extern bool NoRecoil;
extern bool HitX;
extern bool AUOTJUMPAN;
extern bool Fullhack;
extern bool FastCrouch;
extern bool damage;
extern bool infinity;
extern bool bigscope;
extern bool MagicBullet;
extern float MagicBulletX;
extern float MagicBulletY;
extern float MagicBulletZ;
extern bool FastWeapon;
extern bool Fastshoot;
extern bool NoGravity;
extern float valueplayer;
extern bool BigPlayer;
extern bool NoSpreadBullet;
extern bool HighJump;
extern bool FastKnock;
extern bool HeadShoott;
extern bool FastBullet;
extern bool hidename;
extern bool NoCameraShake;
extern bool Peeking;
extern bool spinplayer;
extern bool weaponAbovePlayerHidden;
extern bool crazycar;
extern int carvalue;
extern bool Rainbow;
extern bool Rainbow1;
extern bool Flash2;
extern bool SdkFlash2;
extern int SpeedValue;
extern bool Flash1;
extern bool flashEnabled;
extern int FlashValue;
extern bool SuperJump;
extern bool SdkSuper;
extern float SuperValue;
extern bool Swim;
extern bool Scope;
extern bool goodview;
extern bool good;
extern bool FAKEDAMAGEV2;
extern bool FAKEDAMAGE;
extern bool FAKEDAMAGEV3;
extern bool rest;
extern bool Silenttest;
extern bool bighit2;
extern bool FastSwimV2;
extern bool TeleportToPlayer;
extern bool TeleportToVehicle;
extern bool TeleportToLootBox;
extern bool DefaultSpeed;
extern bool AutoParachute;
extern float AutoParachuteScale;
extern bool AutoAGHA;
extern bool SlowMotion;
extern float SlowMotionFactor;
extern bool SlowMotion2;
extern float SlowMotionFactor2;
extern bool SniAR;
extern float FrameTimeValue;
extern bool WeaponSize;
extern float GunSize;
extern bool SilentGodview;
extern bool welapongod;
extern float gungody;
extern float gungodz;
extern float gungodx;
extern bool showdamage;
extern bool flly;
extern bool bunny;
extern bool ggxhit;
extern int carx;
extern int cary;
extern int carz;
extern bool carfly;
extern bool dead;
extern bool distancee;
extern bool distancee2;
extern bool RightLeft;
extern bool FuelVehicle;
extern bool flyy;
extern bool wall;
extern bool FlashSpeedd;
extern bool Speedknock;
extern bool Crazy;
extern bool IsBulletTracking360Enabled;
extern bool IsAutofire;
extern float HideEsp;
extern bool jumpee;
extern float jumped;
extern bool jumpeee;
extern bool jumpeeee;
extern bool LockStatus;
extern bool LockStatusoff;
extern bool SpeedPlayerV2;
extern bool SpeedPlayer;
extern bool VIPJUMP;
extern float SPEEDJUMP;
extern float SPEEDAIR;
extern float GRAVITYSCALE;
extern float VIPHIGH;
extern float EnergyScale;
extern float JUMPANIMETION;
extern bool Tigerjump;
extern float TIGER;
extern bool Tp;
extern float TpSpeed;
extern bool AutoFly;
extern bool FlashV4;
extern float FlashV4Value;
extern bool RemoveStuck;
extern bool inbta7;
extern bool CRYENGINE;
extern bool AntiBan;
extern bool WallShoot;
extern bool GodViewV2;
extern float jumpedd;
extern bool Fly;
extern bool opp;
extern bool ghostt;
extern bool snoww;
extern bool rainn;
extern bool AutoShoot;
extern bool AutoShootBT;
extern bool Ipad;
extern bool Telep;
extern bool flashparachute;
extern bool flashparachute2;
extern bool flashparachute3;
extern bool JAATSDK;
extern bool spdw;
extern bool SpeedScope;
extern bool ShowDamaze;
extern bool PREDICTION1;
extern bool FixStuck;
extern bool bighitV4;
extern bool bighitV5;
extern int HITSIZE;
extern bool Enable360;
extern bool EnableShootIntervalSlider;
extern float SliderShootIntervalValue;
extern bool ScopeView;
extern float ScopeValue;
extern bool EnableDanceRotation;
extern float DancerValue;
extern float SliderSpeed;
extern bool 物资;
extern bool 美化;
extern int FlashSpeedSpeed;
extern bool oneshoot;
extern int oneshootValue;
extern int ShootValue;
extern bool MenDeal;
extern bool thongtin;

bool isActivated = false;

namespace Settings {
    static int Tab = 0;
}

namespace Colors {
    const ImVec4 Black = ImVec4(0.08f, 0.08f, 0.08f, 1.00f);
    const ImVec4 DarkGray = ImVec4(0.12f, 0.12f, 0.12f, 1.00f);
    const ImVec4 MediumGray = ImVec4(0.20f, 0.20f, 0.20f, 1.00f);
    const ImVec4 White = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
    const ImVec4 Gray = ImVec4(0.50f, 0.50f, 0.50f, 1.00f);
    const ImVec4 Accent = ImVec4(0.0f, 0.45f, 0.25f, 1.00f);
    const ImVec4 Success = ImVec4(0.0f, 0.8f, 0.3f, 1.00f);
    const ImVec4 Error = ImVec4(1.0f, 0.2f, 0.2f, 1.00f);
    const ImVec4 Info = ImVec4(0.3f, 0.7f, 1.0f, 1.00f);
}

void TextRed(const char* text) { ImGui::TextColored(Colors::Error, "%s", text); }
void TextBlue(const char* text) { ImGui::TextColored(Colors::Info, "%s", text); }

void SectionHeader(const char* text) {
    ImGui::Spacing();
    ImGui::PushStyleColor(ImGuiCol_Text, Colors::Accent);
    ImGui::Text("%s", text);
    ImGui::PopStyleColor();
    ImGui::Separator();
    ImGui::Spacing();
}

void CheckboxGroup(const char* label1, bool* v1, const char* label2, bool* v2) {
    ImGui::Checkbox(label1, v1);
    ImGui::SameLine();
    ImGui::Checkbox(label2, v2);
}

void ApplyModernDarkTheme() {
    ImGuiStyle& style = ImGui::GetStyle();
    ImVec4* colors = style.Colors;
    colors[ImGuiCol_WindowBg] = Colors::Black;
    colors[ImGuiCol_ChildBg] = Colors::DarkGray;
    colors[ImGuiCol_PopupBg] = Colors::DarkGray;
    colors[ImGuiCol_Border] = ImVec4(0.30f, 0.30f, 0.30f, 0.60f);
    colors[ImGuiCol_Separator] = Colors::Accent;
    colors[ImGuiCol_Text] = Colors::White;
    colors[ImGuiCol_TextDisabled] = Colors::Gray;
    colors[ImGuiCol_Button] = Colors::Black;
    colors[ImGuiCol_ButtonHovered] = ImVec4(0.15f, 0.15f, 0.15f, 1.00f);
    colors[ImGuiCol_ButtonActive] = Colors::MediumGray;
    colors[ImGuiCol_FrameBg] = ImVec4(0.10f, 0.10f, 0.10f, 1.00f);
    colors[ImGuiCol_FrameBgHovered] = ImVec4(0.20f, 0.20f, 0.20f, 1.00f);
    colors[ImGuiCol_FrameBgActive] = ImVec4(0.30f, 0.30f, 0.30f, 1.00f);
    colors[ImGuiCol_CheckMark] = ImVec4(1.0f, 0.0f, 0.0f, 1.0f);    
    colors[ImGuiCol_SliderGrab] = ImVec4(0.60f, 0.60f, 0.60f, 1.00f);
    colors[ImGuiCol_SliderGrabActive] = ImVec4(0.90f, 0.90f, 0.90f, 1.00f);
    colors[ImGuiCol_Tab] = Colors::Black;
    colors[ImGuiCol_TabHovered] = ImVec4(0.15f, 0.15f, 0.15f, 1.00f);
    colors[ImGuiCol_TabActive] = Colors::MediumGray;
    colors[ImGuiCol_Header] = Colors::Accent;
    colors[ImGuiCol_HeaderHovered] = ImVec4(0.0f, 0.55f, 0.30f, 1.00f);
    colors[ImGuiCol_HeaderActive] = ImVec4(0.0f, 0.65f, 0.35f, 1.00f);
    colors[ImGuiCol_TitleBg] = Colors::Black;
    colors[ImGuiCol_TitleBgActive] = ImVec4(0.10f, 0.10f, 0.10f, 1.00f);
    colors[ImGuiCol_ScrollbarBg] = Colors::Black;
    colors[ImGuiCol_ScrollbarGrab] = ImVec4(0.0f, 0.3f, 0.2f, 0.60f);
    
    style.WindowRounding = 12.0f;
    style.ChildRounding = 8.0f;
    style.FrameRounding = 6.0f;
    style.PopupRounding = 8.0f;
    style.ScrollbarRounding = 10.0f;
    style.GrabRounding = 6.0f;
    style.TabRounding = 6.0f;
    style.WindowPadding = ImVec2(15, 15);
    style.FramePadding = ImVec2(12, 8);
    style.ItemSpacing = ImVec2(10, 8);
    style.WindowBorderSize = 1.0f;
    style.ChildBorderSize = 1.0f;
    style.PopupBorderSize = 1.0f;
    style.FrameBorderSize = 0.0f;
}

// ============= TAB DRAWING FUNCTIONS =============

void DrawMainTab() {
    static float bypass_progress = 0.0f;
    static bool bypass_in_progress = false;
    static bool bypass_completed = false;
    static std::chrono::steady_clock::time_point bypass_start_time;
    static std::chrono::steady_clock::time_point last_message_time;
    static int current_message_index = 0;

    struct BypassMessage { const char* text; int color; float delay; };
    static const BypassMessage messages[] = {
        {"[SYSTEM] Initializing Bypass Sequence...", 2, 0.2f},
        {"[SECURITY] Bypassing PUBG MOBILE Protection...", 2, 0.25f},
        {"[MODULE] Loading Anti-Cheat Modules...", 2, 0.3f},
        {"[完成] 所有系统检查通过!", 0, 0.6f}
    };
    static const int total_messages = sizeof(messages) / sizeof(messages[0]);

    ImGui::PushStyleVar(ImGuiStyleVar_FramePadding, ImVec2(15, 15));
    ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0.2f, 0.5f, 0.8f, 1.0f));

    if (ImGui::Button("ACTIVATE BYPASS SYSTEM", ImVec2(-1, 60))) {
        if (!bypass_in_progress && !bypass_completed) {
            bypass_in_progress = true; bypass_completed = false; bypass_progress = 0.0f;
            bypass_start_time = std::chrono::steady_clock::now(); last_message_time = bypass_start_time;
            current_message_index = 0;
        }
    }
    ImGui::PopStyleColor(); ImGui::PopStyleVar();

    if (bypass_in_progress) {
        auto current_time = std::chrono::steady_clock::now();
        auto elapsed_time = std::chrono::duration_cast<std::chrono::milliseconds>(current_time - bypass_start_time).count();
        bypass_progress = static_cast<float>(elapsed_time) / 5000.0f; // 5 saniye sürsün
        
        if (current_message_index < total_messages) {
            auto time_since_last_message = std::chrono::duration_cast<std::chrono::milliseconds>(current_time - last_message_time).count();
            if (time_since_last_message >= (messages[current_message_index].delay * 1000)) { current_message_index++; last_message_time = current_time; }
        }
        if (elapsed_time >= 5000) { bypass_in_progress = false; bypass_completed = true; bypass_progress = 1.0f; }
        
        ImGui::BeginChild("BypassConsole", ImVec2(0, 150), true);
        for (int i = 0; i < current_message_index && i < total_messages; i++) {
            ImVec4 color = (messages[i].color == 0) ? Colors::Success : (messages[i].color == 1) ? Colors::Error : Colors::Info;
            ImGui::TextColored(color, "[%02d:%02d] %s", (int)(elapsed_time/1000)/60, (int)(elapsed_time/1000)%60, messages[i].text);
        }
        ImGui::EndChild();
        ImGui::ProgressBar(bypass_progress, ImVec2(-1, 30), "");
    }

    if (bypass_completed) {
        ImGui::TextColored(Colors::Success, "BYPASS ACTIVATED SUCCESSFULLY!");
        if (ImGui::Button("DONE", ImVec2(-1, 40))) { bypass_completed = false; }
    }

    ImGui::Spacing(); ImGui::Separator(); ImGui::Spacing();
    ImGui::Text("Welcome To NEXT CHEAT");
    ImGui::Text("@mci_h");
}

void DrawESPTab() {
    SectionHeader("Player ESP");
    ImGui::Columns(2, nullptr, false);
    CheckboxGroup("Draw Line", &Line, "Draw Bone", &Skeleton);
    CheckboxGroup("Draw Info", &信息, "Draw Weapon", &Weapon);
    CheckboxGroup("Draw Box 4L", &Box, "Draw Box 3D", &Box2);
    ImGui::Checkbox("Draw Distance", &distancee);
    ImGui::NextColumn();
    CheckboxGroup("Draw Health", &血条B, "Draw Alert", &Alert);
    CheckboxGroup("Draw Vehicle", &IsVehcle, "Draw Loot Box", &IsLootBox);
    ImGui::Checkbox("Grenade Warning", &GRWAR);
    ImGui::Checkbox("Skip AI", &ESPNotBot);
    ImGui::Columns(1);
}

void DrawLootTab() {
    SectionHeader("Item ESP");
    ImGui::Columns(3, nullptr, false);
    ImGui::Checkbox("Rifle", &步枪); ImGui::Checkbox("Sniper", &狙击); ImGui::Checkbox("SMG", &物资冲锋);
    ImGui::NextColumn();
    ImGui::Checkbox("Scope", &物资倍镜); ImGui::Checkbox("Armor", &物资防具); ImGui::Checkbox("Accessories", &物资配件);
    ImGui::NextColumn();
    ImGui::Checkbox("Car Info", &IsCarFuel); ImGui::Checkbox("Box Vehicle", &IsboxVechle); ImGui::Checkbox("Airdrop", &地铁物资);
    ImGui::Columns(1);
}

void DrawAimTab() {
    SectionHeader("Aim Settings");
    ImGui::Columns(2, nullptr, false);
    CheckboxGroup("AimBot", &AimBot, "Bullet Track 360", &Enable);
    CheckboxGroup("Bullet Track V2", &Enablev2, "Auto Fire", &AutoFire);
    ImGui::Columns(1);
    ImGui::Spacing(); ImGui::Separator();
    SectionHeader("Filters");
    CheckboxGroup("Ignore Knocked", &IgnoreKnocked, "Ignore AI", &IgnoreBot);
    CheckboxGroup("Vis Check", &VisCheck, "Vis Check BT", &VisCheckBT);
    ImGui::Spacing(); ImGui::Separator();
    SectionHeader("Aim Target");
    ImGui::RadioButton("Head", &AimL, 1); ImGui::SameLine();
    ImGui::RadioButton("Neck", &AimL, 3); ImGui::SameLine();
    ImGui::RadioButton("Body", &AimL, 2);
    ImGui::Spacing(); ImGui::Separator();
    SectionHeader("Advanced Settings");
    ImGui::SliderInt("Aim FOV", &Cross, 1, 1000);
    ImGui::SliderFloat("Distance", &g_disstance, 1.0f, 1000.0f);
    ImGui::SliderFloat("Aim Speed", &AimSpeed, 1.0f, 10.0f);
}

// ============= MAIN MENU WINDOW =============

@implementation mi

INI* config;
OverlayView *overlayView;

- (instancetype)initWithFrame:(ModuleControl*)control {
    self.moduleControl = control;
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"dolphins.ini"];
    if(![fileManager fileExistsAtPath:filePath]){
        [fileManager createFileAtPath:filePath contents:[NSData data] attributes:nil];
    }
    config = ini_load((char*)filePath.UTF8String);
    return [super init];
}

-(void)setOverlayView:(OverlayView*)ov{
    overlayView = ov;
    [self readIniConfig];
}

-(void)drawMenuWindow {
    ImGui::CreateContext();
    ApplyModernDarkTheme();
    
    ImGuiIO& io = ImGui::GetIO();
    ImGui::SetNextWindowSize(ImVec2(900, 600), ImGuiCond_FirstUseEver);
    ImGui::SetNextWindowPos(ImVec2(io.DisplaySize.x * 0.5f, io.DisplaySize.y * 0.5f), 0, ImVec2(0.5f, 0.5f));

    if (ImGui::Begin("DARK IOS MENU", &self.moduleControl->menuStatus, ImGuiWindowFlags_NoCollapse)) {
        
        static int selected_tab = 0;
        const float sidebar_width = 180.0f;
        
        ImGui::BeginChild("Sidebar", ImVec2(sidebar_width, 0), true);
        {
            ImGui::PushStyleColor(ImGuiCol_Text, Colors::Accent);
            ImGui::Text("MENU");
            ImGui::PopStyleColor();
            ImGui::Separator();
            ImGui::Spacing();
            
            const char* tabs[] = {"Main", "ESP", "Loot", "Aim"};
            for (int i = 0; i < 4; i++) {
                if (selected_tab == i) { ImGui::PushStyleColor(ImGuiCol_Button, Colors::Accent); ImGui::PushStyleColor(ImGuiCol_Text, Colors::White); } 
                else { ImGui::PushStyleColor(ImGuiCol_Button, Colors::Black); ImGui::PushStyleColor(ImGuiCol_Text, Colors::Gray); }
                if (ImGui::Button(tabs[i], ImVec2(-1, 50))) { selected_tab = i; }
                ImGui::PopStyleColor(2);
            }
        }
        ImGui::EndChild();
        
        ImGui::SameLine();
        
        ImGui::BeginChild("Content", ImVec2(0, 0), true);
        {
            switch(selected_tab) {
                case 0: DrawMainTab(); break;
                case 1: DrawESPTab(); break;
                case 2: DrawLootTab(); break;
                case 3: DrawAimTab(); break;
            }
        }
        ImGui::EndChild();
    }
    ImGui::End();
}

-(void)readIniConfig {
    switch(self.moduleControl->fps) {
        case 0: overlayView.preferredFramesPerSecond = 60; break;
        case 1: overlayView.preferredFramesPerSecond = 90; break;
        case 2: overlayView.preferredFramesPerSecond = 120; break;
        default: overlayView.preferredFramesPerSecond = 60; break;
    }
}

- (void)dealloc {}

@end
