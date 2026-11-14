
// ================================================================================
// ##################################################
// # Bot: t.me/imguisource_bot
// # Main: t.me/ImGui_Source_FIXNEY (ImGui Source)
// # Two: t.me/il2cpp_src (shit src 🧨)
// ##################################################
// ================================================================================

//     __ _____ _____ _____
//  __|  |   __|     |   | |  JSON for Modern C++
// |  |  |__   |  |  | | | |  version 3.11.3
// |_____|_____|_____|_|___|  https://github.com/nlohmann/json
//
// SPDX-FileCopyrightText: 2013-2023 Niels Lohmann <https://nlohmann.me>
// SPDX-License-Identifier: MIT

#pragma once

#include <nlohmann/detail/macro_scope.hpp>

#if JSON_HAS_EXPERIMENTAL_FILESYSTEM
#include <experimental/filesystem>
NLOHMANN_JSON_NAMESPACE_BEGIN
namespace detail
{
namespace std_fs = std::experimental::filesystem;
}  // namespace detail
NLOHMANN_JSON_NAMESPACE_END
#elif JSON_HAS_FILESYSTEM
#include <filesystem>
NLOHMANN_JSON_NAMESPACE_BEGIN
namespace detail
{
namespace std_fs = std::filesystem;
}  // namespace detail
NLOHMANN_JSON_NAMESPACE_END
#endif
