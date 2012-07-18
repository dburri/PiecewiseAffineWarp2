//
//  PiecewiseAffineWarp.m
//  PiecewiseAffineWarp
//
//  Created by DINA BURRI on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PiecewiseAffineWarp.h"


typedef struct {
    GLfloat posTo[2];
    GLfloat posFrom[2];
} vertex_pair_t;



@implementation PiecewiseAffineWarp

@synthesize originalImage;
@synthesize warpedImage;


//const Vertex vertices3[] = {
//    {{ 1,  1}, {0.8, 0.8}},
//    {{0,  1}, {0.2, 0.8}},
//    {{0, 0}, {0.2, 0.2}},
//    {{-1, 0}, {0.2, 0.2}},
//    {{ 1, 0}, {0.8, 0.2}},
//    {{ 1,  1}, {0.8, 0.8}}
//};

/**
 Initialize object. Overwriten from NSObject
 @returns An initialized object
 */
- (id)init {
    
    self = [super init];
    
    if (self) {
        NSLog(@"INITIALIZE OPENGL!!!");
        
        dataAvailable = NO;
        
        fileVShader = @"vShader";
        fileFShader = @"fShader";
        imgSize = CGSizeMake(640, 960);
        
        [self initOES];
        [self initShaders];
        
        NSLog(@"VertexShader: %@, FragmentShader: %@", fileVShader, fileFShader);
    }
    
    return self;
}


// *************************************************************
// OPENGL HANDLING
// *************************************************************

/**
 Render the scene, that is process the image
 */
- (void)render {
    NSLog(@"Render Image...");
    
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    
    glClearColor(0.5, 0., 0.5, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, imgSize.width, imgSize.height);
    
    glBindVertexArrayOES(vao);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
    glUniform1i(shaderLocation[TEXTURE], 0);
    
    glDrawArrays(GL_TRIANGLES, 0, numVertices);
}

/**
 Create vertex buffer array object
 */
- (void)setupVAO:(const vertex_pair_t*)v :(int)nv
{
    NSLog(@"SETUP VERTEX ARRAY OBJECT");
    
    // create and bind vertex array object
    glGenVertexArraysOES(1, &vao);
    glBindVertexArrayOES(vao);
    
    // create vertex buffer objects
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, nv*sizeof(vertex_pair_t), v, GL_STATIC_DRAW);
    
    
    GLuint vPosition = glGetAttribLocation(program, "aPosTo");
    glEnableVertexAttribArray(vPosition);
    glVertexAttribPointer(vPosition, 2, GL_FLOAT, GL_FALSE, sizeof(vertex_pair_t), 0);
    
    GLuint vTransformation = glGetAttribLocation(program, "aPosFrom");
    glEnableVertexAttribArray(vTransformation);
    glVertexAttribPointer(shaderLocation[VERTEX_FROM], 2, GL_FLOAT, GL_FALSE, sizeof(vertex_pair_t), (GLvoid*)(sizeof(float)*2));
    
    
    
    // Bind back to the default state.
    glBindBuffer(GL_ARRAY_BUFFER,0);
    glBindVertexArrayOES(0);
    
    
    [self checkOpenGLError:@"SetupVAO"];
    
    numVertices = nv;
    dataAvailable = YES;
}

///**
// Create vertex buffer array object
// */
//- (void)setupVAO:(const vertex_t*)v :(int)nv
//{
//    // create and bind vertex array object
//    glGenVertexArraysOES(1, &vao);
//    glBindVertexArrayOES(vao);
//    
//    // create vertex buffer objects
//    GLuint vertexBuffer;
//    glGenBuffers(1, &vertexBuffer);
//    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
//    glBufferData(GL_ARRAY_BUFFER, nv*sizeof(vertex_t), v, GL_STATIC_DRAW);
//    
//    GLuint vPosition = glGetAttribLocation(program, "aPosition");
//    glEnableVertexAttribArray(vPosition);
//    glVertexAttribPointer(vPosition, 4, GL_FLOAT, GL_FALSE, sizeof(vertex_t), 0);
//    
//    
//    // Bind back to the default state.
//    glBindBuffer(GL_ARRAY_BUFFER,0);
//    glBindVertexArrayOES(0);
//    
//    numVertices = nv;
//    dataAvailable = YES;
//}


