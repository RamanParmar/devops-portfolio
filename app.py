from fastapi import FastAPI
import time

app = FastAPI()

@app.get("/")
def read_root():
    return {
        "status": "healthy", 
        "message": "Welcome to my DevOps Portfolio API!"
    }

@app.get("/compute")
def do_work():
    # This endpoint simulates a heavy task so we can test monitoring later
    start_time = time.time()
    y = 0
    for i in range(1_000_000):
        y += i
    return {"status": "success", "execution_time": time.time() - start_time}