#!/usr/bin/perl

use strict;
use warnings;
use Date::Calc qw(Today Delta_Days);
use Net::SMTP;

my $root = '/flars';
my %hosts;

die "Unable to access $root or is not a directory\n" unless -d $root;

opendir(my $DIR, $root) or die "Unable to open $root for reading: $!\n";

my ($nowYear,$nowMonth,$nowDay) = Today();

while(my $fileObj = readdir $DIR)
{
	my $hostDir = $root . '/' . $fileObj;
	# Skip this file object unless it is a directory
	next unless -d $hostDir;
	# Also skip the . and .. file objects even though they are directories
	next if $fileObj eq '.' or $fileObj eq '..';	
	# Skip the .snapshot subdirectory
	next if $fileObj eq '.snapshot';
	$hosts{$fileObj} = 0;
	opendir(my $SUBDIR, $hostDir) or die "Unable to open the hostname based subdirectory $hostDir: $!\n";
	my @flars = grep(/\.flar$/,readdir($SUBDIR));
	foreach my $flar (@flars)
	{
		my ($name,$dateCode,$extension) = split(/\./,$flar);
		my ($snapYear,$snapMonth,$snapDay) = split(/\-/,$dateCode);
		my $ddays = Delta_Days($snapYear,$snapMonth,$snapDay,$nowYear,$nowMonth,$nowDay);
		# Set a flag if this snapshot is less than 32 days old so we can determine if a snapshot was missed
		if($ddays < 32)
		{
			$hosts{$fileObj} = 1;
		} 
		elsif($ddays > 95)
		{
			# When snapshot files reach this age we delete them
			my $fullPath = $hostDir . '/' . $flar;
			unlink($fullPath) or die "Unable to delete $fullPath because: $!\n";
		}

	}
	closedir($SUBDIR);
}
closedir($DIR);

# Walk the host hash and call out any hosts without a recent snapshot

my $smtp = Net::SMTP->new('mailhost.sargento.com');
$smtp->mail($ENV{USER});
if ($smtp->to('jason.seymour@sargento.com'))
{
	$smtp->data();
	$smtp->datasend("To: ITUnixAdmins\n");
	$smtp->datasend("Subject: Solaris FLAR status\n");
	$smtp->datasend("\n");
	$smtp->datasend("Beginning of host report\n");
	foreach my $host (keys(%hosts))
	{
		if($hosts{$host} == 0)
		{
			$smtp->datasend("Host $host is missing a recent flash archive\n\n");
		}
	}
	$smtp->dataend();
} else {
	print "Error: ", $smtp->message();
}
$smtp->quit();

