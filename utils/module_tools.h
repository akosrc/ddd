#ifndef CustomStrcut_h
#define CustomStrcut_h

#include "imgui.h"
#include <random>
#include <string>

// ImVec3 strukturu
struct ImVec3 {
    float x, y, z;
    ImVec3() : x(0.0f), y(0.0f), z(0.0f) {}
    ImVec3(float _x, float _y, float _z) : x(_x), y(_y), z(_z) {}

    ImVec3 operator-(const ImVec3& other) const {
        return ImVec3(x - other.x, y - other.y, z - other.z);
    }

    static float Dot(const ImVec3& a, const ImVec3& b) {
        return a.x * b.x + a.y * b.y + a.z * b.z;
    }
};

// Objective-C (.h) fayllarının bu strukturları birbaşa tanınması üçün typedef-lər:
typedef struct ModuleControl ModuleControl;
typedef struct PlayerData PlayerData;
typedef struct MaterialData MaterialData;
