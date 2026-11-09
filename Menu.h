#import <UIKit/UIKit.h>

@interface FFMenuViewController : UIViewController
+ (instancetype)sharedInstance;
- (void)showMenu;
@end

// Variáveis globais de estado do ESP para serem lidas pelo Tweak.xm
extern bool espLineEnabled;
extern bool espBoxEnabled;
extern bool espNameEnabled;
extern bool espDistanceEnabled;
