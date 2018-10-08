
#!/usr/bin/env bash
usage () {
  echo "usage: $0 <pfx> "
  echo "  (e.g. if your sequence file is named condition1.fastq,"
  echo "   the prefix is \"condition1\")"
  echo ""
  echo "Example:"
  echo "$0 condition1"
}

PREFIX=$1

echo "Performing inital trimming on $PREFIX..."
echo "Processing stats for $PREFIX" > $PREFIX-barcodestats.txt
echo "Total sequences: " >> $PREFIX-barcodestats.txt
egrep -c '^@' $PREFIX.fastq >> $PREFIX-barcodestats.txt


# Pull reads that have genome sequence
echo "$PREFIX: Searching for reads with an genome sequence..."
echo "$PREFIX: Removing genome sequence and trimming first bp..."
cutadapt -a TGCGCCGTAGTCCCAATGAAAAACCTATGGACTTTGTTTTGGGTAGCATCAGGAATCTGAACC -u 1 -M 15 --discard-untrimmed -o $PREFIX.trim1.fastq $PREFIX.fastq >$PREFIX.trim1.cutadapt_log.txt
echo "Sequences with genomic region: " >> $PREFIX-barcodestats.txt
egrep -c '^@' $PREFIX.trim1.fastq >> $PREFIX-barcodestats.txt


# Demultiplex reads based on barcodes
echo "$PREFIX: Pulling reads with each barcode..."
cutadapt -a PAO1-B11=GTGTCGTGGG -a PA14-1=CAAAAGGACA -a B23-2=GCCTATTGTG -a CF18-1=GTTACGTCAA -a MSH10-2=TATCAGATTT -a S54485-1=TTAAACTAGG -a extrabc=CGACAAGTGG --no-trim --untrimmed-output $PREFIX.nobarcode.fastq -o $PREFIX.{name}.fastq $PREFIX.trim1.fastq >$PREFIX.barcodes.cutadapt_log.txt

# counting
echo "PAO1-B11 (GTGTCGTGGG): " >> $PREFIX-barcodestats.txt
egrep -c '^@' $PREFIX.PAO1-B11.fastq >> $PREFIX-barcodestats.txt
echo "PA14-1 (CAAAAGGACA): " >> $PREFIX-barcodestats.txt
egrep -c '^@' $PREFIX.PA14-1.fastq >> $PREFIX-barcodestats.txt
echo "B23-2 (GCCTATTGTG): " >> $PREFIX-barcodestats.txt
egrep -c '^@' $PREFIX.B23-2.fastq >> $PREFIX-barcodestats.txt
echo "CF18-1 (GTTACGTCAA): " >> $PREFIX-barcodestats.txt
egrep -c '^@' $PREFIX.CF18-1.fastq >> $PREFIX-barcodestats.txt
echo "MSH10-2 (TATCAGATTT): " >> $PREFIX-barcodestats.txt
egrep -c '^@' $PREFIX.MSH10-2.fastq >> $PREFIX-barcodestats.txt
echo "S54485-1 (TTAAACTAGG): " >> $PREFIX-barcodestats.txt
egrep -c '^@' $PREFIX.S54485-1.fastq >> $PREFIX-barcodestats.txt
echo "extrabc (CGACAAGTGG): " >> $PREFIX-barcodestats.txt
egrep -c '^@' $PREFIX.extrabc.fastq >> $PREFIX-barcodestats.txt
echo "reads with no barcode: " >> $PREFIX-barcodestats.txt
egrep -c '^@' $PREFIX.nobarcode.fastq >> $PREFIX-barcodestats.txt

#look to see "barcodes" that are not getting demultiplexed
fastqc $PREFIX.nobarcode.fastq
unzip $PREFIX.nobarcode_fastqc.zip
echo "Overrepresented sequences that didn't match barcodes: " >> $PREFIX-barcodestats.txt
sed -n '/>>Overrepresented sequences/{n;p;n;p;n;p;n;p;n;p;n;p;n;p}' ./$PREFIX.nobarcode_fastqc/fastqc_data.txt >> $PREFIX-barcodestats.txt

