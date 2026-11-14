#pragma once
#include <vector>
#include "../utils/module_tools.h"

void readFrameData(ImVec2 screenSize, std::vector<PlayerData> &playerDataList, std::vector<MaterialData> &materialDataList);
void *LoadHack(void *);
