//
//  NSInvocation+WKJKit.m
//  WKJKit
//
//  Created by Zed on 2020/8/12.
//

#import "NSInvocation+WKJKit.h"
#import "WKJCommonDefine.h"
#import <objc/runtime.h>

#define WRAP_AND_RETURN(type) do { type val = 0; [self getArgument:&val atIndex:(NSInteger)index]; return @(val); } while (0)

@implementation NSInvocation (WKJKit)

- (id)wkj_argumentAtIndex:(NSUInteger)index
{
    if (index > self.methodSignature.numberOfArguments - 1) {
        return nil;
    }
    
    const char *argType = [self.methodSignature getArgumentTypeAtIndex:index];
    // Skip const type qualifier.
    if (argType[0] == _C_CONST) argType++;
    
    if (isObjectTypeEncoding(argType) || isClassTypeEncoding(argType)) {
        __autoreleasing id returnObj;
        [self getArgument:&returnObj atIndex:(NSInteger)index];
        return returnObj;
    }
    
    if (isSelectorTypeEncoding(argType)) {
        SEL selector = 0;
        [self getArgument:&selector atIndex:(NSInteger)index];
        return NSStringFromSelector(selector);
    }
    
    // 以下基本类型全部以NSNumber形式返回
    if (isCharTypeEncoding(argType)) {
        WRAP_AND_RETURN(char);
    } else if (isIntTypeEncoding(argType)) {
        WRAP_AND_RETURN(int);
    } else if (isShortTypeEncoding(argType)) {
        WRAP_AND_RETURN(short);
    } else if (isLongTypeEncoding(argType)) {
        WRAP_AND_RETURN(long);
    } else if (isLongLongTypeEncoding(argType)) {
        WRAP_AND_RETURN(long long);
    } else if (isUnsignedCharTypeEncoding(argType)) {
        WRAP_AND_RETURN(unsigned char);
    } else if (isUnsignedIntTypeEncoding(argType)) {
        WRAP_AND_RETURN(unsigned int);
    } else if (isUnsignedShortTypeEncoding(argType)) {
        WRAP_AND_RETURN(unsigned short);
    } else if (isUnsignedLongTypeEncoding(argType)) {
        WRAP_AND_RETURN(unsigned long);
    } else if (isUnsignedLongLongTypeEncoding(argType)) {
        WRAP_AND_RETURN(unsigned long long);
    } else if (isFloatTypeEncoding(argType)) {
        WRAP_AND_RETURN(float);
    } else if (isDoubleTypeEncoding(argType)) {
        WRAP_AND_RETURN(double);
    } else if (isBOOLTypeEncoding(argType)) {
        WRAP_AND_RETURN(BOOL);
    } else if (isCharacterTypeEncoding(argType)) {
        WRAP_AND_RETURN(const char *);
    } else if (isVoidTypeEncoding(argType)) {
        __unsafe_unretained id block = nil;
        [self getArgument:&block atIndex:(NSInteger)index];
        return [block copy];
    } else {
        // 未知类型则以value形式返回
        NSUInteger valueSize = 0;
        NSGetSizeAndAlignment(argType, &valueSize, NULL);
        
        unsigned char valueBytes[valueSize];
        [self getArgument:valueBytes atIndex:(NSInteger)index];
        
        return [NSValue valueWithBytes:valueBytes objCType:argType];
    }
    return nil;
}

- (NSArray *)wkj_arguments
{
    NSMutableArray *args = @[].mutableCopy;
    for (NSUInteger idx = 2; idx < self.methodSignature.numberOfArguments; idx++) {
        [args addObject:[self wkj_argumentAtIndex:idx] ?: NSNull.null];
    }
    return args.copy;
}

@end
