//
//  CDVGCNSUsersDefaults.m
//  CDVGCNSUsersDefaults
//
//  MIT License
//
//  Copyright (c) 2017 Giulio Caruso aka rdn. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


#import "CDVGCTouchID.h"
#import <LocalAuthentication/LocalAuthentication.h>

@implementation CDVGCTouchID

-(void)isAvailable:(CDVInvokedUrlCommand *)command {
    
    [self.commandDelegate runInBackground:^{
        
        BOOL isAvailable = NO;
        
        if ([LAContext class]) {
            isAvailable = [[[LAContext alloc] init] canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
        } else {
            isAvailable = NO;
        }
        
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isAvailable];
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

-(void)authWithTouchID:(CDVInvokedUrlCommand *)command {
    LAContext *context = [[LAContext alloc] init];
    NSDictionary *options = [[NSDictionary alloc]init];
    
    BOOL insertPwd = NO;
    NSString *textValue = @"";
    NSString *message = @"";
    
    if ([command.arguments count] > 0) {
        options = [command argumentAtIndex:0];
        insertPwd = [[options objectForKey:@"insertPwd"]  isEqual: @"true"] ? YES : NO;
        textValue = [options objectForKey:@"textValue"];
        message = [options objectForKey:@"message"];
    }
    
    context.localizedFallbackTitle = insertPwd ? textValue : @"";
    
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:message
                          reply:^(BOOL success, NSError *error) {
                              
                              if (error) {
                                  CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsBool:false];
                                  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                              }
                              
                              if (success) {
                                  CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:true];
                                  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                              } else {
                                  CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:false];
                                  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                              }
                              
                          }];
        
        
        
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Your device cannot authenticate using TouchID."
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
}

@end
