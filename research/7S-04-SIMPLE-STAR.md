# 7S-04: SIMPLE-STAR Ecosystem Integration


**Date**: 2026-01-23

**Library:** simple_csv
**Date:** 2026-01-23
**Status:** BACKWASH (reverse-engineered from implementation)

## Ecosystem Dependencies

### Required Libraries
- **simple_encoding** - Encoding detection (SIMPLE_ENCODING_DETECTOR)
- **simple_reflection** - Object mapping (SIMPLE_REFLECTED_OBJECT, SIMPLE_FIELD_INFO)

### Optional Integration
- **simple_sql** - Database import/export workflows

## Integration Patterns

### With simple_encoding

```eiffel
-- Automatic BOM detection
csv.has_bom (content)      -- Uses SIMPLE_ENCODING_DETECTOR
csv.strip_bom (content)    -- Uses SIMPLE_ENCODING_DETECTOR
csv.detect_encoding (input) -- Full encoding detection
csv.is_valid_utf8 (input)  -- UTF-8 validation
```

### With simple_reflection (SIMPLE_CSV_MAPPER)

```eiffel
-- Object to CSV
mapper: SIMPLE_CSV_MAPPER
objects: ARRAYED_LIST [PERSON]

create mapper.make
csv := mapper.objects_to_csv (objects)

-- CSV to Object
prototype: PERSON
create prototype.make_default
objects := mapper.csv_to_objects (csv, prototype)
```

## API Consistency

Follows simple_* patterns:
- **Multiple creation procedures** - make, make_with_header, make_with_delimiter
- **Feature aliases** - parse/load/from_string, field/cell/value_at
- **Query/Command separation** - Clear distinction
- **Design by Contract** - Full preconditions, postconditions, invariants
- **MML integration** - Mathematical models for formal verification

## Ecosystem Value

High-value utility library used by:
- Data import/export features
- Configuration file handling
- Report generation
- Test data management
