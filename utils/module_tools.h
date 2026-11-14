#ifndef CustomStrcut_h
#define CustomStrcut_h

#include "imgui.h"
#include <random>
#include <string>

// ImGui üçün ImVec3 strukturu əlavə olundu
struct ImVec3 {
    float x, y, z;
    ImVec3() : x(0.0f), y(0.0f), z(0.0f) {}
    ImVec3(float _x, float _y, float _z) : x(_x), y(_y), z(_z) {}
};

enum SystemStatus {
    WaitingResponse,
    SystemError,
    NeedUpdate,
    LoginFailure,
    CheckFailure,
    TransmissionNormal,
};

enum MaterialType{
    Null = -1,
    Vehicle = 0,
    Airdrop = 1,
    FlareGun = 2,
    Sniper = 3,
    Rifle = 4,
    Missile = 5,
    Armor = 6,
    SniperParts = 7,
    RifleParts = 8,
    Drug = 9,
    Bullet = 10,
    Grip = 11,
    Sight = 12,
    Warning = 13,
    All = 14,
    WEP=15,
    MachineGun=16,
    Pistol=17,
    ShotGun=18
};

struct MainSwitch {
    int Drawstyle;
    int Drawbox;
    int Drawangle;
    bool playerStatus;
    bool materialStatus;
    bool aimbotStatus;
    bool BulletTrack;
    bool gzb;
};

struct PlayerSwitch {
    bool boxStatus;
    bool boneStatus;
    bool lineStatus;
    bool infoStatus;
    bool radarStatus;
    bool backStatus;
    bool SCStatus;
    bool SCWZStatus;
    bool WZStatus;
    bool WZWZStatus;
    bool Vehiclehf;
    bool Vehiclebox;
    bool Airdropbox;
    bool MG3;
    bool 大菠萝;
    bool 大盘鸡;
    bool AKM;
    bool AUG;
    bool Groza;
    bool QBZ;
    bool G36C;
    bool Mk47;
    bool M16A4;
    bool M416;
    bool SCARL;
    bool M762;
    bool QBU;
    bool AWM;
    bool AMR;
    bool MK12;
    bool 莫辛纳甘;
    bool Mk14;
    bool Kar98k;
    bool M24;
    bool Mini14;
    bool SKS;
    bool SLR;
    bool 手雷;
    bool 烟雾弹;
    bool 燃烧瓶;
    bool 二级头;
    bool 三级头;
    bool 二级甲;
    bool 三级甲;
    bool 二级包;
    bool 三级包;
    bool 肾上腺素;
    bool 止痛药;
    bool 饮料;
    bool 急救包;
    bool 医疗箱;
    bool 红点;
    bool 全息;
    bool 倍镜3;
    bool 倍镜4;
    bool 倍镜6;
    bool 倍镜8;
    bool jdStatus;
    bool jjStatus;
    float radarSize;
    ImVec2 radarCoord;
};

struct AimbotController {
    bool fallNotAim;
    int aimbotMode;
    int aimbotParts;
    float aimbotRadius;
    bool showAimbotRadius;
    float aimbotIntensity;    
    float distance;    
    bool smoke;    
    bool wuhou;
    bool judian;
    bool HitEffect;
    bool BulletFireSpeed;
    bool 人物加速;
    bool 超广角;
    bool 车辆加速;
    float Trackinghitrate;
};

struct Box3D {
    ImVec2 s1;
    ImVec2 s2;
    ImVec2 s3;
    ImVec2 s4;
    ImVec2 s5;
    ImVec2 s6;
    ImVec2 s7;
    ImVec2 s8;
};

struct Vector3A {
    float X;
    float Y;
    float Z;

    Vector3A() {
        this->X = 0;
        this->Y = 0;
        this->Z = 0;
    }

    Vector3A(float x, float y, float z) {
        this->X = x;
        this->Y = y;
        this->Z = z;
    }
};

struct Rotator {
    float Y;
    float X;
    float Roll;
};

struct Tracking {
    Rotator aim_angle;
    Rotator aim_angle1;
    Vector3A loc;
};

struct ModuleControl {
    bool menuStatus;
    int fps;
    SystemStatus systemStatus;
    MainSwitch mainSwitch;
    PlayerSwitch playerSwitch;
    bool materialSwitch[All];
    AimbotController aimbotController;
};

struct BonesVisibleData {
    bool head;
    bool pit;
    bool pelvis;
    bool lcollar;
    bool rcollar;
    bool lelbow;
    bool relbow;
    bool lwrist;
    bool rwrist;
    bool lthigh;
    bool rthigh;
    bool lknee;
    bool rknee;
    bool lankle;
    bool rankle;
};

struct BonesData {
    ImVec2 head;
    ImVec2 pit;
    ImVec2 tripe;
    ImVec2 abdomen;
    ImVec2 jb;
    ImVec2 lcollar;
    ImVec2 rcollar;
    ImVec2 lShoulder;
    ImVec2 rShoulder;
    ImVec2 lelbow;
    ImVec2 relbow;
    ImVec2 lwrist;
    ImVec2 rwrist;
    ImVec2 pelvis;
    ImVec2 lthigh;
    ImVec2 rthigh;
    ImVec2 lknee;
    ImVec2 rknee;
    ImVec2 lankle;
    ImVec2 rankle;
};

