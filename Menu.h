#import <UIKit/UIKit.h>

extern bool espLineEnabled;
extern bool espBoxEnabled;
extern bool espNameEnabled;
extern bool espDistanceEnabled;

#ifdef __cplusplus
extern "C" {
#endif
void DrawESPLoop(CGContextRef context);
#ifdef __cplusplus
}
#endif

@interface FFMenuViewController : UIViewController
@property (nonatomic, assign) BOOL isMinimized;
@property (nonatomic, strong) UIWindow *menuWindow;
@property (nonatomic, strong) UIView *mainContainer;
@property (nonatomic, strong) UISegmentedControl *tabControl;
@property (nonatomic, strong) UIView *espContainer;
+ (instancetype)sharedInstance;
- (void)showMenu;
@end

@interface ESPOverlayView : UIView
@end
