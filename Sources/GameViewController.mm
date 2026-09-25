#import "GameViewController.h"
#import "GLBMetalRenderer.h"
#import <MetalKit/MetalKit.h>
#import <GameController/GameController.h>
#import <ModelIO/ModelIO.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#import <MetalKit/MetalKit.h>

@interface GameViewController () <MTKViewDelegate, UIDocumentPickerDelegate>
@property id<MTLDevice> device; @property id<MTLCommandQueue> queue; @property GLBMetalRenderer *renderer;
@property NSDate *loadStart; @property UILabel *status; @property NSURL *persistentMapURL;
@end
@implementation GameViewController
- (void)loadView { self.device=MTLCreateSystemDefaultDevice(); MTKView*v=[[MTKView alloc]initWithFrame:CGRectZero device:self.device];v.delegate=self;v.preferredFramesPerSecond=60;v.depthStencilPixelFormat=MTLPixelFormatDepth32Float;v.clearColor=MTLClearColorMake(.16,.27,.42,1);self.view=v; }
- (void)viewDidLoad { [super viewDidLoad]; self.queue=[self.device newCommandQueue]; MTKView*mv=(MTKView*)self.view; self.renderer=[[GLBMetalRenderer alloc]initWithDevice:self.device colorFormat:mv.colorPixelFormat depthFormat:mv.depthStencilPixelFormat]; self.status=[[UILabel alloc]initWithFrame:CGRectMake(18,18,700,40)];self.status.textColor=UIColor.whiteColor;self.status.text=@"CS2 iOS — cs_office";[self.view addSubview:self.status]; [self loadBundledOrPersistedMap]; [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(controller:) name:GCControllerDidConnectNotification object:nil];[GCController startWirelessControllerDiscoveryWithCompletionHandler:^{}]; }
- (NSURL*)storedMapURL { NSURL*d=[[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] firstObject]; [[NSFileManager defaultManager] createDirectoryAtURL:d withIntermediateDirectories:YES attributes:nil error:nil]; return [d URLByAppendingPathComponent:@"cs_office.glb"]; }
- (void)loadBundledOrPersistedMap { NSURL*b=[[NSBundle mainBundle] URLForResource:@"n0" withExtension:@"glb" subdirectory:@"Assets/Maps/cs_office"]; if(b){self.status.text=@"Loading integrated cs_office…";[self loadMapURL:b];return;} NSURL*u=[self storedMapURL]; if([[NSFileManager defaultManager] fileExistsAtPath:u.path]){self.status.text=@"Loading saved cs_office…";[self loadMapURL:u];return;} self.status.text=@"No integrated map found"; }
- (void)loadMapURL:(NSURL*)x { self.loadStart=[NSDate date]; NSError*err=nil; BOOL ok=[self.renderer loadURL:x error:&err]; NSTimeInterval t=-self.loadStart.timeIntervalSinceNow; if(!ok){self.status.text=[NSString stringWithFormat:@"Map load failed: %@",err.localizedDescription?:@"no GLB primitives"];NSLog(@"[CS2iOS][Step4] direct GLB FAILED %@",err);return;} self.status.text=[NSString stringWithFormat:@"cs_office loaded %.2fs • primitives %lu",t,(unsigned long)self.renderer.primitiveCount];NSLog(@"[CS2iOS][Step4] direct GLB loaded primitives=%lu load=%.3fs",(unsigned long)self.renderer.primitiveCount,t); }
- (void)importMap { UIDocumentPickerViewController*p=[[UIDocumentPickerViewController alloc]initForOpeningContentTypes:@[[UTType typeWithFilenameExtension:@"glb"]]];p.delegate=self;[self presentViewController:p animated:YES completion:nil]; }
- (void)documentPicker:(UIDocumentPickerViewController*)c didPickDocumentsAtURLs:(NSArray<NSURL*>*)u { NSURL*x=u.firstObject;if(!x)return;BOOL a=[x startAccessingSecurityScopedResource]; NSURL*dst=[self storedMapURL]; [[NSFileManager defaultManager] removeItemAtURL:dst error:nil]; NSError*err=nil; BOOL ok=[[NSFileManager defaultManager] copyItemAtURL:x toURL:dst error:&err]; if(a)[x stopAccessingSecurityScopedResource]; if(!ok){self.status.text=[NSString stringWithFormat:@"Import failed: %@",err.localizedDescription];NSLog(@"[CS2iOS][Step4] persist FAILED %@",err);return;} NSLog(@"[CS2iOS][Step4] persisted map %@",dst.path); [self loadMapURL:dst]; }
- (void)controller:(NSNotification*)n { NSLog(@"[CS2iOS] controller=%lu",(unsigned long)GCController.controllers.count); }
- (void)mtkView:(MTKView*)v drawableSizeWillChange:(CGSize)s{}
- (void)drawInMTKView:(MTKView*)v { MTLRenderPassDescriptor*p=v.currentRenderPassDescriptor;id<CAMetalDrawable>d=v.currentDrawable;if(!p||!d)return;id<MTLCommandBuffer>cb=[self.queue commandBuffer];id<MTLRenderCommandEncoder>e=[cb renderCommandEncoderWithDescriptor:p];[self.renderer draw:e drawableSize:v.drawableSize];[e endEncoding];[cb presentDrawable:d];[cb commit]; }
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{return UIInterfaceOrientationMaskLandscape;}
@end
