BEGIN{}
{
	if ($1 == "top") {
		printf "%s", $3;
	}
	if ( match($0, "Cpu") ) {
		printf "\t%f", $2 + $4 + $6;
	}
	if ( match($0, "KiB Mem") ) {
		print "\t", $3
	}
}
END{}
