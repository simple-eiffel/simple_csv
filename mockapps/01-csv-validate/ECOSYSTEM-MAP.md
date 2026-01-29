# CSV-VALIDATE - Ecosystem Integration

## simple_* Dependencies

### Required Libraries

| Library | Purpose | Integration Point |
|---------|---------|-------------------|
| simple_csv | CSV parsing and generation | Core data loading, header detection |
| simple_json | Schema loading/saving | JSON schema files, JSON error output |
| simple_validation | Rule engine framework | Validation rules, constraint checking |
| simple_file | File I/O operations | File reading, path validation |
| simple_logger | Audit trail logging | Compliance logging, operation history |
| simple_cli | Argument parsing | Command-line interface |

### Optional Libraries

| Library | Purpose | When Needed |
|---------|---------|-------------|
| simple_regex | Pattern matching | Email, phone, custom regex rules |
| simple_datetime | Date/time validation | Date format checking, range validation |
| simple_hash | Checksum calculation | File integrity verification in audit log |
| simple_config | Configuration file | When using config files instead of CLI args |
| simple_email | Email notifications | Enterprise: send alerts on validation failure |

## Integration Patterns

### simple_csv Integration

**Purpose:** Core CSV parsing for validation

**Usage:**
```eiffel
class CSV_VALIDATE_ENGINE

feature -- Validation

    validate_file (a_path: STRING; a_schema: CSV_SCHEMA): CSV_VALIDATION_RESULT
            -- Validate CSV file against schema.
        local
            l_csv: SIMPLE_CSV
            l_row: INTEGER
        do
            create Result.make

            -- Parse with header support
            create l_csv.make_with_header
            l_csv.set_delimiter (a_schema.delimiter)
            l_csv.parse_file (a_path)

            -- Validate structure
            validate_headers (l_csv, a_schema, Result)

            -- Validate each row
            from l_row := 1 until l_row > l_csv.row_count loop
                validate_row (l_csv, l_row, a_schema, Result)
                l_row := l_row + 1
            end
        end

feature {NONE} -- Implementation

    validate_row (a_csv: SIMPLE_CSV; a_row: INTEGER;
                  a_schema: CSV_SCHEMA; a_result: CSV_VALIDATION_RESULT)
            -- Validate single row against schema.
        local
            l_col: INTEGER
            l_spec: CSV_COLUMN_SPEC
            l_value: STRING
        do
            from l_col := 1 until l_col > a_schema.column_count loop
                l_spec := a_schema.column_at (l_col)
                l_value := a_csv.field (a_row, l_col)

                -- Apply all validators for this column
                across l_spec.validators as v loop
                    if not v.is_valid (l_value) then
                        a_result.add_error (create {CSV_VALIDATION_ERROR}.make (
                            a_row, l_spec.name, v.error_message (l_value)))
                    end
                end
                l_col := l_col + 1
            end
        end

end
```

**Data flow:** File path -> SIMPLE_CSV.parse_file -> Row iteration -> Field access -> Validation

### simple_json Integration

**Purpose:** Schema definition and JSON output

**Usage:**
```eiffel
class CSV_SCHEMA

feature -- Persistence

    load_from_json (a_path: STRING)
            -- Load schema from JSON file.
        local
            l_json: SIMPLE_JSON
            l_obj: JSON_OBJECT
        do
            create l_json.make
            l_json.parse_file (a_path)
            l_obj := l_json.root_object

            name := l_obj.string_item ("name")
            delimiter := l_obj.string_item ("delimiter").item (1)
            has_header := l_obj.boolean_item ("has_header")

            -- Load columns
            across l_obj.array_item ("columns") as col loop
                columns.extend (parse_column_spec (col.as_object))
            end
        end

    to_json: STRING
            -- Generate JSON representation.
        local
            l_json: SIMPLE_JSON
            l_obj: JSON_OBJECT
        do
            create l_json.make
            create l_obj.make

            l_obj.put_string ("name", name)
            l_obj.put_string ("delimiter", delimiter.out)
            l_obj.put_boolean ("has_header", has_header)
            l_obj.put_array ("columns", columns_to_json_array)

            Result := l_obj.to_string
        end

end
```

### simple_validation Integration

**Purpose:** Rule engine for validators

**Usage:**
```eiffel
class CSV_TYPE_RULE

inherit
    SIMPLE_VALIDATION_RULE [STRING]

feature -- Validation

    is_valid (a_value: STRING): BOOLEAN
            -- Is value valid for this type?
        do
            inspect type_name
            when "integer" then
                Result := a_value.is_empty or else a_value.is_integer
            when "decimal" then
                Result := a_value.is_empty or else a_value.is_double
            when "boolean" then
                Result := a_value.is_empty or else
                          a_value.same_string ("true") or else
                          a_value.same_string ("false")
            when "date" then
                Result := is_valid_date (a_value)
            else
                Result := True  -- string accepts anything
            end
        end

    error_message (a_value: STRING): STRING
            -- Error message for invalid value.
        do
            Result := "Expected " + type_name + ", got: " + a_value
        end

feature -- Configuration

    type_name: STRING
            -- Expected type name.

end
```

