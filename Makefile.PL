use inc::Module::Install;

name 'kaztools';
abstract 'shellscripts and utilities for myself';
author 'Kazuho Oku';
version '0.01';
license 'bsd';
perl_version '5.8.5';

requires 'Pod::Usage';
test_requires 'File::Slurp';
test_requires 'Test::More' => 0.88;

install_script 'cronlog';
install_script 'guncat';
install_script 'ssh_run';

auto_include;
auto_install;

WriteAll;
