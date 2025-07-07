class_name Utils

static func normalize(code: String) -> String:
	# all tabs with spaces.
	var normalized_text = code.replace("\t", " ")
	
	# all newline characters with spaces.
	normalized_text = normalized_text.replace("\n", " ")
	
	# all carriage return characters (for Windows compatibility).
	normalized_text = normalized_text.replace("\r", "")
	
	# ll leading and trailing whitespace from the whole block.
	normalized_text = normalized_text.strip_edges()
	
	#  multiple spaces into a single space.
	while "  " in normalized_text:
		normalized_text = normalized_text.replace("  ", " ")
		
	return normalized_text
