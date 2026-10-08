import { defineConfig,devices } from '@playwright/test'

export default defineConfig({
 testDir:'./tests/e2e',
 timeout:30000,
 expect:{timeout:7000},
 fullyParallel:false,
 workers:1,
 retries:1,
 projects:[
  {name:'chromium',use:{...devices['Pixel 7']}},
  {name:'webkit',use:{...devices['iPhone 14']}},
  {name:'firefox',use:{...devices['Desktop Firefox']}},
 ]
 use:{
  trace:'retain-on-failure',
  screenshot:'only-on-failure',
 },
})
