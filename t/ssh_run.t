use strict;
use warnings;

use POSIX qw(:sys_wait_h);
use Test::More;

plan skip_all => 'tests using local SSH connnections skipped unless $ENV{TEST_SSH}'
    unless $ENV{TEST_SSH};

my @cmd = qw(blib/script/ssh_run localhost t/assets/ssh_run_wrapper.pl);

{ # read output
    open my $fh, '-|', join(' ', @cmd, 'print 12345'),
        or die "failed to exec ssh_run:$!";
    is join('', <$fh>), 12345, 'read output of ssh_run';
    close $fh;
    my $e = $?;
    ok WIFEXITED($e), 'normal exit';
    is WEXITSTATUS($e), 0, 'normal exit status';
}

{ # exit code
    my $e = system @cmd, 'exit 3';
    ok WIFEXITED($e), 'exit 3 exitted';
    is WEXITSTATUS($e), 3, 'exit 3 code';
}

{ # kill
    my $e = system @cmd, 'kill 9, $$';
    ok WIFEXITED($e), 'no way to transfer signal';
    is WEXITSTATUS($e), 255, '255 on kill';
}

done_testing;