/**
 Read the OpenGL Framebuffer
 @returns Content of the framebuffer as an image
 */
- (UIImage *)readFramebuffer {
    
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    unsigned char numValues = 4;
    uint dataSize = (uint)(imgSize.width*imgSize.height*numValues);
    NSLog(@"Read number of bytes: %d", dataSize);
    unsigned char *imgData = (unsigned char *)malloc(dataSize);
    if(!imgData) {
        NSLog(@"Could not allocate buffer to retrieve pixels...");
        return nil;
    }
    glReadPixels(0, 0, imgSize.width, imgSize.height, GL_RGBA, GL_UNSIGNED_BYTE, imgData);
    
    GLenum error = glGetError();
    if(error != 0) {
        NSLog(@"Could not read pixels from buffer: %d", error);
        return nil;
    }
    
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Host;
    CGContextRef contextRef = CGBitmapContextCreate(imgData, imgSize.width, imgSize.height, 8, numValues*imgSize.width, colorSpace, bitmapInfo);
    if (!contextRef) {
        NSLog(@"Unable to create CGContextRef...");
        return nil;
    }
    
    CGImageRef imageRef = CGBitmapContextCreateImage(contextRef);
    if (!imageRef) {
        NSLog(@"Unable to create CGImageRef.");
        return nil;
    }
    
    return [UIImage imageWithCGImage:imageRef];
}



/**
 Initialize OpenGL ES (Context, Framebuffer, Renderbuffer)
 */
- (void)initOES {
    
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if(!context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    if(![EAGLContext setCurrentContext:context]) {
        NSLog(@"Failed to set current context to OpenGL");
        exit(1);
    }
    
    
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    
    glGenRenderbuffers(1, &colorRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8_OES, imgSize.width, imgSize.height);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER) ;
    if(status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"failed to make complete framebuffer object %x", status);
        exit(1);
    }
    
    // ---------------------------------
    // check some stuff
    
    GLint myMaxTextureUnits;
    GLint myMaxTextureSize;
    GLint myMaxVertexUniformVectors;
    
    const GLubyte * strVersion;
    const GLubyte * strExt;
    
    float myGLVersion;
    
    
    strVersion = glGetString (GL_VERSION);
    sscanf((char *)strVersion, "%f", &myGLVersion);
    
    strExt = glGetString(GL_EXTENSIONS);
    
    glGetIntegerv(GL_MAX_TEXTURE_IMAGE_UNITS, &myMaxTextureUnits);
    glGetIntegerv(GL_MAX_TEXTURE_SIZE, &myMaxTextureSize); 
    glGetIntegerv(GL_MAX_VERTEX_UNIFORM_VECTORS, &myMaxVertexUniformVectors);
    
    
    GLboolean isTextureObject;
    isTextureObject = [self checkForExtension:[NSString stringWithString:@"EXT_texture_buffer_object"]];
    //isTextureObject = gluCheckExtension((const GLubyte*), strExt); 
    
    NSMutableString *text = [[NSMutableString alloc] init];
    [text appendString:@"\n\n-------------------------------------\n"];
    [text appendFormat:@"OpenGL Version: %s\n", strVersion];
    [text appendFormat:@"GL_MAX_TEXTURE_IMAGE_UNITS = %i\n", myMaxTextureUnits];
    [text appendFormat:@"GL_MAX_TEXTURE_SIZE = %i\n", myMaxTextureSize];
    [text appendFormat:@"GL_MAX_VERTEX_UNIFORM_VECTORS = %i\n", myMaxVertexUniformVectors];
    [text appendFormat:@"isTextureObject = %i\n", isTextureObject];
    [text appendFormat:@"Extensions = \n%s\n", strExt];
    [text appendString:@"-------------------------------------\n\n"];
    NSLog(@"%@", text);

}


/**
 Set a new image to process
 @returns An initialized object
 */
