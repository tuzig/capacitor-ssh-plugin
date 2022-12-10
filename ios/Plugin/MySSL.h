//
//  Header.h
//  Plugin
//
//  Created by Benny Daon on 08/12/2022.
//  Copyright © 2022 Max Lynch. All rights reserved.
//
#import <Foundation/Foundation.h>

#ifndef SSL_h
#define SSL_h

@interface MySSL : NSObject

+ (int)keyGenPublicKey:(char *)publicKey privateKey:(char *)privateKey
            passphrase:(char *)passphrase;
@end

#endif /* Header_h */
