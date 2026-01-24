# S03: CONTRACTS

**Library:** simple_csv
**Date:** 2026-01-23
**Status:** BACKWASH (reverse-engineered from implementation)

## Class Invariants

### SIMPLE_CSV

```eiffel
invariant
    rows_exist: rows /= Void
    header_map_exists: header_map /= Void
    valid_delimiter: delimiter /= '%N' and delimiter /= '%R'
    valid_quote_char: quote_char /= '%N' and quote_char /= '%R'
    delimiter_not_quote: delimiter /= quote_char
    parse_errors_exist: parse_errors /= Void
```

### SIMPLE_CSV_QUICK

```eiffel
invariant
    csv_exists: csv /= Void
```

## Key Feature Contracts

### make_with_delimiter

```eiffel
require
    valid_delimiter: a_delimiter /= '%N' and a_delimiter /= '%R'
ensure
    delimiter_set: delimiter = a_delimiter
```

### parse (SIMPLE_CSV)

```eiffel
ensure
    header_mode_unchanged: has_header = old has_header
    header_map_built: (has_header and rows.count > 0) implies
                      header_map.count = rows.first.count
    model_consistent: rows_model.count = rows.count
```

### field/cell/value_at

```eiffel
require
    valid_row: a_row >= 1 and a_row <= row_count
    valid_column: a_column >= 1 and a_column <= column_count
```

### field_by_name

```eiffel
require
    has_header: has_header
    valid_row: a_row >= 1 and a_row <= row_count
    valid_column_name: has_column (a_column_name)
```

### row_count

```eiffel
ensure
    non_negative: Result >= 0
    model_consistent: Result = data_rows_model.count
```

### column_index

```eiffel
require
    has_column: has_column (a_name)
ensure
    valid_lower_bound: Result >= 1
    valid_upper_bound: Result <= column_count
    model_consistent: Result = header_map_model [a_name.as_lower]
```

## MML Model Postconditions

```eiffel
-- rows_model
ensure
    count_matches: Result.count = rows.count

-- header_map_model
ensure
    count_matches: Result.count = header_map.count
```
