#import "GameViewController.h"
#import <MetalKit/MetalKit.h>
#import <GameController/GameController.h>
#import <ModelIO/ModelIO.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#import <MetalKit/MetalKit.h>

@interface GameViewController () <MTKViewDelegate, UIDocumentPickerDelegate>
@property id<MTLDevice> device; @property id<MTLCommandQueue> queue; @property MTKMesh *mapMesh;
@property NSDate *loadStart; @property UILabel *status; @property NSURL *persistentMapURL;
@end
@implementation GameViewController
- (void)loadView { self.device=MTLCreateSystemDefaultDevice(); MTKView*v=[[MTKView alloc]initWithFrame:CGRectZero device:self.device];v.delegate=self;v.preferredFramesPerSecond=60;v.clearColor=MTLClearColorMake(.35,.55,.8,1);self.view=v; }
- (void)viewDidLoad { [super viewDidLoad]; self.queue=[self.device newCommandQueue]; self.status=[[UILabel alloc]initWithFrame:CGRectMake(18,18,700,40)];self.status.textColor=UIColor.whiteColor;self.status.text=@"CS2 iOS — Import cs_office n0.glb";[self.view addSubview:self.status]; UIButton*b=[UIButton buttonWithType:UIButtonTypeSystem];b.frame=CGRectMake(18,65,210,44);[b setTitle:@"Import CS2 Map" forState:UIControlStateNormal];[b addTarget:self action:@selector(importMap) forControlEvents:UIControlEventTouchUpInside];[self.view addSubview:b]; [self loadBundledOrPersistedMap]; [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(controller:) name:GCControllerDidConnectNotification object:nil];[GCController startWirelessControllerDiscoveryWithCompletionHandler:^{}]; }
- (NSURL*)storedMapURL { NSURL*d=[[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] firstObject]; [[NSFileManager defaultManager] createDirectoryAtURL:d withIntermediateDirectories:YES attributes:nil error:nil]; return [d URLByAppendingPathComponent:@"cs_office.glb"]; }
- (void)loadBundledOrPersistedMap { NSURL*b=[[NSBundle mainBundle] URLForResource:@"n0" withExtension:@"glb" subdirectory:@"Assets/Maps/cs_office"]; if(b){self.status.text=@"Loading integrated cs_office…";[self loadMapURL:b];return;} NSURL*u=[self storedMapURL]; if([[NSFileManager defaultManager] fileExistsAtPath:u.path]){self.status.text=@"Loading saved cs_office…";[self loadMapURL:u];return;} self.status.text=@"No integrated map found"; }
- (void)loadMapURL:(NSURL*)x { self.loadStart=[NSDate date]; MDLAsset*asset=[[MDLAsset alloc]initWithURL:x vertexDescriptor:nil bufferAllocator:[[MTKMeshBufferAllocator alloc]initWithDevice:self.device]]; NSArray*meshes=nil; NSError*err=nil; NSArray*mtk=[MTKMesh newMeshesFromAsset:asset device:self.device sourceMeshes:&meshes error:&err]; NSTimeInterval t=-self.loadStart.timeIntervalSinceNow; if(err||mtk.count==0){self.status.text=[NSString stringWithFormat:@"Map load failed: %@",err.localizedDescription?:@"no meshes"]; NSLog(@"[CS2iOS][Step4] map load FAILED %@",err);return;} self.mapMesh=mtk.firstObject; self.status.text=[NSString stringWithFormat:@"Saved cs_office loaded %.2fs • meshes %lu",t,(unsigned long)mtk.count]; NSLog(@"[CS2iOS][Step4] saved map loaded meshes=%lu load=%.3fs",(unsigned long)mtk.count,t); }
- (void)importMap { UIDocumentPickerViewController*p=[[UIDocumentPickerViewController alloc]initForOpeningContentTypes:@[[UTType typeWithFilenameExtension:@"glb"]]];p.delegate=self;[self presentViewController:p animated:YES completion:nil]; }
- (void)documentPicker:(UIDocumentPickerViewController*)c didPickDocumentsAtURLs:(NSArray<NSURL*>*)u { NSURL*x=u.firstObject;if(!x)return;BOOL a=[x startAccessingSecurityScopedResource]; NSURL*dst=[self storedMapURL]; [[NSFileManager defaultManager] removeItemAtURL:dst error:nil]; NSError*err=nil; BOOL ok=[[NSFileManager defaultManager] copyItemAtURL:x toURL:dst error:&err]; if(a)[x stopAccessingSecurityScopedResource]; if(!ok){self.status.text=[NSString stringWithFormat:@"Import failed: %@",err.localizedDescription];NSLog(@"[CS2iOS][Step4] persist FAILED %@",err);return;} NSLog(@"[CS2iOS][Step4] persisted map %@",dst.path); [self loadMapURL:dst]; }
- (void)controller:(NSNotification*)n { NSLog(@"[CS2iOS] controller=%lu",(unsigned long)GCController.controllers.count); }
- (void)mtkView:(MTKView*)v drawableSizeWillChange:(CGSize)s{}
- (void)drawInMTKView:(MTKView*)v { MTLRenderPassDescriptor*p=v.currentRenderPassDescriptor;id<CAMetalDrawable>d=v.currentDrawable;if(!p||!d)return;id<MTLCommandBuffer>cb=[self.queue commandBuffer];id<MTLRenderCommandEncoder>e=[cb renderCommandEncoderWithDescriptor:p];[e endEncoding];[cb presentDrawable:d];[cb commit]; }
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{return UIInterfaceOrientationMaskLandscape;}
@end
