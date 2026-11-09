#import <UIKit/UIKit.h>

// Variáveis globais que controlam o ESP (Lidas pelo Tweak.xm)
extern bool espLineEnabled;
extern bool espBoxEnabled;
extern bool espNameEnabled;
extern bool espDistanceEnabled;

@interface FFMenuViewController : UIViewController
+ (instancetype)sharedInstance;
- (void)showMenu;
@end

// Classe responsável por desenhar o ESP na tela (Overlay)
@interface ESPOverlayView : UIView
@property (nonatomic, assign) CGContextRef context;
@end
