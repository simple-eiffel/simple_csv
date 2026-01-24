# S02: CLASS CATALOG

**Library:** simple_csv
**Date:** 2026-01-23
**Status:** BACKWASH (reverse-engineered from implementation)

## Class Overview

| Class | Purpose | LOC |
|-------|---------|-----|
| SIMPLE_CSV | Full-featured CSV parsing/generation | 963 |
| SIMPLE_CSV_QUICK | Zero-configuration facade | 266 |
| SIMPLE_CSV_MAPPER | Object-to-CSV reflection mapping | 254 |

## SIMPLE_CSV

### Description
RFC 4180 compliant CSV parser and generator with Excel compatibility.

### Creation Procedures
| Name | Purpose |
|------|---------|
| make | Default (comma delimiter) |
| make_with_header | Expect first row as header |
| make_with_delimiter | Custom delimiter |

### Feature Groups

**Parsing:** parse/load/from_string, parse_file/load_file/read_file/from_file
**Access:** field/cell/value_at, field_by_name, row/get_row/row_at, column, column_by_name, headers
**Null Handling:** set_null_representation, is_null, is_null_by_name
**Iteration:** start_iteration, next_row, current_row, current_field
**Query:** has_column, column_index, is_empty, row_count, column_count
**Generation:** to_csv/as_string/render/generate, to_csv_with_bom, to_csv_excel
**Settings:** delimiter, quote_char, has_header, set_delimiter
**Lenient Mode:** lenient_mode, set_lenient_mode, parse_errors
**BOM/Encoding:** has_bom, strip_bom, detect_encoding, is_valid_utf8
**MML Models:** rows_model, header_map_model, data_rows_model, column_names_model

## SIMPLE_CSV_QUICK

### Description
One-liner CSV operations for beginners.

### Features
- read, read_with_headers, parse
- write, write_with_headers, to_csv
- set_delimiter, use_tabs, use_semicolons
- row, rows_from_arrays, column

## SIMPLE_CSV_MAPPER

### Description
Reflection-based object-to-CSV conversion.

### Features
- objects_to_csv, object_to_row
- csv_to_objects, row_to_object
- snake_case_headers setting
