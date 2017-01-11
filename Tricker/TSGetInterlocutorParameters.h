//
//  TSGetInterlocutorParameters.h
//  Tricker
//
//  Created by Mac on 11.01.17.
//  Copyright © 2017 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSGetInterlocutorParameters : NSObject

+ (TSGetInterlocutorParameters *)sharedGetInterlocutor;
- (void)getInterlocutorFromDatabase:(NSString *)interlocutorUid respondent:(NSString *)respondent;

@end
