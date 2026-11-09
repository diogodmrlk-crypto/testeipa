#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <mach-o/dyld.h>
#import "Menu.h"
#include "Offsets.h"
#include <math.h>

uint64_t getGameBase() { return _dyld_get_image_vmaddr_slide(0); }

template<typename T>
T ReadMemory(uint64_t address) {
    if (!address || address < 0x100000000) return T();
    return *(T*)address;
}

template<typename T>
void WriteMemory(uint64_t address, T value) {
    if (address && address > 0x100000000) *(T*)address = value;
}

struct Vector3 { float x, y, z; };
Vector3 GetPos3D(uint64_t playerPtr) {
    uint64_t transform = ReadMemory<uint64_t>(playerPtr + FF_Offsets::player_cached_transform);
    if (!transform) return {0,0,0};
    uint64_t posPtr = transform + 0x38; 
    return { ReadMemory<float>(posPtr), ReadMemory<float>(posPtr + 4), ReadMemory<float>(posPtr + 8) };
}

NSString* GetPlayerName(uint64_t playerPtr) {
    uint64_t namePtr = ReadMemory<uint64_t>(playerPtr + FF_Offsets::player_nick_name);
    if (!namePtr) return nil;
    int length = ReadMemory<int>(namePtr + FF_Offsets::managed_string_length);
    if (length <= 0 || length > 32) return nil;
    uint16_t* chars = (uint16_t*)(namePtr + FF_Offsets::managed_string_data);
    return [[NSString alloc] initWithCharacters:chars length:length];
}

extern "C" void DrawFovCircle(CGContextRef ctx) {
    if (!aimbotEnabled) return;
    CGPoint center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 2);
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(ctx, 1.5);
    CGContextStrokeEllipseInRect(ctx, CGRectMake(center.x - aimbotFov/2, center.y - aimbotFov/2, aimbotFov, aimbotFov));
}

