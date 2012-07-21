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
@end

@implementation PiecewiseAffineWarpCPU

- (UIImage*)warpImage:(UIImage *)image :(PDMShape*)s1 :(PDMShape*)s2 :(NSArray*)tri
{
    
    NSLog(@"Perform PAW on CPU");
    
    // determine transformation matrix for every triangle pair
    // as well as all pixels in the destination triangle
    NSMutableArray *transformations = [[NSMutableArray alloc] init];
    NSMutableArray *trianglePixels = [[NSMutableArray alloc] init];
    
    float points1[9];
    float points2[9];
    for (int i = 0; i < [tri count]; ++i) {
        PDMTriangle *triangle = [tri objectAtIndex:i];
        for (int j = 0; j < 3; ++j) {
            points1[j*3+0] = s1.shape[triangle.index[j]].pos[0];
            points1[j*3+1] = s1.shape[triangle.index[j]].pos[1];
            points1[j*3+2] = 1;
            
            points2[j*3+0] = s2.shape[triangle.index[j]].pos[0];
            points2[j*3+1] = s2.shape[triangle.index[j]].pos[1];
            points2[j*3+2] = 1;
        }
        PDMTMat *Tmat = [self getTransformationMatNB:&points2[0] :&points1[0]];
        [transformations addObject:Tmat];
        
        NSMutableArray *pixels = [self findPixelIndices:&points2[0] :image.size];
        [trianglePixels addObject:pixels];
    }


    // image definitions
    
    float width = image.size.width;
    float height = image.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel*width;
    NSUInteger bitsPerComponent = 8;
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
    
    // source image
    unsigned char *rawData1 = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    CGImageRef imageRef1 = [image CGImage];
    CGContextRef context = CGBitmapContextCreate(rawData1, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    

    
//    if (image.imageOrientation == UIImageOrientationUp || image.imageOrientation == UIImageOrientationDown) {
//        NSLog(@"IMAGE ORIENTATION IS UP");
//        context = CGBitmapContextCreate(rawData1, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo);
//    } else {
//        NSLog(@"IMAGE ORIENTATION IS SIDEWAYS");
//        width = image.size.height;
//        height = image.size.width;
//        context = CGBitmapContextCreate(rawData1, height, width, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo);
//    }       
//    
//    if (image.imageOrientation == UIImageOrientationLeft) {
//        CGContextRotateCTM(context, M_PI_2);
//        CGContextTranslateCTM(context, 0, -height);
//        
//    } else if (image.imageOrientation == UIImageOrientationRight) {
//        CGContextRotateCTM(context, -M_PI_2);
//        CGContextTranslateCTM(context, -width, 0);
//        
//    } else if (image.imageOrientation == UIImageOrientationUp) {
//        // NOTHING
//    } else if (image.imageOrientation == UIImageOrientationDown) {
//        CGContextTranslateCTM(context, width, height);
//        CGContextRotateCTM(context, -M_PI);
//    }

    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef1);
    //CGImageRef imageRef2 = CGBitmapContextCreateImage(context);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);

    
    // destination image
    unsigned char *rawData2 = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));


    for(int i = 0; i < [trianglePixels count]; ++i)
    {
        PDMTMat *T = [transformations objectAtIndex:i];
        
        NSMutableArray *triangle = [trianglePixels objectAtIndex:i];
        for(int j = 0; j < [triangle count]; ++j)
        {
            int index = [[triangle objectAtIndex:j] intValue];
            float xto = (index%(int)width);
            float yto = floor(index/width);
            
            int xfrom = (int)(xto * T.T[0] + yto * T.T[3] + T.T[6]); 
            int yfrom = (int)(xto * T.T[1] + yto * T.T[4] + T.T[7]);
            
            if(xfrom < 0 || xfrom >= width)
                continue;
            if(yfrom < 0 || yfrom >= height)
                continue;
            
            
            int byteIndex1 = yfrom * width * 4 + xfrom * 4;
            int byteIndex2 = yto * width * 4 + xto * 4;
            rawData2[byteIndex2 + 0] = rawData1[byteIndex1 + 0];
            rawData2[byteIndex2 + 1] = rawData1[byteIndex1 + 1];
            rawData2[byteIndex2 + 2] = rawData1[byteIndex1 + 2];
            rawData2[byteIndex2 + 3] = rawData1[byteIndex1 + 3];
        }
    }
    
    // create UIImage with data 
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, rawData2, width * height * 4, NULL);
    CGImageRef imageRef3;
    if (image.imageOrientation == UIImageOrientationUp || image.imageOrientation == UIImageOrientationDown) {
        NSLog(@"IMAGE ORIENTATION IS UP");
        
        imageRef3 = CGImageCreate(width, height, bitsPerComponent, bytesPerPixel*8, bytesPerRow, colorSpace, bitmapInfo, provider, NULL, false, kCGRenderingIntentDefault);
    } else {
        NSLog(@"IMAGE ORIENTATION IS SIDEWAYS");
        imageRef3 = CGImageCreate(height, width, bitsPerComponent, bytesPerPixel*8, bytesPerRow, colorSpace, bitmapInfo, provider, NULL, false, kCGRenderingIntentDefault);
    }   
    
    //free(rawData1);
    //free(rawData2);
    
    UIImage *warpedImg = [UIImage imageWithCGImage:imageRef3];
    return warpedImg;
}