- (void)setImage:(UIImage *)image :(Shape*)s1 : (Shape*)s2 {
    originalImage = image;
    
    
    
    // create vertices from shapes
    assert(s1.num_vertices == s2.num_vertices);
    NSMutableString *text = [[NSMutableString alloc] init];
    
    int num_vertices = s1.num_triangles*3;
    vertex_pair_t *vertex_pairs = malloc(num_vertices*sizeof(vertex_pair_t));
    
    int vpi = 0;
    for(int i = 0; i < s1.num_triangles; ++i)
    {
        const triangle_t *tri = &s1.triangles[i];
        for(int j = 0; j < 3; ++j)
        {
            vertex_pairs[vpi].posFrom[0] = s1.vertices[tri->p_index[j]].pos[0];
            vertex_pairs[vpi].posFrom[1] = s1.vertices[tri->p_index[j]].pos[1];
            
            vertex_pairs[vpi].posTo[0] = s2.vertices[tri->p_index[j]].pos[0];
            vertex_pairs[vpi].posTo[1] = s2.vertices[tri->p_index[j]].pos[1];
            
            [text appendFormat:@"[%f, %f], [%f, %f]\n", vertex_pairs[vpi].posFrom[0], vertex_pairs[vpi].posFrom[1], vertex_pairs[vpi].posTo[0], vertex_pairs[vpi].posTo[1]] ;
            
            vpi++;
        }
        [text appendFormat:@"\n"];
    }
    NSLog(@"Triangles: \n%@", text);
    
    
    
    
    [self setupVAO:vertex_pairs :num_vertices];
    free(vertex_pairs);
    
    
    [self setupTexture:image];
    [self render];
    warpedImage = [self readFramebuffer];
}


/**
 Setup the texture and send the texture to the graphics card
 @param image Image to use as texture
 @returns Handle to texture
 */
- (void)setupTexture:(UIImage *)image {    

    NSLog(@"Setup a new texture with image of size %f x %f...", image.size.width, image.size.height);
    
    // make image size a power of 2
    CGSize sizeNPOT = image.size;
    CGSize size;
    size.width = [self findNextPowerOfTwo:sizeNPOT.width];
    size.height = [self findNextPowerOfTwo:sizeNPOT.height];
    CGRect rectNPOT = CGRectMake(0, 0, sizeNPOT.width, sizeNPOT.height);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:rectNPOT];
    UIImage *imagePOT = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef imageCG = imagePOT.CGImage;
    
    
    // put data into format for opengl
    uchar *data = (uchar *)malloc(size.width*size.height*4);
    memset(data, 0, size.width*size.height*4);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
    CGContextRef imageContext = CGBitmapContextCreate(data, size.width, size.height, 8, size.width*4, colorSpace, bitmapInfo);    
    CGColorSpaceRelease( colorSpace );
    CGContextClearRect(imageContext, CGRectMake( 0, 0, size.width, size.height));
    CGContextDrawImage(imageContext, CGRectMake(0, 0, size.width, size.height), imageCG);
    
    // generate texture
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST); 
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, size.width, size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    CGContextRelease(imageContext);
    free(data);
    
    GLint imgSizeLocation = glGetUniformLocation(program, "uImgSize");
    glUniform2f(imgSizeLocation, sizeNPOT.width, sizeNPOT.height);
    
    GLint texSizeLocation = glGetUniformLocation(program, "uTexSize");
    glUniform2f(texSizeLocation, size.width, size.height);
    
    
    GLenum error = glGetError();
    if(error != GL_NO_ERROR) {
        NSLog(@"Error in setting up texture: %d", error);
    }
}


// *************************************************************
// SHADER HANDLING
// *************************************************************

/**
 Load shader source from file
 @param file Filename which contains the source
 @returns Source code as a string
 */
- (NSString *)loadShaderSource:(NSString *)file {
    
    NSError* err;
    NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:@"glsl"];
    NSString *shader = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    
    //NSLog(@"Shader Code: \n%@", shader);
    
    if (!shader) {
        NSLog(@"Couldn't load shader %@: %@", path, err.localizedDescription);
        exit(1);
    }
    return shader;
}


