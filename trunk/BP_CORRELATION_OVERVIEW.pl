#!/usr/bin/perl

use strict; 
use warnings;
use CGI::Simple;
use DBI;
use CGI; 
use CGI::Carp qw ( fatalsToBrowser ); 
use File::Basename;

use BP;

my $dsn = sprintf(
    'DBI:mysql:database=blood_plus_v2;host=localhost',
    'cdcol', 'localhost'
);

my $dbh = DBI->connect($dsn, $BP::MYSQL_USER,$BP::MYSQL_PASS);

BP::header("Correlation Overview");

#print '<script src="../../BloodPlus/Correlations.html"></script>';
#print '<!--#include file="../../BloodPlus/Correlations.html" -->';
print '<iframe src="../../BloodPlus/Correlations.html" width="100%" height="75% seamless frameborder="0"></iframe>';

BP::footer();

1;