### simple_logger Integration

**Purpose:** Audit trail for compliance

**Usage:**
```eiffel
class CSV_AUDIT_LOGGER

feature -- Logging

    log_validation_start (a_file, a_schema: STRING)
            -- Log start of validation.
        do
            logger.info ("VALIDATION_START",
                << ["file", a_file], ["schema", a_schema],
                   ["timestamp", timestamp_now] >>)
        end

    log_validation_error (a_row: INTEGER; a_column, a_message: STRING)
            -- Log validation error.
        do
            logger.warning ("VALIDATION_ERROR",
                << ["row", a_row.out], ["column", a_column],
                   ["message", a_message] >>)
            error_count := error_count + 1
        end

    log_validation_complete (a_valid: BOOLEAN; a_row_count: INTEGER)
            -- Log validation completion.
        do
            logger.info ("VALIDATION_COMPLETE",
                << ["valid", a_valid.out], ["rows", a_row_count.out],
                   ["errors", error_count.out],
                   ["duration_ms", elapsed_ms.out] >>)
        end

feature {NONE} -- Implementation

    logger: SIMPLE_LOGGER
            -- Underlying logger.

    error_count: INTEGER
            -- Errors logged this session.

end
```

## Dependency Graph

```
csv_validate
    |
    +-- simple_csv (required)
    |       +-- simple_encoding
    |       +-- simple_mml
    |
    +-- simple_json (required)
    |       +-- simple_codec
    |
    +-- simple_validation (required)
    |
    +-- simple_file (required)
    |
    +-- simple_logger (required)
    |       +-- simple_datetime
    |       +-- simple_file
    |
    +-- simple_cli (required)
    |
    +-- simple_regex (optional)
    |
    +-- simple_datetime (optional)
    |
    +-- simple_hash (optional)
    |
    +-- ISE base (required)
```

## ECF Configuration

```xml
<?xml version="1.0" encoding="ISO-8859-1"?>
<system name="csv_validate" uuid="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX" xmlns="http://www.eiffel.com/developers/xml/configuration-1-23-0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.eiffel.com/developers/xml/configuration-1-23-0 http://www.eiffel.com/developers/xml/configuration-1-23-0.xsd">
    <description>CSV-VALIDATE: Schema-based CSV validation tool</description>

    <target name="csv_validate">
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
        <library name="simple_validation" location="$SIMPLE_EIFFEL\simple_validation\simple_validation.ecf"/>
        <library name="simple_file" location="$SIMPLE_EIFFEL\simple_file\simple_file.ecf"/>
        <library name="simple_logger" location="$SIMPLE_EIFFEL\simple_logger\simple_logger.ecf"/>
        <library name="simple_cli" location="$SIMPLE_EIFFEL\simple_cli\simple_cli.ecf"/>

        <!-- simple_* dependencies (optional, enabled by default) -->
        <library name="simple_regex" location="$SIMPLE_EIFFEL\simple_regex\simple_regex.ecf"/>
        <library name="simple_datetime" location="$SIMPLE_EIFFEL\simple_datetime\simple_datetime.ecf"/>

        <!-- ISE libraries -->
        <library name="base" location="$ISE_LIBRARY\library\base\base.ecf"/>
    </target>

    <target name="csv_validate_cli" extends="csv_validate">
        <description>CLI executable</description>
        <root class="CSV_VALIDATE_CLI" feature="make"/>
        <setting name="executable_name" value="csv-validate"/>
    </target>

    <target name="csv_validate_tests" extends="csv_validate">
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
ec.exe -batch -config csv_validate.ecf -target csv_validate_cli -c_compile

# Production build (finalized)
ec.exe -batch -config csv_validate.ecf -target csv_validate_cli -finalize -c_compile

# Test build
ec.exe -batch -config csv_validate.ecf -target csv_validate_tests -c_compile
./EIFGENs/csv_validate_tests/W_code/csv_validate.exe
```

### CI/CD Integration

```yaml
# GitHub Actions example
- name: Build CSV-VALIDATE
  run: |
    ec.exe -batch -config csv_validate.ecf -target csv_validate_cli -finalize -c_compile

- name: Run Tests
  run: |
    ec.exe -batch -config csv_validate.ecf -target csv_validate_tests -c_compile
    ./EIFGENs/csv_validate_tests/W_code/csv_validate.exe

- name: Package Release
  run: |
    cp ./EIFGENs/csv_validate_cli/F_code/csv-validate.exe ./release/
```
