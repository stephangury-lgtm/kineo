// A real two-page PDF, with a valid cross-reference table, for renderer tests.
export function coursePdf(){
 const stream=text=>`BT /F1 18 Tf 30 150 Td (${text}) Tj ET`
 const first=stream('Anatomie page une'),second=stream('Anatomie page deux')
 const objects=['<< /Type /Catalog /Pages 2 0 R >>','<< /Type /Pages /Kids [3 0 R 5 0 R] /Count 2 >>',
  '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 300 200] /Resources << /Font << /F1 7 0 R >> >> /Contents 4 0 R >>',
  `<< /Length ${first.length} >>\nstream\n${first}\nendstream`,
  '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 300 200] /Resources << /Font << /F1 7 0 R >> >> /Contents 6 0 R >>',
  `<< /Length ${second.length} >>\nstream\n${second}\nendstream`,'<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>']
 let body='%PDF-1.4\n',offsets=[0]
 for(let index=0;index<objects.length;index++){offsets.push(Buffer.byteLength(body));body+=`${index+1} 0 obj\n${objects[index]}\nendobj\n`}
 const xref=Buffer.byteLength(body)
 body+=`xref\n0 8\n0000000000 65535 f \n`+offsets.slice(1).map(value=>`${String(value).padStart(10,'0')} 00000 n \n`).join('')+`trailer\n<< /Size 8 /Root 1 0 R >>\nstartxref\n${xref}\n%%EOF\n`
 return Buffer.from(body)
}
