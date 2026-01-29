# CSV-RECONCILE - Technical Design

## Architecture

### Component Overview

```
+----------------------------------------------------------+
|                   CSV-RECONCILE CLI                       |
+----------------------------------------------------------+
|  CLI Interface Layer                                      |
|    - Argument parsing (simple_cli)                        |
|    - Command routing (compare, report, hash)              |
|    - Output formatting (text, json, csv, pdf)             |
+----------------------------------------------------------+
|  Reconciliation Engine Layer                              |
|    - File loading and normalization                       |
|    - Row matching by keys                                 |
|    - Field comparison with tolerance                      |
|    - Discrepancy classification                           |
+----------------------------------------------------------+
|  Matching Library                                         |
|    - Exact key matching                                   |
|    - Fuzzy text matching (Levenshtein, soundex)           |
|    - Numeric tolerance matching                           |
|    - Date tolerance matching                              |
+----------------------------------------------------------+
|  Reporting Layer                                          |
|    - Summary statistics                                   |
|    - Detailed discrepancy list                            |
|    - Audit trail generation                               |
+----------------------------------------------------------+
|  Integration Layer                                        |
|    - simple_csv: CSV parsing                              |
|    - simple_diff: Difference calculation                  |
|    - simple_json: JSON reports                            |
|    - simple_hash: Record fingerprinting                   |
|    - simple_logger: Audit logging                         |
|    - simple_pdf: PDF report generation                    |
+----------------------------------------------------------+
```

### Class Design

| Class | Responsibility | Key Features |
|-------|----------------|--------------|
| CSV_RECONCILE_CLI | Command-line interface | parse_args, execute, format_output |
| CSV_RECONCILE_ENGINE | Reconciliation orchestrator | load_files, match_rows, compare, report |
| CSV_RECONCILE_CONFIG | Comparison configuration | keys, fields, tolerances, options |
| CSV_ROW_MATCHER | Row matching engine | match_exact, match_fuzzy, score |
| CSV_FIELD_COMPARATOR | Field comparison | compare_string, compare_numeric, compare_date |
| CSV_DISCREPANCY | Individual difference | type, source_row, target_row, fields |
| CSV_RECONCILE_RESULT | Full comparison result | summary, discrepancies, matched, unmatched |
| CSV_RECONCILE_REPORT | Report generator | text_report, json_report, csv_report, pdf_report |
| CSV_AUDIT_TRAIL | Audit logging | log_comparison, log_discrepancy, export |

### Command Structure

```bash
csv-reconcile <command> [options] [arguments]

Commands:
  compare        Compare two CSV files
  report         Generate report from saved comparison
  hash           Generate hash fingerprint of CSV file
  schema         Show comparison configuration schema
  version        Show version information

Compare Command:
  csv-reconcile compare <source.csv> <target.csv> [options]

  Options:
    --config, -c FILE     Comparison configuration (JSON)
    --key, -k COLUMNS     Key column(s) for matching (comma-separated)
    --compare COLUMNS     Columns to compare (default: all)
    --ignore COLUMNS      Columns to ignore
    --output, -o FORMAT   Output format: text|json|csv|pdf (default: text)
    --report, -r FILE     Write report to file
    --tolerance N         Numeric tolerance (e.g., 0.01 for 1%)
    --date-tolerance N    Date tolerance in days
    --fuzzy               Enable fuzzy text matching
    --fuzzy-threshold N   Minimum similarity score (0-100, default: 80)
    --case-insensitive    Ignore case in text comparison
    --trim                Trim whitespace before comparison
    --audit-log FILE      Write audit trail to file
    --exit-code           Exit 0=match, 1=differences, 2=error

Hash Command:
  csv-reconcile hash <file.csv> [options]

  Options:
    --algorithm ALG       Hash algorithm: md5|sha256 (default: sha256)
    --key, -k COLUMNS     Hash only key columns
    --per-row             Output hash per row

Global Options:
    --config FILE         Configuration file
    --quiet, -q           Suppress non-error output
    --verbose, -v         Verbose output
    --help, -h            Show help
    --version             Show version
```

### Comparison Configuration (JSON)

```json
{
  "name": "customer_reconciliation",
  "description": "Monthly customer data reconciliation",
  "source": {
    "delimiter": ",",
    "has_header": true,
    "encoding": "utf-8"
  },
  "target": {
    "delimiter": ",",
    "has_header": true,
    "encoding": "utf-8"
  },
  "matching": {
    "keys": ["customer_id"],
    "fuzzy": false,
    "case_insensitive": true
  },
  "comparison": {
    "fields": ["name", "email", "balance", "status"],
    "ignore": ["updated_at", "created_at"],
    "tolerances": {
      "balance": {
        "type": "numeric",
        "value": 0.01,
        "mode": "percentage"
      },
      "created_date": {
        "type": "date",
        "days": 1
      }
    },
    "options": {
      "case_insensitive": true,
      "trim_whitespace": true,
      "null_equals_empty": true
    }
  },
  "reporting": {
    "format": "text",
    "include_matched": false,
    "max_discrepancies": 1000
  }
}
```

