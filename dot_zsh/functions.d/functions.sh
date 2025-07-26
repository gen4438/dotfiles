# パーセントエンコード・デコード
function url_encode {
  echo "$1" | nkf -WwMQ | sed 's/=$//g' | tr = % | tr -d '\n'
}

function url_decode {
  echo "$1" | tr % = | nkf -WwmQ
}

# unicode エンコード・デコード
function unicode_encode {
  echo -en "$1" | nkf -W -w32B0 | xxd -ps -c4 | sed 's/^0\{4\}//' | xargs printf '\\u%4s'
}

function unicode_decode {
   echo -en "$1"
}

# pandoc
function pandoc_md2html {
    local name=$(echo $1 | sed 's/.[^.]*$//')
    pandoc $1 --self-contained -c ~/Sources/github-markdown-css/github-markdown.css -o ${name}.html
}

function pandoc_md2pdf {
    md2html $1
    local name=$(echo $1 | sed 's/.[^.]*$//')
    google-chrome --disable-crash-reporter --disable-gpu --headless --print-to-pdf=${name}.pdf ${name}.html
}

# 現在のディレクトリの中にあるディレクトリを番号指定で移動
function cdlist {
    local -a dirlist opt_f=false
    local i d num=0 dirnum opt opt_f
    while getopts ":f" opt ; do
        case $opt in
            f ) opt_f=true ;;
        esac
    done
    shift $(( OPTIND -1 ))
    dirlist[0]=..
    # external pipe scope. array is established.
    for d in * ; do test -d "$d" && dirlist[$((++num))]="$d" ; done
    # TODO: Is seq installed?
    for i in $( seq 0 $num ) ; do printf "%3d %s%b\n" $i "$( $opt_f && echo -n "$PWD/" )${dirlist[$i]}" ; done
    read -p "select number: " dirnum
    if [ -z "$dirnum" ] ; then
        echo "$FUNCNAME: Abort." 1>&2
    elif ( echo $dirnum | egrep '^[[:digit:]]+$' > /dev/null ) ; then
        cd "${dirlist[$dirnum]}"
    else
        echo "$FUNCNAME: Something wrong." 1>&2
    fi
}
