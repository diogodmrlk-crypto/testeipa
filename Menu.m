#import "Menu.h"

bool espLineEnabled = false;
bool espBoxEnabled = false;
bool espNameEnabled = false;
bool espDistanceEnabled = false;

@implementation FFMenuViewController

+ (instancetype)sharedInstance {
    static FFMenuViewController *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FFMenuViewController alloc] init];
    });
    return instance;
}

- (void)showMenu {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self showMenu]; });
        return;
    }
    if (self.menuWindow && !self.menuWindow.hidden) return;

    self.isMinimized = NO;
    self.menuWindow = [[UIWindow alloc] initWithFrame:CGRectMake(50, 100, 300, 380)];
    self.menuWindow.windowLevel = UIWindowLevelAlert + 1;
    self.menuWindow.backgroundColor = [UIColor clearColor];
    self.menuWindow.rootViewController = self; 
    
    [self setupUI];
    [self.menuWindow makeKeyAndVisible];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor clearColor];
    
    self.mainContainer = [[UIView alloc] initWithFrame:self.view.bounds];
    self.mainContainer.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.08 alpha:0.95];
    self.mainContainer.layer.cornerRadius = 12;
    self.mainContainer.layer.masksToBounds = YES;
    self.mainContainer.layer.borderWidth = 1.5;
    self.mainContainer.layer.borderColor = [UIColor colorWithRed:0.6 green:0.2 blue:0.8 alpha:1.0].CGColor;
    [self.view addSubview:self.mainContainer];

    // Header
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    headerView.backgroundColor = [UIColor colorWithRed:0.6 green:0.2 blue:0.8 alpha:1.0];
    [self.mainContainer addSubview:headerView];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 250, 40)];
    titleLabel.text = @"FFH4X ANDROID APK MOD V8.0";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [headerView addSubview:titleLabel];

    // Botão Minimizar ("-")
    UIButton *minBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    minBtn.frame = CGRectMake(265, 5, 30, 30);
    [minBtn setTitle:@"-" forState:UIControlStateNormal];
    [minBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    minBtn.titleLabel.font = [UIFont boldSystemFontOfSize:24];
    [minBtn addTarget:self action:@selector(toggleMinimize:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:minBtn];

    // Tabs
    self.tabControl = [[UISegmentedControl alloc] initWithItems:@[@"AIM", @"ESP", @"CFG", @"INFO"]];
    self.tabControl.frame = CGRectMake(10, 50, 280, 30);
    self.tabControl.selectedSegmentIndex = 1;
    self.tabControl.selectedSegmentTintColor = [UIColor colorWithRed:0.6 green:0.2 blue:0.8 alpha:1.0];
    [self.tabControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    [self.mainContainer addSubview:self.tabControl];

    // Container ESP
    self.espContainer = [[UIView alloc] initWithFrame:CGRectMake(10, 90, 280, 280)];
    [self.mainContainer addSubview:self.espContainer];

    [self addSwitch:self.espContainer y:10 title:@"ESP Line" action:@selector(toggleLine:) state:espLineEnabled];
    [self addSwitch:self.espContainer y:50 title:@"ESP Box" action:@selector(toggleBox:) state:espBoxEnabled];
    [self addSwitch:self.espContainer y:90 title:@"ESP Name" action:@selector(toggleName:) state:espNameEnabled];
    [self addSwitch:self.espContainer y:130 title:@"ESP DISTANCE" action:@selector(toggleDistance:) state:espDistanceEnabled];

    // Arrastar
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [headerView addGestureRecognizer:pan];
}

- (void)toggleMinimize:(UIButton *)sender {
    if (self.isMinimized) {
        // Restaurar
        self.isMinimized = NO;
        [sender setTitle:@"-" forState:UIControlStateNormal];
        [UIView animateWithDuration:0.3 animations:^{
            self.menuWindow.frame = CGRectMake(self.menuWindow.frame.origin.x, self.menuWindow.frame.origin.y, 300, 380);
            self.tabControl.alpha = 1.0;
            self.espContainer.alpha = 1.0;
        }];
    } else {
        // Minimizar
        self.isMinimized = YES;
        [sender setTitle:@"+" forState:UIControlStateNormal];
        [UIView animateWithDuration:0.3 animations:^{
            self.menuWindow.frame = CGRectMake(self.menuWindow.frame.origin.x, self.menuWindow.frame.origin.y, 300, 40);
            self.tabControl.alpha = 0.0;
            self.espContainer.alpha = 0.0;
        }];
    }
}

- (void)addSwitch:(UIView *)parent y:(CGFloat)y title:(NSString *)title action:(SEL)action state:(bool)state {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(5, y, 180, 30)];
    lbl.text = title;
    lbl.textColor = [UIColor whiteColor];
    [parent addSubview:lbl];
    
    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(210, y, 50, 30)];
    sw.onTintColor = [UIColor colorWithRed:0.6 green:0.2 blue:0.8 alpha:1.0];
    sw.on = state;
    [sw addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    [parent addSubview:sw];
}

- (void)toggleLine:(UISwitch *)s { espLineEnabled = s.isOn; }
- (void)toggleBox:(UISwitch *)s { espBoxEnabled = s.isOn; }
- (void)toggleName:(UISwitch *)s { espNameEnabled = s.isOn; }
- (void)toggleDistance:(UISwitch *)s { espDistanceEnabled = s.isOn; }

- (void)handlePan:(UIPanGestureRecognizer *)g {
    CGPoint translation = [g translationInView:self.view];
    g.view.window.center = CGPointMake(g.view.window.center.x + translation.x, g.view.window.center.y + translation.y);
    [g setTranslation:CGPointZero inView:self.view];
}
@end

@implementation ESPOverlayView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
    }
    return self;
}
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (ctx) DrawESPLoop(ctx);
}
@end
