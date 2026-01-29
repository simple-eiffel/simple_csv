# CSV-VALIDATE - Build Plan

## Phase Overview

| Phase | Deliverable | Effort | Dependencies |
|-------|-------------|--------|--------------|
| Phase 1 | MVP CLI | 3-4 days | simple_csv, simple_json, simple_cli |
| Phase 2 | Full CLI | 4-5 days | Phase 1, simple_validation, simple_regex |
| Phase 3 | Production Polish | 2-3 days | Phase 2, simple_logger |

**Total Estimated Effort:** 9-12 days

---

## Phase 1: MVP

### Objective

Deliver a working CLI that validates CSV files against JSON schemas with basic type checking and required field validation. Users can run `csv-validate validate data.csv --schema schema.json` and get pass/fail output.

### Deliverables

1. **CSV_VALIDATE_CLI** - Command-line argument parsing and execution
2. **CSV_VALIDATE_ENGINE** - Core validation orchestrator
3. **CSV_SCHEMA** - JSON schema loader
4. **CSV_COLUMN_SPEC** - Column specification with type and required
5. **CSV_VALIDATION_RESULT** - Error collection and summary
6. **CSV_VALIDATION_ERROR** - Individual error representation

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T1.1 | Create project structure | ECF compiles, directories exist |
| T1.2 | Implement CSV_SCHEMA.load_from_json | Loads JSON schema with columns, types |
| T1.3 | Implement CSV_COLUMN_SPEC | Stores name, type, required flag |
| T1.4 | Implement CSV_VALIDATION_ERROR | Row, column, message storage |
| T1.5 | Implement CSV_VALIDATION_RESULT | Error list, summary stats |
| T1.6 | Implement CSV_VALIDATE_ENGINE.validate_file | Parses CSV, checks types, collects errors |
| T1.7 | Implement CSV_VALIDATE_CLI | Args parsing, text output, exit codes |
| T1.8 | Write MVP tests | Type validation, required fields |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Valid file | data.csv with matching schema | Exit 0, "Validation: PASSED" |
| Missing required | Row missing required field | Exit 1, error with row/column |
| Type mismatch | "abc" in integer column | Exit 1, error with expected type |
| File not found | Non-existent path | Exit 2, error message |
| Schema not found | Non-existent schema | Exit 2, error message |
| Extra columns | CSV has columns not in schema | Exit 0 (default allows) |

### MVP Schema Support

```json
{
  "name": "basic_schema",
  "columns": [
    {"name": "id", "type": "integer", "required": true},
    {"name": "name", "type": "string", "required": true},
    {"name": "value", "type": "decimal", "required": false}
  ]
}
```

**Supported types:** string, integer, decimal, boolean
**Supported constraints:** required (true/false)

---

## Phase 2: Full Implementation

### Objective

Extend MVP with complete validation rules, multiple output formats, schema auto-generation, and constraint validation (unique, min/max, patterns).

### Deliverables

1. **CSV_TYPE_RULE** - Extended type validators (date, email, etc.)
2. **CSV_CONSTRAINT_RULE** - min, max, range, unique validators
3. **CSV_PATTERN_RULE** - regex, enum validators
4. **CSV_SCHEMA_GENERATOR** - Auto-generate schema from CSV
5. **JSON output format** - Machine-readable validation results
6. **CSV output format** - Error list as CSV
7. **Schema show command** - Human-readable schema display

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T2.1 | Add date type validation | Validates YYYY-MM-DD format |
| T2.2 | Add enum constraint | Validates value in allowed list |
| T2.3 | Add unique constraint | Detects duplicate values in column |
| T2.4 | Add min/max constraints | Validates numeric ranges |
| T2.5 | Add pattern/regex constraint | Validates against regex pattern |
| T2.6 | Implement JSON output | --output json produces valid JSON |
| T2.7 | Implement CSV output | --output csv produces error CSV |
| T2.8 | Implement schema-gen command | Analyzes CSV, outputs schema |
| T2.9 | Implement schema-show command | Pretty-prints schema |
| T2.10 | Add --fail-fast option | Stops on first error |
| T2.11 | Add --max-errors option | Limits error collection |
| T2.12 | Write Phase 2 tests | All new validators, outputs |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Date valid | "2026-01-24" | Pass |
| Date invalid | "01-24-2026" | Fail, format error |
| Enum valid | "active" with enum: [active, inactive] | Pass |
| Enum invalid | "deleted" with enum: [active, inactive] | Fail, enum error |
| Unique pass | Distinct values in unique column | Pass |
| Unique fail | Duplicate value in unique column | Fail, duplicate error |
| Min pass | 50 with min: 10 | Pass |
| Min fail | 5 with min: 10 | Fail, range error |
| Pattern pass | "test@example.com" with email pattern | Pass |
| Pattern fail | "not-an-email" with email pattern | Fail, pattern error |
| JSON output | Any validation | Valid JSON with errors array |
| Schema-gen | Sample CSV | JSON schema with inferred types |

