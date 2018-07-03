#!/bin/bash

echo '
    ________________________________________
    < Keep Calm and Let Me Clean your System >
    ----------------------------------------
            \   ^__^
             \  (oo)\_________
                (__)\         )\/\\
                     || ----w|
                     ||     ||
    '

echo '----------  This Script Has Been Writen For Personnal Use  ----------'
echo '----------       Normaly It Won'"'"'t Break Your System        ----------'
echo '----------             But.... We Never Know               ----------'
echo '----------            Use It At Your Own Risk !            ----------'
echo '----------                 And... Maybe...                 ----------'
echo '----------  Check The Code If You Don'"'"'t Want Something ;)  ----------'



if [ $USER != "root" ];
then
    echo '[*] Please Launch This With sudo !'
    exit 0
fi

install_package () {
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $1|grep "install ok installed")

    if [ "" == "$PKG_OK" ];
    then
        echo "[*] "$1"'s not installed, i'll do it for you !"
        sudo apt-get --force-yes --yes install $1 2>/dev/null
    fi
}

home='/home/'

echo '[*] Update'  # ---------------------------------------------------------
apt-get update -y
apt-get upgrade -y
apt-get dist-upgrade -y

echo '[*] Correcting dependencies'  # --------------------------------------------------------
apt-get -f -y install

echo '[*] Clean Cache'  # ---------------------------------------------------------
apt-get clean -y

echo '[*] Clean Useless Packages And Old Kernel'  # --------------------------------------------------------
apt-get autoremove --purge -y

echo '[*] Clean Orphan packages'  # ------------------------------------------------------
install_package deborphan
deborphan | xargs apt-get -y remove --purge

echo '[*] Clean Deleted Packages Waste'  # ------------------------------------------------------
[[ $(dpkg -l | grep ^rc) ]] && sudo dpkg -P $(dpkg -l | awk '/^rc/{print $2}')

echo '[*] Clean Os Cache'  # ----------------------------------------------------
sync | tee /proc/sys/vm/drop_caches

echo '[*] Clean Thumbnails Cache'  # --------------------------------------------
for userdir in $(ls $home)
do
    for underdir in $(ls $home$userdir'/.cache/thumbnails/')
    do
        path_to_del=$home$userdir'/.cache/thumbnails/'$underdir
        rm -r $path_to_del'/'* 2>/dev/null
    done
done

echo '[*] Clean Trash'  # -------------------------------------------------------
install_package trash-cli
trash-empty

echo '[*] Clean Browser Cache'  # -----------------------------------------------
declare -a browser_list=('mozilla' 'chromium' 'chrome')

for browser in ${browser_list[@]}
do
    for userdir in $(ls $home)
    do
        rm -rf $home$userdir'/.cache/'$browser'/'
    done
done

echo '
    ____________________________________________
    < Done ! Thank You to Use The Cow Cleaner ! >
    --------------------------------------------
            \   ^__^
             \  (oo)\_________
                (__)\         )\/\\
                     || ----w|
                     ||     ||
    '
exit 0
