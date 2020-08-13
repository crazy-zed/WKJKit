//
//  NSInvocation+WKJKit.h
//  WKJKit
//
//  Created by Zed on 2020/8/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSInvocation (WKJKit)

- (id)wkj_argumentAtIndex:(NSUInteger)index;

- (NSArray *)wkj_arguments;

@end

NS_ASSUME_NONNULL_END
