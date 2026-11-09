#import <UIKit/UIKit.h>

// Variáveis globais que controlam o ESP (Lidas pelo Tweak.xm)
extern bool espLineEnabled;
extern bool espBoxEnabled;
extern bool espNameEnabled;
extern bool espDistanceEnabled;

// Declaração da função de desenho em C puro (Evita erro de linker no arm64)
#ifdef __cplusplus
extern "C" {
#endif
void DrawESPLoop(CGContextRef context);
#ifdef __cplusplus
}
#endif

@interface FFMenuViewController : UIViewController
+ (instancetype)sharedInstance;
- (void)showMenu;
@end

// Classe responsável por desenhar o ESP na tela (Overlay)
@interface ESPOverlayView : UIView
@property (nonatomic, assign) CGContextRef context;
@end
