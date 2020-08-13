//
//  NSString+WKJKit.h
//
//  Created by 王恺靖 on 2019/4/19.
//  Copyright © 2019 wkj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (WKJKit)

- (BOOL)wkj_isMatchRegex:(NSString *)regex;

- (BOOL)wkj_hasChinese;

- (BOOL)wkj_isNumber;

- (NSString *)wkj_MD5String;

- (NSString *)wkj_base64Encode;

- (NSString *)wkj_base64Decode;

- (BOOL)wkj_isURLEncodeString;

- (NSString *)wkj_URLEncodeString;

- (NSString *)wkj_URLQueryEncodeString;

- (NSString *)wkj_URLDecodeString;

- (NSString *)wkj_secretStringWithRange:(NSRange)range;

+ (NSString *)wkj_randomStringWithLenth:(int)len;

+ (NSString *)wkj_formatMediaTimeWithSeconds:(NSInteger)seconds;

+ (NSString *)wkj_formatFileSizeWithBytes:(NSInteger)byte;

- (CGSize)wkj_sizeWithMaxSize:(CGSize)maxSize font:(UIFont *)font;

@end
