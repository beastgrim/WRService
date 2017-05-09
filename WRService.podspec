#
# Be sure to run `pod lib lint WRService.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WRService'
  s.version          = '0.1.0'
  s.summary          = 'WRService is light and convinient tool for working with an API via NSURLSession for most of applications.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC

# WRService

WRService is light and convinient tool for working with an API via NSURLSession  for most of applications.

Standart configuration has 2 queues: default and background. Background queue has less priority than standart queue. Each quque is represented as an NSURLSession instance. 

You get internet data throuth WROperations. There is an example:

    NSURL *url = [NSURL URLWithString:@"http://speedtest.ftp.otenet.gr/files/test100Mb.db"];
    
    WROperation *op = [[WROperation alloc] initWithUrl:url];
    
    [[WRService shared] execute:op onSuccess:^(WROperation * _Nonnull op, NSData * _Nonnull data) {
        NSLog(@"Backgound task is READY! %@", op);
    } onFail:^(WROperation * _Nonnull op, NSError * _Nonnull error) {
        NSLog(@"Fail error: %@", error);
    }];



You can get progress via block or delegate. Example:

    op.progressCallback = ^(float progress) {
        NSLog(@"Progress: %f", progress);
    };
    

If you emplemented WRObjectOperationProtocol to your class you can get result as your class instance or array of your class instanse. Example:

    NSURL *url = [NSURL URLWithString:@"http://ip.jsontest.com"];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    WRObjectOperation * objOp = [[WRObjectOperation alloc] initWithRequest:req resultClass:[Article class]];
    
    [[WRService shared] execute:objOp onSuccess:^(WROperation * _Nonnull op, Article  _Nonnull result) {
        NSLog(@"Article: %@", result);
    } onFail:^(WROperation * _Nonnull op, NSError * _Nonnull error) {
        NSLog(@"Error: %@", error);
    }];

WROperation.
------------

Each WROperation has priority property. There are three types of priority: 
WROperationPriorityDefault, WROperationPriorityBackground, WROperationPriorityExclusive.

If you start an operation with Exclusive priority all task (except Exclusive) will be suspended. 
Suspended tasks will continue work after all exclusive tasks is finished.


JSON encoding and decoding.
--------------------------
And if you want have the fastest way for creating class which will be decoded from JSON use NSObject_WRJSON category for generating Objective-C class from JSON object. Example:

    NSURL *url = [NSURL URLWithString:@"https://api.github.com/events"];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    WRObjectOperation *op = [[WRObjectOperation alloc] initWithRequest:req];
    
    [[WRService shared] execute:op onSuccess:^(WROperation * _Nonnull op, NSData*  _Nonnull result) {
        
        id json = [NSJSONSerialization JSONObjectWithData:result options:0 error:nil];
        if (json) {
            NSString *classInterface = [NSObject wrGenerateClass:@"GitHubEvent" fromJSON:json];
            NSLog(@"%@", classInterface);
        }
    } onFail:nil];
    
    
    /* Result of NSLog: */

@class Repo, Actor, Payload;\
@interface GitHubEvent : NSObject

@property (nonatomic, strong) Repo *repo;\
@property (nonatomic, strong) Actor *actor;\
@property (nonatomic, assign) short public;\
@property (nonatomic, assign) NSInteger id;\
@property (nonatomic, copy) NSString *created_at;\
@property (nonatomic, strong) Payload *payload;\
@property (nonatomic, copy) NSString *type;\
@end


@interface Repo : NSObject

@property (nonatomic, assign) NSInteger id;\
@property (nonatomic, copy) NSString *name;\
@property (nonatomic, copy) NSString *url;\
@end


@interface Actor : NSObject

@property (nonatomic, copy) NSString *display_login;\
@property (nonatomic, assign) NSInteger id;\
@property (nonatomic, copy) NSString *login;\
@property (nonatomic, copy) NSString *avatar_url;\
@property (nonatomic, copy) NSString *url;\
@property (nonatomic, copy) NSString *gravatar_id;\
@end

@interface Payload : NSObject

@property (nonatomic, copy) NSString *before;\
@property (nonatomic, copy) NSString *ref;\
@property (nonatomic, assign) NSInteger push_id;\
@property (nonatomic, assign) NSInteger size;\
@property (nonatomic, assign) NSInteger distinct_size;\
@property (nonatomic, copy) NSString *head;\
@end

                       DESC

  s.homepage         = 'https://github.com/beastgrim/WRService'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'beastgrim' => 'beastgrim@gmail.com' }
  s.source           = { :git => 'https://github.com/beastgrim/WRService.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'WRService/Classes/**/*'
  
  # s.resource_bundles = {
  #   'WRService' => ['WRService/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
