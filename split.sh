#!/bin/bash

DST=temp
PDIR=`pwd`
mkdir -p $DST
mkdir -p sporche

for SPLIT in `ls | grep -i ".mp3"`; do
	#mp3splt -s -p th=-27,nt=0,off=0,min=3,trackmin=90,rm -o "$DST/@n_(@m2.@s2-@M2.@S2)" $SPLIT
	mp3splt -s -p th=-30,nt=0,off=0,min=3,trackmin=90,rm -o "$DST/@n" $SPLIT
	rm mp3splt.log
done
cp -r $DST sporche

cd $DST
for OUT in `ls *.mp3`; do
	$PDIR/mp3clean.sh $OUT
done
