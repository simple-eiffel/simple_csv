note
	description: "[
		Zero-configuration CSV facade for beginners.

		One-liner CSV read/write operations.
		For full control, use SIMPLE_CSV directly.

		Quick Start Examples:
			create csv.make

			-- Read CSV file to list of rows
			rows := csv.read ("data.csv")

			-- Write rows to CSV file
			csv.write ("output.csv", rows)

			-- Parse CSV string
			rows := csv.parse (csv_string)

			-- Convert rows to CSV string
			csv_string := csv.to_csv (rows)
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_CSV_QUICK

create
	make

feature {NONE} -- Initialization

	make
			-- Create quick CSV facade.
		do
			create csv.make
			create logger.make ("csv_quick")
			delimiter := ','
			has_header := True
		ensure
			csv_exists: csv /= Void
		end

feature -- Configuration

	set_delimiter (a_char: CHARACTER)
			-- Set field delimiter (default is comma).
		do
			delimiter := a_char
			csv.set_delimiter (a_char)
		ensure
			delimiter_set: delimiter = a_char
		end

	set_has_header (a_value: BOOLEAN)
			-- Set whether files have header row (default True).
		do
			has_header := a_value
		ensure
			has_header_set: has_header = a_value
		end

	use_tabs
			-- Use tab as delimiter (TSV format).
		do
			set_delimiter ('%T')
		end

	use_semicolons
			-- Use semicolon as delimiter (European CSV).
		do
			set_delimiter (';')
		end

feature -- Reading

	read (a_path: STRING): ARRAYED_LIST [ARRAYED_LIST [STRING]]
			-- Read CSV file to list of rows (each row is list of fields).
		require
			path_not_empty: not a_path.is_empty
		do
			logger.debug_log ("Reading CSV: " + a_path)
			csv.read_file (a_path)
			Result := csv.rows
			if Result = Void then
				create Result.make (0)
			end
			logger.debug_log ("Read " + Result.count.out + " rows")
		ensure
			result_exists: Result /= Void
		end

	read_with_headers (a_path: STRING): ARRAYED_LIST [STRING_TABLE [STRING]]
			-- Read CSV file to list of maps (field name -> value).
			-- First row is treated as headers.
		require
			path_not_empty: not a_path.is_empty
		local
			l_rows: ARRAYED_LIST [ARRAYED_LIST [STRING]]
			l_headers: ARRAYED_LIST [STRING]
			l_map: STRING_TABLE [STRING]
			i: INTEGER
		do
			csv.read_file (a_path)
			l_rows := csv.rows
			create Result.make (l_rows.count)
			if l_rows.count > 0 then
				l_headers := l_rows.first
				from i := 2 until i > l_rows.count loop
					create l_map.make (l_headers.count)
					across l_headers as h loop
						if l_rows [i].valid_index (h.cursor_index) then
							l_map.put (l_rows [i] [h.cursor_index], h)
						end
					end
					Result.extend (l_map)
					i := i + 1
				end
			end
		ensure
			result_exists: Result /= Void
		end

	parse (a_csv: STRING): ARRAYED_LIST [ARRAYED_LIST [STRING]]
			-- Parse CSV string to list of rows.
		require
			csv_not_empty: not a_csv.is_empty
		do
			logger.debug_log ("Parsing CSV string (" + a_csv.count.out + " chars)")
			csv.parse_string (a_csv)
			Result := csv.rows
			if Result = Void then
				create Result.make (0)
			end
		ensure
			result_exists: Result /= Void
		end

feature -- Writing

	write (a_path: STRING; a_rows: ARRAYED_LIST [ARRAYED_LIST [STRING]])
			-- Write rows to CSV file.
		require
			path_not_empty: not a_path.is_empty
			rows_not_void: a_rows /= Void
		do
			logger.debug_log ("Writing CSV: " + a_path + " (" + a_rows.count.out + " rows)")
			csv.set_rows (a_rows)
			csv.write_file (a_path)
		end

	write_with_headers (a_path: STRING; a_headers: ARRAY [STRING]; a_rows: ARRAYED_LIST [ARRAYED_LIST [STRING]])
			-- Write rows to CSV file with header row.
		require
			path_not_empty: not a_path.is_empty
			headers_not_empty: a_headers.count > 0
			rows_not_void: a_rows /= Void
		local
			l_all_rows: ARRAYED_LIST [ARRAYED_LIST [STRING]]
			l_header_row: ARRAYED_LIST [STRING]
		do
			create l_all_rows.make (a_rows.count + 1)
			create l_header_row.make_from_array (a_headers)
			l_all_rows.extend (l_header_row)
			across a_rows as r loop
				l_all_rows.extend (r)
			end
			csv.set_rows (l_all_rows)
			csv.write_file (a_path)
		end

	to_csv (a_rows: ARRAYED_LIST [ARRAYED_LIST [STRING]]): STRING
			-- Convert rows to CSV string.
		require
			rows_not_void: a_rows /= Void
		do
			csv.set_rows (a_rows)
			Result := csv.to_string
			if Result = Void then
				Result := ""
			end
		ensure
			result_exists: Result /= Void
		end

feature -- Quick Row Building

	row (a_fields: ARRAY [STRING]): ARRAYED_LIST [STRING]
			-- Create a row from array of fields.
		require
			fields_not_void: a_fields /= Void
		do
			create Result.make_from_array (a_fields)
		ensure
			result_exists: Result /= Void
		end

	rows_from_arrays (a_arrays: ARRAY [ARRAY [STRING]]): ARRAYED_LIST [ARRAYED_LIST [STRING]]
			-- Create rows from arrays.
		require
			arrays_not_void: a_arrays /= Void
		do
			create Result.make (a_arrays.count)
			across a_arrays as a loop
				Result.extend (row (a))
			end
		ensure
			result_exists: Result /= Void
		end

feature -- Utility

	column (a_rows: ARRAYED_LIST [ARRAYED_LIST [STRING]]; a_index: INTEGER): ARRAYED_LIST [STRING]
			-- Extract single column from rows.
		require
			rows_not_void: a_rows /= Void
			valid_index: a_index >= 1
		do
			create Result.make (a_rows.count)
			across a_rows as r loop
				if r.valid_index (a_index) then
					Result.extend (r [a_index])
				end
			end
		ensure
			result_exists: Result /= Void
		end

	row_count (a_rows: ARRAYED_LIST [ARRAYED_LIST [STRING]]): INTEGER
			-- Number of rows.
		require
			rows_not_void: a_rows /= Void
		do
			Result := a_rows.count
		end

	column_count (a_rows: ARRAYED_LIST [ARRAYED_LIST [STRING]]): INTEGER
			-- Number of columns (from first row).
		require
			rows_not_void: a_rows /= Void
		do
			if not a_rows.is_empty then
				Result := a_rows.first.count
			end
		end

feature -- Status

	delimiter: CHARACTER
			-- Current field delimiter.

	has_header: BOOLEAN
			-- Does file have header row?

feature -- Advanced Access

	csv: SIMPLE_CSV
			-- Access underlying CSV handler for advanced operations.

feature {NONE} -- Implementation

	logger: SIMPLE_LOGGER
			-- Logger for debugging.

invariant
	csv_exists: csv /= Void
	logger_exists: logger /= Void

end
