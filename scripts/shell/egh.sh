ts=$(date "+%Y%m%d%H%M%S")
cdir=$(pwd)
cp $cdir/$1 $cdir/history/$1-$ts
