#!/usr/bin/perl

# Requires perl-Test-Simple installation.
use Test::Simple tests => 20;

$suffix = "";
if (-e "../dos2unix.exe") {
  $suffix = ".exe";
}
$DOS2UNIX = "../dos2unix" . $suffix;
$MAC2UNIX = "../mac2unix" . $suffix;
$UNIX2DOS = "../unix2dos" . $suffix;
$UNIX2MAC = "../unix2mac" . $suffix;

$ENV{'LC_ALL'} = 'en_US.UTF-8';

system("$DOS2UNIX -v -7 -n chardos.txt out_unix.txt; cmp out_unix.txt charu7.txt");
ok( $? == 0, '7bit');

system("$DOS2UNIX -v < dos.txt > out_unix.txt; cmp out_unix.txt unix.txt");
ok( $? == 0, 'DOS to Unix conversion, stdin/out' );

system("$UNIX2DOS -v < unix.txt > out_dos.txt; cmp out_dos.txt dos.txt");
ok( $? == 0, 'Unix to DOS conversion, stdin/out' );

system("cat utf16le.txt | $DOS2UNIX -v > out_unix.txt; cmp out_unix.txt utf8unix.txt");
ok( $? == 0, 'UTF-16LE with BOM to UTF-8, stdin/out' );

system("cat utf16u.txt | $UNIX2DOS -v -u > out_dos.txt; cmp out_dos.txt utf16.txt");
ok( $? == 0, 'UTF-16LE with BOM to UTF-16LE, stdin/out' );

system("$DOS2UNIX -v -n utf16len.txt out_bin.txt");
# file out_bin.txt may not exist.
if (-e "out_bin.txt") {
  $exists = "1";
} else {
  $exists = "0";
}
ok( $exists == 0, 'dos2unix skip binary file.' );

system("$UNIX2DOS -v -n utf16len.txt out_bin.txt");
# file out_bin.txt may not exist.
if (-e "out_bin.txt") {
  $exists = "1";
} else {
  $exists = "0";
}
ok( $exists == 0, 'unix2dos skip binary file.' );

system("$DOS2UNIX -v < utf16len.txt > out.txt");
$result = ($? >> 8);
ok( $result == 1, 'Dos2unix stdio returns error on binary input.' );

system("$UNIX2DOS -v < utf16len.txt > out.txt");
$result = ($? >> 8);
ok( $result == 1, 'Unix2dos stdio returns error on binary input.' );

system("rm -f out_forc.txt");
system("$DOS2UNIX -f -v -n utf16len.txt out_forc.txt");
# file out_bin.txt may not exist.
if (-e "out_forc.txt") {
  $exists = "1";
} else {
  $exists = "0";
}
ok( $exists == 1, 'dos2unix force binary file.' );

system("rm -f out_forc.txt");
system("$UNIX2DOS -f -v -n utf16len.txt out_forc.txt");
# file out_bin.txt may not exist.
if (-e "out_forc.txt") {
  $exists = "1";
} else {
  $exists = "0";
}
ok( $exists == 1, 'unix2dos force binary file.' );

system("$DOS2UNIX -v -f -n dos_bin.txt out_unix.txt; cmp out_unix.txt unix_bin.txt");
ok( $? == 0, 'Dos2unix, force ASCII file with binary symbols' );

system("$UNIX2DOS -v -f -n unix_bin.txt out_dos.txt; cmp out_dos.txt dos_bin.txt");
ok( $? == 0, 'Unix2dos, force ASCII file with binary symbols' );

system("$DOS2UNIX -v -7 -n utf16le.txt out_unix.txt chardos.txt out_u7.txt; cmp out_unix.txt utf8unix.txt");
ok( $? == 0, '7bit disabled for utf16');

system("cmp out_u7.txt charu7.txt");
ok( $? == 0, '7bit enabled again, dos2unix');

system("$UNIX2DOS -v -7 -n utf8unxb.txt out_dos.txt charunix.txt out_d7.txt; cmp out_dos.txt utf8dos.txt");
ok( $? == 0, '7bit disabled for utf8 with BOM');

system("cmp out_d7.txt chard7.txt");
ok( $? == 0, '7bit enabled again, unix2dos');

system("$UNIX2DOS -v -u -m -n unix.txt out_dos.txt; cmp out_dos.txt dos_bom.txt");
ok( $? == 0, 'Option -u must not disable -m on ASCII input');

system("$DOS2UNIX -i dos.txt unix.txt mac.txt mixed.txt utf16le.txt utf16be.txt utf16len.txt utf8unix.txt utf8dos.txt gb18030.txt > outinfo.txt");
system("$DOS2UNIX outinfo.txt; diff info.txt outinfo.txt");
ok( $? == 0, 'Option -i, --info');

system("$DOS2UNIX -v -n gb18030.txt out_unix.txt; cmp out_unix.txt gb18030u.txt");
ok( $? == 0, 'Remove GB18030 BOM');
