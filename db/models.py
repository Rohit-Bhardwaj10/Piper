from sqlalchemy import (
    Column,
    String,
    Integer,
    Float,
    Boolean,
    DateTime,
    ForeignKey,
    Text,
)
from sqlalchemy.dialects.postgresql import UUID, JSONB, TSVECTOR
from sqlalchemy.orm import DeclarativeBase, relationship
from pgvector.sqlalchemy import Vector
from datetime import datetime
import uuid


class Base(DeclarativeBase):
    pass


class Session(Base):
    __tablename__ = "sessions"
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    repo_path = Column(Text, nullable=False)
    task = Column(Text, nullable=False)
    status = Column(String(20), default="running")
    model = Column(String(100), nullable=False)
    total_tokens = Column(Integer, default=0)
    total_cost_usd = Column(Float, default=0.0)
    tool_calls_count = Column(Integer, default=0)
    duration_seconds = Column(Integer)
    created_at = Column(DateTime, default=datetime.utcnow)
    completed_at = Column(DateTime)

    tool_calls = relationship("ToolCall", back_populates="session")


class ToolCall(Base):
    __tablename__ = "tool_calls"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    session_id = Column(UUID(as_uuid=True), ForeignKey("sessions.id"))
    tool_name = Column(String(100), nullable=False)
    input = Column(JSONB, nullable=False)
    output = Column(JSONB)
    success = Column(Boolean)
    duration_ms = Column(Integer)
    called_at = Column(DateTime, default=datetime.utcnow)

    session = relationship("Session", back_populates="tool_calls")


class Chunk(Base):
    __tablename__ = "chunks"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    repo_path = Column(Text, nullable=False)
    file_path = Column(Text, nullable=False)
    start_line = Column(Integer, nullable=False)
    end_line = Column(Integer, nullable=False)
    content = Column(Text, nullable=False)
    language = Column(String(50))
    chunk_type = Column(String(50))
    symbol_name = Column(String(255))
    embedding = Column(Vector(768))
    ts_vector = Column(TSVECTOR)
    created_at = Column(DateTime, default=datetime.utcnow)


class Prompt(Base):
    __tablename__ = "prompts"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(100), nullable=False)
    version = Column(Integer, nullable=False)
    content = Column(Text, nullable=False)
    eval_score = Column(Float)
    deployed = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
