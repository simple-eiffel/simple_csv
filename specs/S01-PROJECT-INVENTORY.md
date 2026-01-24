# S01: PROJECT INVENTORY

**Library:** simple_csv
**Date:** 2026-01-23
**Status:** BACKWASH (reverse-engineered from implementation)

## Project Structure

```
simple_csv/
├── src/
│   ├── simple_csv.e           # Main CSV class
│   ├── simple_csv_quick.e     # Zero-config facade
│   └── simple_csv_mapper.e    # Object reflection mapper
├── testing/
│   ├── test_app.e             # Test entry point
│   ├── lib_tests.e            # Unit tests
│   └── test_person.e          # Test data class
├── research/                   # 7S research documents
├── specs/                      # Specification documents
├── docs/                       # API documentation
├── simple_csv.ecf             # Library ECF
└── README.md                   # Documentation
```

## File Inventory

| File | Type | Lines | Purpose |
|------|------|-------|---------|
| simple_csv.e | Source | 963 | Main CSV parsing/generation |
| simple_csv_quick.e | Source | 266 | Simple facade |
| simple_csv_mapper.e | Source | 254 | Object mapping |
| test_app.e | Test | ~30 | Test entry |
| lib_tests.e | Test | ~150 | Unit tests |
| test_person.e | Test | ~30 | Test data class |

## Dependencies

### simple_* Libraries
- simple_encoding - BOM/encoding detection

### For SIMPLE_CSV_MAPPER
- simple_reflection - Object introspection

### Eiffel Base Libraries
- ARRAYED_LIST, HASH_TABLE, STRING, PLAIN_TEXT_FILE
- STRING_TABLE (for quick facade)
- INTERNAL (for mapper)

## Build Configuration

**ECF Targets:**
- `simple_csv` - Library target
- `simple_csv_tests` - Test target
