import {defineConfig,devices} from '@playwright/test'
process.env.LERYKO_TEST_ROLLBACK='1'
export default defineConfig({
 testDir:'./tests/e2e',testMatch:'v5-rollback.spec.mjs',outputDir:'test-results-rollback',timeout:60000,workers:1,retries:0,
 expect:{timeout:10000},
 projects:[{name:'chromium',use:{...devices['Pixel 7']}}],
 webServer:{command:'node tests/fixtures/releaseServer.mjs',url:'http://127.0.0.1:4180',reuseExistingServer:false},
 use:{trace:'retain-on-failure',screenshot:'only-on-failure'},
})
