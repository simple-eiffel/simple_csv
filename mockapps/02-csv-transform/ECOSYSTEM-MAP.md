# CSV-TRANSFORM - Ecosystem Integration

## simple_* Dependencies

### Required Libraries

| Library | Purpose | Integration Point |
|---------|---------|-------------------|
| simple_csv | CSV parsing and generation | Input/output, all data operations |
| simple_json | Pipeline configuration | Load/save pipeline definitions |
| simple_file | File I/O operations | Multi-file joins, output writing |
| simple_cli | Argument parsing | Command-line interface |

### Optional Libraries

| Library | Purpose | When Needed |
|---------|---------|-------------|
| simple_regex | Pattern matching | grep operation, regex conditions |
| simple_template | Output formatting | Template-based output format |
| simple_datetime | Date operations | Date parsing, formatting, arithmetic |
| simple_math | Numeric operations | Aggregations, calculations |
| simple_sorter | Efficient sorting | Large file sorting |
| simple_hash | Deduplication | unique operation, merge keys |

## Integration Patterns

### simple_csv Integration

**Purpose:** Core CSV data manipulation

**Usage:**
```eiffel
class CSV_PIPELINE

feature -- Execution

    execute (a_input_path: STRING): CSV_PIPELINE_CONTEXT
            -- Execute pipeline on input file.
        local
            l_csv: SIMPLE_CSV
        do
            -- Load input
            create l_csv.make_with_header
            l_csv.set_delimiter (input_config.delimiter)
            l_csv.parse_file (a_input_path)

            -- Initialize context
            create Result.make_from_csv (l_csv)

            -- Execute each operation
            across operations as op loop
                op.execute (Result)
            end
        end

feature -- Output

    write_output (a_context: CSV_PIPELINE_CONTEXT; a_path: STRING)
            -- Write result to file.
        local
            l_csv: SIMPLE_CSV
        do
            create l_csv.make_with_header
            l_csv.set_delimiter (output_config.delimiter)
            l_csv.set_headers (a_context.headers.to_array)

            across a_context.rows as row loop
                l_csv.add_data_row (row.to_array)
            end

            write_string_to_file (l_csv.to_csv, a_path)
        end

end
```

### simple_json Integration

**Purpose:** Pipeline configuration files

**Usage:**
```eiffel
class CSV_PIPELINE

feature -- Loading

    load_from_file (a_path: STRING)
            -- Load pipeline from JSON file.
        local
            l_json: SIMPLE_JSON
            l_obj: JSON_OBJECT
            l_ops: JSON_ARRAY
        do
            create l_json.make
            l_json.parse_file (a_path)
            l_obj := l_json.root_object

            name := l_obj.string_item ("name")
            description := l_obj.string_item ("description")

            -- Load input/output config
            parse_io_config (l_obj)

            -- Load operations
            l_ops := l_obj.array_item ("operations")
            across l_ops as op_json loop
                operations.extend (parse_operation (op_json.as_object))
            end
        end

feature {NONE} -- Implementation

    parse_operation (a_json: JSON_OBJECT): CSV_OPERATION
            -- Parse operation from JSON.
        local
            l_op_name: STRING
        do
            l_op_name := a_json.string_item ("op")

            inspect l_op_name
            when "filter", "where" then
                create {CSV_FILTER_OP} Result.make_from_json (a_json)
            when "select" then
                create {CSV_SELECT_OP} Result.make_from_json (a_json)
            when "rename" then
                create {CSV_RENAME_OP} Result.make_from_json (a_json)
            when "derive" then
                create {CSV_DERIVE_OP} Result.make_from_json (a_json)
            when "sort" then
                create {CSV_SORT_OP} Result.make_from_json (a_json)
            when "group_by" then
                create {CSV_GROUP_OP} Result.make_from_json (a_json)
            -- ... other operations
            else
                create {CSV_UNKNOWN_OP} Result.make (l_op_name)
            end
        end

end
```

### simple_regex Integration

**Purpose:** Pattern matching in filters and transforms

**Usage:**
```eiffel
class CSV_GREP_OP

inherit
    CSV_OPERATION

feature -- Execution

    execute (a_context: CSV_PIPELINE_CONTEXT)
            -- Filter rows by regex pattern.
        local
            l_regex: SIMPLE_REGEX
            l_col_index: INTEGER
            l_new_rows: ARRAYED_LIST [ARRAYED_LIST [STRING]]
        do
            create l_regex.make (pattern)
            l_col_index := a_context.column_index (column)

            create l_new_rows.make (a_context.rows.count)
            across a_context.rows as row loop
                if l_regex.matches (row [l_col_index]) then
                    l_new_rows.extend (row)
                end
            end

            a_context.set_rows (l_new_rows)
        end

feature -- Configuration

    column: STRING
            -- Column to match against.

    pattern: STRING
            -- Regex pattern.

end
```

### simple_template Integration

**Purpose:** Template-based output formatting

**Usage:**
```eiffel
class CSV_TEMPLATE_FORMATTER

inherit
    CSV_OUTPUT_FORMATTER

feature -- Formatting

    format (a_context: CSV_PIPELINE_CONTEXT): STRING
            -- Format output using template.
        local
            l_template: SIMPLE_TEMPLATE
            l_row_output: STRING
        do
            create l_template.make
            l_template.load_file (template_path)

            create Result.make (a_context.rows.count * 100)

            -- Process header template if present
            if attached header_template as ht then
                Result.append (l_template.render_with (ht, header_vars (a_context)))
            end

            -- Process each row
            across a_context.rows as row loop
                l_row_output := l_template.render_with (row_template, row_vars (row, a_context.headers))
                Result.append (l_row_output)
            end

            -- Process footer template if present
            if attached footer_template as ft then
                Result.append (l_template.render_with (ft, footer_vars (a_context)))
            end
        end

feature {NONE} -- Implementation

    row_vars (a_row: ARRAYED_LIST [STRING]; a_headers: ARRAYED_LIST [STRING]): STRING_TABLE [STRING]
            -- Create variable map for row.
        do
            create Result.make (a_headers.count)
            across a_headers as h loop
                Result.put (a_row [@h.target_index], h)
            end
        end

end
```

