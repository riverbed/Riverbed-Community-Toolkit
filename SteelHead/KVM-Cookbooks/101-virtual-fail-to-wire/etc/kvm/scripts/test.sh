L3="0"                                                                              #
L1="0"                                                                              #
readarray -t routing < /etc/kvm/scripts/rvbd-routing.cfg # Read in file             #
ROUTE=${#routing[@]}                                                                #
L1=$ROUTE                                                                           #

echo "${routing[@]} "

echo " "

echo "${routing[4]} "



