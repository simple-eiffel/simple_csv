# CSV-RECONCILE - Ecosystem Integration

## simple_* Dependencies

### Required Libraries

| Library | Purpose | Integration Point |
|---------|---------|-------------------|
| simple_csv | CSV parsing for both files | Dual file loading, data access |
| simple_json | Config loading, JSON reports | Comparison config, JSON output |
| simple_diff | Difference calculation | Field-level diff generation |
| simple_file | File I/O operations | File reading, report writing |
| simple_cli | Argument parsing | Command-line interface |

### Optional Libraries

| Library | Purpose | When Needed |
|---------|---------|-------------|
| simple_hash | Record fingerprinting | Hash verification, dedup detection |
| simple_logger | Audit trail | Compliance logging |
| simple_pdf | PDF report generation | Professional report output |
| simple_datetime | Date comparison | Date tolerance matching |
| simple_zstring | Fuzzy string matching | Levenshtein distance, soundex |

## Integration Patterns

### simple_csv Integration

**Purpose:** Parse both source and target CSV files

**Usage:**
```eiffel
class CSV_RECONCILE_ENGINE

feature -- Loading

    load_files (a_source_path, a_target_path: STRING)
            -- Load source and target CSV files.
        do
            create source_csv.make_with_header
            source_csv.set_delimiter (config.source_delimiter)
            source_csv.parse_file (a_source_path)

            create target_csv.make_with_header
            target_csv.set_delimiter (config.target_delimiter)
            target_csv.parse_file (a_target_path)

            -- Build key indexes for fast matching
            build_source_index
            build_target_index
        end

feature -- Comparison

    compare: CSV_RECONCILE_RESULT
            -- Compare source and target, return result.
        do
            create Result.make

            -- Find matched rows
            find_matches (Result)

            -- Find source-only rows
            find_source_only (Result)

            -- Find target-only rows
            find_target_only (Result)

            -- Compare fields for matched rows
            compare_matched_fields (Result)
        end

feature {NONE} -- Implementation

    source_csv: SIMPLE_CSV
    target_csv: SIMPLE_CSV
    source_index: HASH_TABLE [INTEGER, STRING]  -- key -> row number
    target_index: HASH_TABLE [INTEGER, STRING]  -- key -> row number

    build_key (a_csv: SIMPLE_CSV; a_row: INTEGER): STRING
            -- Build composite key for row.
        local
            l_parts: ARRAYED_LIST [STRING]
        do
            create l_parts.make (config.key_columns.count)
            across config.key_columns as kc loop
                l_parts.extend (a_csv.field_by_name (a_row, kc))
            end
            Result := l_parts.joined ("|")
        end

end
```

### simple_diff Integration

**Purpose:** Calculate field-level differences

**Usage:**
```eiffel
class CSV_FIELD_COMPARATOR

feature -- Comparison

    compare_fields (a_source_row, a_target_row: ARRAYED_LIST [STRING];
                    a_headers: ARRAYED_LIST [STRING]): ARRAYED_LIST [CSV_FIELD_DIFF]
            -- Compare fields between rows.
        local
            l_diff: SIMPLE_DIFF
            l_field_diff: CSV_FIELD_DIFF
            l_source_val, l_target_val: STRING
            l_col_index: INTEGER
        do
            create Result.make (10)
            create l_diff.make

            across config.compare_fields as field loop
                l_col_index := headers_index (a_headers, field)

                l_source_val := a_source_row [l_col_index]
                l_target_val := a_target_row [l_col_index]

                if not values_match (field, l_source_val, l_target_val) then
                    create l_field_diff.make (field, l_source_val, l_target_val)

                    -- Use simple_diff for detailed text diff if needed
                    if is_text_field (field) and l_source_val.count > 50 then
                        l_field_diff.set_diff_detail (l_diff.inline_diff (l_source_val, l_target_val))
                    end

                    Result.extend (l_field_diff)
                end
            end
        end

    values_match (a_field, a_source, a_target: STRING): BOOLEAN
            -- Do values match considering tolerances?
        do
            if attached config.tolerance_for (a_field) as tol then
                Result := match_with_tolerance (a_source, a_target, tol)
            elseif config.case_insensitive then
                Result := a_source.as_lower.same_string (a_target.as_lower)
            else
                Result := a_source.same_string (a_target)
            end
        end

end
```

