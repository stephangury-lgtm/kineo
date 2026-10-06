import type { BadgeProgressV2 } from '../services/kineoApi'

export function getBadgeCopy(badge:BadgeProgressV2,isSpain:boolean){
 if(!isSpain)return {name:badge.name,description:badge.description}
 const target=badge.target_value
 switch(badge.condition_type){
  case 'quiz_completed':
   return target===1
    ? {name:'Primer paso',description:'Completa tu primer quiz'}
    : {name:`${target} quizzes completados`,description:`Completa ${target} quizzes`}
  case 'correct_answers':
   return {name:`${target} respuestas correctas`,description:`Responde correctamente a ${target} preguntas`}
  case 'streak':
   return {name:`Racha de ${target} días`,description:`Repasa durante ${target} días consecutivos`}
  case 'daily_completed':
   if(target===7)return {name:'Habitual del reto',description:'Completa 7 retos del día'}
   if(target===30)return {name:'Maestro del reto',description:'Completa 30 retos del día'}
   return {name:`${target} retos del día`,description:`Completa ${target} retos del día`}
  case 'daily_perfect':
   return {name:'Reto perfecto',description:'Consigue 10/10 en el reto del día'}
  default:
   return {name:badge.name,description:badge.description}
 }
}
