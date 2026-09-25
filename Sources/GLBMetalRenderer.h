#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>
@interface GLBMetalRenderer:NSObject
@property(nonatomic,readonly) NSUInteger primitiveCount;
-(instancetype)initWithDevice:(id<MTLDevice>)device colorFormat:(MTLPixelFormat)color depthFormat:(MTLPixelFormat)depth;
-(BOOL)loadURL:(NSURL*)url error:(NSError**)error;
-(void)draw:(id<MTLRenderCommandEncoder>)encoder drawableSize:(CGSize)size;
@end
