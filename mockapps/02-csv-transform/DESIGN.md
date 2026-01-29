# CSV-TRANSFORM - Technical Design

## Architecture

### Component Overview

```
+----------------------------------------------------------+
|                   CSV-TRANSFORM CLI                       |
+----------------------------------------------------------+
|  CLI Interface Layer                                      |
|    - Argument parsing (simple_cli)                        |
|    - Command routing (transform, pipeline, ops)           |
|    - Output formatting (csv, json, tsv, template)         |
+----------------------------------------------------------+
|  Pipeline Engine Layer                                    |
|    - Pipeline loading and validation                      |
|    - Operation sequencing                                 |
|    - Row-by-row processing                                |
+----------------------------------------------------------+
|  Operations Library                                       |
|    - Filter operations (where, grep, head, tail)          |
|    - Transform operations (map, rename, derive, format)   |
|    - Aggregate operations (group, sum, count, avg)        |
|    - Join operations (merge, lookup)                      |
|    - Sort operations (sort, reverse, shuffle)             |
+----------------------------------------------------------+
|  Integration Layer                                        |
|    - simple_csv: CSV parsing/generation                   |
|    - simple_json: Pipeline config, JSON output            |
|    - simple_regex: Pattern matching in filters            |
|    - simple_template: Output formatting                   |
|    - simple_file: Multi-file operations                   |
|    - simple_datetime: Date transformations                |
+----------------------------------------------------------+
```

### Class Design

| Class | Responsibility | Key Features |
|-------|----------------|--------------|
| CSV_TRANSFORM_CLI | Command-line interface | parse_args, execute, format_output |
| CSV_PIPELINE | Pipeline orchestrator | load, validate, execute, chain |
| CSV_PIPELINE_CONTEXT | Execution context | rows, headers, variables, stats |
| CSV_OPERATION | Base operation class | execute, validate_config |
| CSV_FILTER_OP | Row filtering | where, grep, head, tail, sample |
| CSV_MAP_OP | Field transformation | rename, derive, format, convert |
| CSV_AGGREGATE_OP | Aggregation | group_by, sum, count, avg, min, max |
| CSV_JOIN_OP | Multi-file operations | merge, lookup, union |
| CSV_SORT_OP | Ordering | sort, reverse, shuffle, unique |
| CSV_OUTPUT_FORMATTER | Output generation | csv, json, tsv, template |

### Command Structure

```bash
csv-transform <command> [options] [arguments]

Commands:
  transform      Apply pipeline to CSV file
  run            Same as transform (alias)
  ops            List available operations
  validate       Validate pipeline configuration
  version        Show version information

Transform Command:
  csv-transform transform <csv-file> --pipeline <pipeline-file> [options]
  csv-transform transform <csv-file> --op <operation> [op-options]

  Options:
    --pipeline, -p FILE   Pipeline configuration file (JSON)
    --op, -o OPERATION    Single operation (inline mode)
    --output, -O FILE     Output file (default: stdout)
    --format, -f FORMAT   Output format: csv|json|tsv|template (default: csv)
    --template, -t FILE   Template file (for format=template)
    --delimiter, -d CHAR  CSV delimiter (default: comma)
    --no-header           Input has no header row
    --quiet, -q           Suppress progress output

Single Operation Mode:
  csv-transform transform data.csv --op filter --where "status=active"
  csv-transform transform data.csv --op select --columns "name,email"
  csv-transform transform data.csv --op sort --by "created_at" --desc
  csv-transform transform data.csv --op derive --name "full_name" --expr "{first} {last}"

Global Options:
  --config FILE    Configuration file
  --verbose, -v    Verbose output
  --help, -h       Show help
  --version        Show version
```

### Pipeline Configuration (JSON)

```json
{
  "name": "clean_contacts",
  "description": "Clean and format contact list for CRM import",
  "input": {
    "delimiter": ",",
    "has_header": true
  },
  "output": {
    "format": "csv",
    "delimiter": ","
  },
  "operations": [
    {
      "op": "filter",
      "where": "email != ''"
    },
    {
      "op": "select",
      "columns": ["first_name", "last_name", "email", "phone", "company"]
    },
    {
      "op": "rename",
      "mapping": {
        "first_name": "FirstName",
        "last_name": "LastName"
      }
    },
    {
      "op": "derive",
      "name": "FullName",
      "expression": "{FirstName} {LastName}"
    },
    {
      "op": "format",
      "column": "phone",
      "pattern": "+1-XXX-XXX-XXXX"
    },
    {
      "op": "unique",
      "by": "email"
    },
    {
      "op": "sort",
      "by": "LastName",
      "order": "asc"
    }
  ]
}
```

### Available Operations

**Filter Operations:**

| Operation | Description | Parameters |
|-----------|-------------|------------|
| filter / where | Keep rows matching condition | condition (expr) |
| grep | Keep rows matching regex | column, pattern |
| head | Keep first N rows | count |
| tail | Keep last N rows | count |
| sample | Random sample of rows | count or percent |
| unique | Remove duplicates | by (columns) |

