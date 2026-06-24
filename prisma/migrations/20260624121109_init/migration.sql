-- CreateTable
CREATE TABLE "Session" (
    "id" TEXT NOT NULL,
    "repoPath" TEXT NOT NULL,
    "task" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'running',
    "model" TEXT NOT NULL,
    "totalTokens" INTEGER NOT NULL DEFAULT 0,
    "totalCostUsd" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "toolCallsCount" INTEGER NOT NULL DEFAULT 0,
    "durationSeconds" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completedAt" TIMESTAMP(3),

    CONSTRAINT "Session_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ToolCall" (
    "id" TEXT NOT NULL,
    "sessionId" TEXT NOT NULL,
    "toolName" TEXT NOT NULL,
    "input" JSONB NOT NULL,
    "output" JSONB,
    "success" BOOLEAN,
    "durationMs" INTEGER,
    "calledAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ToolCall_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Chunk" (
    "id" TEXT NOT NULL,
    "repoPath" TEXT NOT NULL,
    "filePath" TEXT NOT NULL,
    "startLine" INTEGER NOT NULL,
    "endLine" INTEGER NOT NULL,
    "content" TEXT NOT NULL,
    "language" TEXT,
    "chunkType" TEXT,
    "symbolName" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Chunk_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Prompt" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "version" INTEGER NOT NULL,
    "content" TEXT NOT NULL,
    "evalScore" DOUBLE PRECISION,
    "deployed" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Prompt_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Prompt_name_version_key" ON "Prompt"("name", "version");

-- AddForeignKey
ALTER TABLE "ToolCall" ADD CONSTRAINT "ToolCall_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "Session"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

--Chunk table (pg-vector)
CREATE EXTENSION IF NOT EXISTS vector;
ALTER TABLE "Chunk" ADD COLUMN IF NOT EXISTS embedding vector(768);
CREATE INDEX ON "Chunk" USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
ALTER TABLE "Chunk" ADD COLUMN IF NOT EXISTS ts_vector tsvector;
CREATE INDEX ON "Chunk" USING GIN (ts_vector);