/**
 Find the pixel indices for each triangle
 @returns Array of array of points [x1, y1, x2, y2, ...., xn, yn]
 */
- (NSMutableArray*)findPixelIndices:(float*)A :(CGSize)size
{
    NSMutableArray *pixels = [[NSMutableArray alloc] init];
    
    double x_min = INFINITY;
    double x_max = -INFINITY;
    double y_min = INFINITY;
    double y_max = -INFINITY;
    
    for(int i = 0; i < 3; ++i) {
        if(x_min > A[i*3+0]) { x_min = A[i*3+0]; }
        if(x_max < A[i*3+0]) { x_max = A[i*3+0]; }
        if(y_min > A[i*3+1]) { y_min = A[i*3+1]; }
        if(y_max < A[i*3+1]) { y_max = A[i*3+1]; }
    }
    double x_min_b = MAX(x_min, 0);
    double x_max_b = MIN(x_max, size.width-1);
    double y_min_b = MAX(y_min, 0);
    double y_max_b = MIN(y_max, size.height-1);
    
//    NSLog(@"x_min = %f, x_max = %f, y_min = %f, y_max = %f", x_min, x_max, y_min, y_max);
//    NSLog(@"x_min_b = %f, x_max_b = %f, y_min_b = %f, y_max_b = %f", x_min_b, x_max_b, y_min_b, y_max_b);
    
    int difference = (int)y_max_b - (int)y_min_b + 1;
    int *border = malloc(2*difference*sizeof(int));
    if(border == NULL) {
        NSLog(@"Error could not allocate memory...");
        exit(EXIT_FAILURE);
    }
    
    for(int i = 0; i < difference; ++i) {
        border[i*2] = INFINITY;
        border[i*2+1] = -INFINITY;
    }
    int offset = y_min_b;
    NSArray *p1 = [self findLinePoints:A[0] :A[1] :A[3] :A[4]];
    NSArray *p2 = [self findLinePoints:A[0] :A[1] :A[6] :A[7]];
    NSArray *p3 = [self findLinePoints:A[3] :A[4] :A[6] :A[7]];
    
    [self findContourPoints:p1 :border :difference :offset];
    [self findContourPoints:p2 :border :difference :offset];
    [self findContourPoints:p3 :border :difference :offset];
    
    for(int i = 0; i < difference; ++i)
    {
        int begin = border[i*2];
        begin = MAX(begin, x_min_b);
        int end = border[i*2+1];
        end = MIN(end, x_max_b);
        
        int index = (offset + i) * size.width + begin;
        for(int i = begin; i <= end; ++i) {
            [pixels addObject:[NSNumber numberWithInt:index]];
            index++;
        }
    }
    
    
    free(border);
    
    return pixels;
}


/**
 Determine the pixels which form a line between two points using Bresenham's line algorithm.
 @returns Array of points [x1, y1, x2, y2, ...., xn, yn]
 */
