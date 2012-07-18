//
//  Shape.h
//  PiecewiseAffineWarpFinal
//
//  Created by DINA BURRI on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef struct {
    float pos[2];
} vertex_t;

typedef struct {
    unsigned int p_index[3];
} triangle_t;


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

@end
