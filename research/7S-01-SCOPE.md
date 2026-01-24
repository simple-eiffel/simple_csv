# 7S-01: SCOPE


**Date**: 2026-01-23

**Library:** simple_csv
**Date:** 2026-01-23
**Status:** BACKWASH (reverse-engineered from implementation)

## Problem Domain

CSV (Comma-Separated Values) is a ubiquitous data interchange format used for:
- Data import/export between applications
- Spreadsheet data storage
- Database exports
- Log file formats
- Configuration files

Despite its simplicity, CSV has edge cases (quoted fields, embedded delimiters, newlines within fields) that require careful handling.

## Target Users

1. **Data Processing Applications** - Importing/exporting tabular data
2. **Report Generators** - Creating CSV output for Excel/spreadsheet users
3. **ETL Pipelines** - Data transformation workflows
4. **Configuration Tools** - Reading CSV configuration files

## Boundaries

### In Scope
- RFC 4180 compliant CSV parsing
- Quoted field handling (embedded commas, quotes, newlines)
- Custom delimiters (comma, tab, semicolon)
- Header row handling
- UTF-8 BOM support (Excel compatibility)
- Excel sep= directive support
- CSV generation from data
- Row-by-row iteration
- Null value handling
- Object-to-CSV mapping via reflection
- Lenient parsing mode with error collection

### Out of Scope
- Fixed-width file parsing
- XML/JSON conversion
- Database connectivity
- Large file streaming (memory-constrained)
- Compression handling

## Key Capabilities

1. **Multiple API levels:**
   - SIMPLE_CSV - Full-featured CSV class
   - SIMPLE_CSV_QUICK - Zero-configuration facade
   - SIMPLE_CSV_MAPPER - Object reflection mapping

2. **Excel compatibility:**
   - UTF-8 BOM support
   - sep= directive handling

3. **Flexible access:**
   - By row/column index
   - By column name
   - Row iteration
