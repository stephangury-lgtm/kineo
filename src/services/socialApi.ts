import { supabase } from '../lib/supabase'
import type { ProgramId } from '../curriculum/programs'

export type SocialStudent={id:string;username:string|null;first_name:string|null;study_year:number|null;level:number|null;avatar_url:string|null;program_id?:string|null;level_code?:string|null;same_level?:boolean|null}
export type FriendshipStudent=SocialStudent&{friendship_id:string;created_at?:string;updated_at?:string}
export type FriendshipsSummary={friends:FriendshipStudent[];incoming:FriendshipStudent[];outgoing:FriendshipStudent[]}
export type FriendLeaderboardRow={id:string;username:string|null;first_name:string|null;avatar_url:string|null;level:number|null;xp_total:number;weekly_xp:number;weekly_answers:number;is_me:boolean;rank:number}

export async function searchStudents(query:string,programId:ProgramId){
 const normalized=query.trim()
 if(normalized.length<2)return[]
 const{data,error}=await supabase.rpc('search_students_v3',{p_query:normalized,p_program_id:programId})
 if(error)throw error
 return(data??[])as SocialStudent[]
}

export async function getFriendships(programId:ProgramId){
 const{data,error}=await supabase.rpc('get_friendships_v3',{p_program_id:programId})
 if(error)throw error
 const result=(data??{})as Partial<FriendshipsSummary>
 return{friends:result.friends??[],incoming:result.incoming??[],outgoing:result.outgoing??[]}satisfies FriendshipsSummary
}

export async function getFriendLeaderboard(){const{data,error}=await supabase.rpc('get_friend_leaderboard_v1');if(error)throw error;return(data??[])as FriendLeaderboardRow[]}
export async function sendFriendRequest(addresseeId:string){const{data,error}=await supabase.rpc('send_friend_request_v1',{p_addressee:addresseeId});if(error)throw error;return data as string}
export async function respondFriendRequest(friendshipId:string,accept:boolean){const{data,error}=await supabase.rpc('respond_friend_request_v1',{p_friendship_id:friendshipId,p_accept:accept});if(error)throw error;return data as string}
export async function removeFriendship(friendshipId:string){const{data,error}=await supabase.rpc('remove_friendship_v1',{p_friendship_id:friendshipId});if(error)throw error;return Boolean(data)}
