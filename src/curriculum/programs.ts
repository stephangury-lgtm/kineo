export type ProgramId='kineo-fr'|'kineo-es'|'ifsi-fr'
export type ProgramStatus='live'|'foundation'
export type LevelKind='year'|'semester'
export type ProgramLevel={id:string;label:string;shortLabel:string;order:number;kind:LevelKind;language:string;secondaryLanguage?:string}
export type Program={
 id:ProgramId
 name:string
 shortName:string
 country:string
 flag:string
 subtitle:string
 accent:string
 status:ProgramStatus
 levelKind:LevelKind
 primaryLanguage:string
 secondaryLanguage?:string
 levels:ProgramLevel[]
}

export const PROGRAM_STORAGE_KEY='healthapp_program'

const numberedYearLevels=(prefix:string,numbers:number[],language:string,secondaryLanguage?:string):ProgramLevel[]=>numbers.map((year,index)=>({
 id:`${prefix}-${year}`,
 label:language==='es'?`${year}.º año`:`${year}${year===1?'re':'e'} année`,
 shortLabel:`${prefix.toUpperCase()}${year}`,
 order:index+1,
 kind:'year',
 language,
 secondaryLanguage
}))

const semesterLevels=(count:number,language:string):ProgramLevel[]=>Array.from({length:count},(_,index)=>({
 id:`s${index+1}`,
 label:`Semestre ${index+1}`,
 shortLabel:`S${index+1}`,
 order:index+1,
 kind:'semester',
 language
}))

export const programs:Program[]=[
 {
  id:'kineo-fr',name:'Kineo France',shortName:'Kineo',country:'France',flag:'🇫🇷',
  subtitle:'Kinésithérapie · K2 à K5',accent:'K',status:'live',levelKind:'year',primaryLanguage:'fr',
  levels:numberedYearLevels('k',[2,3,4,5],'fr')
 },
 {
  id:'kineo-es',name:'Kineo España',shortName:'Kineo España',country:'Espagne',flag:'🇪🇸',
  subtitle:'Fisioterapia · 4 años · FR/ES',accent:'E',status:'foundation',levelKind:'year',primaryLanguage:'es',secondaryLanguage:'fr',
  levels:numberedYearLevels('es',[1,2,3,4],'es','fr')
 },
 {
  id:'ifsi-fr',name:'IFSI',shortName:'IFSI',country:'France',flag:'🩺',
  subtitle:'Soins infirmiers · 3 ans · 6 semestres',accent:'I',status:'foundation',levelKind:'semester',primaryLanguage:'fr',
  levels:semesterLevels(6,'fr')
 }
]

export function getProgram(id:ProgramId){return programs.find(program=>program.id===id)??programs[0]}
export function getCurrentProgram():Program{if(typeof window==='undefined')return programs[0];const id=localStorage.getItem(PROGRAM_STORAGE_KEY) as ProgramId|null;return getProgram(id??'kineo-fr')}
export function selectProgram(id:ProgramId){localStorage.setItem(PROGRAM_STORAGE_KEY,id)}
