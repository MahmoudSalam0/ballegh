from datetime import datetime , timezone

from sqlalchemy import DateTime, Float , String, false, true
from sqlalchemy.orm import Mapped, mapped_column
from database import Base



class Report(Base):
    __tablename__ = "reports"

    id: Mapped[int] = mapped_column(primary_key = true)

    title: Mapped[str] = mapped_column(
        String(70),
        nullable = False
    )
    description : Mapped[str]= mapped_column(
        String(500),
        nullable = False
    )
    category: Mapped[str] = mapped_column(
        String(50),
        nullable = False
    )
    location : Mapped[str] = mapped_column(
        String(255),
        nullable = True
    )
    latitude: Mapped[float|None] = mapped_column(
        Float,
        nullable =True
    )
    longitude: Mapped[float|None] = mapped_column(
        Float,
        nullable = True
    )
    image_url: Mapped[str|None]= mapped_column(
        String(500),
        nullable = true
    )
    status: Mapped[str] = mapped_column(
        String(30),
        nullable = False,
        default = "newReport"
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default =lambda: datetime.now(timezone.utc),
        nullable =false,
    )