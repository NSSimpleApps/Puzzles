//
//  NSMutableArray+Shuffle.m
//  Puzzles
//
//  Created by NSSimpleApps on 23.05.15.
//  Copyright (c) 2015 NSSimpleApps. All rights reserved.
//

#import "NSMutableArray+Shuffle.h"

@implementation NSMutableArray (Shuffle)

- (void)shuffle {
    
    for (NSUInteger i = 0; i < self.count; ++i) {
        
        NSInteger remainingCount = self.count - i;
        
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t)remainingCount);
        
        [self exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
}

@end
