# CSV-RECONCILE - Build Plan

## Phase Overview

| Phase | Deliverable | Effort | Dependencies |
|-------|-------------|--------|--------------|
| Phase 1 | MVP CLI | 4-5 days | simple_csv, simple_json, simple_diff, simple_cli |
| Phase 2 | Full CLI | 5-6 days | Phase 1, simple_hash, simple_datetime |
| Phase 3 | Production Polish | 3-4 days | Phase 2, simple_logger, simple_pdf |

**Total Estimated Effort:** 12-15 days

---

## Phase 1: MVP

### Objective

Deliver a working CLI that compares two CSV files by key column and reports discrepancies. Users can run `csv-reconcile compare source.csv target.csv --key id` and get a text report showing matched/unmatched rows and field differences.

### Deliverables

1. **CSV_RECONCILE_CLI** - Command-line argument parsing and execution
2. **CSV_RECONCILE_ENGINE** - Core comparison orchestrator
3. **CSV_RECONCILE_CONFIG** - Comparison configuration
4. **CSV_ROW_MATCHER** - Row matching by key
5. **CSV_FIELD_COMPARATOR** - Field-by-field comparison
6. **CSV_DISCREPANCY** - Individual difference representation
7. **CSV_RECONCILE_RESULT** - Comparison results with summary
8. **Text report output** - Human-readable discrepancy report

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T1.1 | Create project structure | ECF compiles, directories exist |
| T1.2 | Implement CSV_RECONCILE_CONFIG | Load key columns, comparison options |
| T1.3 | Implement CSV_ROW_MATCHER | Match rows by single key column |
| T1.4 | Implement CSV_FIELD_COMPARATOR | Compare string fields exactly |
| T1.5 | Implement CSV_DISCREPANCY | Store type, key, source, target |
| T1.6 | Implement CSV_RECONCILE_RESULT | Summary counts, discrepancy list |
| T1.7 | Implement CSV_RECONCILE_ENGINE | Load files, match, compare, report |
| T1.8 | Implement CSV_RECONCILE_CLI | Args parsing, text output |
| T1.9 | Implement text report generator | Human-readable output |
| T1.10 | Write MVP tests | Basic matching, discrepancy types |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Identical files | same.csv vs same.csv | 100% match, no discrepancies |
| Missing rows | source has row not in target | SOURCE_ONLY discrepancy |
| Extra rows | target has row not in source | TARGET_ONLY discrepancy |
| Changed field | Same key, different value | FIELD_MISMATCH discrepancy |
| Multiple discrepancies | Various differences | All listed in report |
| Key not found | Invalid --key column | Exit 2, error message |
| File not found | Non-existent path | Exit 2, error message |
| Exit codes | Comparison result | 0=match, 1=differences, 2=error |

### MVP Report Example

```
CSV-RECONCILE REPORT
====================
Source: source.csv (100 rows)
Target: target.csv (98 rows)

SUMMARY
-------
Matched:        95 (95.0%)
Source only:     3 (3.0%)
Target only:     1 (1.0%)
Mismatches:      2 (2.0%)

DISCREPANCIES
-------------
[SOURCE_ONLY] Key: id=105
  Row in source but not in target

[FIELD_MISMATCH] Key: id=42
  email: "old@example.com" -> "new@example.com"

Result: DIFFERENCES FOUND
```

---

## Phase 2: Full Implementation

### Objective

Add multiple key columns, numeric/date tolerances, fuzzy matching, JSON output, and hash verification.

### Deliverables