### simple_hash Integration

**Purpose:** File and record fingerprinting for audit

**Usage:**
```eiffel
class CSV_RECONCILE_ENGINE

feature -- Hashing

    compute_file_hash (a_path: STRING): STRING
            -- Compute SHA256 hash of file.
        local
            l_hash: SIMPLE_HASH
            l_file: SIMPLE_FILE
        do
            create l_hash.make_sha256
            create l_file.make (a_path)
            Result := l_hash.hash_string (l_file.read_all)
        end

    compute_row_hash (a_csv: SIMPLE_CSV; a_row: INTEGER): STRING
            -- Compute hash of row for fingerprinting.
        local
            l_hash: SIMPLE_HASH
            l_row_data: STRING
        do
            create l_hash.make_sha256
            l_row_data := a_csv.row (a_row).joined (",")
            Result := l_hash.hash_string (l_row_data)
        end

feature -- Hash Report

    generate_hash_report (a_path: STRING): CSV_HASH_REPORT
            -- Generate hash fingerprint report for file.
        local
            l_csv: SIMPLE_CSV
            i: INTEGER
        do
            create Result.make

            create l_csv.make_with_header
            l_csv.parse_file (a_path)

            Result.set_file_hash (compute_file_hash (a_path))
            Result.set_row_count (l_csv.row_count)

            from i := 1 until i > l_csv.row_count loop
                Result.add_row_hash (build_key (l_csv, i), compute_row_hash (l_csv, i))
                i := i + 1
            end
        end

end
```

### simple_logger Integration

**Purpose:** Audit trail for compliance

**Usage:**
```eiffel
class CSV_AUDIT_TRAIL

feature -- Logging

    log_comparison_start (a_source, a_target, a_config: STRING)
            -- Log start of comparison.
        do
            logger.info ("RECONCILE_START",
                << ["source", a_source],
                   ["target", a_target],
                   ["config", a_config],
                   ["timestamp", timestamp_now],
                   ["user", current_user] >>)
        end

    log_discrepancy (a_disc: CSV_DISCREPANCY)
            -- Log individual discrepancy.
        do
            logger.info ("DISCREPANCY",
                << ["type", a_disc.type_name],
                   ["key", a_disc.key_string],
                   ["details", a_disc.details_json] >>)
            discrepancy_count := discrepancy_count + 1
        end

    log_comparison_complete (a_result: CSV_RECONCILE_RESULT)
            -- Log completion with summary.
        do
            logger.info ("RECONCILE_COMPLETE",
                << ["matched", a_result.matched_count.out],
                   ["source_only", a_result.source_only_count.out],
                   ["target_only", a_result.target_only_count.out],
                   ["mismatches", a_result.mismatch_count.out],
                   ["duration_ms", elapsed_ms.out],
                   ["source_hash", source_hash],
                   ["target_hash", target_hash] >>)
        end

feature {NONE} -- Implementation

    logger: SIMPLE_LOGGER
    discrepancy_count: INTEGER
    source_hash, target_hash: STRING

end
```

### simple_pdf Integration

**Purpose:** Professional PDF reports

**Usage:**
```eiffel
class CSV_PDF_REPORT_GENERATOR

feature -- Generation

    generate (a_result: CSV_RECONCILE_RESULT; a_output_path: STRING)
            -- Generate PDF reconciliation report.
        local
            l_pdf: SIMPLE_PDF
        do
            create l_pdf.make

            -- Title page
            l_pdf.add_page
            l_pdf.set_font ("Helvetica", 24)
            l_pdf.add_text ("Reconciliation Report")
            l_pdf.add_line_break
            l_pdf.set_font ("Helvetica", 12)
            l_pdf.add_text ("Generated: " + timestamp_now)

            -- Summary section
            l_pdf.add_page
            l_pdf.set_font ("Helvetica", 16)
            l_pdf.add_text ("Summary")
            add_summary_table (l_pdf, a_result)

            -- Discrepancies section
            l_pdf.add_page
            l_pdf.set_font ("Helvetica", 16)
            l_pdf.add_text ("Discrepancies")
            add_discrepancies_table (l_pdf, a_result)

            -- Audit section
            l_pdf.add_page
            l_pdf.set_font ("Helvetica", 16)
            l_pdf.add_text ("Audit Information")
            add_audit_section (l_pdf)

            l_pdf.save (a_output_path)
        end

feature {NONE} -- Implementation

    add_summary_table (a_pdf: SIMPLE_PDF; a_result: CSV_RECONCILE_RESULT)
            -- Add summary statistics table.
        do
            a_pdf.add_table (<<
                << "Metric", "Count", "Percentage" >>,
                << "Matched", a_result.matched_count.out, percent (a_result.matched_count, a_result.total) >>,
                << "Source Only", a_result.source_only_count.out, percent (a_result.source_only_count, a_result.total) >>,
                << "Target Only", a_result.target_only_count.out, percent (a_result.target_only_count, a_result.total) >>,
                << "Mismatches", a_result.mismatch_count.out, percent (a_result.mismatch_count, a_result.total) >>
            >>)
        end

end
```

