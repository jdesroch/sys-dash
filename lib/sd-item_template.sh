######################################
#
#   System Check: <item_name>
#   Author: <creator>
#   Created: <date>
#
#   Date    Change
#   ----    ------
#
#
######################################

<item_name>_title() {
    echo "<item_name>"
}

# Non-negative integer of how much history is kept
<item_name>_historySize() {
    echo 0
}

# Space separated list of local zones (Solaris VMs) that should pass this check
<item_name>_zones() {
    echo "global"
}

# Space separated list of tags to be used for organizing item views
<item_name>_tags() {
    echo "new"
}

# Run checks and validate results
# Returns 0 (pass) or 2 (fail)
#
# Helper methods...
# Run command on given container/zone
#   item_xc <zone> <command>
# Send newline-safe output and the appropriate return value
#   item_pass <output>
#   item_fail <output>
<item_name>_check() {
    # Zone/container to be checked
    zone=$1
    # *DO NOT* make changes to the system

    #TODO Example
    #RES=$(item_xc $zone <cammand>)
    #
    #if [ $? -gt 0 ]
    #then
    #   item_fail "Custom failure description - \n$RES"
    #else
    #   item_pass "Custom passing description - \n$RES"
    #fi
}

<item_name>_description() {
    echo "TODO: What is being checked"
}

# Commands that are run during check
# Help admins reproduce the output
<item_name>_commands() {
    echo "TODO: Commands that are run"
}

# Problems that may occur in the output
<item_name>_indicators() {
    echo "TODO: What to check for in output"    
}

# Potential fix actions
<item_name>_fixMethod() {
    echo "TODO:..."
}

<item_name>_hasAutoFix() {
    #TODO if possible define and return 0
    return 1
}

<item_name>_autoFix() {
    #TODO if possible define and remove return 1
    return 1
}