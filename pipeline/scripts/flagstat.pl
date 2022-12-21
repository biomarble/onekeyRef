use strict;
use warnings;
use File::Basename qw(basename dirname);

die "USAGE:\nperl $0  dir \ndir contains file like   [SampleID].stat\n" if(@ARGV !=1);

my @files=glob "$ARGV[0]/*.stat";
print "Sample\tTotalReads\tMapped\tProperly_Mapped\n";
foreach my $file(sort @files){
open IN,$file or die $!;
my $all=<IN>;
<IN>;
my $sup=<IN>;
<IN>;
my $map=<IN>;
<IN>;
<IN>;
<IN>;
my $pro=<IN>;
close IN;
$all=$1 if($all=~/^(\d+)/);
$sup=$1 if($sup=~/^(\d+)/);
$map=$1 if($map=~/^(\d+)/);
$pro=$1 if($pro=~/^(\d+)/);
$all=$all-$sup;
$map=$map-$sup;
next if($all==0);
my $ratio1=sprintf("%.2f",$map/$all*100);
my $ratio2=sprintf("%.2f",$pro/$all*100);
$file=basename($file);
$file=~s/.stat$//g;
print "$file\t$all\t$map($ratio1\%)\t$pro($ratio2\%)\n";
}