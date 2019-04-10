# https://github.com/i3/i3/issues/838#issuecomment-447289228
# bindsym <binding> [con_mark=_last_focused] focus
{ pkgs, ... }:
pkgs.writeScript "i3-focus-last"
''
epochMillis(){
	echo $(($(date +%s%N)/1000000))
}

lastTime=$(epochMillis)
minFocusedTime=1000

xprop -root -spy _NET_ACTIVE_WINDOW |
while read line
do
	currentFocus=$(echo "$line" | awk -F' ' '{printf $NF}')
	if [ "$currentFocus" = "0x0" -o "$currentFocus" = "$prevFocus" ]
	then
		continue
	fi
	currentTime=$(epochMillis)
	period=$(($currentTime-$lastTime))
	lastTime=$currentTime
	if [ $period -gt $minFocusedTime  -o "$currentFocus" = "$prevPrevFocus" ]
	then
		[[ -z "$prevFocus" ]] || i3-msg "[id=$prevFocus] mark _last_focused" > /dev/null
		prevPrevFocus=$prevFocus
	fi
	prevFocus=$currentFocus
done
''
