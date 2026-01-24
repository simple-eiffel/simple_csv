# S06: BOUNDARIES

**Library:** simple_csv
**Date:** 2026-01-23
**Status:** BACKWASH (reverse-engineered from implementation)

## System Boundaries

### Class Hierarchy

```
SIMPLE_CSV (core)
    |
    +-- SIMPLE_CSV_QUICK (facade, uses SIMPLE_CSV internally)
    |
    +-- SIMPLE_CSV_MAPPER (uses SIMPLE_CSV + simple_reflection)
```

### External Dependencies

```
simple_csv
    |
    +-- simple_encoding (SIMPLE_ENCODING_DETECTOR)
    |
    +-- simple_reflection (SIMPLE_CSV_MAPPER only)
            |
            +-- SIMPLE_REFLECTED_OBJECT
            +-- SIMPLE_FIELD_INFO
```

## Class Responsibilities

### SIMPLE_CSV
- CSV parsing and generation
- Row/column data storage
- Header management
- Delimiter configuration
- BOM/encoding handling
- Lenient mode error collection

### SIMPLE_CSV_QUICK
- Simplified one-liner API
- Format shortcuts (use_tabs, use_semicolons)
- Row building utilities
- Delegates to SIMPLE_CSV

### SIMPLE_CSV_MAPPER
- Object field extraction via reflection
- CSV-to-object population
- Header name conversion (snake_case)
- Type conversion for fields

## Integration Points

| Integration | Direction | Data |
|-------------|-----------|------|
| File system | Input/Output | CSV files |
| simple_encoding | Query | Encoding detection |
| simple_reflection | Query | Object introspection |
| Application | Both | Strings, objects |

## Not Responsible For

- File compression/decompression
- Network I/O
- Database operations
- Schema validation
- Type inference beyond mapping
