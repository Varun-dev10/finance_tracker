from fastapi import FastAPI

app = FastAPI(title="Finance Tracker API")  ## brain of backend every requesst will go through this app object

@app.get("/")  ## called "route" tells server to run below function if someone visits main address root
def read_root():  #called
    return {"message": "Finance Tracker Backend is Running!"}  #return message

@app.get("/health")   ##health check route
def health_check():
    return {"status": "healthy"}