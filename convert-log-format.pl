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
use File::Basename;

my $VERSION = '0.01';

my @MONTHS = qw(January February March April May June July August September October November December);
my @DAYS = qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);

# test_is_day();
# exit(0);

sub say { print @_ . "\n"; }

my ($YEAR) = $ARGV[0];
defined $YEAR or die "Usage $0 <year>\n";

my $logfile = sprintf("%s.log", $YEAR);
open my $LOG_FH, '>>', $logfile or die "$0: $!\n";

my @files = glob("$YEAR/*.md");

foreach my $file (@files) {
	open my $fh, '<', $file or die "$0: $file: $!\n";

	if (!is_month(substr($file, 0))) {
		next;
	}

	while(<$fh>) {
		chomp;
		if (is_day_heading($_)) {
			parse_day($fh, $_);
		}
	}
}

sub is_month
{
	my ($fullname) = @_;
	my ($name,$path,$suffix) = fileparse($fullname, '.md');

	return contains(\@MONTHS, $name);
}

sub is_day_heading
{
	my ($s) = @_;

	my $index = index($s, ' ');

	if ($index == -1) {
		return 0;
	}

	my $first_word = substr($_, 0, $index);
	if (is_day($first_word)) {
		return 1;
	}
	return 0;
}

sub parse_day
{
	my ($fh, $orig_date) = @_;

	my $date = convert_date($orig_date);

	readline($fh);		# skip '--------------'
	while (<$fh>) {
		chomp;

		# white space only, we are done
		if ($_ =~ '^\s*$') {
			return;
		}

		add_entry($_, $date);
	}
}

sub convert_date
{
	# format: Friday 27/01/17
	my ($orig) = @_;

	my $index = index($orig, ' ');
	my $orig_date = substr($orig, $index + 1);

	my @nums = split('/', $orig_date);
	return sprintf("%s-%s-%s", $YEAR, $nums[1], $nums[0]);
}

sub contains
{
	my ($array, $string) = @_;

	foreach my $element (@$array) {
		if ($string eq $element) {
			return 1;
		}
	}
	return 0;
}

sub is_day
{
	my ($word) = @_;
	return contains(\@DAYS, $word);
}

sub yyyy_mm_dd
{
	my ($year, $month, $day) = @_;
	return sprintf("%d-%d-%d", $year, $month, $day);
}

sub add_entry
{
	my ($orig, $date) = @_;
	my $entry;

	my ($start, $stop, $cat, $desc) = convert_original_entry($orig);

	if (defined $desc) {
		$entry = sprintf("%s %s %s  %-5s %s\n",
				    $date, $start, $stop, $cat, $desc);
	} else {
		$entry = sprintf("%s %s %s  %-5s\n",
				    $date, $start, $stop, $cat);
	}
	print $LOG_FH $entry;
}

sub convert_original_entry
{
	# orig_entry format: '20:36 21:36 dev kernel - oou oau aou  '
	my ($orig) = @_;
	my ($start, $stop, $cat);

	my ($orig_data, $desc);

	# split on '-'
	my @halves = split('-', $orig);
	$orig_data = $halves[0];

	my @data = split(' ', $halves[0]);
	return $data[0], $data[1], $data[2], $halves[1];
}

sub month_to_number
{
	my ($name) = @_;
	return -1;
}

## tests

sub test_is_day
{
	foreach my $tc (@DAYS) {
		if (!is_day($tc)) {
			printf("fail: %s\n", $tc)
		}
	}

	my @tcs = qw(Sundaya Moauonday aMonday aou Maou);
	foreach my $tc (@tcs) {
		if (is_day($tc)) {
			printf("fail: %s\n", $tc)
		}
	}
}

