#!/usr/bin/perl

# Requires perl-Test-Simple installation.
use Test::Simple tests => 24;

$suffix = "";
if (-e "../dos2unix.exe") {
  $suffix = ".exe";
}

$system = `uname -s`;
if ($system =~ m/MINGW/)
{
  $unix=0;
} else {
  $unix=1;
}

$DOS2UNIX = "../dos2unix" . $suffix;
$MAC2UNIX = "../mac2unix" . $suffix;
$UNIX2DOS = "../unix2dos" . $suffix;
$UNIX2MAC = "../unix2mac" . $suffix;

$ENV{'LC_ALL'} = 'en_US.UTF-8';

system("$DOS2UNIX -v -n utf16le.txt out_unix.txt; cmp out_unix.txt utf8unix.txt");
ok( $? == 0, 'DOS UTF-16LE to Unix UTF-8' );
system("$DOS2UNIX -v -n utf16be.txt out_unix.txt; cmp out_unix.txt utf8unix.txt");
ok( $? == 0, 'DOS UTF-16BE to Unix UTF-8' );
system("$UNIX2DOS -v -n utf16le.txt out_dos.txt; cmp out_dos.txt utf8dos.txt");
ok( $? == 0, 'DOS UTF-16LE to DOS UTF-8' );
system("$UNIX2DOS -v -n utf16be.txt out_dos.txt; cmp out_dos.txt utf8dos.txt");
ok( $? == 0, 'DOS UTF-16BE to DOS UTF-8' );

system("$DOS2UNIX -v -ul -n utf16len.txt out_unix.txt; cmp out_unix.txt utf8unix.txt");
ok( $? == 0, 'UTF-16LE without BOM to UTF-8' );
system("$DOS2UNIX -v -ub -n utf16ben.txt out_unix.txt; cmp out_unix.txt utf8unix.txt");
ok( $? == 0, 'UTF-16BE without BOM to UTF-8' );
system("$DOS2UNIX -v -ul -n utf16be.txt out_unix.txt; cmp out_unix.txt utf8unix.txt");
ok( $? == 0, 'BOM overrides -ul' );
system("$DOS2UNIX -v -ub -n utf16le.txt out_unix.txt; cmp out_unix.txt utf8unix.txt");
ok( $? == 0, 'BOM overrides -ub' );

system("$DOS2UNIX -v -b -n utf16le.txt out_unix.txt; cmp out_unix.txt utf8unxb.txt");
ok( $? == 0, 'DOS UTF-16LE to Unix UTF-8, keep BOM' );
system("$UNIX2DOS -v -r -n utf16le.txt out_dos.txt; cmp out_dos.txt utf8dosn.txt");
ok( $? == 0, 'DOS UTF-16LE to DOS UTF-8, remove BOM' );

system("$MAC2UNIX -v -n utf16le.txt out_unix.txt; cmp out_unix.txt utf8dosn.txt");
ok( $? == 0, 'mac2unix does not change utf16 DOS line breaks.' );
system("$UNIX2MAC -v -n utf16le.txt out_mac.txt; cmp out_mac.txt utf8dos.txt");
ok( $? == 0, 'unix2mac does not change utf16 DOS line breaks.' );

system("$UNIX2DOS -v -u -n utf16le.txt out_dos.txt; cmp out_dos.txt utf16le.txt");
ok( $? == 0, 'DOS UTF-16LE to DOS UTF-16' );
system("$UNIX2DOS -v -u -n utf16be.txt out_dos.txt; cmp out_dos.txt utf16be.txt");
ok( $? == 0, 'DOS UTF-16BE to DOS UTF-16' );
system("$DOS2UNIX -v -b -u -n utf16.txt out_unix.txt; cmp out_unix.txt utf16u.txt");
ok( $? == 0, 'DOS UTF-16LE to Unix UTF-16' );
system("$MAC2UNIX -v -b -u -n utf16m.txt out_unix.txt; cmp out_unix.txt utf16u.txt");
ok( $? == 0, 'Mac UTF-16LE to Unix UTF-16' );
system("$UNIX2DOS -v -b -u -n utf16u.txt out_dos.txt; cmp out_dos.txt utf16.txt");
ok( $? == 0, 'Unix UTF-16 to DOS UTF-16LE' );
system("$UNIX2MAC -v -b -u -n utf16u.txt out_mac.txt; cmp out_mac.txt utf16m.txt");
ok( $? == 0, 'Unix UTF-16 to Mac UTF-16LE' );

system("$DOS2UNIX -v -f -n utf16bin.txt out_unix.txt; cmp out_unix.txt unix_bin.txt");
ok( $? == 0, 'Dos2unix, force UTF-16 file with binary symbols' );
system("$UNIX2DOS -v -f -r -n utf16bin.txt out_dos.txt; cmp out_dos.txt dos_bin.txt");
ok( $? == 0, 'Unix2dos, force UTF-16 file with binary symbols' );

system("$DOS2UNIX -v -n invalhig.txt out_unix.txt");
$result = ($? >> 8);
ok( $result == 1, 'Dos2unix, invalid surrogate pair, missing low surrogate' );
system("$DOS2UNIX -v -n invallow.txt out_unix.txt");
$result = ($? >> 8);
ok( $result == 1, 'Dos2unix, invalid surrogate pair, missing high surrogate' );

$ENV{'LC_ALL'} = 'C';

system("$DOS2UNIX -v -n utf16le.txt out_unix.txt");
$result = ($? >> 8);
if ( $unix ) { $expected = 1; } else { $expected = 0 };
print "UNIX" . $unix . "\n";
print "EXP" . $expected . "\n";
ok( $result == $expected, 'DOS UTF-16LE to Unix in C locale, conversion error.' );
system("$DOS2UNIX -v -n utf16.txt out_unix.txt");
ok( $? == 0, 'DOS UTF-16LE to Unix in C locale, conversion OK' );