### simple_datetime Integration

**Purpose:** Date parsing, formatting, and arithmetic

**Usage:**
```eiffel
class CSV_DATE_CONVERT_OP

inherit
    CSV_OPERATION

feature -- Execution

    execute (a_context: CSV_PIPELINE_CONTEXT)
            -- Convert date column to new format.
        local
            l_datetime: SIMPLE_DATETIME
            l_col_index: INTEGER
            l_value, l_new_value: STRING
        do
            l_col_index := a_context.column_index (column)

            across a_context.rows as row loop
                l_value := row [l_col_index]
                if not l_value.is_empty then
                    create l_datetime.make_from_string (l_value, from_format)
                    l_new_value := l_datetime.format (to_format)
                    row [l_col_index] := l_new_value
                end
            end
        end

feature -- Configuration

    column: STRING
    from_format: STRING  -- e.g., "MM/DD/YYYY"
    to_format: STRING    -- e.g., "YYYY-MM-DD"

end
```

## Dependency Graph

```
csv_transform
    |
    +-- simple_csv (required)
    |       +-- simple_encoding
    |       +-- simple_mml
    |
    +-- simple_json (required)
    |       +-- simple_codec
    |
    +-- simple_file (required)
    |
    +-- simple_cli (required)
    |
    +-- simple_regex (optional)
    |
    +-- simple_template (optional)
    |
    +-- simple_datetime (optional)
    |
    +-- simple_math (optional)
    |
    +-- simple_sorter (optional)
    |
    +-- simple_hash (optional)
    |
    +-- ISE base (required)
```

## ECF Configuration

```xml
<?xml version="1.0" encoding="ISO-8859-1"?>
<system name="csv_transform" uuid="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX" xmlns="http://www.eiffel.com/developers/xml/configuration-1-23-0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.eiffel.com/developers/xml/configuration-1-23-0 http://www.eiffel.com/developers/xml/configuration-1-23-0.xsd">
    <description>CSV-TRANSFORM: Pipeline-based CSV transformation engine</description>

    <target name="csv_transform">
        <description>Library target (reusable components)</description>
        <root all_classes="true"/>
        <file_rule>
            <exclude>/tests$</exclude>
            <exclude>/EIFGENs$</exclude>
        </file_rule>
        <option warning="warning" void_safety="all">
            <assertions precondition="true" postcondition="true"
                       check="true" invariant="true"/>
        </option>

        <!-- Application source -->
        <cluster name="src" location=".\src\" recursive="true"/>

        <!-- simple_* dependencies (required) -->
        <library name="simple_csv" location="$SIMPLE_EIFFEL\simple_csv\simple_csv.ecf"/>
        <library name="simple_json" location="$SIMPLE_EIFFEL\simple_json\simple_json.ecf"/>
        <library name="simple_file" location="$SIMPLE_EIFFEL\simple_file\simple_file.ecf"/>
        <library name="simple_cli" location="$SIMPLE_EIFFEL\simple_cli\simple_cli.ecf"/>

        <!-- simple_* dependencies (optional, enabled by default) -->
        <library name="simple_regex" location="$SIMPLE_EIFFEL\simple_regex\simple_regex.ecf"/>
        <library name="simple_template" location="$SIMPLE_EIFFEL\simple_template\simple_template.ecf"/>
        <library name="simple_datetime" location="$SIMPLE_EIFFEL\simple_datetime\simple_datetime.ecf"/>

        <!-- ISE libraries -->
        <library name="base" location="$ISE_LIBRARY\library\base\base.ecf"/>
    </target>

    <target name="csv_transform_cli" extends="csv_transform">
        <description>CLI executable</description>
        <root class="CSV_TRANSFORM_CLI" feature="make"/>
        <setting name="executable_name" value="csv-transform"/>
    </target>

    <target name="csv_transform_tests" extends="csv_transform">
        <description>Test suite</description>
        <root class="TEST_APP" feature="make"/>
        <library name="simple_testing" location="$SIMPLE_EIFFEL\simple_testing\simple_testing.ecf"/>
        <cluster name="tests" location=".\tests\"/>
    </target>

</system>
```

## Build Integration

### Compile Commands

```bash
# Development build (workbench)
ec.exe -batch -config csv_transform.ecf -target csv_transform_cli -c_compile

# Production build (finalized)
ec.exe -batch -config csv_transform.ecf -target csv_transform_cli -finalize -c_compile

# Test build
ec.exe -batch -config csv_transform.ecf -target csv_transform_tests -c_compile
./EIFGENs/csv_transform_tests/W_code/csv_transform.exe
```

### Example Usage

```bash
# Single operation mode
csv-transform transform contacts.csv --op select --columns "name,email,phone"
csv-transform transform data.csv --op filter --where "status='active'"
csv-transform transform sales.csv --op sort --by "amount" --desc

# Pipeline mode
csv-transform transform contacts.csv --pipeline clean_contacts.json

# Output to file with format
csv-transform transform data.csv --pipeline transform.json -O result.json -f json

# Chain operations with pipes (Unix-style)
csv-transform transform raw.csv --op filter --where "region='US'" | \
csv-transform transform - --op select --columns "name,sales" | \
csv-transform transform - --op sort --by "sales" --desc > us_top_sales.csv
```
