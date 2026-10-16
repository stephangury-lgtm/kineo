export function interfaceBuild(env){
 const enabled=env.VITE_ENABLE_V5_PREVIEW==='true'
 const defaultV5=env.VITE_V5_DEFAULT==='true'
 if(defaultV5&&!enabled)throw new Error('V5 default requires VITE_ENABLE_V5_PREVIEW=true')
 return defaultV5?'v5':enabled?'preview':'legacy'
}
