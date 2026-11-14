#pragma once
#include <vector>
#include "../utils/module_tools.h"

//获取帧数据
void readFrameData(ImVec2 screenSize, std::vector<PlayerData> &playerDataList, std::vector<MaterialData> &materialDataList);
void *LoadHack(void *);
