#!/bin/bash

# check commands
while IFS= read -r command; do
        if command -v "${command}" &>/dev/null; then
                echo "checking for ${command}... yes"
        else
            	echo "checking for ${command}... no"
                requirements="${requirements} ${command}"
                install="true"
        fi
done < <(grep -o '^[^#]*' INSTALL)

# check perl modules
while IFS= read -r perl_module; do
	if perl -e "use ${perl_module}" &>/dev/null; then
		echo "checking for ${perl_module}... yes"
	else
		echo "checking for ${perl_module}... no"
		perl_requirements="${perl_requirements} ${perl_module}"
		perl_install="true"
	fi
done < <(cat cpanfile | cut -d "'" -f 2)

# print requirements
if [[ "${install}" == "true" ]]; then
        echo -e "\nplease install:"
        echo "   ${requirements}"
fi

if [[ "${perl_install}" == "true" ]]; then
        echo -e "\nplease install perl module:"
        echo "   ${perl_requirements}"
fi

# return false
if [[ "${install}" == "true" ]]; then
        exit 1
fi

if [[ "${perl_install}" == "true" ]]; then
	exit 1
fi
