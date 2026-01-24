# S07: SPECIFICATION SUMMARY

**Library:** simple_csv
**Date:** 2026-01-23
**Status:** BACKWASH (reverse-engineered from implementation)

## Library Summary

**Purpose:** RFC 4180 compliant CSV parsing and generation with Excel compatibility and object mapping.

**Core Functionality:**
1. CSV parsing from strings and files
2. Field access by index and name
3. CSV generation with multiple formats
4. Excel BOM and sep= support
5. Object-to-CSV reflection mapping
6. Row iteration for large data

## API Surface

### SIMPLE_CSV

| Category | Features |
|----------|----------|
| Creation | 3 |
| Parsing | 4 (aliased) |
| Access | 8 |
| Null Handling | 4 |
| Iteration | 5 |
| Query | 4 |
| Generation | 7 |
| Settings | 4 |
| Lenient | 3 |
| BOM/Encoding | 6 |
| MML Models | 4 |

### SIMPLE_CSV_QUICK

| Category | Features |
|----------|----------|
| Config | 4 |
| Reading | 3 |
| Writing | 3 |
| Utility | 5 |

### SIMPLE_CSV_MAPPER

| Category | Features |
|----------|----------|
| Settings | 2 |
| Object->CSV | 2 |
| CSV->Object | 2 |

## Quality Metrics

| Metric | Value |
|--------|-------|
| Classes | 3 |
| Total Lines | ~1480 |
| Invariants | 8 |
| MML Models | 4 |

## Key Design Decisions

1. **DOM-style parsing** - Full random access
2. **Feature aliases** - Multiple names for same operation
3. **MML integration** - Formal verification support
4. **Three API levels** - Full, quick, mapper
