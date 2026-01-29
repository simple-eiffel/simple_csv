# CSV-VALIDATE - Technical Design

## Architecture

### Component Overview

```
+----------------------------------------------------------+
|                    CSV-VALIDATE CLI                       |
+----------------------------------------------------------+
|  CLI Interface Layer                                      |
|    - Argument parsing (simple_cli)                        |
|    - Command routing (validate, schema-gen, version)      |
|    - Output formatting (text, json, csv, silent)          |
+----------------------------------------------------------+
|  Validation Engine Layer                                  |
|    - Schema loading and compilation                       |
|    - Rule execution pipeline                              |
|    - Error collection and aggregation                     |
+----------------------------------------------------------+
|  Rule Library                                             |
|    - Type validators (string, integer, decimal, date)     |
|    - Constraint validators (required, unique, range)      |
|    - Pattern validators (regex, enum, format)             |
|    - Custom validator support                             |
+----------------------------------------------------------+
|  Integration Layer                                        |
|    - simple_csv: CSV parsing                              |
|    - simple_json: Schema I/O                              |
|    - simple_validation: Rule engine                       |
|    - simple_file: File operations                         |
|    - simple_logger: Audit logging                         |
+----------------------------------------------------------+
```

### Class Design

| Class | Responsibility | Key Features |
|-------|----------------|--------------|
| CSV_VALIDATE_CLI | Command-line interface | parse_args, execute, format_output, set_exit_code |
| CSV_VALIDATE_ENGINE | Validation orchestrator | load_schema, validate_file, collect_errors |
| CSV_SCHEMA | Schema representation | columns, constraints, load_from_json, save_to_json |
| CSV_COLUMN_SPEC | Column definition | name, type, required, validators, default |
| CSV_VALIDATION_ERROR | Error representation | row, column, rule, message, severity |
| CSV_RULE | Base rule class | validate, error_message, severity |
| CSV_TYPE_RULE | Type checking | integer, decimal, date, boolean, string |
| CSV_CONSTRAINT_RULE | Constraint checking | required, unique, min, max, range |
| CSV_PATTERN_RULE | Pattern matching | regex, enum, email, url, phone |
| CSV_AUDIT_LOGGER | Audit trail | log_start, log_error, log_complete, export |
| CSV_SCHEMA_GENERATOR | Auto-detect schema | analyze_file, infer_types, generate_schema |

### Command Structure

```bash
csv-validate <command> [options] [arguments]

Commands:
  validate       Validate CSV file against schema
  schema-gen     Generate schema from CSV file (auto-detect)
  schema-show    Display schema in human-readable format
  version        Show version information

Validate Command:
  csv-validate validate <csv-file> --schema <schema-file> [options]

  Options:
    --schema, -s FILE      Schema file (JSON format)
    --output, -o FORMAT    Output format: text|json|csv|silent (default: text)
    --errors-only          Only output errors (no summary)
    --max-errors N         Stop after N errors (default: unlimited)
    --fail-fast            Stop on first error
    --delimiter CHAR       CSV delimiter (default: auto-detect)
    --audit-log FILE       Write audit log to file
    --exit-code            Exit 0=valid, 1=invalid, 2=error

Schema-Gen Command:
  csv-validate schema-gen <csv-file> [options]

  Options:
    --output, -o FILE      Output schema file (default: stdout)
    --sample-rows N        Rows to analyze (default: 1000)
    --strict               Infer stricter constraints

Global Options:
  --config FILE    Configuration file
  --quiet, -q      Suppress non-error output
  --verbose, -v    Verbose output
  --help, -h       Show help
  --version        Show version
```

### Schema Format (JSON)

```json
{
  "name": "customer_import",
  "version": "1.0",
  "description": "Customer data import schema",
  "delimiter": ",",
  "has_header": true,
  "columns": [
    {
      "name": "customer_id",
      "type": "integer",
      "required": true,
      "unique": true,
      "min": 1
    },
    {
      "name": "email",
      "type": "string",
      "required": true,
      "pattern": "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
    },
    {
      "name": "signup_date",
      "type": "date",
      "format": "YYYY-MM-DD",
      "required": false
    },
    {
      "name": "status",
      "type": "string",
      "enum": ["active", "inactive", "pending"]
    },
    {
      "name": "balance",
      "type": "decimal",
      "min": 0,
      "precision": 2
    }
  ],
  "constraints": {
    "min_rows": 1,
    "max_rows": 100000,
    "allow_extra_columns": false
  }
}
```

