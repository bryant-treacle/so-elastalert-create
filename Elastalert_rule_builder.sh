#!/bin/bash
# Author: Bryant Treacle
# Date: 6/14/2018
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Purpose:  This script will allow you to build elastalert rules.
# The rule must be placed in the /etc/elastalert/rules directory.

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "This script must be run as root."
    exit
fi

print_welcome_message()
{

cat << EOF

This script will help automate the creation of Elastalert Rules.  Please choose
the rule you want to create.

For Cardinality rules: Press 1
For Blacklist rules: Press 2
Exit: Press 9

EOF

}

exit_prog()
{
    exit
}


print_cardinality_welcome()
{
cat << EOF

The Cardinality rule matches when the total number of unique values for a 
certain field within a time frame is higher or lower than a threshold.

Please complete options

EOF
}
    
print_blacklist_welcome()
{
cat << EOF

The blacklist rule will check a certain field against a blacklist, 
and match if it is in the blacklist.

Please complete options

EOF
}

print_name_prompt()
{

cat << EOF

What do you want to name the rule?

EOF

}

print_prompt_index()
{
cat << EOF

What elasticsearch index do you want to search?

Below are the default Index Patterns for Security Onion

*:logstash-bro*
*:logstash-beats*
*:elastalert_status*

EOF
}

print_cardinality_field()
{
cat << EOF

The Cardinality Field will Count the number of unique values for this field.
What field do you want to be the Cardinality Field?

EOF
}

print_min_cardinality()
{

cat << EOF

The Minimum Cardinality value will alert you when there are less than 
X unique values in that field.

What is the minimum Cardinality value?

EOF

}

print_max_cardinality()
{

cat << EOF

The Maximum Cardinality value will alert you when there are more than 
X unique values in that field.

What is the maximum Cardinality value?

EOF

}

print_alertoption()
{

cat << EOF

By default, all matches will be written back to the elastalert index.  
If you would like to add an additional alert method please choose from 
the below options. To use the default Email, type 'email'.

EOF

}


print_confirm_options()
{

cat << EOF

below are the following options that will be configured:
    Rule Name: $rulename
    Index: $indexname
    Cardinality Field: $cardinalityfield
    Min Cardinality: $mincardinality
    Max Cardinality: $maxcardinality
    Timeframe: $timeframe
    Alert option: $alertoption
    Email Address: $emailaddress
    Filter Type: $filtertype
    Field Type: $fieldtype
    Field Value: $fieldvalue

Would you like to proceed? (Y/N)

EOF

}

print_cardinality_timeframe()
{

cat << EOF

The Cardinality Timeframe is defined as the number of unique values 
in the most recent X hours.

What is the timeframe?

EOF

}

gen_cardinality_rule()
{

print_cardinality_welcome
print_name_prompt

read rulename

print_prompt_index

read indexname

print_cardinality_field

read cardinalityfield

print

print_min_cardinality

read mincardinality

print_max_cardinality

read maxcardinality

print_cardinality_timeframe
read timeframe

print_alertoption

read alertoption
  	
if [ ${alertoption,,} = "email" ]; then
    echo "Using default alert type of Email."
    echo "Please enter an email address you want to send the alerts to. The email does not need to be legitimate if only writing"
    echo "the alerts back to the elastalert index.  If you want to send legitimate emails ensure the Master Node is properly configured"
    echo "to send emails."
    read emailaddress
fi
    echo ""

cat << EOF

By default this script will use a wildcard seach that will include all logs 
for the index choosen above.

Would you like to use a specific filter? (Y/N)

EOF

read filteroption

if [ ${filteroption,,} = "y" ]; then

cat << EOF

This script will allow you to generate basic filters.  
For complex filters visit 
https://elastalert.readthedocs.io/en/latest/recipes/writing_filters.html

Term: Allows you to match a value in a field.  
For example you can select the field source_ip and the value 192.168.1.1 
or choose a specific logtype you want the rule to apply to ie. 
field_type: event_type and the field_value bro_http

Wildcard: Allows you to use the wildcard * in the field_value.  
For example field_type: useragent and field_value: *Mozilla* 

Please choose from the following filter types.

term or wildcard

EOF

fi

read filtertype

if [ ${filtertype,,} = "term" ]; then
    echo "What field do you want to use?"
    read fieldtype
    echo "What is the value for the field."
    read fieldvalue
elif [ ${filtertype,,} = "wildcard" ]; then
    echo "What field do you want to use?"
    read fieldtype
    echo "What is the value for the field."
    read fieldvalue
else
    filtertype="wildcard"
    fieldtype="event_type"
    fieldvalue="*"
fi

print_confirm_options

read buildrule

if [ ${buildrule,,} = "n" ]; then
    echo "Rule building terminated"
    main_menu
fi

currentdirectory=$(pwd)

cat << EOF

Building rule and placing it in the following directory: 
$currentdirectory 

I recommend you test the rule by using the so-elastalert-test-rule script

After you test the script, move it to the /etc/elastalert/rules 
on the Master Node.

EOF

cp cardinality_rule_template.yaml $rulename.yaml

sed -i 's|name-placeholder|'"$rulename"'|g' $rulename.yaml 
sed -i 's|index-placeholder|'"$indexname"'|g' $rulename.yaml
sed -i 's|cardinality-field-placeholder|'"$cardinalityfield"'|g' $rulename.yaml
sed -i 's|min_cardinality-placeholder|'"$mincardinality"'|g' $rulename.yaml
sed -i 's|max_cardinality-placeholder|'"$maxcardinality"'|g' $rulename.yaml
sed -i 's|timeframe-placeholder|'"$timeframe"'|g' $rulename.yaml
sed -i 's|alert-placeholder|'"$alertoption"'|g' $rulename.yaml
sed -i 's|alert-option-placeholder|'"$alertoption"'|g' $rulename.yaml
sed -i 's|alert-option-value-placeholder|'"$emailaddress"'|g' $rulename.yaml
sed -i 's|filter-type-placeholder|'"$filtertype"'|g' $rulename.yaml
sed -i 's|field-type-placeholder|'"$fieldtype"'|g' $rulename.yaml
sed -i 's|field-value-placeholder|'"$fieldvalue"'|g' $rulename.yaml

}

