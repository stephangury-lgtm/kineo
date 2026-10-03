export type AtlasTarget={x:number;y:number;radius:number}
export type AtlasAsset={
  id:string
  area:'Hanche'|'Genou'|'Cheville'|'Pied'
  asset:string
  sourceTitle:string
  sourcePage:number
  targets:Record<string,AtlasTarget>
}

export const VISUAL_ATLAS:AtlasAsset[]=[
  {id:'hip-femur-proximal',area:'Hanche',asset:'/quiz-assets/ifmk/hip-femur-proximal.svg',sourceTitle:'CM1 Ostéologie et arthrologie de la hanche',sourcePage:34,targets:{'Tête fémorale':{x:66,y:30,radius:13},'Col fémoral':{x:50,y:47,radius:11},'Grand trochanter':{x:25,y:58,radius:12},'Petit trochanter':{x:56,y:72,radius:10}}},
  {id:'hip-femoral-head',area:'Hanche',asset:'/quiz-assets/ifmk/hip-femoral-head.svg',sourceTitle:'CM1 Ostéologie et arthrologie de la hanche',sourcePage:35,targets:{'Tête fémorale':{x:36,y:45,radius:18}}},
  {id:'hip-sartorius',area:'Hanche',asset:'/quiz-assets/ifmk/hip-sartorius.svg',sourceTitle:'CM2 Myologie de la hanche',sourcePage:14,targets:{'Sartorius':{x:28,y:53,radius:14}}},
  {id:'hip-gluteal',area:'Hanche',asset:'/quiz-assets/ifmk/hip-gluteal.svg',sourceTitle:'CM2 Myologie de la hanche',sourcePage:37,targets:{'Petit glutéal':{x:52,y:54,radius:14}}},
  {id:'hip-piriformis',area:'Hanche',asset:'/quiz-assets/ifmk/hip-piriformis.svg',sourceTitle:'CM2 Myologie de la hanche',sourcePage:57,targets:{'Piriforme':{x:58,y:50,radius:13}}},
  {id:'knee-patella',area:'Genou',asset:'/quiz-assets/ifmk/knee-patella.svg',sourceTitle:'CM3 Ostéologie et arthrologie du genou',sourcePage:18,targets:{'Patella':{x:50,y:43,radius:15}}},
  {id:'knee-menisci',area:'Genou',asset:'/quiz-assets/ifmk/knee-menisci.svg',sourceTitle:'CM3 Ostéologie et arthrologie du genou',sourcePage:42,targets:{'Ménisque médial':{x:33,y:49,radius:14},'Ménisque latéral':{x:67,y:49,radius:14}}},
  {id:'knee-lca',area:'Genou',asset:'/quiz-assets/ifmk/knee-lca.svg',sourceTitle:'CM3 Ostéologie et arthrologie du genou',sourcePage:53,targets:{'LCA':{x:44,y:61,radius:10}}},
  {id:'knee-lcp',area:'Genou',asset:'/quiz-assets/ifmk/knee-lcp.svg',sourceTitle:'CM3 Ostéologie et arthrologie du genou',sourcePage:54,targets:{'LCP':{x:53,y:45,radius:10}}},
  {id:'knee-vastus-medial',area:'Genou',asset:'/quiz-assets/ifmk/knee-vastus-medial.svg',sourceTitle:'CM4 Myologie du genou',sourcePage:13,targets:{'Vaste médial':{x:58,y:58,radius:17}}},
  {id:'knee-vastus-lateral',area:'Genou',asset:'/quiz-assets/ifmk/knee-vastus-lateral.svg',sourceTitle:'CM4 Myologie du genou',sourcePage:14,targets:{'Vaste latéral':{x:42,y:54,radius:17}}},
  {id:'ankle-tibia-distal',area:'Cheville',asset:'/quiz-assets/ifmk/ankle-tibia-distal.svg',sourceTitle:'CM6 Ostéologie et arthrologie de la cheville',sourcePage:12,targets:{'Pilon tibial':{x:51,y:50,radius:13},'TP':{x:46,y:68,radius:9},'LFH':{x:65,y:78,radius:9}}},
  {id:'ankle-fibula-distal',area:'Cheville',asset:'/quiz-assets/ifmk/ankle-fibula-distal.svg',sourceTitle:'CM6 Ostéologie et arthrologie de la cheville',sourcePage:20,targets:{'Fibula':{x:48,y:35,radius:12},'Malléole latérale':{x:49,y:72,radius:12}}},
  {id:'ankle-talus',area:'Cheville',asset:'/quiz-assets/ifmk/ankle-talus.svg',sourceTitle:'CM6 Ostéologie et arthrologie de la cheville',sourcePage:27,targets:{'Talus':{x:53,y:57,radius:17}}},
  {id:'ankle-lcf',area:'Cheville',asset:'/quiz-assets/ifmk/ankle-lcf.svg',sourceTitle:'CM6 Ostéologie et arthrologie de la cheville',sourcePage:49,targets:{'LCF':{x:46,y:58,radius:12}}},
  {id:'ankle-lct',area:'Cheville',asset:'/quiz-assets/ifmk/ankle-lct.svg',sourceTitle:'CM6 Ostéologie et arthrologie de la cheville',sourcePage:51,targets:{'LCT':{x:47,y:58,radius:12}}},
  {id:'foot-navicular',area:'Pied',asset:'/quiz-assets/ifmk/foot-navicular.svg',sourceTitle:'CM8 Ostéologie et arthrologie du pied',sourcePage:6,targets:{'Naviculaire':{x:38,y:51,radius:12}}},
  {id:'foot-cuboid',area:'Pied',asset:'/quiz-assets/ifmk/foot-cuboid.svg',sourceTitle:'CM8 Ostéologie et arthrologie du pied',sourcePage:8,targets:{'Cuboïde':{x:57,y:85,radius:11}}},
  {id:'foot-tarsus-labeling',area:'Pied',asset:'/quiz-assets/ifmk/foot-tarsus-labeling.svg',sourceTitle:'CM8 Ostéologie et arthrologie du pied',sourcePage:8,targets:{'Naviculaire':{x:21,y:51,radius:12},'Cuboïde':{x:79,y:85,radius:11}}},
  {id:'foot-cuneiforms',area:'Pied',asset:'/quiz-assets/ifmk/foot-cuneiforms.svg',sourceTitle:'CM8 Ostéologie et arthrologie du pied',sourcePage:12,targets:{'C1':{x:26,y:68,radius:10},'C2':{x:38,y:69,radius:10},'C3':{x:49,y:70,radius:10}}},
  {id:'foot-hallux',area:'Pied',asset:'/quiz-assets/ifmk/foot-hallux.svg',sourceTitle:'CM8 Ostéologie et arthrologie du pied',sourcePage:17,targets:{'Hallux':{x:25,y:27,radius:14}}},
  {id:'foot-m5',area:'Pied',asset:'/quiz-assets/ifmk/foot-m5.svg',sourceTitle:'CM8 Ostéologie et arthrologie du pied',sourcePage:22,targets:{'Base de M5':{x:71,y:54,radius:12}}},
]

export function getAtlasAsset(id:string){return VISUAL_ATLAS.find(asset=>asset.id===id)}

export function findAtlasAsset(sourceTitle:string,sourcePage:number,label?:string){
  return VISUAL_ATLAS.find(asset=>asset.sourceTitle===sourceTitle&&asset.sourcePage===sourcePage&&(!label||asset.targets[label]))
}
