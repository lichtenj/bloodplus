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

BP::header("Branches Overview");
my $cgi = new CGI;

print '<img src="../../Images/Branch_Tree.png" usemap = #example border=0>';
print '<map name=example>';
print '<area shape=Rect Coords=45,295,363,391 Href="./BP_BRANCHES.pl#0">';		#Hematopoiesis
print '<area shape=Rect Coords=429,363,745,459 Href="./BP_BRANCHES.pl#4">'; 		#Lymphopoiesis
print '<area shape=Rect Coords=429,226,745,320 Href="./BP_BRANCHES.pl#3">'; 		#Myelopoiesis
print '<area shape=Rect Coords=811,87,1129,184 Href="./BP_BRANCHES.pl#1">'; 		#Erythropoiesis
print '<area shape=Rect Coords=811,225,1129,322 Href="./BP_BRANCHES.pl#2">'; 	#Megakaryopoiesis
print '<area shape=Rect Coords=811,362,1129,457 Href="./BP_BRANCHES.pl#5">'; 	#Granulopoiesis
print '<area shape=Rect Coords=1195,157,1513,252 Href="./BP_BRANCHES.pl#6">'; 	#Monocytopoiesis
print '<area shape=Rect Coords=1195,294,1513,388 Href="./BP_BRANCHES.pl">'; 	#E.Granulopoiesis
print '<area shape=Rect Coords=1195,432,1513,526 Href="./BP_BRANCHES.pl">'; 	#B.Granulopoiesis
print '<area shape=Rect Coords=1195,569,1513,664 Href="./BP_BRANCHES.pl">'; 	#N.Granulopoiesis
print '</map>';

BP::footer();

1;
