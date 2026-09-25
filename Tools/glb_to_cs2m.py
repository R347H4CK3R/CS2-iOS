#!/usr/bin/env python3
import json,struct,sys
src,dst=sys.argv[1:3]
b=open(src,'rb').read(); jl=struct.unpack_from('<I',b,12)[0]; j=json.loads(b[20:20+jl]); off=(20+jl+3)&~3; bs=off+8
out=bytearray(b'CS2M'+struct.pack('<II',1,0)); n=0
for m in j['meshes']:
 for p in m['primitives']:
  ai=p.get('attributes',{}).get('POSITION')
  if ai is None: continue
  a=j['accessors'][ai]; v=j['bufferViews'][a['bufferView']]
  if a['componentType']!=5126 or a['type']!='VEC3': continue
  stride=v.get('byteStride',12); base=bs+v.get('byteOffset',0)+a.get('byteOffset',0)
  for i in range(a['count']): out += b[base+i*stride:base+i*stride+12]; n+=1
struct.pack_into('<I',out,8,n); open(dst,'wb').write(out); print(n,len(out))
