# 7S-06: SIZING


**Date**: 2026-01-23

**Library:** simple_csv
**Date:** 2026-01-23
**Status:** BACKWASH (reverse-engineered from implementation)

## Implementation Size Analysis

### Actual Implementation

| Component | Lines | Classes |
|-----------|-------|---------|
| SIMPLE_CSV | ~960 | 1 |
| SIMPLE_CSV_QUICK | ~265 | 1 |
| SIMPLE_CSV_MAPPER | ~255 | 1 |
| Test classes | ~200 | 3 |
| **Total** | **~1680** | **6** |

### Complexity Assessment

**Medium Complexity**
- Multi-class implementation
- External dependencies (simple_encoding, simple_reflection)
- State machine parsing
- MML model integration

### Code Breakdown (SIMPLE_CSV)

| Feature Group | Approximate Lines |
|---------------|-------------------|
| Initialization | 100 |
| MML Models | 70 |
| Parsing | 180 |
| Access | 150 |
| Null Handling | 50 |
| Row Iteration | 50 |
| Query | 30 |
| Generation | 150 |
| Settings | 50 |
| Lenient Mode | 50 |
| BOM/Encoding | 80 |

### Memory Footprint

Per SIMPLE_CSV instance:
- rows: ARRAYED_LIST of ARRAYED_LIST of STRING
- header_map: HASH_TABLE
- parse_errors: ARRAYED_LIST

Memory = O(rows * columns * avg_field_length)

### Performance Characteristics

- Parsing: O(n) in input size
- Field access: O(1) by index, O(1) by name (hash lookup)
- Column extraction: O(rows)
- CSV generation: O(rows * columns)
