#import "GameViewController.h"
#import <MetalKit/MetalKit.h>
#import <GameController/GameController.h>
#import <ModelIO/ModelIO.h>
#import <MetalKit/MetalKit.h>

@interface GameViewController () <MTKViewDelegate, UIDocumentPickerDelegate>
@property id<MTLDevice> device; @property id<MTLCommandQueue> queue; @property MTKMesh *mapMesh;
@property NSDate *loadStart; @property UILabel *status;
@end
@implementation GameViewController
- (void)loadView { self.device=MTLCreateSystemDefaultDevice(); MTKView*v=[[MTKView alloc]initWithFrame:CGRectZero device:self.device];v.delegate=self;v.preferredFramesPerSecond=60;v.clearColor=MTLClearColorMake(.35,.55,.8,1);self.view=v; }
- (void)viewDidLoad { [super viewDidLoad]; self.queue=[self.device newCommandQueue]; self.status=[[UILabel alloc]initWithFrame:CGRectMake(18,18,700,40)];self.status.textColor=UIColor.whiteColor;self.status.text=@"CS2 iOS — Import cs_office n0.glb";[self.view addSubview:self.status]; UIButton*b=[UIButton buttonWithType:UIButtonTypeSystem];b.frame=CGRectMake(18,65,210,44);[b setTitle:@"Import CS2 Map" forState:UIControlStateNormal];[b addTarget:self action:@selector(importMap) forControlEvents:UIControlEventTouchUpInside];[self.view addSubview:b]; [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(controller:) name:GCControllerDidConnectNotification object:nil];[GCController startWirelessControllerDiscoveryWithCompletionHandler:^{}]; }
- (void)importMap { UIDocumentPickerViewController*p=[[UIDocumentPickerViewController alloc]initForOpeningContentTypes:@[[UTType typeWithFilenameExtension:@"glb"]]];p.delegate=self;[self presentViewController:p animated:YES completion:nil]; }
- (void)documentPicker:(UIDocumentPickerViewController*)c didPickDocumentsAtURLs:(NSArray<NSURL*>*)u { NSURL*x=u.firstObject;if(!x)return;BOOL a=[x startAccessingSecurityScopedResource];self.loadStart=[NSDate date];MDLAsset*asset=[[MDLAsset alloc]initWithURL:x vertexDescriptor:nil bufferAllocator:[[MTKMeshBufferAllocator alloc]initWithDevice:self.device]];NSArray*meshes=nil;NSArray*mtk=[MTKMesh newMeshesFromAsset:asset device:self.device sourceMeshes:&meshes error:nil];self.mapMesh=mtk.firstObject;NSTimeInterval t=-self.loadStart.timeIntervalSinceNow;self.status.text=[NSString stringWithFormat:@"cs_office loaded %.2fs • meshes %lu",t,(unsigned long)mtk.count];NSLog(@"[CS2iOS][Step4] imported %@ meshes=%lu load=%.3fs",x.lastPathComponent,(unsigned long)mtk.count,t);if(a)[x stopAccessingSecurityScopedResource]; }
- (void)controller:(NSNotification*)n { NSLog(@"[CS2iOS] controller=%lu",(unsigned long)GCController.controllers.count); }
- (void)mtkView:(MTKView*)v drawableSizeWillChange:(CGSize)s{}
- (void)drawInMTKView:(MTKView*)v { MTLRenderPassDescriptor*p=v.currentRenderPassDescriptor;id<CAMetalDrawable>d=v.currentDrawable;if(!p||!d)return;id<MTLCommandBuffer>cb=[self.queue commandBuffer];id<MTLRenderCommandEncoder>e=[cb renderCommandEncoderWithDescriptor:p];[e endEncoding];[cb presentDrawable:d];[cb commit]; }
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{return UIInterfaceOrientationMaskLandscape;}
@end