gen_blacklist_rule()
{

#elif [ $userselect = "2" ] ; then
print_blacklist_welcome
print_name_prompt

read rulename

cat << EOF 

What elasticsearch index do you want to search?

Below are the default Index Patterns for Security Onion

*:logstash-bro*
*:logstash-beats*
*:elastalert_status*

EOF
    
read indexname

echo "The blacklist rule will check a certain field against a blacklist, and match if it is in the blacklist."
echo "What field do you want to compare to the blacklist?"
echo ""

read comparekey

echo ""
echo "The blacklist file should be a text file with a single value per line."
echo "Where is the location of the blacklist file?"
echo ""

read blacklistfile

echo ""
echo "By default, all matches will be written back to the elastalert index.  If you would like to add an additional alert method please"
echo "choose from the below options. To use the default Email type email."
echo ""

read alertoption

if [ ${alertoption,,} = "email" ] ; then
    echo "Using default alert type of Email."
    echo "Please enter an email address you want to send the alerts to. The email does not need to be legitimate if only writing"
    echo "the alerts back to the elastalert index.  If you want to send legitimate emails ensure the Master Node is properly configured"
    echo "to send emails."
    read emailaddress
fi

echo ""
echo "By default this script will use a wildcard seach that will include all logs for the index choosen above."
echo "Would you like to use a specific filter? (Y/N)"

read filteroption

if [ ${filteroption,,} = "y" ] ; then
    echo "This script will allow you to generate basic filters.  For complex filters visit https://elastalert.readthedocs.io/en/latest/recipes/writing_filters.html"
    echo ""
    echo "Term: Allows you to match a value in a field.  For example you can select the field source_ip and the value 192.168.1.1"
    echo "or choose a specific logtype you want the rule to apply to ie. field_type: event_type and the field_value bro_http"
    echo ""
    echo "Wildcard: Allows you to use the wildcard * in the field_value.  For example field_type: useragent and field_value: *Mozilla* "
    echo ""
    echo "Please choose from the following filter types: term or wildcard "
    echo ""

    read filtertype

    if [ ${filtertype,,} = "term" ] ; then
        echo "What field do you want to use?"
        read fieldtype
        echo "What is the value for the field."
        read fieldvalue
    elif [ ${filtertype,,} = "wildcard" ] ; then
        echo "What field do you want to use?"
        read fieldtype
        echo "What is the value for the field."
        read fieldvalue
    fi
    else
        filtertype="wildcard"
        fieldtype="event_type"
        fieldvalue="*"
    fi

    echo ""
    echo "below are the following options that will be configured:"
    echo "    Rule Name: $rulename"
    echo "    Index: $indexname"
    echo "    Compare Key: $comparekey"
    echo "    Blacklist file location: $blacklistfile"
    echo "    Alert option: $alertoption"
    echo "    Email Address: $emailaddress"
    echo "    Filter Type: $filtertype"
    echo "    Field Type: $fieldtype"
    echo "    Field Value: $fieldvalue"
    echo ""
    echo "Would you like to proceed? (Y/N)"
        read buildrule
        
    if [ ${buildrule,,} = "n" ] ;then
        exit
    fi

    currentdirectory=$(pwd)

    echo "building rule and placing it in the following directory: $currentdirectory "
    echo ""
    echo "I recommend you test the rule by using the so-elastalert-test-rule script"
    echo ""
    echo "After you test the script, move it to the /etc/elastalert/rules on the Master Node."

    cp blacklist_rule_template.yaml $rulename.yaml

    sed -i 's|name-placeholder|'"$rulename"'|g' $rulename.yaml
    sed -i 's|index-placeholder|'"$indexname"'|g' $rulename.yaml
    sed -i 's|compare-key-placeholder|'"$comparekey"'|g' $rulename.yaml
    sed -i 's|blacklist-file-placeholder|'"$blacklistfile"'|g' $rulename.yaml
    sed -i 's|alert-placeholder|'"$alertoption"'|g' $rulename.yaml
    sed -i 's|alert-option-placeholder|'"$alertoption"'|g' $rulename.yaml
    sed -i 's|alert-option-value-placeholder|'"$emailaddress"'|g' $rulename.yaml
    sed -i 's|filter-type-placeholder|'"$filtertype"'|g' $rulename.yaml
    sed -i 's|field-type-placeholder|'"$fieldtype"'|g' $rulename.yaml
    sed -i 's|field-value-placeholder|'"$fieldvalue"'|g' $rulename.yaml

}

main_menu()
{

while true; do

    print_welcome_message

    read userselect

    case $userselect in

    1)
        gen_cardinality_rule
        ;;
    2)
        gen_blacklist_rule
        ;;
    9)
        exit_prog
        ;;
    esac

done
}

main_menu
