# S04: FEATURE SPECIFICATIONS

**Library:** simple_csv
**Date:** 2026-01-23
**Status:** BACKWASH (reverse-engineered from implementation)

## Parsing Features

### parse / load / from_string
**Signature:** `parse (a_input: STRING)`
**Purpose:** Parse CSV data from string
**Behavior:**
1. Strip UTF-8 BOM if present
2. Handle Excel sep= directive
3. Normalize line endings (CRLF -> LF)
4. Parse fields handling quotes
5. Build header map if has_header

### parse_file / load_file / read_file / from_file
**Signature:** `parse_file (a_path: STRING)`
**Purpose:** Parse CSV from file
**Behavior:**
1. Open and read file
2. Call parse with content

## Access Features

### field / cell / value_at
**Signature:** `field (a_row, a_column: INTEGER): STRING`
**Purpose:** Get field by row/column (1-based)
**Note:** Row 1 is first data row (after header if present)

### field_by_name
**Signature:** `field_by_name (a_row: INTEGER; a_column_name: STRING): STRING`
**Purpose:** Get field by row and column name
**Requires:** has_header = True

### column
**Signature:** `column (a_column: INTEGER): ARRAYED_LIST [STRING]`
**Purpose:** Get all values in a column

## Generation Features

### to_csv / as_string / render / generate
**Signature:** `to_csv: STRING`
**Purpose:** Generate CSV string from data

### to_csv_with_bom
**Signature:** `to_csv_with_bom: STRING`
**Purpose:** Generate CSV with UTF-8 BOM for Excel

### to_csv_excel
**Signature:** `to_csv_excel: STRING`
**Purpose:** Generate with sep= directive and BOM

## Iteration Features

### start_iteration
**Purpose:** Begin row-by-row iteration

### next_row
**Signature:** `next_row: BOOLEAN`
**Purpose:** Advance to next row, return True if row exists

### current_row
**Signature:** `current_row: ARRAYED_LIST [STRING]`
**Purpose:** Get current iteration row

## Null Value Features

### set_null_representation
**Signature:** `set_null_representation (a_null: detachable STRING)`
**Purpose:** Define what string represents null

### is_null
**Signature:** `is_null (a_row, a_column: INTEGER): BOOLEAN`
**Purpose:** Check if field is null
