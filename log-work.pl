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
my $config_dir = "~/.log-work.d";
my $year = "";
my $month = "";
my $today = 0;
my $this_week = 0;

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

Options (all commands):

	-h, --help, --version   Display this help and exit.
	    --config-dir	Directory holding log files (default ~/.log-work.d)

Report Options:

	-y, --year=<year>	Display report for <year>.
	-m, --month=<month>	Display report for <month>.
	    --today		Display report for today.
	    --this-week		Display report for this week.

Create log entries (start and stop work sessions). View summary
report of hours logged.

EOM
    exit($exitcode);
}

GetOptions(
    'y|year=s'		=> \$year,
    'm|month=s'		=> \$month,
    'today'		=> \$today,
    'this-week'		=> \$this_week,
    'config-dir=s'	=> \$config_dir,
    'h|help'		=> \$help,
    'version'		=> \$help,
    ) or help(1);

help(0) if ($help);

if (@ARGV < 1) {
    help(128);
}

my $CONFIG_DIR = glob($config_dir);

my $command = $ARGV[0];
shift @ARGV;

if ($command =~ /^start/) {
    start();
} elsif ($command =~ /^(stop|end)/) {
    stop(@ARGV);
} elsif ($command =~ /^(report|show)/) {
    if ($year eq "") {
        $year = this_year();
    }

    if ($today && $this_week) {
        die "$0: mutually exclusive options: --today, --this-week\n";
    }

    report($year, $month, $this_week, $today);
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

    my $filename = get_log_filename(this_year());
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
    my $entry = last_log_entry(this_year());
    my $start = start_entry();

    return ((length($entry) > length('2017-1-16 09:26') and
             (length($entry) < length('2017-1-16 09:26 10:18'))));
}

sub last_log_entry
{
    my ($year) = @_;

    my $filename = get_log_filename($year);
    my $backwards = File::ReadBackwards->new($filename) or die "$0: can't read file backwards $filename: $!";
    my $last_line = $backwards->readline();

    return $last_line;
}

sub get_log_filename
{
    my ($year) = @_;
    my $filename;

    my $dir = $CONFIG_DIR;
    if (-e $dir and -d $dir) {
        $filename = sprintf("%s/%s.log", $dir, $year);
    } else {
        $filename = sprintf("%s.log", $year);
    }

    return $filename;
}

sub this_year
{
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
    $year += 1900;
    return $year;
}

sub yyyy_mm_dd
{
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
    $year += 1900;
    $mon += 1;

    my ($smon, $sday);
    $sday = $mday < 10 ? "0" . $mday : $mday . "";
    $smon= $mon < 10 ? "0" . $mon : $mon . "";

    return sprintf("%d-%d-%s", $year, $mon, $sday);
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

    my $year = this_year();
    my $filename = get_log_filename(this_year());

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

# program sub command 'report'
sub report
{
    my ($year, $month, $this_week, $today) = @_;

    my $AoH = parse_log_file($year);
    my ($days, $cats);

    if ($this_week) {
        ($days, $cats) = extract_records_for_this_week($AoH);
    } elsif ($today) {
        ($days, $cats) = extract_records_for_today($AoH);
    } elsif ($month) {
        ($days, $cats) = extract_records_for_month($AoH, $month);
    } else {
        ($days, $cats) = extract_records_all($AoH);
    }

    print_report($days, $cats);
}

sub parse_log_file
{
    my @AoH;

    my $filename = get_log_filename($year);
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

# Extract all records using guardfn() as pre-condition for inclusion.
sub extract_records
{
    my ($AoH, $guardfn) = @_;

    my %days;		# date / count
    my %cats;		# category / total duration

    foreach my $rec (@$AoH) {
        if (!&$guardfn($rec)) {
            next;
        }

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
    return \%days, \%cats;

}

sub print_report
{
    my ($days, $cats) = @_;
    my $total = {
        'hours'	=> 0,
            'mins'	=> 0,
    };

    my $ndays = keys %$days;

    printf("\n%s:\n\n\t%d days\n\n", "Work log records for", $ndays);
    print "Hours logged by category:\n\n";
    foreach my $cat (keys %$cats) {
        my $dur = $cats->{$cat};
        $total = sum_duration($total, $dur);
        printf("\t%-5s: %s\n", $cat, sprint_duration($dur));
    }

    printf("\nTotal hours: %s\n", sprint_duration($total));
}

sub extract_records_all
{
    my ($AoH) = @_;
    my $guardfn = sub {
        return 1;
    };

    return extract_records($AoH, $guardfn);
}

# Extract records for month N
sub extract_records_for_month
{
    my ($AoH, $month) = @_;

    my $guardfn = sub {
        my ($rec) = @_;

        my $mon = month_name_to_number($month);
        my $date = $rec->{'date'};
        my @nums = split('-', $date);
        my $rec_mon = $nums[1];

        return $mon == $rec_mon;
    };

    return extract_records($AoH, $guardfn);
}

# Extract all records for this week.
sub extract_records_for_this_week
{
    my ($AoH) = @_;
    my $guardfn = sub {
        my ($rec) = @_;

        die "$0: not implemented yet\n";
    };

    return extract_records($AoH, $guardfn);
}

# Extract all records for today.
sub extract_records_for_today
{
    my ($AoH) = @_;
    my $guardfn = sub {
        my ($rec) = @_;

        my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();

        my $date = $rec->{'date'};
        my @nums = split('-', $date);
        my $rec_mon = $nums[1];
        my $rec_mday = $nums[2];

        $mon += 1;	# 0 based index
        return ($mday == $rec_mday and $mon == $rec_mon);
    };

    return extract_records($AoH, $guardfn);
}


sub month_name_to_number
{
    my ($month) = @_;
    my @months_long = qw(January February March April May June July August September October November December);
    my @months_short = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);

    my $n = 1;
    foreach my $long (@months_long) {
        if ($long  eq $month) {
            return $n
        }
        $n++;
    }
    $n = 1;
    foreach my $short (@months_short) {
        if ($short eq $month) {
            return $n
        }
        $n++;
    }
    die "$0: unrecognized month: $month\n";
}

sub month_from_rec
{
    my ($rec) = @_;

    my $date = $rec->{'date'};
    my @nums = split('/', $date);
    return $nums[1];
}

# sums two duration hashes
sub sum_duration
{
    my ($da, $db) = @_;
    my $res = {};

    $res->{'hours'} = $da->{'hours'} + $db->{'hours'};
    $res->{'mins'} = $da->{'mins'} + $db->{'mins'};
    if ($res->{'mins'} > 59) {
        $res->{'mins'} -= 60;
        $res->{'hours'}++;
    }
    return $res;
}

sub print_all_entries
{
    my ($AoH) = @_;

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
