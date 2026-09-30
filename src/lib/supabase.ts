import { createClient } from '@supabase/supabase-js'

const DEFAULT_SUPABASE_URL = 'https://kimtiyuytikyseuzmjbv.supabase.co'
const DEFAULT_SUPABASE_PUBLISHABLE_KEY = 'sb_publishable_ANuwDKjYwbR2LF629eqK9Q_izXQUycB'

const supabaseUrl = (import.meta.env.VITE_SUPABASE_URL as string | undefined) ?? DEFAULT_SUPABASE_URL
const supabaseKey = (import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY as string | undefined) ?? DEFAULT_SUPABASE_PUBLISHABLE_KEY

export const supabase = createClient(supabaseUrl, supabaseKey)
