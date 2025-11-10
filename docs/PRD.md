# Islamic History Digital Library & Generative AI Knowledge Engine PRD

## Version

1.0

## Owner

Mazen

## Vision

A unified digital system that preserves, organizes, and activates Islamic history—spanning from the dawn of Islam (610 CE) to the fall of the Ottoman Empire and the modern Islamic world. The system converts raw historical texts into rich, interactive knowledge artifacts powered by GenAI, and makes them accessible through a seamless interface.

## Goals

1. Digital Library of classical Islamic historical texts.
2. Knowledge Pipelines generating summaries, videos, graphics, timelines, and kids' books.
3. RAG-enabled chatbot grounded in authentic sources.
4. Unified interface for all artifacts.

## Scope

### Historical Periods

- Early Islam (610–661)
- Umayyads (661–750)
- Abbasids (750–1258)
- Post-Abbasid Dynasties (1258–1517)
- Ottoman Empire (1299–1923)
- Modern Islamic World (1923–today)

### Source Types

- Classical Islamic historical works (priority)
- Hadith, tafsir, fiqh with historical context
- Modern Islamic scholarship
- Short educational videos

## System Components

### Digital Library

- Uses structured metadata JSON per book
- Stored in Zotero + Calibre + Master DB

### RAG Engine

- Document ingestion
- Text splitting
- Embedding generation
- Vector DB storage
- Retrieval + generation with citations

### Knowledge Pipelines

- Summaries
- Timelines
- Graphics / diagrams
- Short videos
- Kids books

### Chatbot

- Period-based search
- Grounded answers with citations
- No fatwa generation

## Architecture

### Backend

- Python
- FastAPI / Flask
- LangChain / LlamaIndex
- Chroma / Qdrant DB

### Frontend

- Next.js + shadcn/UI
- Chat UI
- Timeline visualizer
- File browser

## Implementation Roadmap

### Phase 1

- RAG pipeline and ingestion

### Phase 2

- Chatbot + frontend

### Phase 3

- Knowledge pipelines

### Phase 4

- Kids books + video generation

### Phase 5

- Optimization + expansion
