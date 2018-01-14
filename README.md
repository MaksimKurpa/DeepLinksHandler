DeepLinksHandler
===========

`DeepLinksHandler` is the easiest way to handle internal and external URLs in your project!

## Demos

I've provided a handful of demos in the bundled example project. To get them to work, you must first install project dependancies with CocoaPods by running:

```
pod install
```


## Installation

Use the awesome [CocoaPods](http://cocoapods.org/) to add `DeepLinksHandler` to your project:

```ruby
pod 'DeepLinksHandler'
```

## Usage

For complience with type of style, use URLs with format:

`deeplinkshandler://inapp_am?type=subscription&productID=com.examplellc.dlh.7days`

where:

scheme - `deeplinkshandler`,
host   - `inapp_am`,
query  - `type=subscription&productID=com.examplellc.dlh.7days`


If you don't need to configurate а complexed behavior, you can use URL without `query`:

`deeplinkshandler://show_subscription_screen`

First special case - handle external URLs when app isn't launched. 

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSURL *url = launchOptions[UIApplicationLaunchOptionsURLKey];
    if (url) {
        [DeepLinksHandler handleURL:url withBlock:^(NSArray<NSURLQueryItem *> *queryItems) {
            NSLog(@"Your deelpink is handled");
        }];
        // this 'dispatch_after' necessary to handle your block after swizzling, which happens after [UIApplication sharedApplication] != nil
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [application openURL:url options:@{} completionHandler:nil];
        });
    }
    return YES;
}
```
In other cases of usage you should set your handle block for special URl before calling its from sowewhere.

<b style='color:red'>!!!Notice:</b> Only the last sent block for a unique URL will be executed.

```objc
static NSString * const kTestHandleURL = @"testurl://viewcontroller?title=ExampleAlert&description=ExampleDescriptionAlert";

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
            [[[UIAlertView alloc] initWithTitle:title message:description delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil] show];
        }
    }];
}

- (IBAction)buttonAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kTestHandleURL] options:@{} completionHandler:nil];
}

@end
```

## License

MIT
