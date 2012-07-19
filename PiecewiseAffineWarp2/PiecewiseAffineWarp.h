//
//  PiecewiseAffineWarp.h
//  PiecewiseAffineWarp
//
//  Created by DINA BURRI on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "Shape.h"

enum {
    VERTEX_TO = 0,
    VERTEX_FROM,
    TEXTURE,
    NUM_LOCATIONS
};

enum {
    SHADER_VERTEX = 0,
    SHADER_FRAGMENT,
    NUM_SHADER
};

@interface PiecewiseAffineWarp : NSObject
{
@public
    UIImage *originalImage;
    UIImage *warpedImage;
    
@private
    EAGLContext *context;
    
    GLuint framebuffer;
    GLuint colorRenderbuffer;
    
    NSString *fileVShader;
    NSString *fileFShader;
    
    GLuint program;
    GLuint texture;
    GLuint vertexBuffer;
    GLuint shader[NUM_SHADER];
    GLuint shaderLocation[NUM_LOCATIONS];
    
    GLuint vao;
    int numVertices;
    
    CGSize imgSize;
    BOOL initialized;
}

@property UIImage *originalImage;
@property UIImage *warpedImage;

typedef unsigned char uchar;



- (void)setImage:(UIImage *)image :(Shape*)s1 : (Shape*)s2;

@end
