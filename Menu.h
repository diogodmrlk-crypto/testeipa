#import <UIKit/UIKit.h>

// ESP
extern bool espLineEnabled;
extern bool espBoxEnabled;
extern bool espNameEnabled;
extern bool espDistanceEnabled;

// AIM
extern bool aimbotEnabled;
extern float aimbotFov;

// MISC / CFG
extern bool wallhackEnabled;
extern bool sniperAlertEnabled;
extern bool teamCheckEnabled;

#ifdef __cplusplus
extern "C" {
#endif
void DrawESPLoop(CGContextRef context);
void DrawFovCircle(CGContextRef context);
#ifdef __cplusplus
}
#endif

@interface FFMenuViewController : UIViewController
@property (nonatomic, assign) BOOL isMinimized;
@property (nonatomic, strong) UIWindow *menuWindow;
@property (nonatomic, strong) UIView *mainContainer;
@property (nonatomic, strong) UIView *aimContainer;
@property (nonatomic, strong) UIView *espContainer;
@property (nonatomic, strong) UIView *miscContainer;
+ (instancetype)sharedInstance;
- (void)showMenu;
@end

@interface ESPOverlayView : UIView
@end
