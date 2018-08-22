# so-elastalert-create
This script uses whiptail as a graphical interface that will walk you through creating basic elastalert rules.  Depending on the type of alert you are building, you may need to modify the rule and build a complex query.

For more information about elastalert check out the following link: https://elastalert.readthedocs.io

This script uses NEWT_COLORS.  To manipulate the color scheme adjust the following section at the beging of the script.

export NEWT_COLORS='
window=,white
border=white,red
textbox=white
button=white
'
Once the rule is created, move it to the rules_folder directory defined in the elastalert_config.yaml
In Security Onion, the default rules_folder directory is /etc/elastalert/rules


![alt text](https://github.com/bryant-treacle/Repository_images/blob/master/so-elastalert-create-whiptail.PNG)