- (NSArray*)findLinePoints:(float)x0 :(float)y0 :(float)x1 :(float)y1
{
    NSMutableArray *points = [[NSMutableArray alloc] init];
    BOOL steep = (abs(y1 - y0) > abs(x1 - x0));
    
    float tmp;
    if (steep) {
        //swap(x0, y0)
        tmp = x0;
        x0 = y0;
        y0 = tmp;
        
        //swap(x1, y1)
        tmp = x1;
        x1 = y1;
        y1 = tmp;
    }
    if (x0 > x1) {
        //swap(x0, x1)
        tmp = x0;
        x0 = x1;
        x1 = tmp;
        
        //swap(y0, y1)
        tmp = y0;
        y0 = y1;
        y1 = tmp;
    }
    
    float deltax = x1 - x0;
    float deltay = abs(y1 - y0);
    float error = 0;
    float deltaerr = deltay / deltax;
    float ystep;
    float y = y0;
    
    
    if(y0 < y1) {
        ystep = 1;
    } else {
        ystep = -1;
    }
    
    //NSLog(@"deltax = %f, deltay = %f, error = %f, deltaerr = %f, ystep = %f", deltax, deltay, error, deltaerr, ystep);
    
    int xx, yy;
    for (float x = x0; x <= x1; x++) {
        if(steep) {
            xx = (int)y;
            yy = (int)x;
            
        } else {
            xx = (int)x;
            yy = (int)y;
        }
        
        [points addObject:[NSNumber numberWithInt:xx]];
        [points addObject:[NSNumber numberWithInt:yy]];
        
        error = error + deltaerr;
        if(error >= 0.5) {
            y += ystep;
            error -= 1.0;
        }
    }
    
    return points;
}


/**
 Check if a given point is inside a triangle which is defined by three points
 @param points Array with points as integers in the following format: [x1,y1,x2,y2,...,xn,yn]
 @param border C-Array of size height x 2 to store the border in. Border will be stored in pairs of x-axis indices {{begin end}, {},..{}} starting at the y-axis offset
 @param height The height of the contour (= size of the c-array)
 @param offset Offset where the contour starts in the y-axis
 */
- (void)findContourPoints:(NSArray*)points :(int*)border :(int)height :(int)offset
{
    int xx = 0;
    int yy = 0;
    for(int i = 0; i < [points count]; i += 2)
    {
        xx = [[points objectAtIndex:i] intValue];
        yy = [[points objectAtIndex:i+1] intValue];
        yy -= offset;
        //NSLog(@"%i : xx = %i, yy = %i", i, xx, yy);
        if(yy >= 0 && yy < height)
        {
            if(border[yy*2] > xx) {
                border[yy*2] = xx;
            }
            if(border[yy*2+1] < xx) {
                border[yy*2+1] = xx;
            }
        }
    }
}


/**
 Deprecated version to find pixel indices
 */
