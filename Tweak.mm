#import <JRMemory/JRMemory.h>
#import <UIKit/UIKit.h>
#import "View/FloatView.h"
#import "Menux/Menu.h"
#import "View/OverlayView.h"

// --- KEY SİSTEMİ ENTEGRASYONU ---
extern void showKeyMenu(void);
extern NSString* globalActiveKey;

ModuleControl *moduleControl = nil;
FloatView *floatView = nil;
OverlayView *overlayView = nil;

// Butonu ve Menüyü ekrana ekleyen fonksiyon
void SetupMenuUI(UIWindow *window) {
    if (!window) return;
    if (floatView) return; // Zaten eklendiyse tekrar ekleme

    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"[DARK IOS] UI kuruluyor...");

        if (!moduleControl) {
            moduleControl = [[ModuleControl alloc] init];
        }

        // OverlayView (Menü arka planı)
        if (!overlayView) {
            overlayView = [[OverlayView alloc] initWithFrame:window.bounds :moduleControl :[[mi alloc] initWithFrame:window.bounds :moduleControl]];
            overlayView.userInteractionEnabled = YES;
            [window addSubview:overlayView];
        }

        // FloatView (Buton)
        if (!floatView) {
            CGFloat screenWidth = window.bounds.size.width;
            CGFloat screenHeight = window.bounds.size.height;
            CGFloat buttonSize = 80.0; // Boyutu büyüttük
            
            CGFloat centerX = (screenWidth - buttonSize) / 2.0;
            CGFloat centerY = (screenHeight - buttonSize) / 2.0;
            
            CGRect frame = CGRectMake(centerX, centerY, buttonSize, buttonSize);
            floatView = [[FloatView alloc] initWithFrame:frame :moduleControl];
            [window addSubview:floatView];
            [window bringSubviewToFront:floatView]; // Her zaman en önde tut
            
            NSLog(@"[DARK IOS] Buton basariyla eklendi!");
        }

        // Key kontrolü
        static dispatch_once_t keyOnceToken;
        dispatch_once(&keyOnceToken, ^{
            if (globalActiveKey == nil) {
                NSLog(@"[DARK IOS] Key girisi bekleniyor...");
                showKeyMenu();
            }
        });
    });
}

// Oyunun ilk penceresi oluştuğunda tetikle
%hook UIWindow

- (void)makeKeyAndVisible {
    %orig;
    
    // Pencere görünür olduktan sonra 1 saniye bekle ve UI'ı kur
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        SetupMenuUI(self);
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
