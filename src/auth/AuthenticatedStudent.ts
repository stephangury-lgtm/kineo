import {createContext,useContext} from 'react'
// UI scope only. Server APIs remain responsible for authorization.
export const AuthenticatedStudent=createContext('')
export const useAuthenticatedStudent=()=>useContext(AuthenticatedStudent)
