//
//  KIFTestStep+EXAdditions.m
//  Testable
//
//  Created by Eric Firestone on 6/13/11.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "KIFTestStep+EXAdditions.h"
#import <QuartzCore/QuartzCore.h>

@implementation KIFTestStep (EXAdditions)

#pragma mark - Factory Steps

+ (id)stepToReset;
{
    return [KIFTestStep stepWithDescription:@"Reset the application state." executionBlock:^(KIFTestStep *step, NSError **error) {
        BOOL successfulReset = YES;
        
        // Do the actual reset for your app. Set successfulReset = NO if it fails.
        
        KIFTestCondition(successfulReset, error, @"Failed to reset some part of the application.");
        
        return KIFTestStepResultSuccess;
    }];
}

#pragma mark - Step Collections

+ (NSArray *)stepsToGoToLoginPage;
{
    NSMutableArray *steps = [NSMutableArray array];
    
    // Dismiss the welcome message
    [steps addObject:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"That's awesome!"]];
    
    // Tap the "I already have an account" button
    [steps addObject:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"I already have an account."]];
    
    return steps;
}

+ (id)stepToTakeScreenshot:(NSString *)name;
{
    
    NSString *description = nil;
    if (name.length) {
        description = [NSString stringWithFormat:@"Taking screenshot \"%@\"", name];
    } else {
        description = [NSString stringWithFormat:@"Taking screenshot"];
    }
    return [self stepWithDescription:description executionBlock:^(KIFTestStep *step, NSError **error) {
    NSString *outputPath = [[[NSProcessInfo processInfo] environment] objectForKey:@"KIF_SCREENSHOTS"];
    if (!outputPath) {
        KIFTestCondition(NO, error, @"Failed to get output path for screenshots");
        return KIFTestStepResultFailure;
    }
    
    NSArray *windows = [[UIApplication sharedApplication] windows];
    if (windows.count == 0) {
        KIFTestCondition(NO, error, @"Failed to find a window for screenshot");
        return KIFTestStepResultFailure;
    }
    
    UIGraphicsBeginImageContext([[windows objectAtIndex:0] bounds].size);
    for (UIWindow *window in windows) {
        [window.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    outputPath = [outputPath stringByExpandingTildeInPath];
    outputPath = [outputPath stringByAppendingPathComponent:name];
    outputPath = [outputPath stringByAppendingPathExtension:@"png"];
    [UIImagePNGRepresentation(image) writeToFile:outputPath atomically:YES];
    return KIFTestStepResultSuccess;
    }];
}

@end
