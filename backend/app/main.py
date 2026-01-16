from fastapi import FastAPI

app = FastAPI(title="AgendaPro API")

@app.get("/health")
def health():
    return {"status": "ok"}
