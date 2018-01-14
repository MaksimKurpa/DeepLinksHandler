//
//  DeepLinksHandler.m
//
//
//  Created by Maksim Kurpa on 1/11/18.
//  Copyright © 2018 Maksim Kurpa. All rights reserved.
//

#import "DeepLinksHandler.h"
#import <objc/runtime.h>

@implementation DeepLinksHandler

static NSMapTable <NSString *, DeepLinksHandlerBlock> *_handlerBlocks = nil;
static NSString *_handlingURL = nil;

#pragma mark - public

+ (void)handleURL:(nullable NSURL *)url withBlock:(nullable DeepLinksHandlerBlock)block
 {
    NSString *key = [self convertToSchemePlusHostKeyForURL:url];
    if (key && block) {
        [_handlerBlocks setObject:block forKey:key];
    }
}

#pragma mark - private

+ (void)load {
    
    _handlerBlocks = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsCopyIn capacity:3];
    
    SEL selectorForSwizzle_UIApplication_ios10_0 = NULL;
    
    if (@available(iOS 10.0, *)) {
        selectorForSwizzle_UIApplication_ios10_0 = @selector(openURL:options:completionHandler:);
    }
    SEL selectorForSwizzle_UIApplication_deprecated = @selector(openURL:);
    
    
    SEL selectorForSwizzle_UIApplicationDelegate_ios9_0 = NULL;
    
    if (@available(iOS 9.0, *)) {
        selectorForSwizzle_UIApplicationDelegate_ios9_0 = @selector(application:openURL:options:);
    }
    SEL selectorForSwizzle_UIApplicationDelegate_deprecated = @selector(application:openURL:sourceApplication:annotation:);
    SEL selectorForSwizzle_UIApplicationDelegate_deprecated2 = @selector(application:handleOpenURL:);
    
    void (^swizzlingBlock)(void) = ^() {
        [self overloadURLsMethodsInObject:[UIApplication sharedApplication] forSelector:selectorForSwizzle_UIApplication_deprecated];
        if (selectorForSwizzle_UIApplication_ios10_0 != NULL) {
            [self overloadURLsMethodsInObject:[UIApplication sharedApplication] forSelector:selectorForSwizzle_UIApplication_ios10_0];
        }
        [self overloadURLsMethodsInObject:[UIApplication sharedApplication].delegate forSelector:selectorForSwizzle_UIApplicationDelegate_deprecated2];
        [self overloadURLsMethodsInObject:[UIApplication sharedApplication].delegate forSelector:selectorForSwizzle_UIApplicationDelegate_deprecated];
        if (selectorForSwizzle_UIApplicationDelegate_ios9_0 != NULL) {
            [self overloadURLsMethodsInObject:[UIApplication sharedApplication].delegate forSelector:selectorForSwizzle_UIApplicationDelegate_ios9_0];
        }
    };
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self runAfterAppInicializationWithBlock:swizzlingBlock];
    });
    
}

+ (void)runAfterAppInicializationWithBlock:(dispatch_block_t)block {
    UIApplication *application = [UIApplication sharedApplication];
    if (!application) {
        [self performSelector:@selector(runAfterAppInicializationWithBlock:) withObject:block afterDelay:0.1];
    } else {
        if (block)
            block();
    }
}

