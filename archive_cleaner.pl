#!/usr/bin/perl

use strict;
use warnings;
use Date::Calc qw(Today Delta_Days);
use Email::Sender::Simple qw(sendmail);
use Email::Simple;
use Email::Simple::Creator;

my $root = '/flars';
my %hostStatus;
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
	$hostStatus{$fileObj} = 0;
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
			$hostStatus{$fileObj} = 1;
		} 
		elsif($ddays >= 95)
		{
			# When snapshot files reach this age we delete them
			my $fullPath = $hostDir . '/' . $flar;
			unlink($fullPath) or die "Unable to delete $fullPath because: $!\n";
		}
		# Any snapshot that is less than 95 days old goes into a list for reporting
		if($ddays < 95)
		{
			push(@{$hosts{$fileObj}}, $flar);	
		}

	}
	closedir($SUBDIR);
}
closedir($DIR);

# Now we sort the hosts into good and bad lists
my $badMessage = "Hosts missing recent snapshot\n" . "---------------------------------------\n";
my $goodMessage = "hosts with recent snapshot\n" . "------------------------------------\n";
foreach my $host (keys(%hostStatus))
{
	if($hostStatus{$host} == 0)
	{
		$badMessage = $badMessage . $host . ":\n";
		foreach my $snapName ( @{$hosts{$host}} )
		{
			$badMessage = $badMessage . "\t\- $snapName\n";
		}
		$badMessage = $badMessage . "\n";
	} else {
		$goodMessage = $goodMessage . $host . ":\n";
		foreach my $snapName ( @{$hosts{$host}} )
		{
			$goodMessage = $goodMessage . "\t\- $snapName\n";
		}
		$goodMessage = $goodMessage . "\n";
	}
}
		

# Assemble and send the e-mail report
my $msg = $badMessage . $goodMessage;
my $email = Email::Simple->create(
	header => [
		To	=> '"John Doe" <john.doe@generic.com>',
		From	=> '"Root" <root@generic.com>',
		Subject	=> "Solaris FLAR status",
	],
	body	=> $msg,
);
sendmail($email);

