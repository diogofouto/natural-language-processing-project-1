#!/bin/bash

mkdir -p compiled images


# SOURCES COMPILATION
for i in sources/*.txt tests/*.txt; do
	echo "Compiling: $i"
    fstcompile --isymbols=syms.txt --osymbols=syms.txt $i | fstarcsort > compiled/$(basename $i ".txt").fst
done
echo "COMPILATION SUCCESSFUL"; echo



# TESTS
for i in compiled/*test*.fst; do
	fst="$(basename $i)"
	fst="${fst%_*}"

	echo "Testing the transducer '$fst' with the input '$i' (generating pdf)"
	fstcompose $i compiled/"$fst".fst | fstshortestpath > compiled/"$(basename $i ".fst")"_result.fst
	echo "PDF Generation Successful"; echo

	echo "Testing the transducer '$fst' with the input '$i' (stdout):"
	fstcompose $i compiled/"$fst".fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt
	echo
done
echo "TESTING SUCCESSFUL"; echo



# IMAGE GENERATION
for i in compiled/*.fst; do
	echo "Creating image: images/$(basename $i '.fst').pdf"
    fstdraw --portrait --isymbols=syms.txt --osymbols=syms.txt $i | dot -Tpdf > images/$(basename $i '.fst').pdf
done
echo "IMAGE GENERATION SUCCESSFUL"; echo



# SUCCESS STATUS
echo "UTTER AND COMPLETE SUCCESS!!"