1. **Multiple key column support** - Composite keys
2. **CSV_NUMERIC_COMPARATOR** - Numeric comparison with tolerance
3. **CSV_DATE_COMPARATOR** - Date comparison with tolerance
4. **CSV_FUZZY_MATCHER** - Levenshtein distance matching
5. **JSON output format** - Machine-readable results
6. **CSV output format** - Discrepancies as CSV
7. **Hash command** - File/row fingerprinting
8. **Configuration file support** - JSON config files

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T2.1 | Support multiple key columns | --key "col1,col2" works |
| T2.2 | Implement numeric tolerance | --tolerance 0.01 compares within 1% |
| T2.3 | Implement date tolerance | --date-tolerance 1 allows 1 day diff |
| T2.4 | Implement fuzzy text matching | --fuzzy with threshold |
| T2.5 | Implement JSON output | --output json produces valid JSON |
| T2.6 | Implement CSV output | --output csv produces error CSV |
| T2.7 | Implement hash command | csv-reconcile hash file.csv |
| T2.8 | Implement config file loading | --config config.json |
| T2.9 | Add --ignore option | Skip specified columns |
| T2.10 | Add --compare option | Only compare specified columns |
| T2.11 | Write Phase 2 tests | Tolerances, fuzzy, outputs |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Composite key | --key "order_id,line" | Matches on both columns |
| Numeric tolerance pass | 100 vs 100.5 with tol=0.01 | Match (within 1%) |
| Numeric tolerance fail | 100 vs 110 with tol=0.01 | Mismatch |
| Date tolerance pass | 2026-01-24 vs 2026-01-25, tol=1 | Match |
| Date tolerance fail | 2026-01-24 vs 2026-01-26, tol=1 | Mismatch |
| Fuzzy match | "John Smith" vs "Jon Smith" | Match (similarity > threshold) |
| Fuzzy no match | "John" vs "Jane" | No match |
| JSON output | Any comparison | Valid JSON report |
| CSV output | Any comparison | CSV with discrepancies |
| Hash file | csv-reconcile hash data.csv | SHA256 hash output |
| Config file | --config recon.json | Settings applied |

### Configuration Schema

```json
{
  "matching": {
    "keys": ["order_id", "line_item"],
    "case_insensitive": true,
    "fuzzy": {
      "enabled": true,
      "threshold": 80,
      "columns": ["name", "address"]
    }
  },
  "comparison": {
    "fields": ["status", "amount", "date"],
    "ignore": ["updated_at"],
    "tolerances": {
      "amount": {"type": "percentage", "value": 0.01},
      "date": {"type": "days", "value": 1}
    }
  }
}
```

---

## Phase 3: Production Polish

### Objective

Add audit logging, PDF reports, performance optimization, comprehensive error handling, documentation, and release packaging.

### Deliverables

1. **CSV_AUDIT_TRAIL** - Compliance-ready audit logging
2. **PDF report generation** - Professional reports via simple_pdf
3. **Performance optimization** - Large file handling
4. **Streaming mode** - Memory-efficient comparison
5. **Documentation** - README, examples, man page
6. **Release packaging** - Windows installer, portable zip

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T3.1 | Implement CSV_AUDIT_TRAIL | Logs all operations |
| T3.2 | Add --audit-log option | Writes detailed audit log |
| T3.3 | Implement PDF report generator | --output pdf works |
| T3.4 | Optimize for large files | 100K rows in <30 seconds |
| T3.5 | Add streaming mode | Memory-efficient for huge files |
| T3.6 | Handle encoding issues | UTF-8 BOM, different encodings |
| T3.7 | Write README.md | Installation, usage, examples |
| T3.8 | Create example configs | Common reconciliation scenarios |
| T3.9 | Build Windows installer | INNO setup |
| T3.10 | Final test suite | Edge cases, stress tests |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Audit log | --audit-log audit.log | Complete audit trail |
| PDF report | --output pdf | Valid PDF file |
| Large files | 100K rows each | Completes in <30 seconds |
| Memory limit | 1M rows | Uses streaming, no OOM |
| BOM handling | UTF-8 BOM files | Processes correctly |

---

## ECF Target Structure

```xml
<!-- Library target (reusable) -->
<target name="csv_reconcile">
    <description>Core reconciliation library</description>
    <root all_classes="true"/>
    <cluster name="src" location=".\src\" recursive="true"/>
    <!-- Dependencies -->
</target>

<!-- CLI executable target -->
<target name="csv_reconcile_cli" extends="csv_reconcile">
    <description>Command-line tool</description>
    <root class="CSV_RECONCILE_CLI" feature="make"/>
    <setting name="executable_name" value="csv-reconcile"/>
</target>

<!-- Test target -->
<target name="csv_reconcile_tests" extends="csv_reconcile">
    <description>Test suite</description>
    <root class="TEST_APP" feature="make"/>
    <library name="simple_testing" location="$SIMPLE_EIFFEL\simple_testing\simple_testing.ecf"/>
    <cluster name="tests" location=".\tests\"/>
</target>
```

