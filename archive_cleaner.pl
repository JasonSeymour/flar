#!/usr/bin/perl

use strict;
use warnings;
use DateTime;
use DateTime::Format::Strptime;
use DateTime::Duration;

my $root = '/flars';
my %hosts;

die "Unable to access $root or is not a directory\n" unless -d $root;

opendir(my $DIR, $root) or die "Unable to open $root for reading: $!\n";

while(my $fileObj = readdir $DIR)
{
	my $hostDir = $root . '/' . $fileObj;
	# Skip this file object unless it is a directory
	next unless -d $hostDir;
	# Also skip the . and .. file objects even though they are directories
	next if $fileObj eq '.' or $fileObj eq '..';	
	# Skip the .snapshot subdirectory
	next if $fileObj eq '.snapshot';
	print("Processing host: $fileObj\n");
	$hosts{$fileObj} = 0;
	opendir(my $SUBDIR, $hostDir) or die "Unable to open the hostname based subdirectory $hostDir: $!\n";
	@flars = grep(/\.flar$/,readdir($SUBDIR));
	foreach my $flar (@flars)
	{
		my ($name,$dateCode,$extension) = split(/\./,$flar);
		my $strp = DateTime::Format::Strptime->new(pattern   => '%Y%m%d',);
		my $snapDate = $strp->parse_datetime($dateCode);
}
		



closedir($DIR);
