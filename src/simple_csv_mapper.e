note
	description: "Reflection-based mapper for automatic object-to-CSV conversion"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_CSV_MAPPER

create
	make

feature {NONE} -- Initialization

	make
			-- Create CSV mapper.
		do
			snake_case_headers := True
		ensure
			snake_case_enabled: snake_case_headers
		end

feature -- Settings

	snake_case_headers: BOOLEAN
			-- Convert field names to snake_case for headers?
			-- e.g., firstName -> first_name

	set_snake_case_headers (a_value: BOOLEAN)
			-- Set whether to use snake_case for headers.
		do
			snake_case_headers := a_value
		ensure
			set: snake_case_headers = a_value
		end

feature -- Object to CSV Mapping

	objects_to_csv (a_objects: ARRAYED_LIST [ANY]): SIMPLE_CSV
			-- Convert list of objects to CSV with auto-generated headers.
		require
			objects_not_empty: not a_objects.is_empty
		local
			l_first: ANY
			l_headers: ARRAYED_LIST [STRING]
			l_reflected: SIMPLE_REFLECTED_OBJECT
			l_field: SIMPLE_FIELD_INFO
			i: INTEGER
		do
			create Result.make_with_header
			l_first := a_objects.first

			-- Generate headers from first object's fields
			create l_headers.make (10)
			create l_reflected.make (l_first)
			from
				i := 1
			until
				i > l_reflected.type_info.fields.count
			loop
				l_field := l_reflected.type_info.fields [i]
				l_headers.extend (field_to_header (l_field.name.to_string_8))
				i := i + 1
			end
			Result.set_headers (l_headers.to_array)

			-- Add data rows
			across a_objects as ic loop
				Result.add_data_row (object_to_row (ic).to_array)
			end
		ensure
			has_header: Result.has_header
			correct_row_count: Result.row_count = a_objects.count
		end

	object_to_row (a_object: ANY): ARRAYED_LIST [STRING]
			-- Convert object fields to row of strings.
		require
			object_exists: a_object /= Void
		local
			l_reflected: SIMPLE_REFLECTED_OBJECT
			l_field: SIMPLE_FIELD_INFO
			l_value: detachable ANY
			i: INTEGER
		do
			create Result.make (10)
			create l_reflected.make (a_object)
			from
				i := 1
			until
				i > l_reflected.type_info.fields.count
			loop
				l_field := l_reflected.type_info.fields [i]
				l_value := l_field.value (a_object)
				Result.extend (value_to_string (l_value))
				i := i + 1
			end
		ensure
			result_exists: Result /= Void
		end

feature -- CSV to Object Mapping

	csv_to_objects (a_csv: SIMPLE_CSV; a_prototype: ANY): ARRAYED_LIST [ANY]
			-- Convert CSV rows to objects using prototype.
		require
			csv_has_header: a_csv.has_header
			prototype_exists: a_prototype /= Void
		local
			i: INTEGER
		do
			create Result.make (a_csv.row_count)
			from
				i := 1
			until
				i > a_csv.row_count
			loop
				Result.extend (row_to_object (a_csv, i, a_prototype))
				i := i + 1
			end
		ensure
			correct_count: Result.count = a_csv.row_count
		end

	row_to_object (a_csv: SIMPLE_CSV; a_row: INTEGER; a_prototype: ANY): ANY
			-- Convert CSV row to object using prototype.
			-- Matches headers to field names (case-insensitive).
		require
			csv_has_header: a_csv.has_header
			valid_row: a_row >= 1 and a_row <= a_csv.row_count
			prototype_exists: a_prototype /= Void
		local
			l_result: ANY
			l_reflected: SIMPLE_REFLECTED_OBJECT
			l_field: SIMPLE_FIELD_INFO
			l_header: STRING
			l_value: STRING
			i: INTEGER
		do
			l_result := a_prototype.twin
			create l_reflected.make (l_result)
			from
				i := 1
			until
				i > l_reflected.type_info.fields.count
			loop
				l_field := l_reflected.type_info.fields [i]
				l_header := field_to_header (l_field.name.to_string_8)
				if a_csv.has_column (l_header) then
					l_value := a_csv.field_by_name (a_row, l_header)
					set_field_from_string (l_result, l_field, l_value)
				end
				i := i + 1
			end
			Result := l_result
		ensure
			result_exists: Result /= Void
		end

feature {NONE} -- Implementation

	field_to_header (a_field_name: STRING): STRING
			-- Convert field name to header name.
		do
			if snake_case_headers then
				Result := to_snake_case (a_field_name)
			else
				Result := a_field_name.twin
			end
		ensure
			result_not_empty: not Result.is_empty
		end

	to_snake_case (a_name: STRING): STRING
			-- Convert camelCase to snake_case.
		local
			i: INTEGER
			c: CHARACTER
		do
			create Result.make (a_name.count + 5)
			from
				i := 1
			until
				i > a_name.count
			loop
				c := a_name.item (i)
				if c.is_upper then
					if i > 1 then
						Result.append_character ('_')
					end
					Result.append_character (c.as_lower)
				else
					Result.append_character (c)
				end
				i := i + 1
			end
		ensure
			result_not_empty: not Result.is_empty
		end

	value_to_string (a_value: detachable ANY): STRING
			-- Convert value to CSV string representation.
		do
			if a_value = Void then
				Result := ""
			elseif attached {BOOLEAN} a_value as l_bool then
				Result := if l_bool then "true" else "false" end
			elseif attached {READABLE_STRING_GENERAL} a_value as l_str then
				Result := l_str.to_string_8
			else
				Result := a_value.out
			end
		ensure
			result_exists: Result /= Void
		end

	set_field_from_string (a_object: ANY; a_field: SIMPLE_FIELD_INFO; a_value: STRING)
			-- Set field value from CSV string.
		local
			l_type_name: STRING
			l_internal: INTERNAL
			l_converted: detachable ANY
		do
			create l_internal
			l_type_name := l_internal.type_name_of_type (a_field.field_type_id).as_upper
			if l_type_name.has_substring ("BOOLEAN") then
				l_converted := a_value.same_string ("true") or a_value.same_string ("1")
			elseif l_type_name.has_substring ("INTEGER_64") then
				if a_value.is_integer_64 then
					l_converted := a_value.to_integer_64
				end
			elseif l_type_name.has_substring ("INTEGER") then
				if a_value.is_integer then
					l_converted := a_value.to_integer
				end
			elseif l_type_name.has_substring ("REAL") or l_type_name.has_substring ("DOUBLE") then
				if a_value.is_double then
					l_converted := a_value.to_double
				end
			elseif l_type_name.has_substring ("STRING") then
				l_converted := a_value.twin
			else
				l_converted := a_value
			end
			if l_converted /= Void then
				a_field.set_value (a_object, l_converted)
			end
		end

note
	copyright: "Copyright (c) 2024-2025, Larry Rix"
	license: "MIT License"

end
