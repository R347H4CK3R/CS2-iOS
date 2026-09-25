#import "GameViewController.h"
#import <MetalKit/MetalKit.h>
#import <AVFAudio/AVFAudio.h>
#import <GameController/GameController.h>

typedef struct { vector_float2 p; vector_float4 c; } Vertex;

@interface GameViewController () <MTKViewDelegate>
@property(nonatomic,strong) id<MTLDevice> device;
@property(nonatomic,strong) id<MTLCommandQueue> queue;
@property(nonatomic,strong) id<MTLRenderPipelineState> pipeline;
@property(nonatomic,strong) id<MTLBuffer> vertices;
@property(nonatomic,strong) AVAudioEngine *audio;
@end

@implementation GameViewController
- (void)loadView {
 self.device=MTLCreateSystemDefaultDevice(); NSAssert(self.device,@"Metal unavailable");
 MTKView *v=[[MTKView alloc]initWithFrame:CGRectZero device:self.device]; v.delegate=self; v.preferredFramesPerSecond=60;
 v.clearColor=MTLClearColorMake(.035,.045,.065,1); v.multipleTouchEnabled=YES; self.view=v;
}
- (void)viewDidLoad {
 [super viewDidLoad]; self.queue=[self.device newCommandQueue]; self.audio=[AVAudioEngine new]; [self.audio prepare];
 NSString *shader=@"#include <metal_stdlib>\nusing namespace metal; struct V{float2 p;float4 c;}; struct O{float4 p[[position]];float4 c;}; vertex O vs(uint i[[vertex_id]],constant V* v[[buffer(0)]]){O o;o.p=float4(v[i].p,0,1);o.c=v[i].c;return o;} fragment float4 fs(O i[[stage_in]]){return i.c;}";
 NSError *err=nil; id<MTLLibrary> lib=[self.device newLibraryWithSource:shader options:nil error:&err]; NSAssert(lib,@"shader %@",err);
 MTLRenderPipelineDescriptor *pd=[MTLRenderPipelineDescriptor new]; pd.vertexFunction=[lib newFunctionWithName:@"vs"]; pd.fragmentFunction=[lib newFunctionWithName:@"fs"]; pd.colorAttachments[0].pixelFormat=((MTKView*)self.view).colorPixelFormat;
 self.pipeline=[self.device newRenderPipelineStateWithDescriptor:pd error:&err]; NSAssert(self.pipeline,@"pipeline %@",err);
 const Vertex verts[]={{{-.9f,-.75f},{.25f,.30f,.34f,1}},{{.9f,-.75f},{.25f,.30f,.34f,1}},{{.75f,.6f},{.55f,.52f,.43f,1}},{{-.75f,.6f},{.55f,.52f,.43f,1}},{{-.9f,-.75f},{.25f,.30f,.34f,1}},{{.75f,.6f},{.55f,.52f,.43f,1}}};
 self.vertices=[self.device newBufferWithBytes:verts length:sizeof(verts) options:MTLResourceStorageModeShared];
 [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(controller:) name:GCControllerDidConnectNotification object:nil];
 [GCController startWirelessControllerDiscoveryWithCompletionHandler:^{}];
 NSLog(@"[CS2iOS][Step4] renderer ready map=cs_office proxy geometry vertices=6 Metal=%@",self.device.name);
}
- (void)controller:(NSNotification*)n { NSLog(@"[CS2iOS] controller count=%lu",(unsigned long)GCController.controllers.count); }
- (void)touchesBegan:(NSSet<UITouch*>*)t withEvent:(UIEvent*)e { NSLog(@"[CS2iOS] touch=%lu",(unsigned long)t.count); }
- (void)mtkView:(MTKView*)v drawableSizeWillChange:(CGSize)s { NSLog(@"[CS2iOS] drawable %.0fx%.0f",s.width,s.height); }
- (void)drawInMTKView:(MTKView*)v { MTLRenderPassDescriptor *p=v.currentRenderPassDescriptor; id<CAMetalDrawable>d=v.currentDrawable;if(!p||!d)return;id<MTLCommandBuffer>cb=[self.queue commandBuffer];id<MTLRenderCommandEncoder>e=[cb renderCommandEncoderWithDescriptor:p];[e setRenderPipelineState:self.pipeline];[e setVertexBuffer:self.vertices offset:0 atIndex:0];[e drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];[e endEncoding];[cb presentDrawable:d];[cb commit];}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{return UIInterfaceOrientationMaskLandscape;}
@end
