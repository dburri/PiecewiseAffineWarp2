//
//  PiecewiseAffineWarp2Tests.m
//  PiecewiseAffineWarp2Tests
//
//  Created by DINA BURRI on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PiecewiseAffineWarp2Tests.h"

@implementation PiecewiseAffineWarp2Tests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testTriangleRasterize
{
    CGSize imgSize = CGSizeMake(50, 30);
    PiecewiseAffineWarpCPU *PAW = [[PiecewiseAffineWarpCPU alloc] init];
    float points[9] = {
        -3, -3, 0,
        35, 3, 0,
        3, 20, 0
    };
    
    NSMutableArray *indices = [PAW findPixelIndices:&points[0] :imgSize];
    
    int numValues = imgSize.width*imgSize.height;
    unsigned char *image = malloc(numValues*sizeof(unsigned char));
    memset(image, 0, numValues&sizeof(unsigned char));
    
    for(int i = 0; i < numValues; ++i) {
        image[i] = 0;
    }
    
    for(int i = 0; i < [indices count]; ++i) {
        int index = [[indices objectAtIndex:i] intValue];
        image[index] = 1;
    }
    
    NSMutableString *text = [[NSMutableString alloc] init];
    [text appendString:@"\n"];
    for(int i = 0; i < imgSize.height; ++i) {
        for(int j = 0; j < imgSize.width; ++j) {
            [text appendFormat:@"%i, ", image[(int)(i*imgSize.width+j)]];
        }
        [text appendString:@"\n"];
    }
    [text appendString:@"\n"];
    
    NSLog(@"%@", text);
    
    free(image);
    
    //STFail(@"Unit tests are not implemented yet in PiecewiseAffineWarp2Tests");
}

@end
