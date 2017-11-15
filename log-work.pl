#!/usr/bin/env perl
#
# (c) 2017 Tobin C. Harding <me@tobin.cc>
# Licensed under the terms of the GNU GPL License version 2

use warnings;
use strict;
use POSIX;
use v5.14;
use Term::ANSIColor qw(:constants);
use Getopt::Long qw(:config no_auto_abbrev);
use File::ReadBackwards;

my $VERSION = '0.01';

my @MONTHS = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
my @DAYS = qw(Sun Mon Tue Wed Thu Fri Sat Sun);

# Command line options.
my $help = 0;
my $debug = 0;

sub help
{
	my ($exitcode) = @_;

	print << "EOM";

Usage: $0 COMMAND [OPTIONS]
Version: $VERSION

Commands:

	start	Start a work session.
	stop	Finish a work session.
	report	Show report of logged hours.

	end	Same as stop.
	show	Same as report.

Options:

	-h, --help, --version    Display this help and exit.

Create log entries (start and stop work sessions). View summary
report of hours logged.

EOM
	exit($exitcode);
}

GetOptions(
	'h|help'		=> \$help,
	'version'		=> \$help,
) or help(1);

help(0) if ($help);

if (@ARGV < 1) {
	help(128);
}

my $command = $ARGV[0];
shift @ARGV;

if ($command =~ /^start/) {
	start();
} elsif ($command =~ /^(stop|end)/){
	stop(@ARGV);
} elsif ($command =~ /^(report|show)/) {
	report(@ARGV);
} else {
	printf "\nUnknown command: %s\n", $command;
	help(129);
}

exit(0);

sub say
{
	print @_ . "\n";
}

sub todo
{
	my ($msg) = @_;
	print "TODO: " . $msg . "\n";
}

sub start
{
	if (active_session()) {
		die 'You currently have an active session\n';
	}

	my $filename = get_log_filename();
	open my $fh, '>>', $filename or die "$0: $filename: $!\n";

	my $entry = start_entry();
	print $fh $entry;

	close($fh);

	print "logging session\n";
}

sub start_entry
{
	my $date = yyyy_mm_dd();
	my $time = now();

	return sprintf("%s %s ", $date, $time);
}

sub active_session
{
	my $entry = last_log_entry();
	my $start = start_entry();

	return (length($entry) == length($start));
}

sub last_log_entry
{
	my $filename = get_log_filename();
	my $backwards = File::ReadBackwards->new($filename);
	my $last_line = $backwards->readline;
}

sub get_log_filename
{
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
	$year += 1900;
	return sprintf("%s.log", $year);
}

sub yyyy_mm_dd
{
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
	$year += 1900;
	$mon += 1;
	return sprintf("%d-%d-%d", $year, $mon, $mday);
}

sub now
{
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
	return sprintf("%02d:%02d",$hour, $min);
}

sub stop
{
	my ($cat, $desc) = @_;
	die "$0: missing category\n" unless @_ >= 1;

	if (!active_session()) {
		die 'You don\'t currently have an active session\n';
	}

	die "$0: too many arguments\n" if @_ > 2;

	my $filename = get_log_filename();
	open my $fh, '>>', $filename or die "$0: $filename: $!\n";

	my $time = now();

	my $entry;
	if (defined $desc) {
		$entry = sprintf("%s  %-5s %s\n", $time, $cat, $desc);
	} else {
		$entry = sprintf("%s  %-5s\n", $time, $cat);
	}

	print $fh $entry;
	close($fh);
}

sub report
{
	todo('report');
}



#"$mday $months[$mon] $days[$wday]\n";
