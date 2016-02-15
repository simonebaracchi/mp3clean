#!/bin/bash

if [ "$1" == "" ]; then
	IN=`ls *.mp3`
else
	IN=$1
fi

IFS=$'\n'
for MP in $IN; do
	OUT=`echo $MP | sed 's/mp3/ogg/'`

	soundconverter -b -m audio/x-wav "$MP"

#	lv2file -m  \
#		-p bypass:0 -p input_gain:0 -p output_gain:0 \
#		-p filter1_type:10 -p filter1_gain:-16 -p filter1_freq_ptr:600 -p filter1_q:5.25  \
#		-p filter2_type:0 -p filter2_gain:0 -p filter2_freq_ptr:0 -p filter2_q:0 \
#		-p filter3_type:0 -p filter3_gain:0 -p filter3_freq_ptr:0 -p filter3_q:0 \
#		-p filter4_type:0 -p filter4_gain:0 -p filter4_freq_ptr:0 -p filter4_q:0 \
#		-p filter5_type:0 -p filter5_gain:0 -p filter5_freq_ptr:0 -p filter5_q:0 \
#		-p filter6_type:0 -p filter6_gain:0 -p filter6_freq_ptr:0 -p filter6_q:0 \
#		-p filter7_type:0 -p filter7_gain:0 -p filter7_freq_ptr:0 -p filter7_q:0 \
#		-p filter8_type:0 -p filter8_gain:0 -p filter8_freq_ptr:0 -p filter8_q:0 \
#		-p filter9_type:0 -p filter9_gain:0 -p filter9_freq_ptr:0 -p filter9_q:0 \
#		-p filter10_type:0 -p filter10_gain:0 -p filter10_freq_ptr:0 -p filter10_q:0 \
#		-i "$OUT" -o "1_$OUT" http://sapistaplugin.com/eq/param/peaking
#	lv2file -i "$OUT" -o "1_$OUT" http://plugin.org.uk/swh-plugins/split
#	mv "1_$OUT" "$OUT"
	# equalizzatore
	#	-p active1:1 -p freq1:600 -p bandwidth1:0.12 -p gain1:-16 \
	#	-p active2:1 -p frequency2:250 -p bandwidth2:0.40 -p gain2:-10 \
	lv2file -p active:1 -p gain:0.0 \
		-p active1:1 -p freq1:120 -p bandwidth1:0.22 -p gain1:-16 \
		-p active2:1 -p frequency2:300 -p bandwidth2:0.30 -p gain2:-16 \
		-p active3:1 -p frequency3:670 -p bandwidth3:0.125 -p gain3:-20 \
		-p active4:0 -p frequency4:0 -p bandwidth4:0 -p gain4:0 \
		-i "$OUT" -o "1_$OUT" http://nedko.aranaudov.org/soft/filter/2/mono
	mv "1_$OUT" "$OUT"

	echo "equalizzatore2 per registrazioni particolarmente chiuse ..."
	lv2file -p active:1 -p gain:0.0 \
		-p active1:0 -p freq1:120 -p bandwidth1:0.22 -p gain1:-16 \
		-p active2:1 -p frequency2:900 -p bandwidth2:0.12 -p gain2:-8 \
		-p active3:1 -p frequency3:500 -p bandwidth3:0.4 -p gain3:8 \
		-p active4:1 -p frequency4:1000 -p bandwidth4:0.4 -p gain4:8 \
		-i "$OUT" -o "1_$OUT" http://nedko.aranaudov.org/soft/filter/2/mono
	mv "1_$OUT" "$OUT"

	# normalizzo l'audio prima del compressore
	normalize-audio "$OUT"
	echo compressore 1
	lv2file -p peak_limit:-7 -p release_time:1 \
		-p cfrate:1.00 -p crate:0.50 \
		-i "$OUT" -o "1_$OUT" http://plugin.org.uk/swh-plugins/dysonCompress
	mv "1_$OUT" "$OUT"
	# normalizzo l'audio di nuovo
	#normalize-audio "$OUT" --gain=6dB
	echo splitto in stereo
	lv2file -i "$OUT" -o "1_$OUT" http://plugin.org.uk/swh-plugins/split
	mv "1_$OUT" "$OUT"
	echo compressore multiband
	#lv2file -p listen:1 -p l_m:0.100 -p m_h:0.320 \
	#	-p l_comp:0.300 -p m_comp:0.300 -p h_comp:0.350 \
	#	-p l_out:0.500 -p m_out:0.500 -p h_out:0.540 \
	#	-p attack:0.2 -p release:0.6 -p stereo:0.50 -p process:0.4 \
	#	-i "$OUT" -o "1_$OUT" http://drobilla.net/plugins/mdala/MultiBand

	lv2file -p numbandas:5 \
		-p sel_frec1:100 \
		-p sel_frec2:300 \
		-p sel_frec3:1000 \
		-p sel_frec4:2000 \
		-p peak_rms:-1 \
		-p attack-B1:100 \
		-p release-B1:600 \
		-p threshold-B1:-15 \
		-p ratio-b1:5 \
		-p makeup_gain_B1:0 \
		-p mute_solo_B1:1 \
		-p attack-B2:100 \
		-p release-B2:600 \
		-p threshold-B2:-15 \
		-p ratio-b2:8 \
		-p makeup_gain_B2:0 \
		-p mute_solo_B2:1 \
		-p attack-B3:100 \
		-p release-B3:600 \
		-p threshold-B3:-15 \
		-p ratio-b3:10 \
		-p makeup_gain_B3:0 \
		-p mute_solo_B3:1 \
		-p attack-B4:100 \
		-p release-B4:600 \
		-p threshold-B4:-15 \
		-p ratio-b4:8 \
		-p makeup_gain_B4:0 \
		-p mute_solo_B4:1 \
		-p attack-B5:100 \
		-p release-B5:600 \
		-p threshold-B5:-15 \
		-p ratio-b5:5 \
		-p makeup_gain_B5:0 \
		-p mute_solo_B5:1 \
		-p output_g:5 \
		-i "$OUT" -o "1_$OUT" http://miplug.in/plugins/dynamic5band/stereo



	mv "1_$OUT" "$OUT"
	# fake stereo
	lv2file -p width:0.78 -p delay:0.43 -p balance:0.50 -p mod:0 -p rate:0.50 \
		-i "$OUT" -o "1_$OUT" http://drobilla.net/plugins/mdala/Stereo
	mv "1_$OUT" "$OUT"
	soundconverter -b -m audio/mpeg -s ".mp3" "$OUT"
	rm "$OUT"

	lltag --yes --ARTIST LeafRock --ALBUM `date "+%F"` --format "%n" --format "%n %t" $MP
done
