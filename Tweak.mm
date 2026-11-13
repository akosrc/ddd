#import <JRMemory/JRMemory.h>
#import <UIKit/UIKit.h>
#import "View/FloatView.h"
#import "Menux/Menu.h"
#import "View/OverlayView.h"

// --- KEY SİSTEMİ ENTEGRASYONU ---
extern void showKeyMenu(void);
extern NSString* globalActiveKey;

// Global değişkenler
ModuleControl *moduleControl = nil;
FloatView *floatView = nil;
OverlayView *overlayView = nil;

%hook UIWindow

- (void)makeKeyAndVisible {
    %orig;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            NSLog(@"[DARK IOS] Tweak baslatiliyor...");
            
            // 1. Menü kontrolcüsünü oluştur
            if (!moduleControl) {
                moduleControl = [[ModuleControl alloc] init];
            }
            
            // 2. OverlayView'i oluştur
            if (!overlayView) {
                overlayView = [[OverlayView alloc] initWithFrame:self.bounds :moduleControl :[[mi alloc] initWithFrame:self.bounds :moduleControl]];
                overlayView.userInteractionEnabled = YES;
                [self addSubview:overlayView];
            }
            
            // 3. FloatView (Buton) oluştur ve EKRANIN TAM ORTASINA ekle
            if (!floatView) {
                // Ekranın genişliği ve yüksekliği
                CGFloat screenWidth = self.bounds.size.width;
                CGFloat screenHeight = self.bounds.size.height;
                
                // Buton boyutu
                CGFloat buttonSize = 60.0;
                
                // Butonun merkezde olması için X ve Y konumlarını hesapla
                CGFloat centerX = (screenWidth - buttonSize) / 2.0;
                CGFloat centerY = (screenHeight - buttonSize) / 2.0;
                
                CGRect frame = CGRectMake(centerX, centerY, buttonSize, buttonSize);
                
                floatView = [[FloatView alloc] initWithFrame:frame :moduleControl];
                [self addSubview:floatView];
                [self bringSubviewToFront:floatView];
                
                // TEST İÇİN: Butonun arkasını kırmızı ve tam yuvarlak yapalım
                floatView.backgroundColor = [UIColor redColor]; 
                floatView.layer.cornerRadius = buttonSize / 2.0;
                floatView.layer.masksToBounds = YES;
                
                NSLog(@"[DARK IOS] FloatView EKRANIN ORTASINA eklendi!");
            }
            
            // --- KEY KONTROLÜ ---
            if (globalActiveKey == nil) {
                NSLog(@"[DARK IOS] Key girisi bekleniyor...");
                showKeyMenu();
            } else {
                NSLog(@"[DARK IOS] Key dogrulandi. Sistem hazir.");
            }

        });
    });
}

%end


// --- ESKİ HAFIZA KODLARI ---
bool LockStatus = false;
bool SpeedPlayer = false;

bool hasASLR() {
    const struct mach_header *mach;
    mach = _dyld_get_image_header(0);
    return (mach->flags & MH_PIE);
}

long long get_slide() {
    return _dyld_get_image_vmaddr_slide(0);
}

long long calculateAddress(long long offset) {
    if (hasASLR()) {
        return (get_slide() + offset);
    }
    return offset;
}

bool getType(unsigned int data) {
    int a = data & 0xffff8000;
    int b = a + 0x00008000;
    int c = b & 0xffff7fff;
    return c;
}

bool vm_writeData(long long offset, unsigned int data) {
    kern_return_t err;
    mach_port_t port = mach_task_self();
    long long address = calculateAddress(offset);

    err = vm_protect(port, (vm_address_t)address, sizeof(data), NO, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    if (err != KERN_SUCCESS) return FALSE;

    if(getType(data)) {
        data = CFSwapInt32(data);
        err = vm_write(port, (vm_address_t)address, (vm_offset_t)&data, sizeof(data));
    } else {
        data = (unsigned short)data;
        data = CFSwapInt16(data);
        err = vm_write(port, (vm_address_t)address, (vm_offset_t)&data, sizeof(data));
    }
    
    if (err != KERN_SUCCESS) return FALSE;
    
    err = vm_protect(port, (vm_address_t)address, sizeof(data), NO, VM_PROT_READ | VM_PROT_EXECUTE);
    return TRUE;
}

void setLockStatus(bool state) {
    LockStatus = state;
    if (LockStatus) {
        vm_writeData(0x102CA170C, 0x1F2003D5);
    }
}

void setSpeedPlayer(bool state) {
    SpeedPlayer = state;
    if (SpeedPlayer) {
        vm_writeData(0x102C10D84, 0x0810281E);
    }
}