### Full Schema Support

```json
{
  "name": "full_schema",
  "version": "1.0",
  "delimiter": ",",
  "has_header": true,
  "columns": [
    {
      "name": "id",
      "type": "integer",
      "required": true,
      "unique": true,
      "min": 1
    },
    {
      "name": "email",
      "type": "string",
      "required": true,
      "pattern": "^[\\w.+-]+@[\\w.-]+\\.[a-zA-Z]{2,}$"
    },
    {
      "name": "created",
      "type": "date",
      "format": "YYYY-MM-DD"
    },
    {
      "name": "status",
      "type": "string",
      "enum": ["active", "inactive", "pending"]
    },
    {
      "name": "score",
      "type": "decimal",
      "min": 0,
      "max": 100
    }
  ],
  "constraints": {
    "allow_extra_columns": false
  }
}
```

---

## Phase 3: Production Polish

### Objective

Add audit logging, performance optimization, comprehensive error handling, documentation, and release packaging.

### Deliverables

1. **CSV_AUDIT_LOGGER** - Compliance-ready audit trail
2. **Configuration file support** - ~/.csv-validate.json
3. **Performance optimization** - Large file handling
4. **Error handling hardening** - Edge cases, corrupt files
5. **Documentation** - README, man page, examples
6. **Release packaging** - Windows installer, portable zip

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T3.1 | Implement CSV_AUDIT_LOGGER | Logs start, errors, complete |
| T3.2 | Add --audit-log option | Writes log to specified file |
| T3.3 | Add config file support | Reads ~/.csv-validate.json |
| T3.4 | Optimize for large files | 100K rows in <10 seconds |
| T3.5 | Handle corrupt CSV gracefully | Reports parse errors, continues |
| T3.6 | Handle encoding issues | UTF-8 BOM, detection |
| T3.7 | Write README.md | Installation, usage, examples |
| T3.8 | Create example schemas | Common use cases |
| T3.9 | Build Windows installer | INNO setup |
| T3.10 | Final test suite | Edge cases, stress tests |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Audit log | Any validation | Log file with timestamps |
| Large file | 100K row CSV | Completes in <10 seconds |
| Corrupt CSV | Malformed quotes | Parse error reported, partial validation |
| BOM handling | UTF-8 BOM file | Processes correctly |
| Config file | ~/.csv-validate.json | Applies settings |

---

## ECF Target Structure

```xml
<!-- Library target (reusable) -->
<target name="csv_validate">
    <description>Core validation library</description>
    <root all_classes="true"/>
    <cluster name="src" location=".\src\" recursive="true"/>
    <!-- Dependencies -->
</target>

<!-- CLI executable target -->
<target name="csv_validate_cli" extends="csv_validate">
    <description>Command-line tool</description>
    <root class="CSV_VALIDATE_CLI" feature="make"/>
    <setting name="executable_name" value="csv-validate"/>
</target>

<!-- Test target -->
<target name="csv_validate_tests" extends="csv_validate">
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
/d/prod/ec.sh -batch -config csv_validate.ecf -target csv_validate_cli -c_compile

# Run development build
./EIFGENs/csv_validate_cli/W_code/csv-validate.exe validate test.csv --schema test_schema.json

# Production build
/d/prod/ec.sh -batch -config csv_validate.ecf -target csv_validate_cli -finalize -c_compile

# Run tests
/d/prod/ec.sh -batch -config csv_validate.ecf -target csv_validate_tests -c_compile
./EIFGENs/csv_validate_tests/W_code/csv_validate.exe
```

---

## Success Criteria

| Criterion | Measure | Target |
|-----------|---------|--------|
| Compiles | Zero errors | 100% |
| Tests pass | All test cases | 100% |
| CLI works | All commands functional | Pass |
| Performance | 100K rows validation | <10 seconds |
| Documentation | README complete | Yes |
| Audit trail | Compliance-ready logs | Yes |

---

## Directory Structure

```
csv_validate/
├── csv_validate.ecf
├── README.md
├── CHANGELOG.md
├── src/
│   ├── csv_validate_cli.e
│   ├── csv_validate_engine.e
│   ├── csv_schema.e
│   ├── csv_column_spec.e
│   ├── csv_validation_result.e
│   ├── csv_validation_error.e
│   ├── csv_audit_logger.e
│   ├── csv_schema_generator.e
│   └── rules/
│       ├── csv_rule.e
│       ├── csv_type_rule.e
│       ├── csv_constraint_rule.e
│       └── csv_pattern_rule.e
├── tests/
│   ├── test_app.e
│   ├── csv_validate_tests.e
│   └── test_data/
│       ├── valid.csv
│       ├── invalid_types.csv
│       └── test_schema.json
├── examples/
│   ├── customer_schema.json
│   ├── product_schema.json
│   └── transaction_schema.json
└── docs/
    └── index.html
```
