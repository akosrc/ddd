#import <Foundation/Foundation.h>
#import "FloatView.h"
#import "OverlayView.h"
#include "dolphins.h"
#import "mi.h"
#import <mach-o/dyld.h>
#include <stdio.h>
#include <vector>
#include <iostream>
#include "../utils/module_tools.h"
#include "../dobby/dobby.h"
#include "../utils/log.h"

#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
#define __fastcall
using namespace std;
typedef long kaddr;

// Modul funksiya kontrolleri
ModuleControl moduleControl;

// UI giriş funksiyası
static void didFinishLaunching(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Menyu - metod düzgün şəkildə çağrıldı
        mi* menuWindow = [[mi alloc] initWithModuleControl:&moduleControl];
        
        // Örtük qatı (Overlay)
        OverlayView* overlayView = [[OverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds moduleControl:&moduleControl menuWindow:menuWindow];
        [[UIApplication sharedApplication].keyWindow addSubview:overlayView];
        
        // Kiçik düymə (Float Button)
        FloatView* floatView = [[FloatView alloc] initWithFrame:CGRectMake(489, 58, 45, 45) moduleControl:&moduleControl];
        [[UIApplication sharedApplication].keyWindow addSubview:floatView];
    });
}

// Kitabxana giriş funksiyası
__attribute__((constructor)) static void initialize() {
    // Görünüş yüklənməsi
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, &didFinishLaunching, (CFStringRef)UIApplicationDidFinishLaunchingNotification, NULL, CFNotificationSuspensionBehaviorDrop);
    
    // Hook yüklənməsi
    //loadHook();
}
