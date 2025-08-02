braker.pl --genome=genome.fa --softmasking --cpu=$threads --bam=RNAseq.bam  --workingdir=$wdir/braker1/ 2> $wdir/braker1.log


braker.pl --genome=genome.fa --softmasking --cpu=$threads --epmode --prot_seq=proteins.fa  --workingdir=$wdir/braker2/ 2> $wdir/braker2.log


minimap2 -t $threads -ax splice:hq genome.fa all.subreads.fastq  > long_reads.sam
sort -k 3,3 -k 4,4n $wlong_reads.sam > long_reads.s.sam

collapse_isoforms_by_sam.py --input all.subreads.fastq --fq  -s long_reads.s.sam --dun-merge-5-shorter -o cupcake

stringtie2fa.py -g genome.fa -f cupcake.collapsed.gff -o cupcake.fa
gmst.pl --strand direct cupcake.fa.mrna --output gmst.out --format GFF

gmst2globalCoords.py -t cupcake.collapsed.gff -p gmst.out -o gmst.global.gtf -g genome.fa

mkdir $wdir/tsebra
cd $wdir/tsebra

tsebra.py -g $wdir/braker1/augustus.hints.gtf,$wdir/braker2/augustus.hints.gtf -e $wdir/braker1/hintsfile.gff,$wdir/braker2/hintsfile.gff -l $wdir/long_read_protocol/gmst.global.gtf -c /your/path/to/TSEBRA/config/long_reads.cfg -o tsebra.gtf
