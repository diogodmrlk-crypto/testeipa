#import "Menu.h"

// Definição das variáveis globais
bool espLineEnabled = false;
bool espBoxEnabled = false;
bool espNameEnabled = false;
bool espDistanceEnabled = false;

@interface FFMenuViewController ()
@property (nonatomic, strong) UIWindow *menuWindow;
@end

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
    // Garante que a UI seja criada na Main Thread (Evita crash)
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showMenu];
        });
        return;
    }

    if (self.menuWindow && !self.menuWindow.hidden) {
        return; // Menu já está aberto
    }

    // Cria a janela flutuante
    self.menuWindow = [[UIWindow alloc] initWithFrame:CGRectMake(50, 100, 300, 380)];
    self.menuWindow.windowLevel = UIWindowLevelAlert + 1;
    self.menuWindow.backgroundColor = [UIColor clearColor];
    self.menuWindow.rootViewController = self; // OBRIGATÓRIO para não crashar
    
    // Monta o layout
    [self setupUI];
    [self.menuWindow makeKeyAndVisible];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor clearColor];
    
    UIView *mainContainer = [[UIView alloc] initWithFrame:self.view.bounds];
    mainContainer.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.08 alpha:0.95];
    mainContainer.layer.cornerRadius = 12;
    mainContainer.layer.masksToBounds = YES;
    mainContainer.layer.borderWidth = 1.5;
    mainContainer.layer.borderColor = [UIColor colorWithRed:0.6 green:0.2 blue:0.8 alpha:1.0].CGColor;
    [self.view addSubview:mainContainer];

    // Header Roxo
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    headerView.backgroundColor = [UIColor colorWithRed:0.6 green:0.2 blue:0.8 alpha:1.0];
    [mainContainer addSubview:headerView];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 250, 40)];
    titleLabel.text = @"FFH4X ANDROID APK MOD V8.0";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [headerView addSubview:titleLabel];

    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(265, 5, 30, 30);
    [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(hideMenu) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:closeBtn];

    // Tabs
    UISegmentedControl *tabControl = [[UISegmentedControl alloc] initWithItems:@[@"AIM", @"ESP", @"CFG", @"INFO"]];
    tabControl.frame = CGRectMake(10, 50, 280, 30);
    tabControl.selectedSegmentIndex = 1;
    tabControl.selectedSegmentTintColor = [UIColor colorWithRed:0.6 green:0.2 blue:0.8 alpha:1.0];
    [tabControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    [mainContainer addSubview:tabControl];

    // Switches do ESP
    [self addSwitch:mainContainer y:100 title:@"ESP Line" action:@selector(toggleLine:) state:espLineEnabled];
    [self addSwitch:mainContainer y:140 title:@"ESP Box" action:@selector(toggleBox:) state:espBoxEnabled];
    [self addSwitch:mainContainer y:180 title:@"ESP Name" action:@selector(toggleName:) state:espNameEnabled];
    [self addSwitch:mainContainer y:220 title:@"ESP DISTANCE" action:@selector(toggleDistance:) state:espDistanceEnabled];

    // Arrastar
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [headerView addGestureRecognizer:pan];
}

- (void)addSwitch:(UIView *)parent y:(CGFloat)y title:(NSString *)title action:(SEL)action state:(bool)state {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, y, 180, 30)];
    lbl.text = title;
    lbl.textColor = [UIColor whiteColor];
    [parent addSubview:lbl];
    
    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(220, y, 50, 30)];
    sw.onTintColor = [UIColor colorWithRed:0.6 green:0.2 blue:0.8 alpha:1.0];
    sw.on = state;
    [sw addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    [parent addSubview:sw];
}

- (void)toggleLine:(UISwitch *)s { espLineEnabled = s.isOn; }
- (void)toggleBox:(UISwitch *)s { espBoxEnabled = s.isOn; }
- (void)toggleName:(UISwitch *)s { espNameEnabled = s.isOn; }
- (void)toggleDistance:(UISwitch *)s { espDistanceEnabled = s.isOn; }

- (void)hideMenu {
    self.menuWindow.hidden = YES;
}

- (void)handlePan:(UIPanGestureRecognizer *)g {
    CGPoint translation = [g translationInView:self.view];
    g.view.window.center = CGPointMake(g.view.window.center.x + translation.x, g.view.window.center.y + translation.y);
    [g setTranslation:CGPointZero inView:self.view];
}
@end

// ==========================================
// CAMADA DO ESP (Overlay Transparente)
// ==========================================
@implementation ESPOverlayView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO; // Permite clicar no jogo através do ESP
    }
    return self;
}
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (!ctx) return;
    
    // Importa a função de desenho do Tweak
    extern void DrawESPLoop(CGContextRef context);
    DrawESPLoop(ctx);
}
@end