extern "C" void DrawESPLoop(CGContextRef ctx) {
    if (!espLineEnabled && !espBoxEnabled && !espNameEnabled && !espDistanceEnabled && !aimbotEnabled && !sniperAlertEnabled && !wallhackEnabled) return;

    uint64_t gameBase = getGameBase(); 
    uint64_t currentGame = ReadMemory<uint64_t>(gameBase + FF_Offsets::game_current_game);
    if (!currentGame) return;
    uint64_t match = ReadMemory<uint64_t>(currentGame + FF_Offsets::game_match);
    if (!match) return;
    uint64_t entitiesPtr = ReadMemory<uint64_t>(match + FF_Offsets::match_entities);
    if (!entitiesPtr) return;

    int entityCount = ReadMemory<int>(entitiesPtr + 0x18); 
    uint64_t entityArray = ReadMemory<uint64_t>(entitiesPtr + 0x10);
    if (!entityArray || entityCount <= 0 || entityCount > 100) return;

    uint64_t localPlayer = ReadMemory<uint64_t>(match + FF_Offsets::match_local_player);
    if (!localPlayer) return;

    Vector3 localPos = GetPos3D(localPlayer);
    int localTeam = ReadMemory<int>(localPlayer + FF_Offsets::player_team);
    CGPoint screenCenter = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 2);

    bool someoneFiringAtMe = false;
    float closestDist = aimbotFov / 2.0f;
    uint64_t aimTarget = 0;

    for (int i = 0; i < entityCount; i++) {
        uint64_t entity = ReadMemory<uint64_t>(entityArray + (i * 8));
        if (!entity || entity == localPlayer) continue;

        // 🛡️ FILTRO DE TIME
        int entityTeam = ReadMemory<int>(entity + FF_Offsets::player_team);
        if (teamCheckEnabled && entityTeam == localTeam) continue; 

        // 👁️ WALLHACK
        uint64_t avatarMgr = ReadMemory<uint64_t>(entity + FF_Offsets::player_avatar_manager);
        if (!avatarMgr) continue;
        
        if (wallhackEnabled) {
            WriteMemory<bool>(avatarMgr + FF_Offsets::avatar_is_visible, true);
        } else {
            bool isVisible = ReadMemory<bool>(avatarMgr + FF_Offsets::avatar_is_visible);
            if (!isVisible) continue; 
        }

        Vector3 enemyPos = GetPos3D(entity);
        float dx = enemyPos.x - localPos.x;
        float dy = enemyPos.y - localPos.y; 
        float dz = enemyPos.z - localPos.z; 
        float distance = sqrt(pow(dx, 2) + pow(dy, 2) + pow(dz, 2));

        // Projeção simulada para a tela
        CGPoint screenPos;
        screenPos.x = screenCenter.x + (dx * 15.0f);
        screenPos.y = screenCenter.y - (dy * 15.0f);

        // 🚨 SNIPER ALERT
        bool isFiring = ReadMemory<bool>(entity + FF_Offsets::magnet_is_firing);
        if (sniperAlertEnabled && isFiring && distance < 150.0f) {
            someoneFiringAtMe = true;
        }

        // 🎯 AIMBOT LÓGICA
        if (aimbotEnabled) {
            float distToCenter = sqrt(pow(screenPos.x - screenCenter.x, 2) + pow(screenPos.y - screenCenter.y, 2));
            if (distToCenter < closestDist) {
                closestDist = distToCenter;
                aimTarget = entity;
            }
        }

        // ESP DESENHO
        if (screenPos.x < 0 || screenPos.x > [UIScreen mainScreen].bounds.size.width) continue;

        if (espLineEnabled) {
            CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
            CGContextSetLineWidth(ctx, 1.5);
            CGContextMoveToPoint(ctx, screenCenter.x, [UIScreen mainScreen].bounds.size.height);
            CGContextAddLineToPoint(ctx, screenPos.x, screenPos.y + 40);
            CGContextStrokePath(ctx);
        }

        if (espBoxEnabled) {
            CGContextSetStrokeColorWithColor(ctx, [UIColor greenColor].CGColor);
            CGContextStrokeRect(ctx, CGRectMake(screenPos.x - 20, screenPos.y - 40, 40, 80));
        }

        if (espNameEnabled) {
            NSString *name = GetPlayerName(entity);
            if (name) [name drawAtPoint:CGPointMake(screenPos.x - 20, screenPos.y - 60) withAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:10], NSForegroundColorAttributeName: [UIColor whiteColor]}];
        }

        if (espDistanceEnabled) {
            NSString *distStr = [NSString stringWithFormat:@"[%.0fm]", distance];
            [distStr drawAtPoint:CGPointMake(screenPos.x - 15, screenPos.y + 45) withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:9], NSForegroundColorAttributeName: [UIColor yellowColor]}];
        }
    }

    // 🚨 PISCAR A TELA SE ALGUÉM ESTIVER ATIRANDO
    if (someoneFiringAtMe) {
        CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
        CGContextSetLineWidth(ctx, 8.0);
        CGContextStrokeRect(ctx, CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height));
    }

    // Se achou alvo no Aimbot (Aviso: falta o offset da câmera para virar o boneco)
    if (aimbotEnabled && aimTarget != 0) {
        // Aqui entraria a função de rotação da câmera. 
        // Como não temos o offset, o boneco não vira, mas a lógica de achar o alvo está pronta.
    }
}

static UIWindow *overlayWindow = nil;
__attribute__((constructor)) static void initTweak() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[FFMenuViewController sharedInstance] showMenu];
        overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        overlayWindow.windowLevel = UIWindowLevelNormal + 1; 
        overlayWindow.backgroundColor = [UIColor clearColor];
        overlayWindow.userInteractionEnabled = NO;
        ESPOverlayView *espView = [[ESPOverlayView alloc] initWithFrame:overlayWindow.bounds];
        [overlayWindow addSubview:espView];
        overlayWindow.hidden = NO;
        
        [NSTimer scheduledTimerWithTimeInterval:0.016 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [espView setNeedsDisplay]; 
        }];
    });
}
