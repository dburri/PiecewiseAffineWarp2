//
//  PiecewiseAffineWarpCPU.h
//  PiecewiseAffineWarp2
//
//  Created by DINA BURRI on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDMShape.h"
#import "PDMTriangle.h"

@interface PiecewiseAffineWarpCPU : NSObject


- (UIImage*)warpImage:(UIImage *)image :(PDMShape*)s1 :(PDMShape*)s2 :(NSArray*)tri;
- (NSMutableArray*)findPixelIndices:(float*)A :(CGSize)size;

@end
