use strict;
use warnings;

use Test::More;
use File::Slurp;
use File::Temp qw(tempdir);

my $tempdir = tempdir(CLEANUP => 1);
my $touch_file = "$tempdir/hoge";

start(
    "-m HOGE /dev/null",
    sub {
        my $fh = shift;
        print $fh "hoge\n";
        sleep 1;
        ok ! -e $touch_file;
        print $fh "HOGE\n";
        sleep 1;
        ok -e $touch_file;
    },
);

start(
    "-i -m HOGE /dev/null",
    sub {
        my $fh = shift;
        print $fh "hoga\n";
        sleep 1;
        ok ! -e $touch_file;
        print $fh "hoge\n";
        sleep 1;
        ok -e $touch_file;
    },
);

start(
    "-m HOGE -s 3 -t 2 -m HOGE /dev/null",
    sub {
        my $fh = shift;
        print $fh "HOGE\n";
        sleep 5;
        ok ! -e $touch_file;
        print $fh "HOGE\n";
        sleep 1;
        ok ! -e $touch_file;
        print $fh "HOGE\n";
        sleep 1;
        ok -e $touch_file;
    },
);

start(
    qq%-m HOGE -p -- $^X -e 'open my \$fh, ">", "$tempdir/foo"; while (<>) { print \$fh \$_ }'%,
    sub {
        my $fh = shift;
        print $fh "hoge\nHOGE\n";
    },
);
is read_file("$tempdir/foo"), "hoge\nHOGE\n";

done_testing;

sub start {
    my ($args, $code) = @_;
    open my $fh, '|-', "blib/script/touch_if -f $touch_file $args"
        or die "failed to start touch_if with args:$args:$!";
    autoflush $fh;
    sleep 1;
    ok ! -e $touch_file, "not touched after starting with args: $args";
    $code->($fh);
    close $fh;
    is $?, 0, 'touch_if stopped with exit_code=0';
    unlink $touch_file;
}
