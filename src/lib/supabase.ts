import { createClient } from '@supabase/supabase-js'
import { resolveBackend } from '../config/backend'

const backend=resolveBackend(import.meta.env)
export const supabase = createClient(backend.url,backend.key)
