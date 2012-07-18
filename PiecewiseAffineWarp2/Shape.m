//
//  Shape.m
//  PiecewiseAffineWarpFinal
//
//  Created by DINA BURRI on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Shape.h"
#define ARC4RANDOM_MAX      0x100000000

@implementation Shape

@synthesize vertices;
@synthesize num_vertices;

@synthesize triangles;
@synthesize num_triangles;

- (id)init
{
    self = [super init];
    
    if (self) {
        NSLog(@"Shape:init");
        vertices = NULL;
        triangles = NULL;
    }
    
    return self;
}

- (id)initWithTestShape:(CGSize)imgSize
{
    self = [super init];
    
    if (self) {
        NSLog(@"Shape:initWithTestShape");
        num_vertices = 3;
        vertices = malloc(num_vertices*sizeof(vertex_t));
        
        num_triangles = 1;
        triangles = malloc(num_triangles*sizeof(triangle_t));
        
        for(int i = 0; i < num_vertices; ++i)
        {
            vertices[i].position[0] = floorf(((double)arc4random() / ARC4RANDOM_MAX) * imgSize.width);
            vertices[i].position[1] = floorf(((double)arc4random() / ARC4RANDOM_MAX) * imgSize.height);
            vertices[i].position[2] = 0;
        }
        triangles[0].triangle[0] = 0;
        triangles[0].triangle[1] = 1;
        triangles[0].triangle[2] = 2;
    }
    
    return self;
}

- (id)initByRandomModifyGivenShape:(Shape *)s
{
    self = [super init];
    
    if (self) {
        NSLog(@"Shape:initByRandomModifyGivenShape");
        self.num_vertices = s.num_vertices;
        vertices = malloc(num_vertices*sizeof(vertex_t));
        
        self.num_triangles = s.num_triangles;
        triangles = malloc(num_triangles*sizeof(triangle_t));
        
        for(int i = 0; i < num_vertices; ++i)
        {
            vertices[i].position[0] = floorf(((double)arc4random() / ARC4RANDOM_MAX)*10) + s.vertices[i].position[0];
            vertices[i].position[1] = floorf(((double)arc4random() / ARC4RANDOM_MAX)*10) + s.vertices[i].position[1];
            vertices[i].position[2] = 0;
        }
        for(int i = 0; i < num_triangles; ++i)
        {
            triangles[i].triangle[0] = s.triangles[i].triangle[0];
            triangles[i].triangle[1] = s.triangles[i].triangle[1];
            triangles[i].triangle[2] = s.triangles[i].triangle[2];
        }
    }
    
    return self;
}


- (void)dealloc 
{
    free(vertices);
    free(triangles);
}

@end
