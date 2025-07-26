#!/bin/bash

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

# Duration in seconds to display the background
DURATION=1795.0
# Duration of the transition in seconds, default is 2 seconds
TRANSITION=5.0


for arg in "$@"
do
    # Variables
    FILE_NAME=$(basename $arg)
    # SLIDESHOW_NAME=$(zenity --entry --text="Insert wallpaper slideshow name" --entry-text=$arg)
    SLIDESHOW_NAME=$arg

    # Prepare folders
    mkdir -p $HOME/.backgrounds
    mkdir -p $HOME/.local/share/gnome-background-properties

    # Create Slideshow XML
    FILE="$HOME/.backgrounds/$FILE_NAME.xml"
    # Random order
    IMGS=($(ls $arg/*.{jpg,jpeg,png,gif,JPG,JPEG,PNG,GIF} 2>/dev/null | sort -R))
    COUNTER=`expr ${#IMGS[*]} - 1`

    echo "<background><starttime></starttime>" > $FILE

    for ((i=0;  i<$COUNTER; i++))
    do
        echo "<static><duration>$DURATION</duration><file>$(realpath ${IMGS[$i]})</file></static>" >> $FILE
        echo "<transition><duration>$TRANSITION</duration><from>$(realpath ${IMGS[$i]})</from>" >> $FILE
        echo "<to>${IMGS[`expr $i + 1`]}</to></transition>" >> $FILE
    done

    # last picture to first one
    echo "<static><duration>$DURATION</duration><file>$(realpath ${IMGS[$COUNTER]})</file></static>" >> $FILE
    echo "<transition><duration>$TRANSITION</duration><from>$(realpath ${IMGS[$COUNTER]})</from>" >> $FILE
    echo "<to>$(realpath ${IMGS[0]})</to></transition>" >> $FILE

    echo "</background>" >> $FILE

    # Create Gnome Background Definition
    FILEG="$HOME/.local/share/gnome-background-properties/$FILE_NAME.xml"
    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > $FILEG
    echo "<!DOCTYPE wallpapers SYSTEM \"gnome-wp-list.dtd\">" >> $FILEG
    echo "<wallpapers>" >> $FILEG
    echo "  <wallpaper deleted=\"false\">" >> $FILEG
    echo "    <name>$SLIDESHOW_NAME</name>" >> $FILEG
    echo "    <filename>$FILE</filename>" >> $FILEG
    echo "    <options>zoom</options>" >> $FILEG
    echo "  </wallpaper>" >> $FILEG
    echo " </wallpapers>" >> $FILEG

done

IFS=$SAVEIFS
