# S05: CONSTRAINTS

**Library:** simple_csv
**Date:** 2026-01-23
**Status:** BACKWASH (reverse-engineered from implementation)

## Technical Constraints

### Delimiter Constraints

| Constraint | Enforcement | Reason |
|------------|-------------|--------|
| Not newline | Invariant | Would break row detection |
| Not carriage return | Invariant | Would break line normalization |
| Not quote char | Invariant | Would break quoting |

### Data Constraints

| Field | Constraint | Enforcement |
|-------|------------|-------------|
| rows | Not Void | Invariant |
| header_map | Not Void | Invariant |
| row index | 1..row_count | Precondition |
| column index | 1..column_count | Precondition |

### Header Constraints

- Header map only built when has_header = True
- Column name lookup requires has_header
- Header map uses lowercase keys (case-insensitive)

## Behavioral Constraints

### Parsing Rules

1. **Quote handling:**
   - Quotes toggle in_quotes state
   - Doubled quotes ("") become single quote
   - Quotes not required around fields

2. **Newline handling:**
   - CRLF and CR normalized to LF
   - LF within quotes preserved

3. **Empty fields:**
   - Consecutive delimiters create empty strings
   - Trailing delimiter creates empty field

### Model Consistency

MML models must stay consistent with underlying data:
- `rows_model.count = rows.count`
- `data_rows_model.count = row_count`
- `header_map_model [name] = column_index (name)`

### Memory Constraints

- Entire CSV loaded into memory
- Memory = O(rows * columns * avg_field_size)
- Use iteration for memory-conscious processing
