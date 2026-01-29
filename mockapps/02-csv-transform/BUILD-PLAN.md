# CSV-TRANSFORM - Build Plan

## Phase Overview

| Phase | Deliverable | Effort | Dependencies |
|-------|-------------|--------|--------------|
| Phase 1 | MVP CLI | 4-5 days | simple_csv, simple_json, simple_cli |
| Phase 2 | Full CLI | 5-6 days | Phase 1, simple_regex, simple_template |
| Phase 3 | Production Polish | 3-4 days | Phase 2, simple_datetime |

**Total Estimated Effort:** 12-15 days

---

## Phase 1: MVP

### Objective

Deliver a working CLI that transforms CSV files using basic operations. Users can run single operations inline or define simple pipelines in JSON. Core operations: filter, select, rename, sort.

### Deliverables

1. **CSV_TRANSFORM_CLI** - Command-line argument parsing and execution
2. **CSV_PIPELINE** - Pipeline loader and executor
3. **CSV_PIPELINE_CONTEXT** - Execution state (rows, headers)
4. **CSV_OPERATION** - Base class for all operations
5. **CSV_FILTER_OP** - Row filtering with simple conditions
6. **CSV_SELECT_OP** - Column selection
7. **CSV_RENAME_OP** - Column renaming
8. **CSV_SORT_OP** - Row sorting

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T1.1 | Create project structure | ECF compiles, directories exist |
| T1.2 | Implement CSV_PIPELINE_CONTEXT | Stores rows, headers, column lookup |
| T1.3 | Implement CSV_OPERATION base class | Abstract execute method, config loading |
| T1.4 | Implement CSV_FILTER_OP | Filters on equality conditions |
| T1.5 | Implement CSV_SELECT_OP | Keeps specified columns only |
| T1.6 | Implement CSV_RENAME_OP | Renames columns via mapping |
| T1.7 | Implement CSV_SORT_OP | Sorts by column asc/desc |
| T1.8 | Implement CSV_PIPELINE | Loads JSON, executes operations |
| T1.9 | Implement CSV_TRANSFORM_CLI | Args, single-op mode, pipeline mode |
| T1.10 | Write MVP tests | Each operation, pipeline execution |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Filter equality | filter where status="active" | Only active rows |
| Select columns | select name,email | Only those columns |
| Rename column | rename id -> customer_id | Column renamed |
| Sort ascending | sort by name asc | Alphabetical order |
| Sort descending | sort by amount desc | Largest first |
| Pipeline 2 ops | filter then select | Both applied in order |
| Pipeline 4 ops | filter, select, rename, sort | All applied |
| Stdout output | No -O flag | Output to stdout |
| File output | -O result.csv | Written to file |

### MVP Pipeline Example

```json
{
  "name": "basic_filter_sort",
  "operations": [
    {
      "op": "filter",
      "where": "status = 'active'"
    },
    {
      "op": "select",
      "columns": ["id", "name", "email"]
    },
    {
      "op": "sort",
      "by": "name",
      "order": "asc"
    }
  ]
}
```

---

## Phase 2: Full Implementation

### Objective

Add advanced operations: derive (calculated columns), format, aggregate (group_by), unique, head/tail, grep. Add JSON output format and expression evaluation.

### Deliverables

1. **CSV_DERIVE_OP** - Create calculated columns
2. **CSV_FORMAT_OP** - Format column values
3. **CSV_GROUP_OP** - Group by with aggregations
4. **CSV_UNIQUE_OP** - Remove duplicates
5. **CSV_HEAD_OP / CSV_TAIL_OP** - First/last N rows
6. **CSV_GREP_OP** - Regex filtering
7. **CSV_EXPRESSION** - Expression parser and evaluator
8. **JSON output format** - Output as JSON array
9. **Template output format** - Custom output templates

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T2.1 | Implement CSV_EXPRESSION | Parses and evaluates conditions |
| T2.2 | Implement CSV_DERIVE_OP | Creates columns from expressions |
| T2.3 | Implement CSV_FORMAT_OP | Applies format patterns |
| T2.4 | Implement CSV_GROUP_OP | Groups and aggregates |
| T2.5 | Implement CSV_UNIQUE_OP | Removes duplicates |
| T2.6 | Implement CSV_HEAD_OP | First N rows |
| T2.7 | Implement CSV_TAIL_OP | Last N rows |
| T2.8 | Implement CSV_GREP_OP | Regex row filtering |
| T2.9 | Add JSON output format | --format json |
| T2.10 | Add template output | --format template |
| T2.11 | Implement ops command | List available operations |
| T2.12 | Implement validate command | Validate pipeline without running |
| T2.13 | Write Phase 2 tests | All new operations |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Derive concat | derive full_name = "{first} {last}" | New column with concatenation |
| Derive math | derive total = "{qty} * {price}" | Calculated values |
| Format phone | format phone "+1-XXX-XXX-XXXX" | Formatted phone numbers |
| Group by sum | group by region, sum(sales) | Aggregated by region |
| Group by count | group by status, count() | Count per status |
| Unique by email | unique by email | No duplicate emails |
| Head 10 | head 10 | First 10 rows |
| Tail 10 | tail 10 | Last 10 rows |
| Grep email | grep email "@gmail.com" | Rows with gmail |
| JSON output | --format json | Valid JSON array |
| Template output | --format template | Custom formatted |

