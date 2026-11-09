#pragma once
#include <cstdint>

namespace FF_Offsets {
    // Ponteiros Base
    constexpr uint64_t game_current_game = 0x8;
    constexpr uint64_t game_match = 0x90;
    constexpr uint64_t match_local_player = 0xD8;
    constexpr uint64_t match_entities = 0x128;

    // Jogador
    constexpr uint64_t player_cached_transform = 0x58;
    constexpr uint64_t player_data_pool = 0x70;
    constexpr uint64_t player_team = 0x430;
    constexpr uint64_t player_nick_name = 0x490;
    constexpr uint64_t player_original_nick_name = 0x498;
    constexpr uint64_t player_follow_camera = 0x690;
    constexpr uint64_t player_head = 0x6A0;
    constexpr uint64_t player_avatar_manager = 0x770;

    // Câmera
    constexpr uint64_t camera_managed_camera = 0x30;
    constexpr uint64_t magnet_main_camera_transform = 0x3E8;

    // Ossos (Bones)
    constexpr uint64_t bone_head = 0x6A0;
    constexpr uint64_t bone_hip = 0x6A8;
    constexpr uint64_t bone_root = 0x6C8;
    constexpr uint64_t bone_left_foot = 0x6E8;
    constexpr uint64_t bone_right_foot = 0x6F0;

    // Strings e Avatar
    constexpr uint64_t managed_string_length = 0x10;
    constexpr uint64_t managed_string_data = 0x14;
    constexpr uint64_t avatar_instance = 0x138;
    constexpr uint64_t avatar_is_visible = 0x101;

    // Funções Especiais (Magnet / Alerta)
    constexpr uint64_t magnet_is_firing = 0x848;
    constexpr uint64_t magnet_colliders = 0xB58;
    constexpr uint64_t magnet_is_female = 0xC14;
}
