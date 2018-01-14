//
//  ViewController.m
//  DeepLinksHandler
//
//  Created by Maksim Kurpa on 1/12/18.
//  Copyright © 2018 Maksim Kurpa. All rights reserved.
//

#import "ViewController.h"
#import "DeepLinksHandler.h"

static NSString * const kTestHandleURL = @"deeplinkshandler://viewcontroller?title=ExampleAlert&description=ExampleDescriptionAlert";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [DeepLinksHandler handleURL:[NSURL URLWithString:kTestHandleURL] withBlock:^(NSArray<NSURLQueryItem *> *queryItems) {
        
        NSString *title = nil;
        NSString *description = nil;
        for (NSURLQueryItem *item in queryItems)
        {
            if ([item.name isEqualToString:@"title"])
                title = item.value;
            else if ([item.name isEqualToString:@"description"])
                description = item.value;
        }
        if (title && description) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [[[UIAlertView alloc] initWithTitle:title message:description delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil] show];
#pragma clang diagnostic pop
        }
    }];
}

- (IBAction)buttonAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kTestHandleURL] options:@{} completionHandler:nil];
}

@end
