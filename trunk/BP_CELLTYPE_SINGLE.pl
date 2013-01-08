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

if($cgi->param("ct"))
{
	my $CT = $cgi->param("ct");

	my $sth = $dbh->prepare('SELECT * FROM CELL_TYPES');
	my $markers = $dbh->selectall_hashref('SELECT * FROM CELL_TYPES WHERE NAME = "'.$CT.'"', 'ID');

	if(scalar(keys %$markers))
	{
		print "Found ".$CT." - Skipping Insertion<br>";
	}
	else
	{
		my $sth = $dbh->prepare(qq{INSERT INTO CELL_TYPES (ID,NAME) VALUES (?, ?)});
	  	$sth->execute(undef,$CT);
		print "Added ".$CT."<br>";
	}
}
else
{
	print "<FORM action=\"BP_CELLTYPE_SINGLE.pl\" method=\"POST\" ENCTYPE=\"multipart/form-data\">";
	print "Cell Type: <input type=\"text\" name=\"ct\" /><BR><input type=\"submit\" name=\"expression\" value=\"Import\">";
	print "</FORM>";
}

BP::footer();

1;
