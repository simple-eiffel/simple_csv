# 7S-05: SECURITY

**Library:** simple_csv
**Date:** 2026-01-23
**Status:** BACKWASH (reverse-engineered from implementation)

## Security Considerations

### CSV Injection (Formula Injection)

**Risk:** CSV files opened in Excel can execute formulas
```
=cmd|' /C calc'!A0
@SUM(1+1)*cmd|' /C calc'!A0
```

**Status:** NOT directly handled - application responsibility

**Recommendation:** Sanitize data before export if opening in spreadsheet:
- Prefix cells starting with =, @, +, - with apostrophe

### Memory Exhaustion

**Risk:** Large CSV files loaded entirely into memory

**Mitigation:**
- Row iteration API allows streaming patterns
- Application should validate file size before parsing

### Path Traversal

**Risk:** File path injection via parse_file

**Mitigation:**
- Precondition: path_not_empty
- Application responsibility to validate paths

### Encoding Attacks

**Risk:** Invalid UTF-8 sequences

**Mitigation:**
- `is_valid_utf8` validation available
- `detect_encoding` for charset detection
- BOM stripping prevents encoding confusion

## Data Validation

| Aspect | Handling |
|--------|----------|
| Column count mismatch | Lenient mode collects errors |
| Missing fields | Returns empty string |
| Null values | Configurable null_representation |
| Quote escaping | RFC 4180 compliant |

## Recommended Practices

1. **Validate file size** before parsing large files
2. **Use lenient mode** for untrusted input
3. **Sanitize formulas** before Excel export
4. **Validate paths** in application code
5. **Check encoding** for non-ASCII data