### Expression Grammar

```
condition  := comparison | condition 'AND' condition | condition 'OR' condition | 'NOT' condition | '(' condition ')'
comparison := column_ref operator value
column_ref := identifier
operator   := '=' | '!=' | '>' | '>=' | '<' | '<=' | '~' | 'in' | 'is' | 'is not'
value      := string | number | array | 'empty'
string     := '"' characters '"' | "'" characters "'"
number     := integer | decimal
array      := '[' value (',' value)* ']'

expression := term | expression '+' term | expression '-' term | expression '||' term
term       := factor | term '*' factor | term '/' factor
factor     := column_ref | literal | function_call | '{' column_ref '}'
function_call := identifier '(' expression (',' expression)* ')'
```

---

## Phase 3: Production Polish

### Objective

Add join operations, streaming for large files, comprehensive error handling, documentation, and release packaging.

### Deliverables

1. **CSV_LOOKUP_OP** - Lookup values from another file
2. **CSV_MERGE_OP** - Join two CSV files
3. **CSV_UNION_OP** - Concatenate CSV files
4. **Streaming mode** - Process large files without full memory load
5. **Configuration file** - ~/.csv-transform.json
6. **Documentation** - README, examples, man page
7. **Release packaging** - Windows installer, portable zip

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T3.1 | Implement CSV_LOOKUP_OP | Lookups from second file |
| T3.2 | Implement CSV_MERGE_OP | Left/right/inner/outer joins |
| T3.3 | Implement CSV_UNION_OP | Concatenate multiple files |
| T3.4 | Add stdin support | Read from pipe |
| T3.5 | Optimize for large files | 1M rows without memory issues |
| T3.6 | Add config file support | ~/.csv-transform.json |
| T3.7 | Write README.md | Installation, usage, examples |
| T3.8 | Create example pipelines | Common use cases |
| T3.9 | Build Windows installer | INNO setup |
| T3.10 | Final test suite | Integration tests |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Lookup | orders.csv + products.csv | Orders with product names |
| Merge inner | customers.csv + orders.csv | Matched rows only |
| Merge left | customers.csv + orders.csv | All customers, matched orders |
| Union | q1.csv + q2.csv + q3.csv | All rows combined |
| Stdin | echo "..." \| csv-transform - | Process piped input |
| Large file | 1M row CSV | Completes without OOM |
| Config | ~/.csv-transform.json | Settings applied |

---

## ECF Target Structure

```xml
<!-- Library target (reusable) -->
<target name="csv_transform">
    <description>Core transformation library</description>
    <root all_classes="true"/>
    <cluster name="src" location=".\src\" recursive="true"/>
    <!-- Dependencies -->
</target>

<!-- CLI executable target -->
<target name="csv_transform_cli" extends="csv_transform">
    <description>Command-line tool</description>
    <root class="CSV_TRANSFORM_CLI" feature="make"/>
    <setting name="executable_name" value="csv-transform"/>
</target>

<!-- Test target -->
<target name="csv_transform_tests" extends="csv_transform">
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
/d/prod/ec.sh -batch -config csv_transform.ecf -target csv_transform_cli -c_compile

# Run development build
./EIFGENs/csv_transform_cli/W_code/csv-transform.exe transform test.csv --op filter --where "status='active'"

# Production build
/d/prod/ec.sh -batch -config csv_transform.ecf -target csv_transform_cli -finalize -c_compile

# Run tests
/d/prod/ec.sh -batch -config csv_transform.ecf -target csv_transform_tests -c_compile
./EIFGENs/csv_transform_tests/W_code/csv_transform.exe
```

---

## Success Criteria

| Criterion | Measure | Target |
|-----------|---------|--------|
| Compiles | Zero errors | 100% |
| Tests pass | All test cases | 100% |
| CLI works | All commands functional | Pass |
| Performance | 50K rows/second throughput | Measured |
| Operations | Built-in operations count | 20+ |
| Documentation | README complete | Yes |

---

## Directory Structure

```
csv_transform/
├── csv_transform.ecf
├── README.md
├── CHANGELOG.md
├── src/
│   ├── csv_transform_cli.e
│   ├── csv_pipeline.e
│   ├── csv_pipeline_context.e
│   ├── csv_expression.e
│   ├── csv_output_formatter.e
│   └── operations/
│       ├── csv_operation.e
│       ├── csv_filter_op.e
│       ├── csv_select_op.e
│       ├── csv_rename_op.e
│       ├── csv_derive_op.e
│       ├── csv_format_op.e
│       ├── csv_sort_op.e
│       ├── csv_unique_op.e
│       ├── csv_head_op.e
│       ├── csv_tail_op.e
│       ├── csv_grep_op.e
│       ├── csv_group_op.e
│       ├── csv_lookup_op.e
│       ├── csv_merge_op.e
│       └── csv_union_op.e
├── tests/
│   ├── test_app.e
│   ├── csv_transform_tests.e
│   └── test_data/
│       ├── sample.csv
│       ├── customers.csv
│       ├── orders.csv
│       └── pipelines/
│           ├── filter_sort.json
│           └── aggregate.json
├── examples/
│   ├── clean_contacts.json
│   ├── aggregate_sales.json
│   ├── join_orders.json
│   └── README.md
└── docs/
    └── index.html
```
