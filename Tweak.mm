#import <UIKit/UIKit.h>

%hook UIWindow

- (void)makeKeyAndVisible {
    %orig;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            // EKRANA KOCAMAN BİR UYARI ÇIKAR (TEST İÇİN)
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DARK IOS" message:@"Tweak Basariyla Yuklendi ve Calisiyor!" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Tamam" style:UIAlertActionStyleDefault handler:nil]];
            
            UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
            [rootVC presentViewController:alert animated:YES completion:nil];
            
            NSLog(@"[DARK IOS] Test uyarisi gosterildi!");
        });
    });
}

%end
