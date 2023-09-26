//
//  PuzzleCell.m
//  Puzzles
//
//  Created by NSSimpleApps on 27.10.14.
//  Copyright (c) 2014 NSSimpleApps. All rights reserved.
//

#import "PuzzleCell.h"

@interface PuzzleCell ()

@property (weak, nonatomic) IBOutlet UILabel *mainLabel;

@end

@implementation PuzzleCell

- (void)setLabel:(NSNumber *)label {
    self.mainLabel.text = [label stringValue];
}

- (NSInteger)label {
    return [self.mainLabel.text integerValue];
}

@end
