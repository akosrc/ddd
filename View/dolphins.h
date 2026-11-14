#pragma once
#include <vector>
#include "../utils/module_tools.h"
#include "imgui.h"

// Başlıqlar düzgün daxil edildiyi üçün PlayerData, MaterialData və ImVec2 tam tanınacaq
void readFrameData(ImVec2 screenSize, std::vector<PlayerData> &playerDataList, std::vector<MaterialData> &materialDataList);
void *LoadHack(void *);