**Transform Operations:**

| Operation | Description | Parameters |
|-----------|-------------|------------|
| select | Keep only specified columns | columns |
| drop | Remove specified columns | columns |
| rename | Rename columns | mapping (old -> new) |
| derive | Create new column from expression | name, expression |
| format | Format column values | column, pattern |
| convert | Convert column type | column, to_type |
| replace | Search/replace in column | column, search, replace |
| split | Split column into multiple | column, delimiter, names |
| merge | Merge columns into one | columns, into, separator |
| fill | Fill null values | column, value |
| trim | Trim whitespace | columns |
| upper / lower | Case conversion | columns |

**Aggregate Operations:**

| Operation | Description | Parameters |
|-----------|-------------|------------|
| group_by | Group and aggregate | by, aggregations |
| sum | Sum numeric column | column |
| count | Count rows | (grouped) |
| avg | Average of column | column |
| min / max | Min/max of column | column |
| first / last | First/last in group | column |

**Join Operations:**

| Operation | Description | Parameters |
|-----------|-------------|------------|
| lookup | Lookup values from another file | file, key, fields |
| merge | Merge with another file | file, on, how (left/right/inner/outer) |
| union | Concatenate files | files |

**Sort Operations:**

| Operation | Description | Parameters |
|-----------|-------------|------------|
| sort | Sort by column(s) | by, order |
| reverse | Reverse row order | - |
| shuffle | Random order | - |

### Data Flow

```
Input CSV File(s)
      |
      v
+------------------+
| Parse Arguments  |
+------------------+
      |
      v
+------------------+
| Load Pipeline    |  <-- JSON config
+------------------+
      |
      v
+------------------+
| Parse Input CSV  |  <-- simple_csv
+------------------+
      |
      v
+-----------------------------------+
| For Each Operation in Pipeline    |
|   +---------------------------+   |
|   | Execute Operation         |   |
|   |   - Filter rows           |   |
|   |   - Transform fields      |   |
|   |   - Aggregate groups      |   |
|   +---------------------------+   |
|              |                    |
|              v                    |
|   +---------------------------+   |
|   | Update Pipeline Context   |   |
|   |   - Current rows          |   |
|   |   - Current headers       |   |
|   +---------------------------+   |
+-----------------------------------+
      |
      v
+------------------+
| Format Output    |  <-- csv/json/tsv/template
+------------------+
      |
      v
Output File or stdout
```

### Expression Syntax

CSV-TRANSFORM uses a simple expression language for conditions and derivations:

**Conditions (filter):**
```
column = "value"           -- Exact match
column != "value"          -- Not equal
column ~ "pattern"         -- Regex match
column > 100               -- Numeric comparison
column >= 100
column < 100
column <= 100
column in ["a", "b", "c"]  -- Set membership
column is empty            -- Null/empty check
column is not empty
AND, OR, NOT               -- Boolean operators
(condition)                -- Grouping
```

**Derivations (derive):**
```
{column_name}              -- Column reference
{first_name} {last_name}   -- Concatenation
{price} * 1.1              -- Arithmetic
upper({name})              -- Functions
if({status}="active", "Y", "N")  -- Conditional
```

### Configuration File

```json
{
  "csv_transform": {
    "default_format": "csv",
    "default_delimiter": ",",
    "pipelines_path": "~/.csv-transform/pipelines/",
    "max_rows_in_memory": 1000000,
    "temp_directory": "/tmp/csv-transform/"
  }
}
```

### Error Handling

| Error Type | Handling | User Message |
|------------|----------|--------------|
| File not found | Exit 2 | "Error: File not found: {path}" |
| Pipeline invalid | Exit 2 | "Error: Invalid pipeline: {details}" |
| Unknown operation | Exit 2 | "Error: Unknown operation: {op}" |
| Expression error | Exit 2 | "Error: Invalid expression: {expr}" |
| Type mismatch | Exit 2 | "Error: Cannot {op} on {type}" |
| Out of memory | Exit 2 | "Error: File too large. Use streaming mode" |

## GUI/TUI Future Path

**CLI foundation enables:**

1. **TUI (simple_tui) additions:**
   - Interactive pipeline builder
   - Step-by-step execution with preview
   - Expression builder with autocomplete
   - Real-time row count and preview

2. **GUI (simple_gui) additions:**
   - Visual pipeline designer (node-based)
   - Drag-drop column mapping
   - Live data preview at each step
   - Pipeline template library

3. **Shared components between CLI/GUI:**
   - CSV_PIPELINE (execution engine)
   - All CSV_*_OP classes (operations)
   - CSV_OUTPUT_FORMATTER (formatting)
   - Expression parser and evaluator

The CLI defines the transformation semantics; GUI/TUI provide visual construction.