//- (NSMutableArray*)findPixelIndices:(float*)A :(CGSize)size
//{
//    NSMutableArray *pixels = [[NSMutableArray alloc] init];
//    
//    double x_min = INFINITY;
//    double x_max = -INFINITY;
//    double y_min = INFINITY;
//    double y_max = -INFINITY;
//    
//    for(int i = 0; i < 3; ++i) {
//        if(x_min > A[i*3+0]) { x_min = A[i*3+0]; }
//        if(x_max < A[i*3+0]) { x_max = A[i*3+0]; }
//        if(y_min > A[i*3+1]) { y_min = A[i*3+1]; }
//        if(y_max < A[i*3+1]) { y_max = A[i*3+1]; }
//    }
//    double x_min_b = MAX(x_min, 0);
//    double x_max_b = MIN(x_max, size.width-1);
//    double y_min_b = MAX(y_min, 0);
//    double y_max_b = MIN(y_max, size.height-1);
//    
//    NSLog(@"x_min = %f, x_max = %f, y_min = %f, y_max = %f", x_min, x_max, y_min, y_max);
//    NSLog(@"x_min_b = %f, x_max_b = %f, y_min_b = %f, y_max_b = %f", x_min_b, x_max_b, y_min_b, y_max_b);
//    
//    double div01 = (A[3+0]-A[0+0]) + 0.000001;
//    double div02 = (A[6+0]-A[0+0]) + 0.000001;
//    double div12 = (A[6+0]-A[3+0]) + 0.000001;
//    
//    double m01 = (A[3+1]-A[0+1])/div01;
//    double m02 = (A[6+1]-A[0+1])/div02;
//    double m12 = (A[6+1]-A[3+1])/div12;
//    
//    double b01 = (A[3+0]*A[0+1] - A[0+0]*A[3+1])/div01;
//    double b02 = (A[6+0]*A[0+1] - A[0+0]*A[6+1])/div02;
//    double b12 = (A[6+0]*A[3+1] - A[3+0]*A[6+1])/div12;
//    
//    double xc = (A[0] + A[3] + A[6])/3;
//    double yc = (A[1] + A[4] + A[7])/3;
//    
//    double sc1 = 0.5/sqrt((A[0] - xc)*(A[0] - xc) + (A[1] - yc)*(A[1] - yc));
//    double xc1 = A[0] + (A[0] - xc)*sc1;
//    double yc1 = A[1] + (A[1] - yc)*sc1;
//    
//    double sc2 = 0.5/sqrt((A[3] - xc)*(A[3] - xc) + (A[4] - yc)*(A[4] - yc));
//    double xc2 = A[3] + (A[3] - xc)*sc2;
//    double yc2 = A[4] + (A[4] - yc)*sc2;
//    
//    double sc3 = 0.5/sqrt((A[6] - xc)*(A[6] - xc) + (A[7] - yc)*(A[7] - yc));
//    double xc3 = A[6] + (A[6] - xc)*sc3;
//    double yc3 = A[7] + (A[7] - yc)*sc3;
//    
//    NSLog(@"\nshifted triangle: [%f, %f], [%f, %f], [%f, %f]", xc1, yc1, xc2, yc2, xc3, yc3);
//    
//    
//    int scanline_pos = (int)y_min_b;
//    int difference = ((int)y_max_b - (int)y_min_b);
//    NSLog(@"scanline_pos = %i, difference = %i", scanline_pos, difference);
//    for(int y_pos = scanline_pos; y_pos <= (scanline_pos + difference); ++y_pos)
//    {
//        double x1 = ((double)y_pos - b01)/m01;
//        double x2 = ((double)y_pos - b02)/m02;
//        double x3 = ((double)y_pos - b12)/m12;
//        double a1 = 0;
//        double a2 = 0;
//        
//        BOOL x1b = [self isPointInsideTriangle:x1 :y_pos :xc1 :yc1 :xc2 :yc2 :xc3 :yc3];
//        BOOL x2b = [self isPointInsideTriangle:x2 :y_pos :xc1 :yc1 :xc2 :yc2 :xc3 :yc3];
//        BOOL x3b = [self isPointInsideTriangle:x3 :y_pos :xc1 :yc1 :xc2 :yc2 :xc3 :yc3];
//
//        if(x1b && x2b) {
//            a1 = x1;
//            a2 = x2;
//        }
//        else if(x1b && x3b) {
//            a1 = x1;
//            a2 = x3;
//        }
//        else{
//            a1 = x2;
//            a2 = x3;
//        }
//        
//        int begin = round(MIN(a1,a2));
//        int end = round(MAX(a1,a2));
//        
//        if(begin > size.width || end < 0)
//            continue;
//        
//        // clamp to image borders
//        begin = MAX(begin, x_min_b);
//        end = MIN(end, x_max_b);
//        
//        NSLog(@"\ny = %i, x1 = %f, x2 = %f, x3 = %f\nbegin = %i, end = %i", y_pos, x1, x2, x3, begin, end);
//        
//        int index = y_pos * size.width + begin;
//        for(int i = begin; i <= end; ++i) {
//            [pixels addObject:[NSNumber numberWithInt:index]];
//            index++;
//        }
//    }
//    
//    return pixels;
//}



/**
 Check if a given point is inside a triangle which is defined by three points
 @returns YES if the point is inside
 */
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
}


/**
 Determine the transformation matrix given a pair of triangles
 @returns Transformation matrix
 */
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
