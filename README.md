# so-elastalert-create
This Script will walk you through creating elastalert rules. For best results, copy this script into the /usr/sbin/ directory and run in the folder containing the rules you want to test. 

# so-elastalert-create-whiptail
This script uses whiptail as a GUI frontend to walk you through createing elastalert rules.

I recommend that you mount a new volume to the Elastalert docker contaion to put the rules in to test prior to moving them the the /etc/elastalert/rules folder.

Here is an example:
Make a folder on the local filesystem to mount to the docker contation
   - sudo mkdir /etc/elastalert/test_rules/
Add the following options the the /etc/nsm/securityonion.conf file
    - ELASTALERT_OPTIONS="--volume /etc/elastalert/test_rules:/etc/elastalert/test_rules:ro"
Restart the Elastalert Docker container
    - so-elastalert-restart
You can also test the rule using the so-elastalert-test script to verify the rule is alerting as expected.
