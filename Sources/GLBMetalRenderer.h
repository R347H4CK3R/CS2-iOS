#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>
#import <simd/simd.h>
@interface GLBMetalRenderer:NSObject
@property(nonatomic,readonly) NSUInteger primitiveCount;
@property(nonatomic) vector_float3 cameraPosition;
@property(nonatomic) float cameraYaw, cameraPitch;
-(instancetype)initWithDevice:(id<MTLDevice>)device colorFormat:(MTLPixelFormat)color depthFormat:(MTLPixelFormat)depth;
-(BOOL)loadURL:(NSURL*)url error:(NSError**)error;
-(void)draw:(id<MTLRenderCommandEncoder>)encoder drawableSize:(CGSize)size;
-(vector_float3)constrainPlayerPosition:(vector_float3)candidate;
@end
