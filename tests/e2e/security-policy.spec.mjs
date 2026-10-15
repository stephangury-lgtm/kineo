import {test,expect} from '@playwright/test'
const base=(process.env.KINEO_E2E_BASE_URL||'http://127.0.0.1:4173').replace(/\/$/,'')

test('production policy blocks injected inline scripts and framing',async({page,request})=>{
 test.skip(!base.startsWith('https://'),'Cloudflare headers are checked on the HTTPS deployment')
 const response=await request.get(base+'/informations')
 expect(response.ok()).toBeTruthy()
 const headers=response.headers(),csp=headers['content-security-policy']||''
 expect(csp).toContain("script-src 'self'")
 expect(csp).toContain("object-src 'none'")
 expect(csp).toContain("frame-ancestors 'none'")
 expect(headers['strict-transport-security']).toContain('max-age=31536000')
 await page.goto(base+'/informations',{waitUntil:'networkidle'})
 await expect(page.getByRole('heading',{name:/Informations|éditeur|Éditeur/}).first()).toBeVisible()
 const executed=await page.evaluate(()=>{
  const script=document.createElement('script')
  script.textContent='window.__lerykoCspProbe=true'
  document.body.appendChild(script)
  return Boolean(window.__lerykoCspProbe)
 })
 expect(executed).toBe(false)
})
