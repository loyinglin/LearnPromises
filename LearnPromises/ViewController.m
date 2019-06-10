//
//  ViewController.m
//  LearnPromises
//
//  Created by loyinglin on 2019/6/10.
//  Copyright © 2019 Loying. All rights reserved.
//

#import "ViewController.h"
#import <PromisesObjC/FBLPromises.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /******************* basic operator ****************/
//    [self testAsyncAndDo];
//    [self testThen];
//    [self workflow];
    
    
    /******************* extension operator ****************/
    [self testAllAndAny];
    
}


- (void)testAsyncAndDo {
    [FBLPromise onQueue:dispatch_get_main_queue()
                  async:^(FBLPromiseFulfillBlock fulfill,
                          FBLPromiseRejectBlock reject) {
                      // Called asynchronously on the dispatch queue specified.
                      BOOL success = random() % 2;
                      if (success) {
                          // Resolve with a value.
                          fulfill(@"Hello world.");
                      }
                      else {
                          // Resolve with an error.
                          reject([NSError errorWithDomain:@"learn_promises" code:-1 userInfo:nil]);
                      }
                  }];
    
    
    [FBLPromise do:^id _Nullable{
        BOOL success = random() % 2;
        if (success) {
            // Resolve with a value.
            return @"hello world";
        }
        else {
            return [NSError errorWithDomain:@"learn_promises" code:-1 userInfo:nil];
        }
    }];
}


/**
 promise在完成之后，会调用then的方法
 1、直接调用fulfill；
 2、在do方法中返回一个值（不能为error）；
 3、在then方法中返回一个值；
 */
- (void)testThen {
    [[[[FBLPromise do:^id _Nullable{
        BOOL success = YES;
        if (success) {
            // Resolve with a value.
            return @"hello world";
        }
        else {
            return [NSError errorWithDomain:@"learn_promises_do_error" code:-1 userInfo:nil];
        }
    }] then:^id _Nullable(id  _Nullable value) {
        NSLog(@"value: %@", value);
        return @(YES);//[NSError errorWithDomain:@"learn_promises_then_error" code:-1 userInfo:nil];;
    }] then:^id _Nullable(id  _Nullable value) {
        NSLog(@"another then value:%@", value);
        return [NSError errorWithDomain:@"learn_promises_another_then_error" code:-1 userInfo:nil];
    }] catch:^(NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
    }];
}

- (void)workflow {
    [[[[self order:@"order_id"] then:^id _Nullable(NSString * _Nullable value) {
        return [self pay:value];
    }] then:^id _Nullable(id  _Nullable value) {
        return [self check:value];
    }] catch:^(NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
    }];
}

- (FBLPromise<NSString *> *)order:(NSString *)orderParam {
    return [FBLPromise do:^id _Nullable{
        return @"order";
    }];
}

- (FBLPromise<NSString *> *)pay:(NSString *)payParam {
    return  [FBLPromise do:^id _Nullable{
//        return @"pay success";
        return [NSError errorWithDomain:@"pay_error" code:-1 userInfo:nil];
    }];
}

- (FBLPromise<NSString *> *)check:(NSString *)checkParam {
    return  [FBLPromise do:^id _Nullable{
        return @"check success";
    }];
}


- (void)testAllAndAny {
    NSMutableArray *arr = [NSMutableArray new];
    [arr addObject:[self work1]];
    [arr addObject:[self work2]];
    
    [[[FBLPromise all:arr] then:^id _Nullable(NSArray * _Nullable value) {
        NSLog(@"then, value:%@", value);
        return value;
    }] catch:^(NSError * _Nonnull error) {
        NSLog(@"all error:%@", error);
    }];
    
    
    [[[FBLPromise any:arr] then:^id _Nullable(NSArray * _Nullable value) {
        NSLog(@"then, value:%@", value);
        return value;
    }] catch:^(NSError * _Nonnull error) {
        NSLog(@"all error:%@", error);
    }];
    
}

- (FBLPromise<NSString *> *)work1 {
    return [FBLPromise do:^id _Nullable{
        NSLog(@"work1 done");
        return @"work1 done";
    }];
}

- (FBLPromise<NSNumber *> *)work2 {
    return [FBLPromise async:^(FBLPromiseFulfillBlock  _Nonnull fulfill, FBLPromiseRejectBlock  _Nonnull reject) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"work2 done");
            fulfill(@(2));
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"work2 reject");
            reject([NSError errorWithDomain:@"work2_reject" code:-1 userInfo:nil]);
        });
        
    }];
}



@end
