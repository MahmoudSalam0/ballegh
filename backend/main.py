from fastapi import FastAPI , status , HTTPException
from pydantic import BaseModel ,Field
from sqlalchemy import text

from database import engine ,Base
from models import Report


app = FastAPI()

Base.metadata.create_all(bind=engine)


class ReportCreate(BaseModel):
    title: str = Field(min_length=5,max_length=70)
    description: str = Field(min_length=15,max_length=500)
    category: str
    latitude:float | None =None
    longitude:float | None =None

class ReportUpdate(BaseModel):
    title: str | None = Field(default=None, min_length=5, max_length=70)
    description: str | None = Field(default=None, min_length=15, max_length=500)
    category: str | None = None
    latitude: float | None = None
    longitude: float | None = None

reports = []
next_id = 1

@app.get("/db-health")
def db_health():
    with engine.connect() as connection:
        result = connection.execute(text("SELECT 1"))
        return{
            "database":"connected",
            "result": result.scalar_one()
        }
@app.get("/")
def root(): return {"message": "Ballegh API is Running "}

@app.get("/health")
def health(): return{"status":"ok"}

@app.post("/reports", status_code = status.HTTP_201_CREATED)
def create_report(report: ReportCreate):
    global next_id

    new_report={
    "id": next_id,
    "title": report.title,
    "description": report.description,
    "category": report.category,
    "latitude": report.latitude,
    "longitude": report.longitude,
    "status":"newReport"
    }

    reports.append(new_report)
    next_id += 1 

    return new_report

@app.get("/reports")
def get_reports():
    return reports

@app.get("/reports/{report_id}")
def get_report(report_id: int):
    for report in reports:
        if report["id"] == report_id:
            return report

    raise HTTPException(status_code = status.HTTP_404_NOT_FOUND,
detail = "Report not found")

@app.patch("/reports/{report_id}")
def update_report(report_id: int, data: ReportUpdate):
    for report in reports:
        if report["id"] == report_id:
            update_data = data.model_dump(exclude_unset=True)
            report.update(update_data)
            return report
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND,
        detail="Report not found",
    )
    
@app.delete("/reports/{report_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_report(report_id: int):
    for index, report in enumerate(reports):
        if report["id"] == report_id:
            reports.pop(index)
            return
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND,
        detail="Report not found",
    )    