### Discrepancy Types

| Type | Description | Example |
|------|-------------|---------|
| SOURCE_ONLY | Row in source but not in target | Customer deleted from new system |
| TARGET_ONLY | Row in target but not in source | New customer added |
| FIELD_MISMATCH | Row matched but fields differ | Balance changed |
| KEY_DUPLICATE | Multiple rows with same key | Data quality issue |

### Data Flow

```
Source CSV          Target CSV
    |                   |
    v                   v
+------------------+  +------------------+
| Parse & Load     |  | Parse & Load     |
+------------------+  +------------------+
    |                   |
    v                   v
+------------------+  +------------------+
| Index by Key     |  | Index by Key     |
+------------------+  +------------------+
    |                   |
    +-------+   +-------+
            |   |
            v   v
      +------------------+
      | Match Rows       |
      | - Exact match    |
      | - Fuzzy match    |
      +------------------+
            |
            v
      +------------------+
      | Compare Fields   |
      | - By type        |
      | - With tolerance |
      +------------------+
            |
            v
      +------------------+
      | Classify         |
      | Discrepancies    |
      +------------------+
            |
            v
      +------------------+
      | Generate Report  |
      +------------------+
            |
            v
      Output (text/json/csv/pdf)
```

### Report Formats

**Text (human-readable):**
```
CSV-RECONCILE REPORT
====================
Generated: 2026-01-24 14:30:00

Source: customers_crm.csv (1,234 rows)
Target: customers_db.csv (1,230 rows)

SUMMARY
-------
Matched rows:        1,225 (99.3%)
Source only:             4 (0.3%)
Target only:             0 (0.0%)
Field mismatches:        5 (0.4%)

DISCREPANCIES
-------------

[SOURCE_ONLY] Key: customer_id=10042
  Row in source but not in target
  Source row: id=10042, name="John Doe", email="john@example.com"

[SOURCE_ONLY] Key: customer_id=10043
  Row in source but not in target
  Source row: id=10043, name="Jane Smith", email="jane@example.com"

[FIELD_MISMATCH] Key: customer_id=10001
  Column: balance
    Source: 1,234.56
    Target: 1,234.57
    Difference: 0.01 (within tolerance)

  Column: status
    Source: "active"
    Target: "Active"
    Note: Case difference (ignored)

[FIELD_MISMATCH] Key: customer_id=10015
  Column: email
    Source: "bob@oldmail.com"
    Target: "bob@newmail.com"

AUDIT
-----
Comparison hash: SHA256:abc123...
Source file hash: SHA256:def456...
Target file hash: SHA256:ghi789...
```

**JSON (machine-readable):**
```json
{
  "generated": "2026-01-24T14:30:00Z",
  "source": {
    "file": "customers_crm.csv",
    "rows": 1234,
    "hash": "sha256:def456..."
  },
  "target": {
    "file": "customers_db.csv",
    "rows": 1230,
    "hash": "sha256:ghi789..."
  },
  "summary": {
    "matched": 1225,
    "source_only": 4,
    "target_only": 0,
    "field_mismatch": 5,
    "match_rate": 99.3
  },
  "discrepancies": [
    {
      "type": "SOURCE_ONLY",
      "key": {"customer_id": "10042"},
      "source_row": {"id": "10042", "name": "John Doe"},
      "target_row": null
    },
    {
      "type": "FIELD_MISMATCH",
      "key": {"customer_id": "10015"},
      "fields": [
        {
          "column": "email",
          "source": "bob@oldmail.com",
          "target": "bob@newmail.com"
        }
      ]
    }
  ]
}
```

### Error Handling

| Error Type | Handling | User Message |
|------------|----------|--------------|
| File not found | Exit 2 | "Error: File not found: {path}" |
| Config invalid | Exit 2 | "Error: Invalid config: {details}" |
| Key column missing | Exit 2 | "Error: Key column '{col}' not found" |
| Duplicate keys | Warning | "Warning: Duplicate key in {file}: {key}" |
| Parse error | Exit 2 | "Error: Cannot parse {file} at line {n}" |
| Out of memory | Exit 2 | "Error: Files too large. Use --streaming mode" |

## GUI/TUI Future Path

**CLI foundation enables:**

1. **TUI (simple_tui) additions:**
   - Side-by-side diff viewer
   - Interactive discrepancy navigation
   - Key column selection with preview
   - Real-time match statistics

2. **GUI (simple_gui) additions:**
   - Visual file selection and preview
   - Column mapping interface
   - Discrepancy browser with filtering
   - Report export with customization

3. **Shared components between CLI/GUI:**
   - CSV_RECONCILE_ENGINE (core comparison)
   - CSV_ROW_MATCHER (matching logic)
   - CSV_FIELD_COMPARATOR (field comparison)
   - CSV_RECONCILE_RESULT (results model)
   - All report generators

The CLI defines the reconciliation semantics; GUI/TUI provide visualization.
