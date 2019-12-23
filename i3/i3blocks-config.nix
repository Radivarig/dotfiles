{pkgs, ...}:
with pkgs;
''
[size]
command=df --output=avail /dev/disk/by-label/root -BG | awk '{getline; print $0}'
interval=5
color=#F4C2B4

[battery]
command=echo ⚡ $(${acpi}/bin/acpi | awk '{ print $4 }' | tr -d \,)
interval=5
color=#F4C2F4

[volume]
command=echo ♪ $(amixer get Master | awk '$0~/Left.*%/{print $5}' | tr -d '[]') $(amixer get Master | awk '$0~/Left.*%/{print $6}' | tr -d '[]')
interval=1
color=#A4C2F4

[ip]
command=ifconfig | grep -C 1 'BROADCAST RUNNING' | awk '/inet addr:*/{gsub("addr:","");print $2}'
interval=5
color=#91E78B

[time]
command=echo ⏰ $(date "+%H:%M")
interval=5
color=#A4B3D5

[date]
command=date "+%d/%m/%Y"
interval=5
color=#AAAAAA
''