use strict;
use warnings;

use Cwd qw(getcwd);
use File::Temp qw(tempdir);
use POSIX qw(:sys_wait_h);
use Test::More;

plan skip_all => '$ENV{TEST_BT_CORES} not set, skipping all tests'
    unless $ENV{TEST_BT_CORES};

my $pwd = getcwd;
my $tempdir = tempdir(CLEANUP => 1);

# compile bt_cores_segv.c
system(
    "cd $tempdir && gcc -g -c $pwd/t/assets/bt_cores_segv.c && gcc -g -o segv bt_cores_segv.o",
) == 0
    or die "gcc exitted with unexpected status:$?";

# launch bt_cores
my $bt_cores_pid = fork;
die "fork failed:$!"
    unless defined $bt_cores_pid;
unless ($bt_cores_pid) {
    chdir '/cores'
        or die "failed to chdir to /cores:$!";
    exec "$pwd/blib/script/bt_cores", '-u'
        or die "failed to exec bt_cores:$!";
}

# generate core
my $segv_pid = fork;
die "fork failed:$!"
    unless defined $segv_pid;
unless ($segv_pid) {
    exec("$tempdir/segv");
    die "failed to invoke $tempdir/segv:$!";
}

# wait for backtrace file to appear, and stop bt_cores
while (! -e "/cores/bt.$segv_pid") {
    sleep 1;
}
sleep 3;
kill 15, $bt_cores_pid;

# check backtrace
like do {
    open my $fh, '<', "/cores/bt.$segv_pid"
        or die "failed to open file:bt.$segv_pid:$!";
    join '', <$fh>;
}, qr/bt_cores_segv\.c:3/, 'check backtrace';

unlink "/cores/bt.$segv_pid";

done_testing;
