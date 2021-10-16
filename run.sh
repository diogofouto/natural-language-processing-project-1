#!/bin/bash

# SETUP
rm -rf compiled images
mkdir -p compiled images


# SOURCES (SECTION 1 TRANSDUCERS) COMPILATION
for i in sources/*.txt tests/*.txt; do
	echo "Compiling: $i"
    fstcompile --isymbols=syms.txt --osymbols=syms.txt $i | fstarcsort > compiled/$(basename $i ".txt").fst
done
echo "COMPILATION COMPLETE"; echo


# SECTION 2 TRANSDUCERS CREATION
## A2R
fstinvert compiled/R2A.fst > compiled/A2R.fst

## birthR2A
fstcompose compiled/R2A.fst compiled/d2dd.fst > compiled/temp1.fst
fstconcat compiled/temp1.fst compiled/copy.fst > compiled/temp2.fst
fstconcat compiled/temp2.fst compiled/temp2.fst > compiled/temp3.fst
fstcompose compiled/R2A.fst compiled/d2dddd.fst > compiled/temp4.fst
fstconcat compiled/temp3.fst compiled/temp4.fst > compiled/birthR2A.fst

## birthA2T
fstconcat compiled/copy.fst compiled/copy.fst > compiled/temp1.fst
fstconcat compiled/temp1.fst compiled/copy.fst > compiled/temp2.fst
fstconcat compiled/temp2.fst compiled/mm2mmm.fst > compiled/temp3.fst
fstconcat compiled/temp1.fst compiled/temp2.fst > compiled/temp4.fst
fstconcat compiled/temp3.fst compiled/temp4.fst > compiled/birthA2T.fst

## birthT2R
fstinvert compiled/birthA2T.fst > compiled/temp1.fst
fstinvert compiled/birthR2A.fst > compiled/temp2.fst
fstcompose compiled/temp1.fst compiled/temp2.fst > compiled/birthT2R.fst

## birthR2L
fstcompose compiled/birthR2A.fst compiled/date2year.fst > compiled/temp1.fst
fstcompose compiled/temp1.fst compiled/leap.fst > compiled/birthR2L.fst

## Clean Temporary Files
rm -f compiled/temp*.fst


# TESTS
for i in tests/*.txt; do
	testFile="$(basename $i ".txt")"
	# To get the "R", "T", or "A" that symbols what notation the number is in
	notation="${testFile: -1}"
	# Delete that symbol from the number
	studentId="${testFile%?}"

	for j in compiled/birth$notation??.fst; do
		fst="$(basename $j '.fst')"

		echo "Testing the transducer $fst with the input $testFile (generating pdf)"
		fstcompose compiled/$testFile.fst $j | fstshortestpath > compiled/$studentId$fst.fst
		echo "PDF Generation Successful"; echo

		echo "Testing the transducer $fst with the input $testFile (stdout):"
		fstcompose compiled/$testFile.fst $j | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt
		echo
	done
done
echo "TESTING COMPLETE"; echo


# IMAGE GENERATION
for i in compiled/*.fst; do
	echo "Creating image: images/$(basename $i '.fst').pdf"
    fstdraw --portrait --isymbols=syms.txt --osymbols=syms.txt $i | dot -Tpdf > images/$(basename $i '.fst').pdf
done
echo "IMAGE GENERATION COMPLETE"; echo


# SUCCESS STATUS
echo "SCRIPT COMPLETE"


