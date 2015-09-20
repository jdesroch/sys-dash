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
# Echo appropriate output
# return 0 (pass) or 2 (fail)
<item_name>_check() {
    # Expected zone to be checked
    zone=$1
    # *DO NOT* make changes to the system
    # Run commands to check status
    # Echo useful output and return 0 or 2
    echo "TODO: Fail state output"
    return 2

    echo "TODO: Passing state output"
    return 0
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