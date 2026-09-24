#import "GameViewController.h"
#import <MetalKit/MetalKit.h>
#import <AVFAudio/AVFAudio.h>
#import <GameController/GameController.h>

@interface GameViewController () <MTKViewDelegate>
@property(nonatomic,strong) id<MTLDevice> device;
@property(nonatomic,strong) id<MTLCommandQueue> queue;
@property(nonatomic,strong) AVAudioEngine *audio;
@end

@implementation GameViewController
- (void)loadView {
    self.device=MTLCreateSystemDefaultDevice();
    NSAssert(self.device, @"Metal device unavailable");
    MTKView *v=[[MTKView alloc] initWithFrame:CGRectZero device:self.device];
    v.delegate=self; v.preferredFramesPerSecond=60; v.enableSetNeedsDisplay=NO; v.paused=NO;
    v.clearColor=MTLClearColorMake(0.035,0.045,0.065,1.0);
    v.multipleTouchEnabled=YES;
    self.view=v;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.queue=[self.device newCommandQueue];
    self.audio=[AVAudioEngine new];
    [self.audio prepare];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controller:) name:GCControllerDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controller:) name:GCControllerDidDisconnectNotification object:nil];
    [GCController startWirelessControllerDiscoveryWithCompletionHandler:^{ NSLog(@"[CS2iOS] controller discovery ready"); }];
    NSLog(@"[CS2iOS] Metal=%@ audio=ready touch=ready controllers=%lu",self.device.name,(unsigned long)GCController.controllers.count);
}
- (void)controller:(NSNotification *)n { NSLog(@"[CS2iOS] controller event count=%lu",(unsigned long)GCController.controllers.count); }
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { NSLog(@"[CS2iOS] touch begin %lu",(unsigned long)touches.count); }
- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size { NSLog(@"[CS2iOS] drawable %.0fx%.0f",size.width,size.height); }
- (void)drawInMTKView:(MTKView *)view {
    MTLRenderPassDescriptor *p=view.currentRenderPassDescriptor; id<CAMetalDrawable> d=view.currentDrawable;
    if(!p||!d)return; id<MTLCommandBuffer> cb=[self.queue commandBuffer];
    id<MTLRenderCommandEncoder> e=[cb renderCommandEncoderWithDescriptor:p]; [e endEncoding]; [cb presentDrawable:d]; [cb commit];
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations { return UIInterfaceOrientationMaskLandscape; }
- (BOOL)prefersHomeIndicatorAutoHidden { return YES; }
@end
