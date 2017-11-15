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
use Data::Dump qw(dump);

my $VERSION = '0.01';

#run_tests();
#exit(0);

# Command line options.
my $help = 0;
my $debug = 0;
my $YEAR = "";

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

	-y, --year=<year>	Use <year> instead of current year.
	-h, --help, --version   Display this help and exit.

Create log entries (start and stop work sessions). View summary
report of hours logged.

EOM
	exit($exitcode);
}

GetOptions(
	'y|year=s'	=> \$YEAR,
	'h|help'	=> \$help,
	'version'	=> \$help,
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
	my $year;

	if ($YEAR ne "") {
		$year = $YEAR;
	} else {
		my ($sec,$min,$hour,$mday,$mon,$lyear,$wday,$yday,$isdst) = localtime();
		$year = $lyear;
		$year += 1900;
	}
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
	my $AoH = parse_log_file();
	print_report($AoH);
}

sub parse_log_file
{
	my @AoH;

	my $filename = get_log_filename();
	open my $fh, '<', $filename or die "$0: $filename: $!\n";

	while (<$fh>) {
		my $rec = {};
		# format: 2017-11-15 12:53 13:41  <cat>    [<desc>]
		my @fields = split(' ', $_);
		$rec->{'date'} = $fields[0];
		$rec->{'start'} = $fields[1];
		$rec->{'stop'} = $fields[2];
		$rec->{'cat'} = $fields[3];
		if (@fields > 4) {
			my @words = @fields[4..$#fields];
			$rec->{'desc'} = join(' ', @words);
		}
		# Where is the null record coming from?
		if (!null_record($rec)) {
			push @AoH, $rec;
		}
	}

	close($fh);
	return \@AoH;
}

sub print_report
{
	my ($AoH) = @_;
	my %days;		# date / count
	my %cats;		# category / total duration

	foreach my $rec (@$AoH) {
		# count logged days
		$days{$rec->{'date'}}++;

		# sum up duration by category
		my $rec_dur = duration($rec);
		my $key = $rec->{'cat'};

		if (exists($cats{$key})) {
			my $cur_dur = $cats{$key};
			$cats{$key} = sum_duration($cur_dur, $rec_dur);
		} else {
			$cats{$key} = $rec_dur;
		}
	}

	foreach my $cat (keys %cats) {
		printf("%s: %s\n", $cat, sprint_duration($cats{$cat}));
	}
}

# sums two duration hashes
sub sum_duration
{
	my ($da, $db) = @_;

	my $res = {};

	$res->{'hours'} = $da->{'hours'} + $db->{'hours'};
	$res->{'mins'} = $da->{'mins'} + $db->{'mins'};
	if ($res->{'mins'} > 60) {
		$res->{'mins'} -= 60;
		$res->{'hours'}++;
	}
	return $res;
}

sub print_all_entries
{
	my ($AoH) = @_;
	printf("ref: %s\n", ref($AoH));

	foreach (@$AoH) {
		print_record($_);
	}
}

sub print_record
{
	my ($rec) = @_;

	my $dur = duration($rec);
	my $date = $rec->{'date'};
	my $cat = $rec->{'cat'};

	printf("%s %s %s\n", $date, $cat, print_duration($dur));
}

sub duration
{
	my ($rec) = @_;

	my $start = $rec->{'start'};
	my $end = $rec->{'stop'};

	my ($sh, $sm) = split_time($start);
	my ($eh, $em) = split_time($end);

	my ($hours, $mins);
	my $dur = {};

	if ($em > $sm) {
		$hours = $eh - $sh;
		$mins = $em - $sm;
	} else {
		$hours = $eh - $sh - 1;
		$mins = 60 - $sm + $em;
	}

	$dur->{'hours'} = $hours;
	$dur->{'mins'} = $mins;

	return $dur;
}

# Why is this null record getting into the array?
sub null_record
{
	my ($rec) = @_;

	if (!defined $rec->{'date'} or
	    !defined $rec->{'start'} or
	    !defined $rec->{'stop'} or
	    !defined $rec->{'cat'}) {
		return 1;
	}
	return 0;
}

sub sprint_duration
{
	my ($dur) = @_;
	return sprintf("%d h %d m", $dur->{'hours'}, $dur->{'mins'});
}

sub split_time
{
	# fomat: hh:mm
	my ($time) = @_;

	my @parts = split(':', $time);
	return $parts[0], $parts[1];
}

#
# Tests
#

sub run_tests
{
	test_duration();
}

sub test_duration
{
	my ($start, $stop);

	test_duration_tc("10:20", "11:30", 1, 10);
	test_duration_tc("10:20", "11:10", 0, 50);
	test_duration_tc("10:20", "13:10", 2, 50);
}

sub test_duration_tc
{
	my ($start, $stop, $exph, $expm) = @_;

	my $dur = duration($start, $stop);
	my $hours = $dur->{'hours'};
	my $mins = $dur->{'mins'};

	if ($hours != $exph or $mins != $expm) {
		die sprintf("fail duration() exp: %d h %d m got: %d h %d m\n",
		    $exph, $expm, $hours, $mins);
	}
}
