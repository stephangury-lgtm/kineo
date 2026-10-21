#!/usr/bin/env python3
"""Idempotent Drive -> private Supabase Storage migration for course_documents.

Required env: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY.
For private Google files also set GOOGLE_SERVICE_ACCOUNT_JSON (service account
must have access to the Drive files), or GOOGLE_ACCESS_TOKEN (short-lived).
Never put credentials in source control.
"""
import json, os, re, sys, hashlib, urllib.parse, urllib.request, urllib.error

BASE=os.environ["SUPABASE_URL"].rstrip("/")
KEY=os.environ["SUPABASE_SERVICE_ROLE_KEY"]
DRY=os.getenv("DRY_RUN","true").lower()!="false"
HEAD={"apikey":KEY,"Authorization":"Bearer "+KEY}
def call(url, method="GET", data=None, headers=None):
    req=urllib.request.Request(url,data=data,method=method,headers={**HEAD,**(headers or {})})
    with urllib.request.urlopen(req,timeout=90) as response:return response.read()
def drive_id(path):
    if path.startswith("gdrive://"):return path[9:]
    m=re.search(r"drive.google.com/file/d/([^/]+)",path)
    return m.group(1) if m else None
def download(file_id):
    token=os.getenv("GOOGLE_ACCESS_TOKEN")
    if not token and os.getenv("GOOGLE_SERVICE_ACCOUNT_JSON"):
        from google.oauth2 import service_account
        from google.auth.transport.requests import Request
        info=json.loads(os.environ["GOOGLE_SERVICE_ACCOUNT_JSON"])
        credentials=service_account.Credentials.from_service_account_info(info,scopes=["https://www.googleapis.com/auth/drive.readonly"])
        credentials.refresh(Request())
        token=credentials.token
    if not token:raise RuntimeError("Google Drive authentication missing")
    req=urllib.request.Request("https://www.googleapis.com/drive/v3/files/"+urllib.parse.quote(file_id)+"?alt=media",headers={"Authorization":"Bearer "+token})
    with urllib.request.urlopen(req,timeout=120) as response:return response.read()
def main():
    docs=json.loads(call(BASE+"/rest/v1/course_documents?select=id,file_name,storage_path,subject_id,chapter_id&limit=1000"))
    results={"total":len(docs),"drive":0,"migrated":0,"skipped":0,"failed":[],"unsupported":[]}
    for doc in docs:
        path=doc["storage_path"] or ""
        fid=drive_id(path)
        if not fid:
            if path.startswith("conversation-upload://"):results["unsupported"].append(doc["file_name"])
            else:results["skipped"]+=1
            continue
        results["drive"]+=1
        target="courses/"+doc["id"]+".pdf"
        if DRY:
            print("PLAN",doc["file_name"],"->",target)
            continue
        try:
            data=download(fid)
            if not data.startswith(b"%PDF-"):raise ValueError("Downloaded content is not a PDF")
            # Only change the database after a successful Storage upload.
            upload_url=BASE+"/storage/v1/object/documents/"+target
            call(upload_url,"POST",data,{"Content-Type":"application/pdf","x-upsert":"true"})
            payload=json.dumps({"storage_path":target,"file_size":len(data),"mime_type":"application/pdf"}).encode()
            call(BASE+"/rest/v1/course_documents?id=eq."+urllib.parse.quote(doc["id"]),"PATCH",payload,{"Content-Type":"application/json","Prefer":"return=minimal"})
            results["migrated"]+=1
            print("OK",doc["file_name"],hashlib.sha256(data).hexdigest())
        except Exception as exc:
            results["failed"].append({"file":doc["file_name"],"error":str(exc)})
    print(json.dumps(results,ensure_ascii=False,indent=2))
    if results["failed"]:sys.exit(1)
if __name__=="__main__":main()
