//
//  Shape.h
//  PiecewiseAffineWarpFinal
//
//  Created by DINA BURRI on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDMShape.h"
#import "PDMShapeModel.h"


typedef struct {
    float pos[2];
} vertex_t;

@interface Shape : NSObject {
    vertex_t *vertices;
    size_t num_vertices;
    
    triangle_t *triangles;
    size_t num_triangles;
}

@property vertex_t *vertices;
@property size_t num_vertices;

@property triangle_t *triangles;
@property size_t num_triangles;


- (id)initWithTestShape:(CGSize)imgSize;
- (id)initByRandomModifyGivenShape:(Shape*)s;
- (id)initWithPDMShape:(PDMShape*)s :(NSArray*)tri;

@end
