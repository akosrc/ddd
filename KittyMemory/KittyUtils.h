
// ================================================================================
// Проверенные сурсы в боте @imguisource_bot
// Официальный канал: t.me/ImGui_Source_FIXNEY (ImGui Source)
// Второй канал: t.me/il2cpp_src (shit src 🧨)
// ================================================================================

#pragma once

#include <string>
#include <algorithm>

namespace KittyUtils {

    bool validateHexString(std::string &xstr);
    void toHex(void *const data, const size_t dataLength, std::string &dest);
    void fromHex(const std::string &in, void *const data);

}