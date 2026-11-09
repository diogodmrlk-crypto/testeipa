#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <mach-o/dyld.h> // Necessário para pegar a base do jogo
#import "Menu.h"
#include "Offsets.h"

// Pegar endereço base do binário principal (resolvendo o crash de leitura)
uint64_t getGameBase() {
    return _dyld_get_image_vmaddr_slide(0); 
}

template<typename T>
T ReadMemory(uint64_t address) {
    if (!address || address < 0x100000000) return T();
    return *(T*)address;
}

NSString* GetPlayerName(uint64_t playerPtr) {
    uint64_t namePtr = ReadMemory<uint64_t>(playerPtr + FF_Offsets::player_nick_name);
    if (!namePtr) return nil;
    int length = ReadMemory<int>(namePtr + FF_Offsets::managed_string_length);
    if (length <= 0 || length > 32) return nil;
    uint16_t* chars = (uint16_t*)(namePtr + FF_Offsets::managed_string_data);
    return [[NSString alloc] initWithCharacters:chars length:length];
}

CGPoint GetPlayerPosition(uint64_t playerPtr) {
    uint64_t transformPtr = ReadMemory<uint64_t>(playerPtr + FF_Offsets::player_cached_transform);
    if (!transformPtr) return CGPointZero;
    uint64_t posPtr = transformPtr + 0x38; // Unity Transform Position
    float x = ReadMemory<float>(posPtr);
    float y = ReadMemory<float>(posPtr + 4);
    return CGPointMake(x, y);
}

extern "C" void DrawESPLoop(CGContextRef ctx) {
    if (!espLineEnabled && !espBoxEnabled && !espNameEnabled && !espDistanceEnabled) return;

    // CORREÇÃO 1: Pega a base real do jogo
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
    CGPoint localPos = GetPlayerPosition(localPlayer);

    CGPoint screenCenter = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height);

    for (int i = 0; i < entityCount; i++) {
        uint64_t entity = ReadMemory<uint64_t>(entityArray + (i * 8));
        if (!entity || entity == localPlayer) continue;

        uint64_t avatarMgr = ReadMemory<uint64_t>(entity + FF_Offsets::player_avatar_manager);
        if (!avatarMgr) continue;
        bool isVisible = ReadMemory<bool>(avatarMgr + FF_Offsets::avatar_is_visible);
        if (!isVisible) continue;

        CGPoint enemyPos = GetPlayerPosition(entity);
        float distance = sqrt(pow(enemyPos.x - localPos.x, 2) + pow(enemyPos.y - localPos.y, 2));

        // CORREÇÃO 2: Simulação básica de WorldToScreen
        // O ideal é ler a ViewMatrix do jogo. Sem ela, usamos uma matemática simplificada.
        // Isso fará o ESP aparecer, mas talvez não fique 100% preso no corpo do inimigo em 3D.
        float dx = enemyPos.x - localPos.x;
        float dy = enemyPos.y - localPos.y;
        
        // Projeção aproximada para a tela
        CGPoint screenPos;
        screenPos.x = screenCenter.x + (dx * 10.0f);
        screenPos.y = screenCenter.y - (dy * 10.0f);

        // Se o inimigo estiver atrás de você, não desenha
        if (screenPos.y < 0 || screenPos.y > [UIScreen mainScreen].bounds.size.height) continue;

        if (espLineEnabled) {
            CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
            CGContextSetLineWidth(ctx, 1.5);
            CGContextMoveToPoint(ctx, screenCenter.x, screenCenter.y);
            CGContextAddLineToPoint(ctx, screenPos.x, screenPos.y);
            CGContextStrokePath(ctx);
        }

        if (espBoxEnabled) {
            CGRect boxRect = CGRectMake(screenPos.x - 20, screenPos.y - 40, 40, 80);
            CGContextSetStrokeColorWithColor(ctx, [UIColor greenColor].CGColor);
            CGContextStrokeRect(ctx, boxRect);
        }

        if (espNameEnabled) {
            NSString *name = GetPlayerName(entity);
            if (name) {
                [name drawAtPoint:CGPointMake(screenPos.x - 20, screenPos.y - 60) withAttributes:@{
                    NSFontAttributeName: [UIFont boldSystemFontOfSize:10],
                    NSForegroundColorAttributeName: [UIColor whiteColor]
                }];
            }
        }

        if (espDistanceEnabled) {
            NSString *distStr = [NSString stringWithFormat:@"[%.0fm]", distance];
            [distStr drawAtPoint:CGPointMake(screenPos.x - 15, screenPos.y + 45) withAttributes:@{
                NSFontAttributeName: [UIFont systemFontOfSize:9],
                NSForegroundColorAttributeName: [UIColor yellowColor]
            }];
        }
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
