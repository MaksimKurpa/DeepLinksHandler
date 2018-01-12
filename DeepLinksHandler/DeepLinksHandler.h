//
//  DeepLinksHandler.h
//  
//
//  Created by Maksim Kurpa on 1/11/18.
//  Copyright © 2018 Maksim Kurpa. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DeepLinksHandlerBlock) (NSArray<NSURLQueryItem *> *queryItems);

@interface DeepLinksHandler : NSObject
+ (void)setHandlerBlock:(DeepLinksHandlerBlock)block forURL:(NSURL *)url;
@end
