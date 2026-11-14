
// ================================================================================
// Protected source: @imguisource_bot
// Official channels: t.me/ImGui_Source_FIXNEY & t.me/il2cpp_src
// ================================================================================

#pragma once
#include <GLES3/gl3.h>
#include "ImGui/imgui.h"

// Если stb_image уже подключен в проекте, эту строчку можно убрать
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

// --------------------------------------------------------------------------------------
// 1. Сюда вставь байты своей картинки аниме-персонажа (PNG с прозрачным фоном).
//    Сгенерировать можно через: xxd -i anime.png > anime.h или любой онлайн bin2c конвертер.
// --------------------------------------------------------------------------------------
extern const unsigned char anime_image_png[];
extern const unsigned int anime_image_png_len;

static GLuint g_AnimeTexture = 0;
static int g_AnimeW = 0;
static int g_AnimeH = 0;

inline GLuint LoadTextureFromMemory(const unsigned char* buffer, int len, int* out_w, int* out_h) {
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
}

inline void DrawAnimeModel(ImDrawList* draw, ImVec2 boxMin, ImVec2 boxMax, float scale) {
    if (g_AnimeTexture == 0) {
        g_AnimeTexture = LoadTextureFromMemory(anime_image_png, anime_image_png_len, &g_AnimeW, &g_AnimeH);
    }

    if (g_AnimeTexture != 0) {
        float t = (float)ImGui::GetTime();
        float breathY = sinf(t * 2.2f) * 1.5f * scale; // Анимация дыхания

        ImVec2 imgMin(boxMin.x + 3.0f * scale, boxMin.y + 6.0f * scale + breathY);
        ImVec2 imgMax(boxMax.x - 3.0f * scale, boxMax.y - 6.0f * scale + breathY);

        draw->AddImage((ImTextureID)(intptr_t)g_AnimeTexture, imgMin, imgMax);
    }
}

