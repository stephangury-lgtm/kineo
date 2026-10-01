import { createClient } from '@supabase/supabase-js'

const KINEO_SUPABASE_URL = 'https://kimtiyuytikyseuzmjbv.supabase.co'
const KINEO_SUPABASE_PUBLISHABLE_KEY = 'sb_publishable_ANuwDKjYwbR2LF629eqK9Q_izXQUycB'

// Kineo v2 must always authenticate against the production Kineo Supabase project.
// Keeping these public client credentials pinned prevents a stale Vercel environment
// variable from silently sending sign-ups and logins to another Supabase project.
export const supabase = createClient(KINEO_SUPABASE_URL, KINEO_SUPABASE_PUBLISHABLE_KEY)
