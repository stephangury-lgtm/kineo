export function learningSection(path:string){
 if(['/parcours','/cours/','/lesson/','/bibliotheque','/document/'].some(prefix=>path.startsWith(prefix)))return '/parcours'
 if(['/amis','/classement','/defi-cursus/'].some(prefix=>path.startsWith(prefix)))return '/amis'
 if(['/stats','/rewards','/revision/historique','/session/'].some(prefix=>path.startsWith(prefix)))return '/progres'
 if(path==='/progres')return '/progres'
 if(path==='/profil'||path.startsWith('/admin'))return '/profil'
 if(['/revision','/quiz','/fondamentaux','/anatomie','/mes-erreurs','/examen','/ma-seance'].some(prefix=>path.startsWith(prefix)))return '/ma-seance'
 return path==='/'?'/ma-seance':null
}
