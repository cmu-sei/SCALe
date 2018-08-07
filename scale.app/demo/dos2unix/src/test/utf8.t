#!/usr/bin/perl

# Requires perl-Test-Simple installation.
use Test::Simple tests => 6;

$suffix = "";
if (-e "../dos2unix.exe") {
  $suffix = ".exe";
}
$DOS2UNIX = "../dos2unix" . $suffix;
$MAC2UNIX = "../mac2unix" . $suffix;
$UNIX2DOS = "../unix2dos" . $suffix;
$UNIX2MAC = "../unix2mac" . $suffix;

$ENV{'LC_ALL'} = 'en_US.UTF-8';

system("$DOS2UNIX -v -n dos_bom.txt out_unix.txt; cmp out_unix.txt unix.txt");
ok( $? == 0, 'dos2unix removes BOM' );

system("$DOS2UNIX -v -b -n dos_bom.txt out_unix.txt; cmp out_unix.txt unix_bom.txt");
ok( $? == 0, 'dos2unix -b keeps BOM' );

system("$DOS2UNIX -v -m -n dos.txt out_unix.txt; cmp out_unix.txt unix_bom.txt");
ok( $? == 0, 'dos2unix -m adds BOM' );

system("$UNIX2DOS -v -n unix_bom.txt out_dos.txt; cmp out_dos.txt dos_bom.txt");
ok( $? == 0, 'unix2dos keeps BOM' );

system("$UNIX2DOS -v -r -n unix_bom.txt out_dos.txt; cmp out_dos.txt dos.txt");
ok( $? == 0, 'unix2dos -r removes BOM' );

system("$UNIX2DOS -v -m -n unix.txt out_dos.txt; cmp out_dos.txt dos_bom.txt");
ok( $? == 0, 'unix2dos -m adds BOM' );


