@load base/utils/strings

module JSON;

export {
	## A function to convert arbitrary Bro data into a JSON string.
	##
	## v: The value to convert to JSON.  Typically a record.
	##
	## only_loggable: If the v value is a record this will only cause
	##                fields with the &log attribute to be included in the JSON.
	##
	## returns: a JSON formatted string.
	global convert: function(v: any, only_loggable: bool &default=F): string;
}

function convert(v: any, only_loggable: bool &default=F): string
	{
	local tn = type_name(v);
	switch ( tn )
		{
		case "type":
		return "";

		case "string":
		return cat("\"", gsub(gsub(clean(v), /\\/, "\\\\"), /\"/, "\\\""), "\"");

		case "time":
	  return fmt("\"%s.%06.0fZ\"",
	      strftime("%Y-%m-%dT%H:%M:%S", v),
	      (time_to_double(v) - floor(time_to_double(v))) * 1000000
				);
		case "interval":
		return cat(interval_to_double(v));

		case "bool":
		fallthrough;
		case "enum":
		fallthrough;
		case "addr":
		fallthrough;
		case "port":
		return cat("\"", v, "\"");

		case "int":
		fallthrough;
		case "count":
		fallthrough;
		case "double":
		fallthrough;

		return cat(v);

		default:
		break;
		}

	if ( /^record/ in tn )
		{
		local rec_parts: string_vec = vector();

		local ft = record_fields(v);
		for ( field in ft )
			{
			local field_desc = ft[field];
			if ( field_desc?$value && (!only_loggable || field_desc$log) )
				{
				local onepart = cat("\"", field, "\": ", JSON::convert(field_desc$value, only_loggable));
				rec_parts[|rec_parts|] = onepart;
				}
			}
			return cat("{", join_string_vec(rec_parts, ", "), "}");
		}

	else if ( /^set/ in tn )
		{
		local set_parts: string_vec = vector();
		local sa: set[bool] = v;
		for ( sv in sa )
			{
			set_parts[|set_parts|] = JSON::convert(sv, only_loggable);
			}
		return cat("[", join_string_vec(set_parts, ", "), "]");
		}

	else if ( /^table/ in tn )
		{
		local tab_parts: vector of string = vector();
		local ta: table[bool] of any = v;
		for ( ti in ta )
			{
			local ts = JSON::convert(ti);
			local if_quotes = (ts[0] == "\"") ? "" : "\"";
			tab_parts[|tab_parts|] = cat(if_quotes, ts, if_quotes, ": ", JSON::convert(ta[ti], only_loggable));
			}
		return cat("{", join_string_vec(tab_parts, ", "), "}");
		}

	else if ( /^vector/ in tn )
		{
		local vec_parts: string_vec = vector();
		local va: vector of any = v;
		for ( vi in va )
			{
			vec_parts[|vec_parts|] = JSON::convert(va[vi], only_loggable);
			}
		return cat("[", join_string_vec(vec_parts, ", "), "]");
		}

	return "\"\"";
	}
