# 7S-03: SOLUTIONS

**Library:** simple_csv
**Date:** 2026-01-23
**Status:** BACKWASH (reverse-engineered from implementation)

## Existing Solutions Comparison

### Cross-Platform Libraries

| Solution | Language | Features | Complexity |
|----------|----------|----------|------------|
| csv (Python) | Python | Streaming, dialects | Medium |
| Papa Parse | JavaScript | Streaming, workers | Medium |
| FasterCSV/CSV | Ruby | Full-featured | Medium |
| CsvHelper | C# | Object mapping | High |
| OpenCSV | Java | Bean mapping | High |
| **simple_csv** | **Eiffel** | **MML models, DBC** | **Medium** |

### Design Approaches

**1. Streaming Parser**
- Processes row-by-row
- Memory efficient for large files
- Used by: Python csv, Papa Parse

**2. DOM-style Parser (simple_csv)**
- Loads entire CSV into memory
- Random access to rows/columns
- Simpler API

**3. Object Mapper**
- Maps rows to objects via reflection
- Type conversion
- Used by: CsvHelper, OpenCSV, simple_csv_mapper

### Unique Features of simple_csv

1. **MML (Mathematical Model Library) integration**
   - `rows_model`, `header_map_model`, `column_names_model`
   - Formal specification support

2. **Design by Contract**
   - Strong invariants
   - Preconditions on all inputs

3. **Excel compatibility built-in**
   - BOM support
   - sep= directive

4. **Multiple API surfaces**
   - Full-featured: SIMPLE_CSV
   - Simple: SIMPLE_CSV_QUICK
   - Reflection: SIMPLE_CSV_MAPPER
