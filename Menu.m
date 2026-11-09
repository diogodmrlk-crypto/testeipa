#import "Menu.h"

// Variáveis Globais
bool espLineEnabled = false;
bool espBoxEnabled = false;
bool espNameEnabled = false;
bool espDistanceEnabled = false;

@interface FFMenuViewController ()
@property (nonatomic, strong) UIWindow *menuWindow;
@property (nonatomic, strong) UIView *mainContainer;
@property (nonatomic, strong) UIView *espContainer;
@property (nonatomic, strong) UISegmentedControl *tabControl;
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
    if (self.menuWindow) {
        self.menuWindow.hidden = NO;
        return;
    }

    // Cria uma janela flutuante acima do jogo
    self.menuWindow = [[UIWindow alloc] initWithFrame:CGRectMake(50, 100, 300, 350)];
    self.menuWindow.windowLevel = UIWindowLevelAlert + 1;
    self.menuWindow.backgroundColor = [UIColor clearColor];
    self.menuWindow.rootViewController = self;
    [self.menuWindow makeKeyAndVisible];

    [self setupUI];
}

- (void)setupUI {
    // Container Principal (Fundo escuro arredondado)
    self.mainContainer = [[UIView alloc] initWithFrame:self.menuWindow.bounds];
    self.mainContainer.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:0.95];
    self.mainContainer.layer.cornerRadius = 12;
    self.mainContainer.layer.masksToBounds = YES;
    self.mainContainer.layer.borderWidth = 1.5;
    self.mainContainer.layer.borderColor = [UIColor purpleColor].CGColor;
    [self.view addSubview:self.mainContainer];

    // Cabeçalho Roxo
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    headerView.backgroundColor = [UIColor colorWithRed:0.5 green:0.1 blue:0.8 alpha:1.0];
    [self.mainContainer addSubview:headerView];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 250, 40)];
    titleLabel.text = @"FFH4X ANDROID APK MOD V8.0";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [headerView addSubview:titleLabel];

    // Botão de Fechar (X)
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(265, 5, 30, 30);
    [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(hideMenu) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:closeBtn];

    // Abas (AIM, ESP, CFG, INFO)
    self.tabControl = [[UISegmentedControl alloc] initWithItems:@[@"AIM", @"ESP", @"CFG", @"INFO"]];
    self.tabControl.frame = CGRectMake(10, 50, 280, 30);
    self.tabControl.selectedSegmentIndex = 1; // ESP selecionado
    self.tabControl.backgroundColor = [UIColor darkGrayColor];
    self.tabControl.selectedSegmentTintColor = [UIColor purpleColor];
    [self.tabControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    [self.tabControl addTarget:self action:@selector(tabChanged:) forControlEvents:UIControlEventValueChanged];
    [self.mainContainer addSubview:self.tabControl];

    // Container da Aba ESP
    self.espContainer = [[UIView alloc] initWithFrame:CGRectMake(10, 90, 280, 240)];
    self.espContainer.backgroundColor = [UIColor clearColor];
    [self.mainContainer addSubview:self.espContainer];

    // Adiciona os Switches do ESP
    [self addSwitchToContainer:self.espContainer yPos:10 title:@"ESP Line" action:@selector(toggleLine:) defaultState:espLineEnabled];
    [self addSwitchToContainer:self.espContainer yPos:50 title:@"ESP Box" action:@selector(toggleBox:) defaultState:espBoxEnabled];
    [self addSwitchToContainer:self.espContainer yPos:90 title:@"ESP Name" action:@selector(toggleName:) defaultState:espNameEnabled];
    [self addSwitchToContainer:self.espContainer yPos:130 title:@"ESP DISTANCE" action:@selector(toggleDistance:) defaultState:espDistanceEnabled];

    // Adiciona gesto de arrastar para mover o menu
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [headerView addGestureRecognizer:panGesture];
}

// Função auxiliar para criar os switches bonitinhos
- (void)addSwitchToContainer:(UIView *)container yPos:(CGFloat)y title:(NSString *)title action:(SEL)action defaultState:(bool)state {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, y, 180, 30)];
    label.text = title;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14];
    [container addSubview:label];

    UISwitch *toggle = [[UISwitch alloc] initWithFrame:CGRectMake(200, y, 50, 30)];
    toggle.onTintColor = [UIColor purpleColor];
    toggle.on = state;
    [toggle addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    [container addSubview:toggle];
}

// Ações dos Switches
- (void)toggleLine:(UISwitch *)sender { espLineEnabled = sender.isOn; }
- (void)toggleBox:(UISwitch *)sender { espBoxEnabled = sender.isOn; }
- (void)toggleName:(UISwitch *)sender { espNameEnabled = sender.isOn; }
- (void)toggleDistance:(UISwitch *)sender { espDistanceEnabled = sender.isOn; }

- (void)tabChanged:(UISegmentedControl *)sender {
    // Lógica simples para mostrar/esconder containers
    self.espContainer.hidden = (sender.selectedSegmentIndex != 1);
}

- (void)hideMenu {
    self.menuWindow.hidden = YES;
}

// Lógica para arrastar a janela
- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.view];
    gesture.view.window.center = CGPointMake(gesture.view.window.center.x + translation.x,
                                             gesture.view.window.center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:self.view];
}
@end
