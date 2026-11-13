#import <UIKit/UIKit.h>

%hook UIApplication

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    %orig;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DARK IOS" message:@"Tweak Basariyla Yuklendi!" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Tamam" style:UIAlertActionStyleDefault handler:nil]];
        
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        [rootVC presentViewController:alert animated:YES completion:nil];
        
        NSLog(@"[DARK IOS] Test uyarisi gosterildi!");
    });
}

%end