/**
 Compile a shader source
 @param source Shader source code as a string
 @param type Shader type
 @returns Handle to shader
 */
- (GLuint)compileShader:(NSString *)source :(GLenum)type {
    
    // load code from file and create shader
    NSString *stringShader = source;
    GLuint shader = glCreateShader(type);
    
    // set the shader source
    const char *stringShaderUTF8 = [stringShader UTF8String];    
    int stringShaderSize = [stringShader length];
    glShaderSource(shader, 1, &stringShaderUTF8, &stringShaderSize);

    // compile shader code
    glCompileShader(shader);
    
    // check if successfully compiled
    GLint  compiled;
	glGetShaderiv( shader, GL_COMPILE_STATUS, &compiled );
	if(!compiled) {
        NSLog(@"Failed to compile shader of type %d", type);
	    GLint logSize;
	    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logSize);
	    GLchar logMsg[logSize];
	    glGetShaderInfoLog(shader, logSize, NULL, &logMsg[0]);
        NSLog(@"%s", logMsg);
	    exit(EXIT_FAILURE);
	}
    
    return shader;
}

/**
 Initialize shaders
 */
- (void)initShaders {
    
    NSString *stringVShader = [self loadShaderSource:fileVShader];
    NSString *stringFShader = [self loadShaderSource:fileFShader];
    
    GLuint vShader = [self compileShader:stringVShader :GL_VERTEX_SHADER];
    GLuint fShader = [self compileShader:stringFShader :GL_FRAGMENT_SHADER];
    
    program = glCreateProgram();
    glAttachShader(program, vShader);
    glAttachShader(program, fShader);
    glLinkProgram(program);
    
    // check if linking was successfull
    GLint linked;
	glGetProgramiv( program, GL_LINK_STATUS, &linked );
	if(linked != GL_TRUE) {
        NSLog(@"Failed to link shader!");
	    GLint logSize;
	    glGetShaderiv(program, GL_INFO_LOG_LENGTH, &logSize);
	    GLchar logMsg[logSize];
	    glGetShaderInfoLog(program, logSize, NULL, &logMsg[0]);
        NSLog(@"%@", logMsg);
        
	    exit(EXIT_FAILURE);
	}
    else {
        NSLog(@"Successfully linked shader");
    }
    
    glUseProgram(program);
    
	shaderLocation[VERTEX_TO] = glGetAttribLocation(program, "aPosTo");
	shaderLocation[VERTEX_FROM] = glGetAttribLocation(program, "aPosFrom");
    shaderLocation[TEXTURE] = glGetUniformLocation(program, "texUnit");
    
    glEnableVertexAttribArray(shaderLocation[VERTEX_TO]);
    glEnableVertexAttribArray(shaderLocation[VERTEX_FROM]);
    
    [self checkOpenGLError:@"In initShaders"];
}


// *************************************************************
// MISC FUNCTIONS
// *************************************************************

/**
 Check for OpenGL ES errors
 @param msg Message to show with error code
 */
- (void)checkOpenGLError:(NSString *)msg {
    GLenum errCode;
    if ((errCode = glGetError()) != GL_NO_ERROR) {
        NSLog(@"OpenGL Error, Message: %@, Code: %d\n", msg, errCode);
    }
}

- (BOOL)checkForExtension:(NSString*)searchName

{
    // For performance, the array can be created once and cached.
    NSString *extensionsString = [NSString stringWithCString:(const char*)glGetString(GL_EXTENSIONS) encoding: NSASCIIStringEncoding];
    
    NSArray *extensionsNames = [extensionsString componentsSeparatedByString:@" "];
    return [extensionsNames containsObject: searchName];
}

/**
 Find the next power of two
 see: http://acius2.blogspot.com/2007/11/calculating-next-power-of-2.html
 @param val Value to search the next power of two
 @returns Power of two value
 */
- (uint)findNextPowerOfTwo:(uint)val {
    val--;
    val = (val >> 1) | val;
    val = (val >> 2) | val;
    val = (val >> 4) | val;
    val = (val >> 8) | val;
    val = (val >> 16) | val;
    val++;
    return val;
}



@end