---

## Build Commands

```bash
# Development build
/d/prod/ec.sh -batch -config csv_reconcile.ecf -target csv_reconcile_cli -c_compile

# Run development build
./EIFGENs/csv_reconcile_cli/W_code/csv-reconcile.exe compare source.csv target.csv --key id

# Production build
/d/prod/ec.sh -batch -config csv_reconcile.ecf -target csv_reconcile_cli -finalize -c_compile

# Run tests
/d/prod/ec.sh -batch -config csv_reconcile.ecf -target csv_reconcile_tests -c_compile
./EIFGENs/csv_reconcile_tests/W_code/csv_reconcile.exe
```

---

## Success Criteria

| Criterion | Measure | Target |
|-----------|---------|--------|
| Compiles | Zero errors | 100% |
| Tests pass | All test cases | 100% |
| CLI works | All commands functional | Pass |
| Performance | 100K row comparison | <30 seconds |
| Match accuracy | Known test data | 99.9% |
| Audit trail | Compliance-ready | Yes |
| Documentation | README complete | Yes |

---

## Directory Structure

```
csv_reconcile/
├── csv_reconcile.ecf
├── README.md
├── CHANGELOG.md
├── src/
│   ├── csv_reconcile_cli.e
│   ├── csv_reconcile_engine.e
│   ├── csv_reconcile_config.e
│   ├── csv_reconcile_result.e
│   ├── csv_discrepancy.e
│   ├── csv_audit_trail.e
│   ├── matching/
│   │   ├── csv_row_matcher.e
│   │   ├── csv_exact_matcher.e
│   │   └── csv_fuzzy_matcher.e
│   ├── comparison/
│   │   ├── csv_field_comparator.e
│   │   ├── csv_string_comparator.e
│   │   ├── csv_numeric_comparator.e
│   │   └── csv_date_comparator.e
│   └── reporting/
│       ├── csv_reconcile_report.e
│       ├── csv_text_report.e
│       ├── csv_json_report.e
│       ├── csv_csv_report.e
│       └── csv_pdf_report.e
├── tests/
│   ├── test_app.e
│   ├── csv_reconcile_tests.e
│   └── test_data/
│       ├── identical_a.csv
│       ├── identical_b.csv
│       ├── missing_rows.csv
│       ├── changed_fields.csv
│       └── configs/
│           └── test_config.json
├── examples/
│   ├── customer_reconciliation.json
│   ├── financial_audit.json
│   ├── migration_validation.json
│   └── README.md
└── docs/
    └── index.html
```

---

## Use Case Examples

### Monthly Financial Reconciliation

```bash
# Compare general ledger exports
csv-reconcile compare gl_system_a.csv gl_system_b.csv \
    --key "account,period" \
    --compare "debit,credit,balance" \
    --tolerance 0.01 \
    --audit-log /var/log/reconcile/gl_$(date +%Y%m).log \
    --report /reports/gl_reconciliation_$(date +%Y%m).pdf \
    --output pdf
```

### Database Migration Validation

```bash
# Verify all customers migrated correctly
csv-reconcile compare legacy_customers.csv new_customers.csv \
    --key customer_id \
    --ignore "created_at,updated_at,internal_id" \
    --case-insensitive \
    --trim \
    --output json > migration_result.json

# Check exit code for CI/CD
if [ $? -ne 0 ]; then
    echo "Migration validation failed!"
    exit 1
fi
```

### CRM Data Sync Verification

```bash
# Weekly sync verification
csv-reconcile compare salesforce_export.csv hubspot_export.csv \
    --key email \
    --compare "name,company,phone" \
    --fuzzy \
    --fuzzy-threshold 85 \
    --report sync_report.csv \
    --output csv
```