## Dependency Graph

```
csv_reconcile
    |
    +-- simple_csv (required)
    |       +-- simple_encoding
    |       +-- simple_mml
    |
    +-- simple_json (required)
    |       +-- simple_codec
    |
    +-- simple_diff (required)
    |
    +-- simple_file (required)
    |
    +-- simple_cli (required)
    |
    +-- simple_hash (optional)
    |
    +-- simple_logger (optional)
    |       +-- simple_datetime
    |       +-- simple_file
    |
    +-- simple_pdf (optional)
    |
    +-- simple_datetime (optional)
    |
    +-- simple_zstring (optional)
    |
    +-- ISE base (required)
```

## ECF Configuration

```xml
<?xml version="1.0" encoding="ISO-8859-1"?>
<system name="csv_reconcile" uuid="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX" xmlns="http://www.eiffel.com/developers/xml/configuration-1-23-0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.eiffel.com/developers/xml/configuration-1-23-0 http://www.eiffel.com/developers/xml/configuration-1-23-0.xsd">
    <description>CSV-RECONCILE: Two-way CSV comparison and reconciliation</description>

    <target name="csv_reconcile">
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
        <library name="simple_diff" location="$SIMPLE_EIFFEL\simple_diff\simple_diff.ecf"/>
        <library name="simple_file" location="$SIMPLE_EIFFEL\simple_file\simple_file.ecf"/>
        <library name="simple_cli" location="$SIMPLE_EIFFEL\simple_cli\simple_cli.ecf"/>

        <!-- simple_* dependencies (optional, enabled by default) -->
        <library name="simple_hash" location="$SIMPLE_EIFFEL\simple_hash\simple_hash.ecf"/>
        <library name="simple_logger" location="$SIMPLE_EIFFEL\simple_logger\simple_logger.ecf"/>
        <library name="simple_datetime" location="$SIMPLE_EIFFEL\simple_datetime\simple_datetime.ecf"/>

        <!-- ISE libraries -->
        <library name="base" location="$ISE_LIBRARY\library\base\base.ecf"/>
    </target>

    <target name="csv_reconcile_cli" extends="csv_reconcile">
        <description>CLI executable</description>
        <root class="CSV_RECONCILE_CLI" feature="make"/>
        <setting name="executable_name" value="csv-reconcile"/>
    </target>

    <target name="csv_reconcile_tests" extends="csv_reconcile">
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
ec.exe -batch -config csv_reconcile.ecf -target csv_reconcile_cli -c_compile

# Production build (finalized)
ec.exe -batch -config csv_reconcile.ecf -target csv_reconcile_cli -finalize -c_compile

# Test build
ec.exe -batch -config csv_reconcile.ecf -target csv_reconcile_tests -c_compile
./EIFGENs/csv_reconcile_tests/W_code/csv_reconcile.exe
```

### Example Usage

```bash
# Basic comparison
csv-reconcile compare source.csv target.csv --key id

# With configuration file
csv-reconcile compare crm_export.csv db_export.csv --config recon_config.json

# Multiple key columns
csv-reconcile compare orders.csv shipments.csv --key "order_id,line_item"

# With tolerance
csv-reconcile compare expected.csv actual.csv --key id --tolerance 0.01

# JSON output for automation
csv-reconcile compare source.csv target.csv --key id -o json > result.json

# Audit trail for compliance
csv-reconcile compare ledger_a.csv ledger_b.csv --key txn_id --audit-log audit.log

# Hash verification
csv-reconcile hash data.csv --algorithm sha256
```
