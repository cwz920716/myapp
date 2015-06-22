BEGIN{
	start=0;
	end=0;
}
{
	if (start == 0) {
		if ($1 == "Value") {
			start = 1;
		}
	}

	if ($1 == "#[Mean") {
		end = 1;
	}

	if (start > 0 && end == 0) {
		print $0;
	}
}
END{
}
