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

my $cell_id = $cgi->param("cell_id");
my $threshold = $cgi->param("threshold");
my $experiment_type = $cgi->param("experiment_type");

my $sth = $dbh->prepare('SELECT * FROM EXPERIMENT');
my $experiments = $dbh->selectall_hashref('SELECT * FROM EXPERIMENT WHERE CELL_TYPE_ID = "'.$cell_id.'" AND EXPERIMENT_TYPE_ID = "'.$experiment_type.'"', 'ID');

if(scalar(keys %$experiments))
{
	print "Click column header to sort ascending by that column (click again for descending order)<BR><BR>";
	print "<table border=1 class=\"sortable\ class=\"sortable\">";
	print "<tr>";
	print "<th>Gene ID</th>";
	print "<th>Replicates</th>";
	print "<th>Average Measurement</th>";
#	print "<th>Cell Type ID</th>";
	print "</tr>";

	my $hash;

	foreach my $id (keys %$experiments)
	{
		my $sth = $dbh->prepare('SELECT * FROM EXPERIMENT_RESULTS WHERE EXPERIMENT_ID = "'.$id.'" AND CONFIDENCE >= "'.$threshold.'"');
		my $experiment_results = $dbh->selectall_hashref('SELECT * FROM EXPERIMENT_RESULTS WHERE EXPERIMENT_ID = "'.$id.'" AND CONFIDENCE >= "'.$threshold.'"', 'ID');

		foreach my $result_id (keys %$experiment_results)
		{
			$hash->{$experiment_results->{$result_id}->{GENE_ID}}->{$id."_".$experiment_results->{$result_id}->{REPLICATE_ID}} = $experiment_results->{$result_id}->{CONFIDENCE};
		}
	}

	foreach my $gene (keys %$hash)
	{
		print "<tr>";
		print "<td>".$gene."</td>";
		print "<td>".scalar(keys %{$hash->{$gene}})."</td>";
#		print "<td>";
		my $measurement = 0;
		foreach my $replicate (keys %{$hash->{$gene}})
		{
#			print $replicate."<br>";
			$measurement += $hash->{$gene}->{$replicate};
		}
#		print "</td>";
		my $number = $measurement / scalar(keys %{$hash->{$gene}});
		print "<td>".sprintf("%.4f", $number)."</td>";
		print "</tr>";
	}
	print "</table>";
}
else
{
	print "No ".$experiment_type." experiment for ".$cell_id." currently in the database. Please check back later."
}

BP::footer();

1;
