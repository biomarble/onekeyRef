use strict;
use warnings;
use File::Basename;

if(scalar @ARGV !=1 or !-e $ARGV[0] )
{
        print <<"End";
	author: PlantTech Technologies. Beijing.
        Usage: 
        the script is used to merge two or more individual exps

        run example: 
        	perl $0 directory  merge.exp

        results:
        	merge.exp.count.xls   #count值 

End

        exit;
}
my %exp;
my %sample;
my %allcount;
my @files=glob("$ARGV[0]/*_count.tsv");
my $outname="$ARGV[0]/all.sample.count.tsv";

foreach my $file(@files){
	readexp($file,\%exp,\%sample,\%allcount);
}

open OUT,">$outname" or die $!;
my $header="ID\t";
$header.=join "\t",(sort keys %sample);
$header=~s/\_count\.tsv//g;
print OUT "$header\n";
foreach my $gid(sort keys %exp){
	print OUT "$gid";
	foreach my $sample(sort keys %sample){
		if(exists $exp{$gid}{$sample}){
			print OUT "\t$exp{$gid}{$sample}";
		}else{
			print OUT "\t0";
		}
		
	}
	print OUT "\n";
}
close OUT;

sub readexp{
	my ($filename,$hash,$sample,$all)=@_;
	open IN,$filename or die "no such file :$filename\n";
	my $allcount=0;
	my $samplename=basename($filename);
	$sample->{$samplename}=1;
	while(<IN>){
		next if($_=~/#/);
		next if($_=~/^$/);
		my ($id,$count)=split /\s+/,$_;
		next if($id=~/^_/);
		$allcount+=$count;
		$hash->{$id}{$samplename}=$count;
	}
	close IN;
	$all->{$samplename}=$allcount;
}
