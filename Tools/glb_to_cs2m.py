#!/usr/bin/env python3
import json,struct,sys
src,dst=sys.argv[1:3]; b=open(src,'rb').read()
jl=struct.unpack_from('<I',b,12)[0]; j=json.loads(b[20:20+jl]); bo=((20+jl+3)&~3)+8
verts=[]; inds=[]; draws=[]
def raw(ai):
 a=j['accessors'][ai]; v=j['bufferViews'][a['bufferView']]; c=a['componentType']; n=a['count']
 sz={5121:1,5123:2,5125:4,5126:4}[c]; comps={'SCALAR':1,'VEC2':2,'VEC3':3,'VEC4':4}[a['type']]
 stride=v.get('byteStride',sz*comps); base=bo+v.get('byteOffset',0)+a.get('byteOffset',0)
 return a,[b[base+i*stride:base+i*stride+sz*comps] for i in range(n)]
for m in j['meshes']:
 for p in m['primitives']:
  pa=p.get('attributes',{}).get('POSITION')
  if pa is None: continue
  a,vr=raw(pa); base=len(verts); verts.extend(vr)
  if 'indices' in p:
   ia,ir=raw(p['indices']); fmt={5121:'<B',5123:'<H',5125:'<I'}[ia['componentType']]
   ii=[base+struct.unpack(fmt,x)[0] for x in ir]
  else: ii=list(range(base,base+len(vr)))
  start=len(inds); inds.extend(ii); draws.append((start,len(ii)))
with open(dst,'wb') as f:
 f.write(b'CS2M'); f.write(struct.pack('<IIII',2,len(verts),len(inds),len(draws)))
 for v in verts:f.write(v)
 for i in inds:f.write(struct.pack('<I',i))
 for x in draws:f.write(struct.pack('<II',*x))
print('vertices',len(verts),'indices',len(inds),'triangles',len(inds)//3,'draws',len(draws))
