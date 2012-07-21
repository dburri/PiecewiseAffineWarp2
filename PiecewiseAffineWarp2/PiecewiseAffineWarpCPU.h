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
- (NSArray*)findLinePoints:(float)x0 :(float)y0 :(float)x1 :(float)y1;
- (void)findContourPoints:(NSArray*)points :(int*)border :(int)height :(int)offset;

@end
