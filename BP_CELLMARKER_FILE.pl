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

$CGI::POST_MAX = 1024 * 500000;
my $cgi = new CGI;
my $safe_filename_characters = "a-zA-Z0-9_.-";

if($cgi->param("file"))
{
	my $filename = $cgi->param("file");
	$filename =~ s/.*[\/\\](.*)/$1/;

	my $upload_filehandle = $cgi->upload("file");
	print "upload_filehandle not defined\n" unless (defined $upload_filehandle);

	my $show = 0;
	my $sample = "";

	while ( my $rec = <$upload_filehandle> )
	{
		chomp($rec);

		my $CSM = $rec;

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
}
else
{
	print "<FORM action=\"BP_CELLMARKER_FILE.pl\" method=\"POST\" ENCTYPE=\"multipart/form-data\">";
	print "Cell Surface Markers: <input type=\"file\" name=\"file\" /><BR><input type=\"submit\" name=\"expression\" value=\"Import\">";
	print "</FORM>";
}

BP::footer();

1;
