from fastapi import FastAPI
from app.routes import establishments

app = FastAPI(title="AgendaPro API")

app.include_router(establishments.router)

@app.get("/health")
def health():
    return {"status": "ok"}
