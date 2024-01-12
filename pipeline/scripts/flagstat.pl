use strict;
use warnings;
use File::Basename qw(basename dirname);

die "USAGE:\nperl $0  *.stat.txt  \n" if(@ARGV <1);

my @files=glob "@ARGV";
print "Sample\tTotalReads\tMapped\tProperly_Mapped\n";
foreach my $file(sort @files){
open IN,$file or die $!;
my $all;
my $second;
my $sup;
my $map;
my $pro;
while(<IN>){
$all=$1 if($_=~/^(\d+) \+ 0 in total/);
$second=$1 if($_=~/^(\d+) \+ 0 secondary/);
$sup=$1 if($_=~/^(\d+) \+ 0 supp/);
$map=$1 if($_=~/^(\d+) \+ 0 map/);
$pro=$1 if($_=~/^(\d+) \+ 0 properly/);
}
close IN;

$all=$all-$sup-$second;
$map=$map-$sup-$second;
next if($all==0);
my $ratio1=sprintf("%.2f",$map/$all*100);
my $ratio2=sprintf("%.2f",$pro/$all*100);
$file=basename($file);
$file=~s/.stat$//g;
print "$file\t$all\t$map($ratio1\%)\t$pro($ratio2\%)\n";
}
