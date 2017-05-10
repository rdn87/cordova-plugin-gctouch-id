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

NSString *const kPWD = @"password";
NSString *const kUSER = @"CDVGCTouchID";
NSString *const kSERVER = @"GCSERVER";

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
    
    [self.commandDelegate runInBackground:^{
        
        NSDictionary *options = [[NSDictionary alloc]init];
        BOOL insertPwd = NO;
        NSString *textValue = @"";
        NSString *message = @"";
        BOOL security = NO;
        
        if ([command.arguments count] > 0) {
            options = [command argumentAtIndex:0];
            insertPwd = [[options objectForKey:@"insertPwd"]  isEqual: @"true"] ? YES : NO;
            textValue = [options objectForKey:@"textValue"];
            message = [options objectForKey:@"message"];
            security = [[options objectForKey:@"security"]  isEqual: @"true"] ? YES : NO;
        }
        
        context.localizedFallbackTitle = insertPwd ? textValue : @"";
        
        NSError *error = nil;
        if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
            [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                    localizedReason:message
                              reply:^(BOOL success, NSError *error) {
                                  if (success) {
                                      CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:true];
                                      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                  } else {
                                      
                                      switch (error.code) {
                                          case LAErrorUserFallback:
                                              [[NSOperationQueue mainQueue] addOperationWithBlock:^() {
                                                  
                                                  [self showEnterPassword:security :command];
                                                  
                                              }];
                                              
                                              break;
                                      }
                                      
                                  }
                                  
                              }];
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Your device cannot authenticate using TouchID, try unlock your Device from Home Screen"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert show];
            
        }
    }];
}

-(void)showEnterPassword:(BOOL)useKeyChain :(CDVInvokedUrlCommand *)command {
    UIAlertController *controlAlert =  [UIAlertController alertControllerWithTitle:@"Touch ID Password" message:@"Insert your Password" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        UITextField *textField = controlAlert.textFields.firstObject;
        
        if(useKeyChain) {
            
            if([self isValidPassword:textField.text]) {
                [self returnSuccess:command];
            }
            
        } else {
            
            NSString *pwdStored = [[NSUserDefaults standardUserDefaults] objectForKey:kPWD];
            
            if([textField.text isEqualToString:pwdStored]) {
                [self returnSuccess:command];
            } else {
                [self returnError:command];
            }
        }
        
    }];
    
    
    [controlAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = kPWD;
        textField.textColor = [UIColor blackColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.secureTextEntry = YES;
    }];
    
    [controlAlert addAction:action];
    
    UIViewController *viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    
    if ( viewController.presentedViewController && !viewController.presentedViewController.isBeingDismissed ) {
        viewController = viewController.presentedViewController;
    }
    
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:controlAlert.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:viewController.view.frame.size.height*2.0f];
    
    [controlAlert.view addConstraint:constraint];
    [viewController presentViewController:controlAlert animated:YES completion:nil];
}

-(BOOL)isValidPassword:(NSString *)pwd {
    //Let's create an empty mutable dictionary:
    NSMutableDictionary *keychainItem = [NSMutableDictionary dictionary];
    
    //Populate it with the data and the attributes we want to use.
    
    keychainItem[(__bridge id)kSecClass] = (__bridge id)kSecClassInternetPassword; // We specify what kind of keychain item this is.
    keychainItem[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleWhenUnlocked; // This item can only be accessed when the user unlocks the device.
    keychainItem[(__bridge id)kSecAttrServer] = kSERVER;
    keychainItem[(__bridge id)kSecAttrAccount] = kUSER;
    
    //Check if this keychain item already exists.
    
    keychainItem[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    keychainItem[(__bridge id)kSecReturnAttributes] = (__bridge id)kCFBooleanTrue;
    
    CFDictionaryRef result = nil;
    
    OSStatus sts = SecItemCopyMatching((__bridge CFDictionaryRef)keychainItem, (CFTypeRef *)&result);
    
    NSLog(@"Error Code: %d", (int)sts);
    
    if(sts == noErr)
    {
        NSDictionary *resultDict = (__bridge_transfer NSDictionary *)result;
        NSData *pswd = resultDict[(__bridge id)kSecValueData];
        NSString *password = [[NSString alloc] initWithData:pswd encoding:NSUTF8StringEncoding];
        
        if([password isEqualToString:pwd]) {
            return YES;
        } else {
            return NO;
        }
    }else {
        return NO;
    }
}

-(void)setPassword:(CDVInvokedUrlCommand *)command {
    
    [self.commandDelegate runInBackground:^{
        
        NSDictionary *options = [[NSDictionary alloc]init];
        BOOL security = NO;
        NSString *password = @"";
        
        if ([command.arguments count] > 0) {
            options = [command argumentAtIndex:0];
            security = [[options objectForKey:@"security"]  isEqual: @"true"] ? YES : NO;
            password = [options objectForKey:kPWD];
        }
        
        if(password.length > 0) {
            
            if(security) {
                //Let's create an empty mutable dictionary:
                NSMutableDictionary *keychainItem = [NSMutableDictionary dictionary];
                
                //Populate it with the data and the attributes we want to use.
                
                keychainItem[(__bridge id)kSecClass] = (__bridge id)kSecClassInternetPassword; // We specify what kind of keychain item this is.
                keychainItem[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleWhenUnlocked; // This item can only be accessed when the user unlocks the device.
                keychainItem[(__bridge id)kSecAttrServer] = kSERVER;
                keychainItem[(__bridge id)kSecAttrAccount] = kUSER;
                
                //Check if this keychain item already exists.
                
                if(SecItemCopyMatching((__bridge CFDictionaryRef)keychainItem, NULL) == noErr) {
                    
                    NSMutableDictionary *attributesToUpdate = [NSMutableDictionary dictionary];
                    attributesToUpdate[(__bridge id)kSecValueData] = [password dataUsingEncoding:NSUTF8StringEncoding];
                    
                    OSStatus sts = SecItemUpdate((__bridge CFDictionaryRef)keychainItem, (__bridge CFDictionaryRef)attributesToUpdate);
                    NSLog(@"Error Code: %d", (int)sts);
                    
                    [self returnSuccess:command];
                    
                } else {
                    
                    keychainItem[(__bridge id)kSecValueData] = [password dataUsingEncoding:NSUTF8StringEncoding]; //Our password
                    
                    OSStatus sts = SecItemAdd((__bridge CFDictionaryRef)keychainItem, NULL);
                    NSLog(@"Error Code: %d", (int)sts);
                }
            } else {
                NSUserDefaults *nsU = [NSUserDefaults standardUserDefaults];
                [nsU setObject:password forKey:kPWD];
                [nsU synchronize];
                
                [self returnSuccess:command];
                
            }
        } else {
            [self returnError:command];
        }
    }];
}


-(void)returnSuccess:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:true];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)returnError:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsBool:false];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