+ (void)overloadURLsMethodsInObject:(id)object forSelector:(SEL)selector {
    
    Method originalMethod = class_getInstanceMethod([object class], selector);
    IMP originalIMP = method_getImplementation(originalMethod);
    NSString *selectorString = NSStringFromSelector(selector);
    NSInteger parametersCount = [selectorString componentsSeparatedByString:@":"].count;
    
    if (parametersCount == 5) {
        //UIApplicationDelegate - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
        
        typedef void (*DeepLinkBlock5Parameters)(void* target, SEL selector, void* value, void* value1, void* value2, void* value3);
        DeepLinkBlock5Parameters block = (DeepLinkBlock5Parameters)(originalIMP);
        swizzleMethodWithBlock_returnedOriginalIMP([object class], selector, ^(void* target, void* value, void* value1, void* value2, void* value3){
            NSURL *sourceURL = [(__bridge id)(value1) isKindOfClass:[NSURL class]] ? (__bridge id)(value1) : nil;
            NSURL *urlDidntHandle = [self handleURL:sourceURL];
            if (urlDidntHandle) {
                block(value, selector, value, value1, value2, value3);
            }
        });
    } else if (parametersCount == 4) {
        //UIApplication - (void)openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options completionHandler:(void (^)(BOOL))completion
        //UIApplicationDelegate - (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
        
        typedef void (*DeepLinkBlock4Parameters)(void* target, SEL selector, void* value, void* value1, void* value2);
        DeepLinkBlock4Parameters block = (DeepLinkBlock4Parameters)(originalIMP);
        swizzleMethodWithBlock_returnedOriginalIMP([object class], selector, ^(void* target, void* value, void* value1, void* value2){
            NSURL *sourceURL = [(__bridge id)(value) isKindOfClass:[NSURL class]] ? (__bridge id)(value) : nil;
            sourceURL = sourceURL ? : ([(__bridge id)(value1) isKindOfClass:[NSURL class]] ? (__bridge id)(value1) : nil);
            NSURL *urlDidntHandle = [self handleURL:sourceURL];
            if (urlDidntHandle) {
                block(target, selector, value, value1, value2);
            }
        });
    } else if (parametersCount == 2) {
        //UIApplicationDelegate - (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
        //UIApplication- (BOOL)openURL:(NSURL *)url
        typedef void (*DeepLinkBlock2Parameters)(void* target, SEL selector, void* value);
        DeepLinkBlock2Parameters block = (DeepLinkBlock2Parameters)(originalIMP);
        swizzleMethodWithBlock_returnedOriginalIMP([object class], selector, ^(void* target, void* value){
            NSURL *sourceURL = [(__bridge id)(value) isKindOfClass:[NSURL class]] ? (__bridge id)(value) : nil;
            NSURL *urlDidntHandle = [self handleURL:sourceURL];
            if (urlDidntHandle) {
                block(target, selector, value);
            }
        });
    }
    
}

#pragma mark - handle

+ (NSURL *)handleURL:(NSURL *)url {
    if ([url.absoluteString isEqualToString:_handlingURL] == NO)
    {
        _handlingURL = url.absoluteString;
        
        NSURL *returnedValue = nil;
        NSString *urlStringKey = [self convertToSchemePlusHostKeyForURL:url];
        DeepLinksHandlerBlock block = [_handlerBlocks objectForKey:urlStringKey];
        
        if (!block) {
            returnedValue = url;
        } else {
            NSArray<NSURLQueryItem *> *queryItems = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES].queryItems;
            [self handleIfAppIsLoadedWithConmplitionBlock:^() {
                block(queryItems);
            }];
        }
        if ([url.absoluteString isEqualToString:_handlingURL])
        {
            _handlingURL = nil;
        }
        return returnedValue;
    }
    else
    {
        return url;
    }
}

+ (void)handleIfAppIsLoadedWithConmplitionBlock:(dispatch_block_t)complitionBlock {
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        if (complitionBlock) {
            complitionBlock();
        }
    } else {
        __block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if (complitionBlock) {
                complitionBlock();
                [[NSNotificationCenter defaultCenter] removeObserver:observer];
                observer = nil;
            }
        }];
    }
}

#pragma mark - swizzling

IMP swizzleMethodWithBlock_returnedOriginalIMP(Class clss, SEL selector, id executionBlock)
{
    if (executionBlock == nil || selector == NULL || clss == NULL) {
        return NULL;
    }
    
    Method originalMethod = class_getInstanceMethod(clss, selector);
    if (originalMethod == NULL) {
        return NULL;
    }
    
    IMP blockIMP = imp_implementationWithBlock(executionBlock);
    BOOL swizzledMethod = class_addMethod(clss, selector, blockIMP, method_getTypeEncoding(originalMethod));
    if (!swizzledMethod) {
        return method_setImplementation(originalMethod, blockIMP);
    } else {
        return method_getImplementation(originalMethod);
    }
}

#pragma mark - utility

+ (NSString *)convertToSchemePlusHostKeyForURL:(NSURL *)url {
    if (!url) {
        return nil;
    }
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
    NSString *stringKey = [NSString stringWithFormat:@"%@://%@", components.scheme ? : @"", components.host ? : @""];
    if (stringKey.length == 0) {
        stringKey = [url absoluteString];
    }
    return stringKey;
}

@end
