from fastapi import FastAPI, File, UploadFile
from pydantic import BaseModel
import uvicorn

app = FastAPI()

class MLResponse(BaseModel):
    text: str
    summary: str

@app.post("/summarize", response_model=MLResponse)
async def summarize(file: UploadFile = File(...)):
    # Test logic: Read file and return dummy response
    content = await file.read()
    text = content.decode("utf-8")
    summary = "This is a test summary."  # Dummy summary for testing

    return MLResponse(text=text, summary=summary)

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
