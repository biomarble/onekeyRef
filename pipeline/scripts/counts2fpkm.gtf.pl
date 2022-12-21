use strict;
use warnings;
die "Count FPKM from Count matrix and GTF file\nUsage: perl $0 count.txt gene.gtf\n" if(scalar @ARGV !=2);
my %tlen;
my %glen;
open IN,$ARGV[1] or die $!; # gtf
while(<IN>){
	next if($_=~/#/);
	chomp;
	my($chr,undef,$type,$start,$end,undef,undef,undef,$str)=split /\t/,$_;
	next if($type !~/exon/);
	my $gid;
	my $tid;
	if($str=~/gene_id\s+\"([0-9a-zA-Z:._-]+)/){
		$gid=$1;
		$gid=~s/\w+://g;
		$glen{$gid}+=abs($end-$start)+1;
	}else{
		#warn "GTF malformated: gene_id tag not found\n$str\n";
	}
	if($str=~/transcript_id\s+\"([0-9a-zA-Z:._-]+)/){
		$tid=$1;
		$tid=~s/\w+://g;
		$tlen{$tid}+=abs($end-$start)+1;
	}else{
		#warn "GTF malformated: transcript_id tag not found\n$str\n";
	}
}
close IN;

my %libsize;
open IN,$ARGV[0] or die $!; # count txt
my $header=<IN>;
print "$header";
my @header=split /\s+/,$header;
while(<IN>){
	chomp;
	my @line=split /\s+/,$_;
	for(my $i=1;$i<@line;$i++){
		$libsize{$header[$i]}+=$line[$i];
	}
}
seek IN,0,0;
<IN>;
while(<IN>){
	chomp;
	my @line=split /\s+/,$_;
	$line[0]=~s/^\w+://g;
	my $length=featurelen($line[0]);
	print "$line[0]";
	for(my $i=1;$i<@line;$i++){
		my $fpkm=(1000000)*$line[$i]/($length*$libsize{$header[$i]});
		if($fpkm>=0.01 or $fpkm==0){
			$fpkm=sprintf("%.2f",$fpkm);
		}else{
			$fpkm=sprintf("%.2e",$fpkm);
		}
		print "\t$fpkm";
	}
	print "\n";
}
sub featurelen{
	my ($id)=@_;
	my $length;
	if(exists $glen{$id}){
		$length=$glen{$id}/1000;
	}elsif(exists $tlen{$id}){
		$length=$tlen{$id}/1000;
	}else{
		die "ERROR: length not found for $id !\n";
	}
	return $length;
}

