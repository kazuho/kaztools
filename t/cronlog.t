use strict;
use warnings;

use File::Slurp qw(read_file);
use File::Temp qw(tempdir);
use Test::More;

my $tempdir = tempdir(CLEANUP => 1);

open my $fh, '-|', "blib/script/cronlog -l $tempdir/log -- $^X -e 'print 12345678; print STDERR q(abcdefgh)'"
    or die "failed to run cronlog:$!";
is join('', <$fh>), '', 'no output on success';
close $fh;
like read_file("$tempdir/log"), qr/12345678/, 'stdout to log';
like read_file("$tempdir/log"), qr/abcdefgh/, 'stderr to log';

open $fh, '-|', "blib/script/cronlog -l $tempdir/log -- $^X -e 'die q(foo)'"
    or die "failed to run cronlog:$!";
my $output = join '', <$fh>;
close $fh;
like $output, qr/foo/, 'output on failure';
unlike $output, qr/12345678/, 'output does not contain log of previous job';

done_testing;
