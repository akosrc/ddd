
// ================================================================================
// -----------------[ TELEGRAM SOURCE ]-----------------
// * BOT:     t.me/imguisource_bot
// * CHANNEL: t.me/ImGui_Source_FIXNEY (ImGui Source)
// * CH 2:    t.me/il2cpp_src (shit src 🧨)
// -----------------------------------------------------
// ================================================================================

//     __ _____ _____ _____
//  __|  |   __|     |   | |  JSON for Modern C++
// |  |  |__   |  |  | | | |  version 3.11.3
// |_____|_____|_____|_|___|  https://github.com/nlohmann/json
//
// SPDX-FileCopyrightText: 2013-2023 Niels Lohmann <https://nlohmann.me>
// SPDX-License-Identifier: MIT

#pragma once

#include <nlohmann/detail/abi_macros.hpp>

NLOHMANN_JSON_NAMESPACE_BEGIN
namespace detail
{

template<typename ...Ts> struct make_void
{
    using type = void;
};
template<typename ...Ts> using void_t = typename make_void<Ts...>::type;

}  // namespace detail
NLOHMANN_JSON_NAMESPACE_END
