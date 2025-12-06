# Archived Test Documentation

This directory contains archived test documentation that has been consolidated into the new documentation structure.

**Archive Date:** December 5-6, 2025

---

## Why These Files Were Archived

All documentation in this archive has been **consolidated and improved** in the new structure:

- **Better organization** - Clear separation of concerns
- **Easier navigation** - Quick start guide + detailed guides
- **No duplication** - Single source of truth for each topic
- **Up-to-date** - Reflects current test fixes and improvements

---

## New Documentation Structure

```
tests/
├── README.md                          # Main entry point
├── QUICK_START.md                     # Quick start for all testing
│
├── guides/                            # Detailed guides
│   ├── TEMPLATE_SYSTEM_TESTING.md
│   └── ARCHETYPE_IMPLEMENTATION_TESTING.md
│
├── rag-archetype/                     # RAG-specific docs
│   ├── README.md
│   ├── QUICK_REFERENCE.md
│   ├── FULL_STACK_TESTING.md
│   └── FIXES_HISTORY.md
│
└── archive/                           # This directory
    └── [old documentation files]
```

---

## Archived Files Mapping

### Template System Testing

| Archived File | Consolidated Into |
|---------------|-------------------|
| TESTING_GUIDE.md | guides/TEMPLATE_SYSTEM_TESTING.md |
| TESTING_ARCHETYPE_STRUCTURE.md | guides/TEMPLATE_SYSTEM_TESTING.md |
| TESTING_ARCHETYPE_VALIDATION.md | guides/TEMPLATE_SYSTEM_TESTING.md |
| TESTING_FILE_MERGING.md | guides/TEMPLATE_SYSTEM_TESTING.md |
| TESTING_GIT_INTEGRATION.md | guides/TEMPLATE_SYSTEM_TESTING.md |
| TESTING_MULTI_ARCHETYPE.md | guides/TEMPLATE_SYSTEM_TESTING.md |
| TESTING_MULTI_PROJECTS.md | guides/TEMPLATE_SYSTEM_TESTING.md |

### RAG Archetype Testing

| Archived File | Consolidated Into |
|---------------|-------------------|
| QUICK_REFERENCE_RAG_TESTING.md | rag-archetype/QUICK_REFERENCE.md |
| RAG_ARCHETYPE_TEST_SUMMARY.md | rag-archetype/README.md |
| TEST_RAG_FULL_STACK.md | rag-archetype/FULL_STACK_TESTING.md |
| RAG_TEST_FIXES_APPLIED.md | rag-archetype/FIXES_HISTORY.md |
| COMPLETE_FIX_SUMMARY.md | rag-archetype/FIXES_HISTORY.md |

---

## What Changed

### Improvements in New Documentation

1. **Clear Entry Point** - README.md with quick links to everything
2. **Quick Start Guide** - Get started in <5 minutes
3. **Organized by Topic** - Separate guides for different test types
4. **RAG-Specific Section** - Dedicated directory for RAG testing
5. **Complete Fix History** - All infrastructure fixes documented
6. **Better Navigation** - Easy to find what you need
7. **No Redundancy** - Each topic covered once, comprehensively

### Content Preserved

All content from archived files has been:
- ✅ Reviewed and updated
- ✅ Consolidated into appropriate guides
- ✅ Enhanced with recent test results
- ✅ Cross-referenced for easy navigation

---

## Using New Documentation

**Start here:** `tests/QUICK_START.md`

**For specific topics:**
- Template system testing → `guides/TEMPLATE_SYSTEM_TESTING.md`
- Archetype code testing → `guides/ARCHETYPE_IMPLEMENTATION_TESTING.md`
- RAG archetype testing → `rag-archetype/README.md`

---

## When to Use Archive

**You should use the archive if:**
- You need to reference old documentation for historical purposes
- You want to see what testing looked like before December 2025
- You're tracking down when specific guidance was added

**You should NOT use the archive for:**
- Current testing procedures (use new docs instead)
- Up-to-date test results (see rag-archetype/FIXES_HISTORY.md)
- Quick reference (use QUICK_START.md)

---

## Archive Contents

### Template System Testing (7 files)

- **TESTING_GUIDE.md** - Old comprehensive testing guide
- **TESTING_ARCHETYPE_STRUCTURE.md** - Archetype structure tests
- **TESTING_ARCHETYPE_VALIDATION.md** - Archetype validation tests
- **TESTING_FILE_MERGING.md** - File merging tests
- **TESTING_GIT_INTEGRATION.md** - Git integration tests
- **TESTING_MULTI_ARCHETYPE.md** - Multi-archetype composition
- **TESTING_MULTI_PROJECTS.md** - Multi-project workflow

### RAG Archetype Testing (5 files)

- **QUICK_REFERENCE_RAG_TESTING.md** - Quick reference (old)
- **RAG_ARCHETYPE_TEST_SUMMARY.md** - Test summary (old)
- **TEST_RAG_FULL_STACK.md** - Full stack testing (old)
- **RAG_TEST_FIXES_APPLIED.md** - Initial 3 fixes
- **COMPLETE_FIX_SUMMARY.md** - All 6 fixes summary

---

## Restoration

If you need to restore any archived documentation:

```bash
# Copy from archive back to tests/
cp tests/archive/FILENAME.md tests/

# Or view in archive
cat tests/archive/FILENAME.md
```

---

**Archived:** December 5-6, 2025
**Reason:** Documentation consolidation and reorganization
**Status:** Superseded by new documentation structure
