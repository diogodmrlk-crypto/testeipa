#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Menu.h"
#include "Offsets.h"

// ==========================================
// Funções de Leitura de Memória (IL2CPP)
// ==========================================
template<typename T>
T ReadMemory(uint64_t address) {
    if (!address) return T();
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
    uint64_t posPtr = transformPtr + 0x38; // Offset padrão de posição no Unity Transform
    float x = ReadMemory<float>(posPtr);
    float y = ReadMemory<float>(posPtr + 4);
    return CGPointMake(x, y);
}

// ==========================================
// Loop de Desenho do ESP (CoreGraphics)
// ==========================================
void DrawESP(CGContextRef ctx) {
    // Se nenhum ESP estiver ligado, não gasta processamento
    if (!espLineEnabled && !espBoxEnabled && !espNameEnabled && !espDistanceEnabled) return;

    // ATENÇÃO: Substitua '0x0' pela base real do módulo do jogo (ex: usando _dyld_get_image_vmaddr_slide)
    uint64_t gameBase = 0x0; 
    
    uint64_t currentGame = ReadMemory<uint64_t>(gameBase + FF_Offsets::game_current_game);
    if (!currentGame) return;
    uint64_t match = ReadMemory<uint64_t>(currentGame + FF_Offsets::game_match);
    if (!match) return;

    uint64_t entitiesPtr = ReadMemory<uint64_t>(match + FF_Offsets::match_entities);
    if (!entitiesPtr) return;

    int entityCount = ReadMemory<int>(entitiesPtr + 0x18); 
    uint64_t entityArray = ReadMemory<uint64_t>(entitiesPtr + 0x10);

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

        // Conversão simplificada (Requer WorldToScreen Matrix para funcionar 100%)
        CGPoint screenPos = CGPointMake(enemyPos.x, enemyPos.y); 

        // Desenha a Linha
        if (espLineEnabled) {
            CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
            CGContextSetLineWidth(ctx, 1.5);
            CGContextMoveToPoint(ctx, screenCenter.x, screenCenter.y);
            CGContextAddLineToPoint(ctx, screenPos.x, screenPos.y);
            CGContextStrokePath(ctx);
        }

        // Desenha a Caixa
        if (espBoxEnabled) {
            CGRect boxRect = CGRectMake(screenPos.x - 20, screenPos.y - 40, 40, 80);
            CGContextSetStrokeColorWithColor(ctx, [UIColor greenColor].CGColor);
            CGContextStrokeRect(ctx, boxRect);
        }

        // Desenha o Nome
        if (espNameEnabled) {
            NSString *name = GetPlayerName(entity);
            if (name) {
                [name drawAtPoint:CGPointMake(screenPos.x - 20, screenPos.y - 60) withAttributes:@{
                    NSFontAttributeName: [UIFont boldSystemFontOfSize:10],
                    NSForegroundColorAttributeName: [UIColor whiteColor]
                }];
            }
        }

        // Desenha a Distância
        if (espDistanceEnabled) {
            NSString *distStr = [NSString stringWithFormat:@"[%.0fm]", distance];
            [distStr drawAtPoint:CGPointMake(screenPos.x - 15, screenPos.y + 45) withAttributes:@{
                NSFontAttributeName: [UIFont systemFontOfSize:9],
                NSForegroundColorAttributeName: [UIColor yellowColor]
            }];
        }
    }
}

// ==========================================
// Injeção do Tweak no Jogo
// ==========================================
%hook UnityFramework

// Hook chamado quando a Unity inicializa. Aqui mostramos o menu.
- (void)UnityInit {
    %orig;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[FFMenuViewController sharedInstance] showMenu];
    });
}

// Você deve procurar a função de renderização correta do FreeFire
// Exemplo genérico de um hook de renderização da Unity
- (void)UnityRender {
    %orig;
    // Cria o contexto gráfico para desenhar na tela
    UIGraphicsBeginImageContextWithOptions([UIScreen mainScreen].bounds.size, NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    DrawESP(ctx);
    
    UIGraphicsEndImageContext();
}
%end
