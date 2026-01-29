# CSV-VALIDATE

**Schema-based CSV validation with detailed error reporting and audit logging**

## Executive Summary

CSV-VALIDATE is a command-line tool that validates CSV files against user-defined schemas before they enter production systems. It catches data quality issues at the gate: missing required fields, type mismatches, format violations, and constraint failures. Unlike basic CSV parsers that only check syntax, CSV-VALIDATE enforces business rules and generates audit-ready reports.

The tool integrates into existing workflows as a pre-processor: CI/CD pipelines run it before database imports, ETL jobs invoke it as a validation step, and compliance teams use it to certify data before regulatory submission. When validation fails, CSV-VALIDATE provides actionable error messages with row numbers, column names, and specific violation details.

CSV-VALIDATE targets the gap between free tools like csvkit (no schema validation) and enterprise platforms like Informatica (complex, expensive). It offers the validation rigor of The National Archives' CSV Validator with better CLI ergonomics and integration with the simple_* ecosystem.

## Problem Statement

**The problem:** Organizations import CSV data from partners, exports, and legacy systems without validating structure or content. Invalid data enters databases, causing application errors, report inaccuracies, and compliance failures. Manual inspection is impossible at scale.

**Current solutions:**
- Manual spot-checks in Excel (misses errors, doesn't scale)
- Custom validation scripts (brittle, undocumented, unmaintained)
- Database constraints (catch errors too late, cryptic messages)
- Enterprise ETL tools (expensive, complex deployment)
- CSV Validator from TNA (Java-based, limited transformation)

**Our approach:** A lightweight, Eiffel-native CLI tool that:
- Validates against JSON-defined schemas
- Reports all errors in a single pass (no "first error only")
- Integrates with existing CLI workflows (pipes, exit codes, machine-readable output)
- Logs validation runs for audit purposes
- Uses Design by Contract for correctness guarantees

## Target Users

| User Type | Description | Key Needs |
|-----------|-------------|-----------|
| Primary | Data Engineer building ETL pipelines | Pre-load validation, CI/CD integration, clear exit codes |
| Primary | Compliance Officer certifying data | Audit trails, detailed reports, schema documentation |
| Secondary | IT Administrator managing imports | Quick validation, cron scheduling, email alerts on failure |
| Secondary | Business Analyst checking exports | Easy schema creation, human-readable errors |

## Value Proposition

**For** data engineers and compliance teams
**Who** need to validate CSV files before system import
**This app** enforces schema rules and reports all violations
**Unlike** manual inspection or enterprise ETL platforms
**We** provide lightweight CLI integration with audit-ready logging

## Revenue Model

| Model | Description | Price Point |
|-------|-------------|-------------|
| Open Source Core | Basic validation, text output | Free (MIT) |
| Professional | JSON/CSV error output, schema auto-detection | $99/seat/year |
| Enterprise | Audit logging, compliance reports, priority support | $499/seat/year |

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Files validated/second | 10+ small files | Benchmark suite |
| Error detection rate | 100% of schema violations | Test suite coverage |
| Integration time | <30 minutes to CI/CD | User feedback |
| Adoption | 100+ GitHub stars in year 1 | GitHub metrics |
| Revenue | $50K ARR by year 2 | License sales |
