# WRService

WRService is light and convinient tool for woking with internet. Every iOS application works with internet connection.
This small framework gives you default setting for convinient work in most of applications.

Standart configuration has 2 queues: default and background. Background queue has less priority than standart queue. Each quque is represented as an URLSession instance. 

You get internet data throuth WROperations. There is an example:

    NSURL *url = [NSURL URLWithString:@"http://speedtest.ftp.otenet.gr/files/test100Mb.db"];
    
    WROperation *op = [[WROperation alloc] initWithUrl:url];
    
    [[WRService shared] execute:op onSuccess:^(WROperation * _Nonnull op, NSData * _Nonnull data) {
        NSLog(@"Backgound task is READY! %@", op);
    } onFail:^(WROperation * _Nonnull op, NSError * _Nonnull error) {
        NSLog(@"Fail error: %@", error);
    }];



You can get progress via block. Example:

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

If you start an operation with Exclusive priority all task (except Exclusive) will be suspend.
Suspended task will continued work after all exclusive tasks is finished.


JSON encoding and decoding.
--------------------------
And if you want have the fastest way for creating class which will be decoded from JSON then use NSObject_WRJSON category for generating Objective-C class from JSON object. Example:

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

