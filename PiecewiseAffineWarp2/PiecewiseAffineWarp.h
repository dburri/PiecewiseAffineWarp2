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

@interface PiecewiseAffineWarp : NSObject
{
    EAGLContext *context;
    
    GLuint framebuffer;
    GLuint colorRenderbuffer;
    
    NSString *fileVShader;
    NSString *fileFShader;
    
    GLuint program;
    GLuint texture;
    GLuint dataTexture;
    GLuint shaderLocation[NUM_LOCATIONS];
    
    CGSize imgSize;
    UIImage *originalImage;
    UIImage *warpedImage;
    
    GLuint vao;
    BOOL dataAvailable;
    int numVertices;
}

@property UIImage *originalImage;
@property UIImage *warpedImage;

typedef unsigned char uchar;



- (void)initOES;

- (void)setupVBO;
- (void)setImage:(UIImage *)image :(Shape*)s1 : (Shape*)s2;

- (void)render;
- (UIImage *)readFramebuffer;

- (void)initShaders;
- (NSString *)loadShaderSource:(NSString *)file;
- (GLuint)compileShader:(NSString *)file :(GLenum)type;

- (void)checkOpenGLError:(NSString *)msg;
- (BOOL)checkForExtension:(NSString*)searchName;
- (uint)findNextPowerOfTwo:(uint)val;

@end
