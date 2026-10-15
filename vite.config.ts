import { defineConfig,loadEnv } from 'vite'
import react from '@vitejs/plugin-react'
import { resolveBackend } from './src/config/backend'

export default defineConfig(({mode})=>{
 const backend=resolveBackend({...loadEnv(mode,process.cwd(),'VITE_'),...process.env})
 return {
  plugins: [react(),{
    name:'backend-security-headers',
    apply:'build',
    // publicDir files are copied after generateBundle, so rewrite the copied file.
    async closeBundle(){
      if(backend.production)return
      const fs=await import('node:fs/promises')
      const file='dist/_headers'
      const text=await fs.readFile(file,'utf8')
      await fs.writeFile(file,text.replaceAll('kimtiyuytikyseuzmjbv.supabase.co',new URL(backend.url).host),'utf8')
    },
  }],
  build: {
    rollupOptions: {
      output: {
        manualChunks(id) {
          if (!id.includes('node_modules')) return
          if (id.includes('/react/') || id.includes('/react-dom/') || id.includes('/react-router') || id.includes('/scheduler/')) return 'vendor-react'
          if (id.includes('/@supabase/')) return 'vendor-supabase'
        },
      },
    },
  },
 }
})
