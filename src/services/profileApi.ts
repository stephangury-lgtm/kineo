import { supabase } from '../lib/supabase'

export type StudentProfile={id:string;first_name:string|null;username:string|null;avatar_url:string|null;study_year:number|null;role:'student'|'admin'}

export async function getCurrentProfile(){const{data:userData,error:userError}=await supabase.auth.getUser();if(userError)throw userError;const user=userData.user;if(!user)return null;const{data,error}=await supabase.from('profiles').select('id, first_name, username, avatar_url, study_year, role').eq('id',user.id).maybeSingle();if(error)throw error;return data as StudentProfile|null}

export async function markAppOpen(){const{error}=await supabase.rpc('mark_app_open_v1');if(error)throw error}
export async function touchUserActivity(){const{error}=await supabase.rpc('touch_user_activity_v1');if(error)throw error}

export async function updateStudyProfile(params:{firstName?:string;username?:string;studyYear:number}){
 const username=params.username?.trim()
 if(params.studyYear<2||params.studyYear>5)throw new Error('Choisis une année comprise entre K2 et K5.')
 if(username&&!/^[a-zA-Z0-9._-]{3,24}$/.test(username))throw new Error('Le pseudo doit contenir 3 à 24 caractères : lettres, chiffres, point, tiret ou underscore.')
 const{error}=await supabase.rpc('update_study_profile_v1',{p_first_name:params.firstName?.trim()??'',p_username:username??'',p_study_year:params.studyYear})
 if(error)throw error
 const refreshed=await getCurrentProfile();if(!refreshed)throw new Error('Profil introuvable après mise à jour.')
 window.dispatchEvent(new Event('kineo-profile-updated'))
 return refreshed
}

function inferImageType(file:File){if(file.type)return file.type.toLowerCase();const ext=file.name.split('.').pop()?.toLowerCase();if(ext==='jpg'||ext==='jpeg')return'image/jpeg';if(ext==='png')return'image/png';if(ext==='webp')return'image/webp';if(ext==='heic')return'image/heic';if(ext==='heif')return'image/heif';return''}
async function convertToJpeg(file:File):Promise<File>{try{const bitmap=await createImageBitmap(file);const maxSide=1400;const ratio=Math.min(1,maxSide/Math.max(bitmap.width,bitmap.height));const width=Math.max(1,Math.round(bitmap.width*ratio));const height=Math.max(1,Math.round(bitmap.height*ratio));const canvas=document.createElement('canvas');canvas.width=width;canvas.height=height;const ctx=canvas.getContext('2d');if(!ctx)throw new Error('Canvas indisponible');ctx.drawImage(bitmap,0,0,width,height);bitmap.close();const blob=await new Promise<Blob|null>(resolve=>canvas.toBlob(resolve,'image/jpeg',0.88));if(!blob)throw new Error('Conversion impossible');return new File([blob],'avatar.jpg',{type:'image/jpeg',lastModified:Date.now()})}catch{throw new Error('Cette photo utilise un format que ton navigateur ne peut pas convertir. Essaie de la partager/exporter en JPG puis sélectionne-la à nouveau.')}}
function storagePathFromAvatarUrl(url:string,userId:string){try{const clean=url.split('?')[0];const marker='/storage/v1/object/public/avatars/';const index=clean.indexOf(marker);if(index<0)return null;const path=decodeURIComponent(clean.slice(index+marker.length));return path.startsWith(`${userId}/`)?path:null}catch{return null}}

export async function uploadProfilePhoto(originalFile:File){
 if(originalFile.size>8*1024*1024)throw new Error('La photo doit faire moins de 8 Mo avant optimisation.')
 const originalType=inferImageType(originalFile);const directlySupported=['image/jpeg','image/png','image/webp'];const convertibleMobile=['image/heic','image/heif'];let file=originalFile
 if(convertibleMobile.includes(originalType))file=await convertToJpeg(originalFile);else if(!directlySupported.includes(originalType)){if(!originalType.startsWith('image/'))throw new Error('Le fichier sélectionné n’est pas une image.');file=await convertToJpeg(originalFile)}
 if(file.size>5*1024*1024)file=await convertToJpeg(file);if(file.size>5*1024*1024)throw new Error('La photo reste trop volumineuse après optimisation. Choisis une image plus légère.')
 const{data:userData,error:userError}=await supabase.auth.getUser();if(userError)throw userError;const user=userData.user;if(!user)throw new Error('Utilisateur non authentifié')
 const currentProfile=await getCurrentProfile();const previousPath=currentProfile?.avatar_url?storagePathFromAvatarUrl(currentProfile.avatar_url,user.id):null
 const extension=file.type==='image/png'?'png':file.type==='image/webp'?'webp':'jpg';const path=`${user.id}/avatar-${Date.now()}.${extension}`
 const{error:uploadError}=await supabase.storage.from('avatars').upload(path,file,{cacheControl:'3600',contentType:file.type||'image/jpeg',upsert:false});if(uploadError)throw new Error(`Envoi de la photo impossible : ${uploadError.message}`)
 const{data:publicData}=supabase.storage.from('avatars').getPublicUrl(path);const avatarUrl=publicData.publicUrl
 const{data:savedUrl,error:saveError}=await supabase.rpc('set_profile_avatar_v1',{p_avatar_url:avatarUrl});if(saveError||!savedUrl){await supabase.storage.from('avatars').remove([path]);throw new Error(`Photo envoyée mais profil non enregistré : ${saveError?.message??'réponse invalide'}`)}
 if(previousPath&&previousPath!==path)await supabase.storage.from('avatars').remove([previousPath]).catch(()=>undefined)
 const displayUrl=`${String(savedUrl)}?v=${Date.now()}`;window.dispatchEvent(new CustomEvent('kineo-profile-updated',{detail:{avatarUrl:displayUrl}}));return displayUrl
}

export async function removeProfilePhoto(currentUrl?:string|null){const{data:userData,error:userError}=await supabase.auth.getUser();if(userError)throw userError;const user=userData.user;if(!user)throw new Error('Utilisateur non authentifié');const{error:clearError}=await supabase.rpc('set_profile_avatar_v1',{p_avatar_url:''});if(clearError)throw clearError;if(currentUrl){const path=storagePathFromAvatarUrl(currentUrl,user.id);if(path)await supabase.storage.from('avatars').remove([path]).catch(()=>undefined)}window.dispatchEvent(new CustomEvent('kineo-profile-updated',{detail:{avatarUrl:null}}))}
