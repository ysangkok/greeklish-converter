#!/bin/bash
die () {
    echo >&2 "$@"
    exit 1
}

url_encode() {
 [ $# -lt 1 ] && { return; }

 encodedurl="$1";

 # make sure hexdump exists, if not, just give back the url
 [ ! -x "/usr/bin/hexdump" ] && { return; }

 encodedurl=`
   echo $encodedurl | hexdump -v -e '1/1 "%02x\t"' -e '1/1 "%_c\n"' |
   LANG=C awk '
     $1 == "20"                    { printf("%s",   "+"); next } # space becomes plus
     $1 ~  /0[adAD]/               {                      next } # strip newlines
     $2 ~  /^[a-zA-Z0-9.*()\/-]$/  { printf("%s",   $2);  next } # pass through what we can
                                   { printf("%%%s", $1)        } # take hex value of everything else
   ' `; # | tr 'a-z' 'A-Z'
};

[ $# -ne 2 ] && { die "Need two arguments"; }
if [[ ! ("$2" == "Gl2Gr" || "$2" == Gr2Gl) ]]; then
	die "Second parameter must be Gl2Gr or Gr2Gl";
fi

url_encode "$1";

UA="Mozilla/5.0 (Windows NT 6.2; rv:9.0.1) Gecko/20100101 Firefox/9.0.1"
curl -s --user-agent "$UA" -o submitstuff "http://services.innoetics.com/gadgets/GoogleGadget/large.aspx"
gid=$( cat submitstuff | grep -E 'gid' | sed -r 's/[^0-9]*[0-9][^0-9]*([0-9][0-9]+).*/\1/')
vars=$(grep -E "VIEWSTATE|EVENTVALIDATION|EVENTARGUMENT|EVENTTARGET" < submitstuff | sed -r 's/.*(name)="(__[A-Z]+)".*(value)="(.*)".*/\2=\4/g')
rm -f __VIEWSTATE __EVENTVALIDATION __EVENTARGUMENT __EVENTTARGET
touch __VIEWSTATE __EVENTVALIDATION __EVENTARGUMENT __EVENTTARGET
for i in $vars ; do echo $i | cut -d"=" -f2- | tee $(echo $i | cut -d'=' -f1) > /dev/null; done
curl -s --user-agent "$UA" --data-urlencode "G2GTextBox=$1" -d "$2Button.x=7&$2Button.y=7" --data-urlencode "__VIEWSTATE=$(cat __VIEWSTATE)" --data-urlencode "__EVENTVALIDATION=$(cat __EVENTVALIDATION)" --data-urlencode "__EVENTARGUMENT=$(cat __EVENTARGUMENT)" --data-urlencode "__EVENTTARGET=$(cat __EVENTTARGET)" "http://services.innoetics.com/gadgets/GoogleGadget/large.aspx?gid=$gid&text=$encodedurl" --trace-ascii trace -o output --speed-time 1 --speed-limit 100
translation="$(echo $(cat output | grep "textarea" | sed -r 's/<textarea[^>]*>([^<]*)<\/textarea>/\1/gi'))"
javascript="$(cat output | grep "var kw" | cut -d';' -f 1,2)"
echo $translation
kw="$(echo $javascript | cut -d';' -f1 | cut -d'=' -f2-)"
kw=$(node -e "JSON.stringify($kw)")
kv="$(echo $javascript | cut -d';' -f2 | cut -d'=' -f2- | python -mjson.tool)"
echo $kw
echo $kv
