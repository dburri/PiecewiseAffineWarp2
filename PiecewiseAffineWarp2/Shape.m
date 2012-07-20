//
//  Shape.m
//  PiecewiseAffineWarpFinal
//
//  Created by DINA BURRI on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Shape.h"
#import "PDMShape.h"

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



- (id)initWithPDMShape:(PDMShape*)s :(NSArray*)tri
{
    self = [super init];
    
    if (self) {
        NSLog(@"Shape:initWithPDMShape");
        
        num_vertices = s.num_points;
        vertices = malloc(num_vertices*sizeof(vertex_t));
        
        num_triangles = [tri count]/3;
        triangles = malloc(num_triangles*sizeof(triangle_t));
        
        for(int i = 0; i < num_vertices; ++i)
        {
            vertices[i].pos[0] = s.shape[i*3+0];
            vertices[i].pos[1] = s.shape[i*3+1];
        }
        
        for(int i = 0; i < num_triangles; ++i)
        {
            triangles[i].index[0] = [[tri objectAtIndex:i*3+0] intValue];
            triangles[i].index[1] = [[tri objectAtIndex:i*3+1] intValue];
            triangles[i].index[2] = [[tri objectAtIndex:i*3+2] intValue];
        }
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
            vertices[i].pos[0] = floorf(((double)arc4random() / ARC4RANDOM_MAX) * imgSize.width);
            vertices[i].pos[1] = floorf(((double)arc4random() / ARC4RANDOM_MAX) * imgSize.height);
        }
        triangles[0].index[0] = 0;
        triangles[0].index[1] = 1;
        triangles[0].index[2] = 2;
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
            vertices[i].pos[0] = s.vertices[i].pos[0] + floorf((((double)arc4random() / ARC4RANDOM_MAX) - 0.5) * 100);
            vertices[i].pos[1] = s.vertices[i].pos[1] + floorf((((double)arc4random() / ARC4RANDOM_MAX) - 0.5) * 100);
        }
        for(int i = 0; i < num_triangles; ++i)
        {
            triangles[i].index[0] = s.triangles[i].index[0];
            triangles[i].index[1] = s.triangles[i].index[1];
            triangles[i].index[2] = s.triangles[i].index[2];
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
