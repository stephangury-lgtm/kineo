export type ProgramId='kineo-fr'|'kineo-es'|'ifsi-fr'
export type Program={id:ProgramId;name:string;shortName:string;country:string;flag:string;subtitle:string;accent:string;structure:string[];status:'live'|'foundation'}
export const PROGRAM_STORAGE_KEY='healthapp_program'
export const programs:Program[]=[
 {id:'kineo-fr',name:'Kineo France',shortName:'Kineo',country:'France',flag:'🇫🇷',subtitle:'Kinésithérapie · K1 à K4',accent:'K',structure:['K1','K2','K3','K4'],status:'live'},
 {id:'kineo-es',name:'Kineo España',shortName:'Kineo España',country:'Espagne',flag:'🇪🇸',subtitle:'Fisioterapia · 4 años · FR/ES',accent:'E',structure:['1re année','2e année','3e année','4e année'],status:'foundation'},
 {id:'ifsi-fr',name:'IFSI',shortName:'IFSI',country:'France',flag:'🩺',subtitle:'Soins infirmiers · 3 ans · 6 semestres',accent:'I',structure:['S1','S2','S3','S4','S5','S6'],status:'foundation'}
]
export function getCurrentProgram():Program{if(typeof window==='undefined')return programs[0];const id=localStorage.getItem(PROGRAM_STORAGE_KEY) as ProgramId|null;return programs.find(p=>p.id===id)??programs[0]}
export function selectProgram(id:ProgramId){localStorage.setItem(PROGRAM_STORAGE_KEY,id)}
