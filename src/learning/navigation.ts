export function learningSection(path:string){
 if(['/parcours','/cours/','/lesson/','/bibliotheque','/document/'].some(prefix=>path.startsWith(prefix)))return '/parcours'
 if(['/amis','/classement','/defi-cursus/'].some(prefix=>path.startsWith(prefix)))return '/amis'
 if(['/stats','/rewards','/revision/historique','/session/'].some(prefix=>path.startsWith(prefix)))return '/progres'
 if(path==='/progres')return '/progres'
 if(['/revision','/quiz','/fondamentaux','/anatomie','/mes-erreurs','/examen'].some(prefix=>path.startsWith(prefix)))return '/revision'
 return path==='/'?'/':null
}