struct PlayerData {
    std::string name;
    ImVec2 screen;
    ImVec2 screen2;
    ImVec2 size;
    ImVec2 screen1;
    ImVec2 size1;
    ImVec2 radar;
    float angle;
    int team;
    float VehicleHP;
    float VehicleFuel;
    float VehicleHPMax;
    float VehicleFuelMax;
    float bDead;
    float hp;
    float HPMax;
    Box3D objbox3d;
    std::string weaponName;
    std::string statusName;
    int distance;
    int robot;
    int status;
    BonesVisibleData boneVisibleData;
    BonesData bonesData;
    bool visibility;
    int KillActor;
    std::string KillName;
    int KillHP;
    std::string KillStatus;
    std::string KillweaponName;
    int KillAmmo;
    int KillAmmoMax;
    ImVec3 AimCoord;
    bool AimType;
    ImVec2 AimScreen;
};

struct MaterialData {
    int type;
    int id;
    std::string name;
    int distance;
    Box3D objbox3d;
    float angle;
    float VehicleHP;
    float VehicleFuel;
    float VehicleHPMax;
    float VehicleFuelMax;
    ImVec2 screen;
};

struct StaticPlayerData {
    uintptr_t addr;
    uintptr_t coordAddr;
    std::string name;
    int team;
    int status;
    bool robot;
};

struct StaticMaterialData {
    std::string name;
    int type;
    int id;
    uintptr_t addr;
    uintptr_t coordAddr;
    Box3D objbox3d;
};

struct Ue4Transform {
    ImVec4 rotation;
    ImVec3 translation;
    ImVec3 scale3d;
};

struct Ue4Matrix {
    float matrix[4][4];
    
    float *operator[](int index) {
        return matrix[index];
    }
};

class Ue4Rotator {
public:
    Ue4Rotator() : Pitch(0.f), Yaw(0.f), Roll(0.f) {}
    Ue4Rotator(float _Pitch, float _Yaw, float _Roll) : Pitch(_Pitch), Yaw(_Yaw), Roll(_Roll) {}
    ~Ue4Rotator() {}

    float Pitch;
    float Yaw;
    float Roll;
  
    inline Ue4Rotator Clamp() {
        if (Pitch > 180) Pitch -= 360;
        else if (Pitch < -180) Pitch += 360;
        if (Yaw > 180) Yaw -= 360;
        else if (Yaw < -180) Yaw += 360;
        if (Pitch > 89) Pitch = 89;
        if (Pitch < -89) Pitch = -89;
        while (Yaw < 180) Yaw += 360;
        while (Yaw > 180) Yaw -= 360;
        Roll = 0;
        return Ue4Rotator(Pitch, Yaw, Roll);
    }

    inline float Length() {
        return sqrtf(Pitch * Pitch + Yaw * Yaw + Roll * Roll);
    }

    Ue4Rotator operator+(Ue4Rotator v) {
        return Ue4Rotator(Pitch + v.Pitch, Yaw + v.Yaw, Roll + v.Roll);
    }

    Ue4Rotator operator-(Ue4Rotator v) {
        return Ue4Rotator(Pitch - v.Pitch, Yaw - v.Yaw, Roll - v.Roll);
    }
    
    Ue4Rotator AdjustAim(float hitProbability) {
        if (hitProbability < 0.0f) hitProbability = 0.0f;
        else if (hitProbability > 1.0f) hitProbability = 1.0f;

        std::random_device rd;
        std::mt19937 gen(rd());
        std::uniform_real_distribution<float> dist(-8.0f, 8.0f);

        float pitchOffset = dist(gen) * (1 - hitProbability);
        float yawOffset = dist(gen) * (1 - hitProbability);

        float newPitch = Pitch + pitchOffset;
        float newYaw = Yaw + yawOffset;

        newPitch = fmod(newPitch + 180.0f, 360.0f) - 180.0f;
        newYaw = fmod(newYaw + 180.0f, 360.0f) - 180.0f;

        return Ue4Rotator(newPitch, newYaw, Roll);
    }
};

struct MinimalViewInfo {
    ImVec3 location;
    ImVec3 locationLocalSpace;
    Ue4Rotator rotation;
    float fov;
};

struct MaterialStruct {
    int type;
    int id;
    char name[64];
};

ImVec3 matrixToVector(Ue4Matrix matrix);
Ue4Matrix matrixMulti(Ue4Matrix m1, Ue4Matrix m2);
Ue4Matrix transformToMatrix(Ue4Transform transform);
Ue4Matrix rotatorToMatrix(ImVec3 rotation);
ImVec2 worldToScreen(ImVec3 worldLocation, MinimalViewInfo camViewInfo, ImVec2 screenCenter);
float getAngleDifference(float angle1, float angle2);
float change(float num);
float get2dDistance(ImVec2 self, ImVec2 object);
float get3dDistance(ImVec3 self, ImVec3 object, float divice);
ImVec2 rotateCoord(float angle, ImVec2 coord);
float rotateAngle(ImVec3 selfCoord, ImVec3 targetCoord);
ImVec2 rotateAngleView(ImVec3 selfCoord, ImVec3 targetCoord);
bool isRecycled(const char *name);
MaterialStruct isWeapon(const char *name);
MaterialStruct isMaterial(const char *name);
MaterialStruct isBoxMaterial(int box_goods_id);

#endif /* CustomStrcut_h */
