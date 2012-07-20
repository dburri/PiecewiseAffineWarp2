//
//  PiecewiseAffineWarpCPU.m
//  PiecewiseAffineWarp2
//
//  Created by DINA BURRI on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PiecewiseAffineWarpCPU.h"


@interface PiecewiseAffineWarpCPU()
- (BOOL)isPointInsideTriangle:(float)x :(float)y :(float)x1 :(float)y1 :(float)x2 :(float)y2 :(float)x3 :(float)y3;
- (PDMTMat*)getTransformationMatNB:(float*)A:(float*)B;
- (NSMutableArray*)findPixelIndices:(float*)A;
@end

@implementation PiecewiseAffineWarpCPU

- (UIImage*)warpImage:(UIImage *)image :(PDMShape*)s1 :(PDMShape*)s2 :(NSArray*)tri
{
    
    // determine transformation matrix for every triangle pair
    NSMutableArray *transformations = [[NSMutableArray alloc] init];
    NSMutableArray *trianglePixels = [[NSMutableArray alloc] init];
    
    float points1[9];
    float points2[9];
    for (int i = 0; i < [tri count]; ++i) {
        PDMTriangle *triangle = [tri objectAtIndex:i];
        for (int j = 0; j < 3; ++j) {
            points1[j*3+0] = s1.shape[triangle.index[j]].pos[0];
            points1[j*3+1] = s1.shape[triangle.index[j]].pos[1];
            points1[j*3+2] = 0;
            
            points2[j*3+0] = s2.shape[triangle.index[j]].pos[0];
            points2[j*3+1] = s2.shape[triangle.index[j]].pos[1];
            points2[j*3+2] = 0;
        }
        [transformations addObject:[self getTransformationMatNB:&points1[0] :&points2[0]]];
        
        NSMutableArray *pixels = [self findPixelIndices:&points2[0] :image.size];
        [trianglePixels addObject:pixels];
    }


    // go through the whole image and determine pixel value
    
    // put image into data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
//    //int byteIndex = (bytesPerRow * yy) + xx * bytesPerPixel;
//    unsigned char *data_ptr = rawData;
//    for(int yy = 0; yy < height; ++yy)
//    {
//        for(int xx = 0; xx < width; ++xx)
//        {
//            //for(int i = 0; i < [tri count]; ++i)
//            //{
//                //[self isPointInsideTriangle:xx :yy :triangles[i*6] :triangles[i*6+1] :triangles[i*6+2] :triangles[i*6+3] :triangles[i*6+4] :triangles[i*6+5]];
//            //}
//            //NSLog(@"byte index = %i", byteIndex);
//            *data_ptr++ = (xx*255.0)/((float)width);
//            *data_ptr++ = (yy*255.0)/((float)height);
//            *data_ptr++ = 0;
//            *data_ptr++ = 1;
//        }
//    }

    for(int i = 0; i < [trianglePixels count]; ++i)
    {
        NSMutableArray *triangle = [trianglePixels objectAtIndex:i];
        for(int j = 0; j < [triangle count]; ++j)
        {
            int index = [[triangle objectAtIndex:j] intValue];
            int byteIndex = index * bytesPerPixel;
            rawData[byteIndex + 0] = 0;
            rawData[byteIndex + 1] = 1;
            rawData[byteIndex + 2] = 0;
            rawData[byteIndex + 3] = 1;
        }
    }

    CGBitmapInfo bitmapInfo = kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Host;
    CGContextRef contextRef = CGBitmapContextCreate(rawData, width, height, 8, bytesPerRow, colorSpace, bitmapInfo);
    
    CGImageRef imageRef2 = CGBitmapContextCreateImage(contextRef);
    


// DRAW TRIANGLES
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context = CGBitmapContextCreate(NULL, imgSize.width, imgSize.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
//    
//    CGContextSetRGBFillColor(context, (CGFloat)0.0, (CGFloat)0.0, (CGFloat)0.0, (CGFloat)1.0 );
//
//    CGContextMoveToPoint(context, 100, 100);
//    CGContextAddLineToPoint(context, 50, 90);
//    CGContextAddLineToPoint(context, 90, 80);
//    CGContextFillPath(context);
//    CGContextSetLineWidth(context, 1.0);
//    CGContextStrokePath(context);
//    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
//    
//
//    CGImageRef cgImage = CGBitmapContextCreateImage(context);
//    
//    CGColorSpaceRelease(colorSpace);
//    CGContextRelease(context);
//
//    UIImage *warpedImg = [UIImage imageWithCGImage:cgImage];
    
    UIImage *warpedImg = [UIImage imageWithCGImage:imageRef2];

    return warpedImg;
}


- (NSMutableArray*)findPixelIndices:(float*)A :(CGSize)size
{
    NSMutableArray *pixels = [[NSMutableArray alloc] init];
    
    float x_min = INFINITY;
    float x_max = -INFINITY;
    float y_min = INFINITY;
    float y_max = -INFINITY;
    
    for(int i = 0; i < 3; ++i) {
        if(x_min > A[i*3+0]) { x_min = A[i*3+0]; }
        if(x_max < A[i*3+0]) { x_max = A[i*3+0]; }
        if(y_min > A[i*3+1]) { y_min = A[i*3+1]; }
        if(y_max < A[i*3+1]) { y_max = A[i*3+1]; }
    }
    
    //NSLog(@"x_min = %f, x_max = %f, x_min = %f, y_max = %f", x_min, x_max, y_min, y_max);
    
    float m01 = (A[3+1]-A[0+1])/(A[3+0]-A[0+0]);
    float m02 = (A[6+1]-A[0+1])/(A[6+0]-A[0+0]);
    float m12 = (A[6+1]-A[3+1])/(A[6+0]-A[3+0]);
    
    float b01 = (A[3+0]*A[0+1] - A[0+0]*A[3+1]) / (A[3+0] - A[0+0]);
    float b02 = (A[6+0]*A[0+1] - A[0+0]*A[6+1]) / (A[6+0] - A[0+0]);
    float b12 = (A[6+0]*A[3+1] - A[3+0]*A[6+1]) / (A[6+0] - A[3+0]);
    
    
    int scanline_pos = (int)y_min;
    int difference = ((int)y_max - (int)y_min);
    //NSLog(@"scanline_pos = %i, difference = %i", scanline_pos, difference);
    for(int y_pos = scanline_pos; y_pos < (scanline_pos + difference); ++y_pos)
    {
        float x1 = ((float)y_pos - b01)/m01;
        float x2 = ((float)y_pos - b02)/m02;
        float x3 = ((float)y_pos - b12)/m12;
        
        int begin = 0;
        int end = 0;
        if(x1 < x_min) {
            if(x2 < x3) {
                begin = (int)x2;
                end = (int)x3;
            }
            else {
                begin = (int)x3;
                end = (int)x2;
            }
        }
        else if(x1 < x_min) {
            if(x1 < x3) {
                begin = (int)x1;
                end = (int)x3;
            }
            else {
                begin = (int)x3;
                end = (int)x1;
            }
        }
        else {
            if(x1 < x2) {
                begin = (int)x1;
                end = (int)x2;
            }
            else {
                begin = (int)x2;
                end = (int)x1;
            }
        }
        //NSLog(@"\nx1 = %f, x2 = %f, x3 = %f\nbegin = %i, end = %i", x1, x2, x3, begin, end);

        int index = scanline_pos * size.width + begin;
        for(int i = begin; i < end; ++i) {
            [pixels addObject:[NSNumber numberWithInt:index]];
            index++;
        }
    }
    
    
    
    
    return pixels;
}



- (BOOL)isPointInsideTriangle:(float)x :(float)y :(float)xa :(float)ya :(float)xb :(float)yb :(float)xc :(float)yc
{
    float vbx = xb-xa;
    float vby = yb-ya;
    float vcx = xc-xa;
    float vcy = yc-ya;
    float vx = x-xa;
    float vy = y-ya;



    float dot00 = vbx*vbx + vby*vby;
    float dot01 = vbx*vcx + vby*vcy;
    float dot02 = vbx*vx + vby*vy;
    float dot11 = vcx*vcx + vcy*vcy;
    float dot12 = vcx*vx + vcy*vy;

    float invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
    float u = (dot11 * dot02 - dot01 * dot12) * invDenom;
    float v = (dot00 * dot12 - dot01 * dot02) * invDenom;

    return (u >= 0) && (v >= 0) && (u + v < 1);

//// Compute vectors        
//v0 = C - A
//v1 = B - A
//v2 = P - A
//
//// Compute dot products
//dot00 = dot(v0, v0)
//dot01 = dot(v0, v1)
//dot02 = dot(v0, v2)
//dot11 = dot(v1, v1)
//dot12 = dot(v1, v2)
//
//// Compute barycentric coordinates
//invDenom = 1 / (dot00 * dot11 - dot01 * dot01)
//u = (dot11 * dot02 - dot01 * dot12) * invDenom
//v = (dot00 * dot12 - dot01 * dot02) * invDenom
//
//// Check if point is in triangle
//return (u >= 0) && (v >= 0) && (u + v < 1)

}

- (PDMTMat*)getTransformationMatNB:(float*)A:(float*)B
{
    PDMTMat *mat = [[PDMTMat alloc] init];
    
    float x11 = A[0];
    float x12 = A[1];
    float x21 = A[3];
    float x22 = A[4];
    float x31 = A[6];
    float x32 = A[7];
    float y11 = B[0];
    float y12 = B[1];
    float y21 = B[3];
    float y22 = B[4];
    float y31 = B[6];
    float y32 = B[7];
    
    mat.T[0] = ((y11-y21)*(x12-x32)-(y11-y31)*(x12-x22))/((x11-x21)*(x12-x32)-(x11-x31)*(x12-x22));
    mat.T[3] = ((y11-y21)*(x11-x31)-(y11-y31)*(x11-x21))/((x12-x22)*(x11-x31)-(x12-x32)*(x11-x21));
    mat.T[6] = y11-mat.T[0]*x11-mat.T[3]*x12;
    mat.T[1] = ((y12-y22)*(x12-x32)-(y12-y32)*(x12-x22))/((x11-x21)*(x12-x32)-(x11-x31)*(x12-x22));
    mat.T[4] = ((y12-y22)*(x11-x31)-(y12-y32)*(x11-x21))/((x12-x22)*(x11-x31)-(x12-x32)*(x11-x21));
    mat.T[7] = y12-mat.T[1]*x11-mat.T[4]*x12;
    
    mat.T[2] = 0;
    mat.T[5] = 0;
    mat.T[8] = 1;
    
    return mat;
}


@end
