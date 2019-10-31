#!/usr/bin/perl

use strict;
use warnings;

my $root = '/flars';
my %hosts;

die "Unable to access $root or is not a directory\n" unless -d $root;

opendir(my $DIR, $root) or die "Unable to open $root for reading: $!\n";

while(my $fileObj = readdir $DIR)
{
	# Skip this file object unless it is a directory
	next unless -d $root . '/' . $fileObj;
	# Also skip the . and .. file objects even though they are directories
	next if $fileObj eq '.' or $fileObj eq '..';	
	# Skip the .snapshot subdirectory
	next if $fileObj eq '.snapshot';
	print("Processing host: $fileObj\n");
	$hosts{$fileObj} = 0;
}


closedir($DIR);
