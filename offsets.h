#pragma once
#include <cstdint>

namespace FF_Offsets {
    // Ponteiros Base da Partida e Jogador
    constexpr uint64_t game_current_game = 0x8;          // CurrentMatchGame
    constexpr uint64_t game_match = 0x90;                // m_Match
    constexpr uint64_t match_local_player = 0xD8;        // MHJCLOPOBAA
    constexpr uint64_t match_entities = 0x128;           // NOLEDCGOJKC

    // Dados do Jogador
    constexpr uint64_t player_cached_transform = 0x58;   // m_CachedTransform
    constexpr uint64_t player_data_pool = 0x70;          // m_PRIDataPool
    constexpr uint64_t player_team = 0x430;              // <DJJMAHEIDID>k__BackingField
    constexpr uint64_t player_nick_name = 0x490;         // BDHGDLFDHAL
    constexpr uint64_t player_head = 0x6A0;              // GBKFHDFCPMD
    constexpr uint64_t player_avatar_manager = 0x770;    // GGJOLDEEIEN

    // Câmera Principal
    constexpr uint64_t camera_managed_camera = 0x30;     // AFMGCAELKBD
    constexpr uint64_t magnet_main_camera_transform = 0x3E8; // MainCameraTransform

    // Ossos (Bones) Principais para ESP
    constexpr uint64_t bone_head = 0x6A0;                // GBKFHDFCPMD
    constexpr uint64_t bone_hip = 0x6A8;                 // COBFGNOIPMF
    constexpr uint64_t bone_root = 0x6C8;                // IIPBIDIBJDK
    constexpr uint64_t bone_left_foot = 0x6E8;           // GMJLIMFHMAE
    constexpr uint64_t bone_right_foot = 0x6F0;          // JMHBBGIKBNO

    // Strings Gerenciadas (Unity)
    constexpr uint64_t managed_string_length = 0x10;     // _stringLength
    constexpr uint64_t managed_string_data = 0x14;       // _firstChar

    // Avatar
    constexpr uint64_t avatar_instance = 0x138;          // LHEDBMJJOLM
    constexpr uint64_t avatar_is_visible = 0x101;        // IsVisible
}
