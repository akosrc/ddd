#import "FloatView.h"

@implementation FloatView {
    NSTimer *_fadeTimer;
}

- (instancetype)initWithFrame:(CGRect)frame :(ModuleControl*)control {
    self = [super initWithFrame:frame];
    if (self) {
        self.moduleControl = control;
        
        // Dairəvi və kənarları səliqəli kəsilmiş dizayn
        self.layer.cornerRadius = frame.size.width / 2.0;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor]; // Şəffaf fond
        self.alpha = 0.7f; // İlkin şəffaflıq 70%
        
        // Şəkli düymənin içərisinə yerləşdiririk (Şəkil adını burada qeyd edirik)
        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        logoImageView.image = [UIImage imageNamed:@"dark.png"]; // Fayl adına uyğun olaraq dəyişə bilərsən (məs: dark.pnj.jpeg)
        logoImageView.contentMode = UIViewContentModeScaleAspectFill;
        logoImageView.layer.cornerRadius = frame.size.width / 2.0;
        logoImageView.clipsToBounds = YES;
        [self addSubview:logoImageView];
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    // Üzərinə basıldıqda dərhal 100% (1.0) şəffaflığa çıxsın
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1.0f;
    }];
    
    // Əvvəlki taymer varsa sıfırlayaq
    if (_fadeTimer) {
        [_fadeTimer invalidate];
        _fadeTimer = nil;
    }
    
    // Menyunu aç/bağla
    if (self.moduleControl) {
        self.moduleControl->menuStatus = !self.moduleControl->menuStatus;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    // Toxunma bitdikdən 5 saniyə sonra yenidən 70% (0.7) şəffaflığa qayıtsın
    _fadeTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [UIView animateWithDuration:0.5 animations:^{
            self.alpha = 0.7f;
        }];
    }];
}

@end
