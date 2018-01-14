//
//  DeepLinksHandler.h
//  
//
//  Created by Maksim Kurpa on 1/11/18.
//  Copyright © 2018 Maksim Kurpa. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DeepLinksHandlerBlock) (NSArray<NSURLQueryItem *> * _Nullable queryItems);

@interface DeepLinksHandler : NSObject
+ (void)handleURL:(nullable NSURL *)url withBlock:(nullable DeepLinksHandlerBlock)block;
@end
