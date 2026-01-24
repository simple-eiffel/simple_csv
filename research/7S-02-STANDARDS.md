# 7S-02: STANDARDS


**Date**: 2026-01-23

**Library:** simple_csv
**Date:** 2026-01-23
**Status:** BACKWASH (reverse-engineered from implementation)

## Applicable Standards

### Primary Standard

**RFC 4180 - Common Format and MIME Type for CSV Files**
- URL: https://datatracker.ietf.org/doc/html/rfc4180
- Status: Informational RFC
- Published: October 2005

### Key RFC 4180 Rules

1. Each record on a separate line (CRLF)
2. Optional header record
3. Each record has the same number of fields
4. Fields separated by comma
5. Fields MAY be enclosed in double quotes
6. Fields containing commas, double quotes, or line breaks MUST be enclosed in double quotes
7. Double quotes within fields escaped by doubling (")

### Excel Conventions (De Facto Standards)

**UTF-8 BOM (Byte Order Mark)**
- Bytes: EF BB BF
- Purpose: Signals UTF-8 encoding to Excel
- Required for non-ASCII character support

**sep= Directive**
- Format: `sep=<char>` on first line
- Purpose: Tells Excel which delimiter to use
- Common for European locales (semicolon)

### MIME Type

`text/csv` with optional parameters:
- `charset=UTF-8`
- `header=present` or `header=absent`

## Implementation Compliance

| RFC Rule | Implemented |
|----------|-------------|
| CRLF line endings | Yes (also LF) |
| Optional header | Yes |
| Quoted fields | Yes |
| Escaped quotes | Yes |
| Custom delimiter | Yes (extension) |
| BOM support | Yes (extension) |
| sep= directive | Yes (extension) |
