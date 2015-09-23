#!/usr/bin/ksh
. $(dirname $0)/../config/sys-dash.env 
 
showMainMenu(){
    while true
    do
        clear
        echo "***************"
        echo "Main Admin Menu"
        echo "***************"
        PS3="Select item: "
        select selectedItem in Quit "Run All" $ITEM_LIST; 
        do
            case $selectedItem in
            Quit)   exit 0 ;;
            *All)   
                    for item in $ITEM_LIST; 
                    do
                        item_toString $item 
                        printf "Press Enter to continue (q to quit)> "
                        read input
                        if [ "$input" = "q" ]
                        then
                            break
                        fi
                        clear
                    done
                    break ;;
            *)      item_isValid $selectedItem
                    if [ $? -eq 0 ]
                    then
                        echo ""
                        echo "Check Output"
                        echo "********************"
                        item_check $selectedItem
                        if [ $? -eq 2 ]
                        then
                            echo ""
                            echo "Problem indicator found: $INDICATOR"
                        fi
                        showExploreItemMenu
                    else
                        echo "Invalid Option"
                    fi
                    break ;;
            esac
        done
        printf "Press Enter to continue"
        read line
    done
}
showExploreItemMenu(){
    while true;
    do
        MAIN=
        echo ""
        echo "Item Options"
        echo "********************"
        PS3="Explore Item: "
        select suboption in "Main Menu" "Run Again" "Check Description" "Problem Indicators" "Possible Fix"
        do
            case $suboption in 
            Main*)          MAIN="true"; break ;;
            *Again)         echo ""; item_check $selectedItem ;;
            *Description)   echo ""; item_description $selectedItem 
                            echo "Example Commands:"; item_commands $selectedItem ;;
            *Indicators)    echo ""; item_indicators $selectedItem ;;
            *Fix)           echo ""; item_fixMethod $selectedItem ;;
            *)              echo "DO WHAT?!?" ;;
            esac
        done
        if [ $MAIN ]; then break; fi
    done
}

# Run
showMainMenu