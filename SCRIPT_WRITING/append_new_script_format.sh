#!/bin/sh

#MAC_BOGONS="$(ls ./BOGONS/MAC)";
IPV4_BOGONS=$(ls ./BOGONS/IPV4);
#IPV6_BOGONS=$(ls ./BOGONS/IPV6/);

TOTAL_FILES=$(echo "$IPV4_BOGONS" | wc -l);

i=1;
while true; do
	if [ $i -gt $TOTAL_FILES ]; then break; fi

	FILE=$(echo "$IPV4_BOGONS" | head -n $i | tail -n 1);

	cat ./ipv4_bogon_template.template >> "./BOGONS/IPV4/$FILE";

#	./SCRIPT_BUILDING/build_script_imports.sh >> "./BOGONS/MAC/$FILE";
#	./SCRIPT_BUILDING/build_script_description_dependencies_usage_functions.sh >> "./BOGONS/MAC/$FILE";
#	./SCRIPT_BUILDING/build_script_argument_parsing.sh --arguments "SOURCE_OR_DESTINATION" >> "./BOGONS/MAC/$FILE";

	i=$(($i+1));
done;

echo "Appended the new format to $(($i-1)) files.";

exit 0;
