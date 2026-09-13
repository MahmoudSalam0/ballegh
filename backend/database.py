from pydantic_settings import BaseSettings , SettingsConfigDict
from sqlalchemy import URL ,create_engine, false, true
from sqlalchemy.orm import DeclarativeBase, sessionmaker


class Settings(BaseSettings):
    db_user: str
    db_password: str
    db_host: str
    db_port: int
    db_name: str

    model_config = SettingsConfigDict(env_file=".env")

settings = Settings()


database_url = URL.create(
        drivername= "postgresql+psycopg",
        username = settings.db_user,
        password = settings.db_password,
        host = settings.db_host,
        port = settings.db_port,
        database = settings.db_name
    )

engine = create_engine(
        database_url,
        pool_pre_ping= true,
    )

SessionLocal = sessionmaker(
        bind = engine,
        autoflush=false,
    )


class Base(DeclarativeBase):
    pass