### Data Flow

```
Input CSV File
      |
      v
+------------------+
| Parse Arguments  |  <-- CLI layer
+------------------+
      |
      v
+------------------+
| Load Schema      |  <-- JSON -> CSV_SCHEMA
+------------------+
      |
      v
+------------------+
| Parse CSV        |  <-- simple_csv
+------------------+
      |
      v
+------------------+     +------------------+
| For Each Row     | --> | Apply Rules      |
+------------------+     +------------------+
      |                         |
      |                         v
      |                  +------------------+
      |                  | Collect Errors   |
      |                  +------------------+
      |                         |
      +<------------------------+
      |
      v
+------------------+
| Format Output    |  <-- text/json/csv
+------------------+
      |
      v
+------------------+
| Write Audit Log  |  <-- simple_logger
+------------------+
      |
      v
Exit Code (0=valid, 1=invalid, 2=error)
```

### Error Output Formats

**Text (human-readable):**
```
CSV-VALIDATE: customers.csv
Schema: customer_schema.json
Validated: 2026-01-24 14:30:00

ERRORS (3 found):

  Row 15, Column "email":
    Invalid email format: "not-an-email"
    Expected: valid email address

  Row 23, Column "customer_id":
    Duplicate value: 1042
    First occurrence: Row 8

  Row 45, Column "status":
    Invalid enum value: "deleted"
    Allowed values: active, inactive, pending

SUMMARY:
  Total rows: 100
  Valid rows: 97
  Invalid rows: 3
  Validation: FAILED
```

**JSON (machine-readable):**
```json
{
  "file": "customers.csv",
  "schema": "customer_schema.json",
  "timestamp": "2026-01-24T14:30:00Z",
  "valid": false,
  "summary": {
    "total_rows": 100,
    "valid_rows": 97,
    "invalid_rows": 3,
    "error_count": 3
  },
  "errors": [
    {
      "row": 15,
      "column": "email",
      "value": "not-an-email",
      "rule": "pattern",
      "message": "Invalid email format",
      "severity": "error"
    }
  ]
}
```

### Configuration File

```json
{
  "csv_validate": {
    "default_output": "text",
    "max_errors": 100,
    "audit_log": {
      "enabled": true,
      "path": "/var/log/csv-validate/",
      "retention_days": 90
    },
    "schemas_path": "/etc/csv-validate/schemas/",
    "delimiter_detection": true
  }
}
```

### Error Handling

| Error Type | Handling | User Message |
|------------|----------|--------------|
| File not found | Exit 2 | "Error: File not found: {path}" |
| Schema invalid | Exit 2 | "Error: Invalid schema: {details}" |
| CSV parse error | Exit 2 | "Error: Cannot parse CSV at line {n}: {details}" |
| Validation failure | Exit 1 | Summary with error details |
| Permission denied | Exit 2 | "Error: Permission denied: {path}" |
| Out of memory | Exit 2 | "Error: File too large. Use --max-rows to limit" |

## GUI/TUI Future Path

**CLI foundation enables:**

1. **TUI (simple_tui) additions:**
   - Interactive schema builder with field navigation
   - Real-time validation progress display
   - Error browser with row preview
   - Schema editor with syntax highlighting

2. **GUI (simple_gui) additions:**
   - Visual schema designer with drag-drop columns
   - File browser integration
   - Error highlighting in data preview
   - Batch validation queue management

3. **Shared components between CLI/GUI:**
   - CSV_VALIDATE_ENGINE (core validation)
   - CSV_SCHEMA (schema representation)
   - All rule classes (validation logic)
   - CSV_AUDIT_LOGGER (audit trail)

The CLI defines the API contract; GUI/TUI are presentation layers only.
