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

BP::header();
my $cgi = new CGI;

if($cgi->param("csm"))
{
	my $CSM = $cgi->param("csm");

	my $sth = $dbh->prepare('SELECT * FROM CELL_SURFACE_MARKERS');
	my $markers = $dbh->selectall_hashref('SELECT * FROM CELL_SURFACE_MARKERS WHERE NAME = "'.$CSM.'"', 'ID');

	if(scalar(keys %$markers))
	{
		print "Found ".$CSM." - Skipping Insertion<br>";
	}
	else
	{
		my $sth = $dbh->prepare(qq{INSERT INTO CELL_SURFACE_MARKERS (ID,NAME) VALUES (?, ?)});
	  	$sth->execute(undef,$CSM);
	}
}
else
{
	print "<FORM action=\"BP_CELLMARKER_SINGLE.pl\" method=\"POST\" ENCTYPE=\"multipart/form-data\">";
	print "Cell Surface Marker: <input type=\"text\" name=\"csm\" /><BR><input type=\"submit\" name=\"expression\" value=\"Import\">";
	print "</FORM>";
}

BP::footer();

1;
