//
//  NSString+WKJKit.m
//
//  Created by 王恺靖 on 2019/4/19.
//  Copyright © 2019 wkj. All rights reserved.
//

#import "NSString+WKJKit.h"
#import "WKJCommonDefine.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (WKJKit)

- (BOOL)wkj_isMatchRegex:(NSString *)regex
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [predicate evaluateWithObject:self];
}

- (BOOL)wkj_hasChinese
{
    return [self wkj_isMatchRegex:@"[\u4e00-\u9fa5]{1,}"];
}

- (BOOL)wkj_isNumber
{
    return [self wkj_isMatchRegex:@"[0-9]{1,}"];
}

- (NSString *)wkj_MD5String
{
    const char *cString = [self UTF8String];
    unsigned char md5[32];
    CC_MD5(cString, (CC_LONG)strlen(cString), md5);
    NSMutableString *result = [[NSMutableString alloc] init];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x",md5[i]];
    }
    return result;
}

- (NSString *)wkj_base64Encode
{
    if (!self.length) return @"";
    NSData *d = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSString *result = [d base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    // 去除base64中的\r与\n
    result = [result stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return result.length ? result : @"";
}

- (NSString *)wkj_base64Decode
{
    if (!self.length) return @"";
    NSData *d = [[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSString *result = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    // 去除base64中的\r与\n
    result = [result stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return result.length ? result : @"";
}

- (BOOL)wkj_isURLEncodeString
{
    return ![self.wkj_URLDecodeString isEqualToString:self];
}

- (NSString *)wkj_URLEncodeString
{
    NSCharacterSet *hostSet = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *hostEncode = [self stringByAddingPercentEncodingWithAllowedCharacters:hostSet];
    NSURL *encodeURL = [NSURL URLWithString:hostEncode];
    if (!encodeURL) {
        return self.wkj_URLQueryEncodeString;
    }
    
    // 因URLQueryAllowedCharacterSet编码不完全，所以自己进行query编码，再拼接至原编码串
    if (encodeURL.query.length) {
        hostEncode = [hostEncode stringByReplacingOccurrencesOfString:encodeURL.query withString:@""];
    }

    NSArray *queryItems = [NSURLComponents componentsWithURL:encodeURL resolvingAgainstBaseURL:NO].queryItems;
    for (NSURLQueryItem *item in queryItems) {
        hostEncode = [hostEncode stringByAppendingFormat:@"%@=%@&", item.name.wkj_URLQueryEncodeString, item.value.wkj_URLQueryEncodeString];
    }
    
    hostEncode = queryItems.count ? [hostEncode substringToIndex:hostEncode.length - 1] : hostEncode;
    return hostEncode.copy;
}

- (NSString *)wkj_URLQueryEncodeString
{
    // 除了 !*() 以外，剩下字符都进行编码
    NSMutableCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet].mutableCopy;
    [set removeCharactersInString:@"#&=';:@+/?~$,"];
    return [self stringByAddingPercentEncodingWithAllowedCharacters:set];
}

- (NSString *)wkj_URLDecodeString
{
    return [self stringByRemovingPercentEncoding];
}

- (NSString *)wkj_secretStringWithRange:(NSRange)range
{
    if ((range.location + range.length) > self.length) {
        return self;
    }
    
    return [self stringByReplacingCharactersInRange:range withString:@"*"];
}

+ (NSString *)wkj_randomStringWithLenth:(int)len
{
    char ch[len];
    for (int index=0; index < len; index++) {
        int num = arc4random_uniform(58)+65;
        if (num>90 && num<97) { num = num%90+65; }
        ch[index] = num;
    }
    return [[NSString alloc] initWithBytes:ch length:len encoding:NSUTF8StringEncoding];
}

+ (NSString *)wkj_formatFileSizeWithBytes:(NSInteger)byte
{
    float formatSize = byte;
    NSString *unit = @"B";
    
    if (byte / 1024.f < 1024.f) {
        formatSize = byte / 1024.f;
        unit = @"KB";
    }
    else if (byte / pow(1024.f, 2) < 1024.f) {
        formatSize = byte / pow(1024.f, 2);
        unit = @"MB";
    }
    else {
        formatSize = byte / pow(1024.f, 2) / 1024.f;
        unit = @"GB";
    }
    
    return NSFormatString(@"%.1f %@", formatSize, unit);
}

+ (NSString *)wkj_formatMediaTimeWithSeconds:(NSInteger)seconds
{
    if (seconds / 3600 >= 1) {
        NSString *hour = NSFormatString(@"%.2ld", seconds / 3600);
        NSString *minute = NSFormatString(@"%.2ld", (seconds % 3600) / 60);
        NSString *second = NSFormatString(@"%.2ld", seconds % 60);
        return NSFormatString(@"%@:%@:%@", hour, minute, second);
    }
    else {
        NSString *minute = NSFormatString(@"%.2ld", seconds / 60);
        NSString *second = NSFormatString(@"%.2ld", seconds % 60);
        return NSFormatString(@"%@:%@", minute, second);
    }
}

- (CGSize)wkj_sizeWithMaxSize:(CGSize)maxSize font:(UIFont *)font
{
    return [self boundingRectWithSize:maxSize
                              options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin
                           attributes:@{NSFontAttributeName:font}
                              context:nil].size;
}

@end
