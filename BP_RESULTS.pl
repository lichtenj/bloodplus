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

my $threshold = $cgi->param("threshold");
my $experiment_type = $cgi->param("experiment_type");

my $experiments;
if($cgi->param("cell_id"))
{
	my $cell_id = $cgi->param("cell_id");
	my $sth = $dbh->prepare('SELECT * FROM EXPERIMENT');
	$experiments = $dbh->selectall_hashref('SELECT * FROM EXPERIMENT WHERE CELL_TYPE_ID = "'.$cell_id.'" AND EXPERIMENT_TYPE_ID = "'.$experiment_type.'"', 'ID');
}
else
{
	my $sth = $dbh->prepare('SELECT * FROM DIFFERENTIATION_BRANCH_CELLS WHERE BRANCH_ID = "'.$cgi->param("branch_id").'"');
	my $branch_cell_types = $dbh->selectall_hashref('SELECT * FROM DIFFERENTIATION_BRANCH_CELLS WHERE BRANCH_ID = "'.$cgi->param("branch_id").'"', 'CELL_TYPE_ID');

	my $cell_type_sql = "";
	my $count = 0;
	foreach my $branch_cell_type_id (sort {$a<=>$b} keys %$branch_cell_types)
	{
		if($count != 0)
		{
			$cell_type_sql .= ' OR '
		}
		$cell_type_sql .= 'CELL_TYPE_ID = "'.$branch_cell_type_id.'"';
		$count++;
	}

	my $sql = 'SELECT * FROM EXPERIMENT WHERE ('.$cell_type_sql.') AND EXPERIMENT_TYPE_ID = "'.$experiment_type.'"';

#	print $sql."<br>";

	my $sth = $dbh->prepare($sql);
	$experiments = $dbh->selectall_hashref($sql, 'ID');
}

my $sth = $dbh->prepare('SELECT * FROM GENES');
my $genes = $dbh->selectall_hashref('SELECT * FROM GENES', 'GENE_ID');

my $sth = $dbh->prepare('SELECT * FROM PUBLICATIONS');
my $publications = $dbh->selectall_hashref('SELECT * FROM PUBLICATIONS', 'ID');

if(scalar(keys %$experiments))
{
	my $hash;

	print "Pooled data from:<br>";
	print '<ul>';

	foreach my $id (keys %$experiments)
	{
		print "<li>".$publications->{$experiments->{$id}->{PUBLICATION_ID}}->{CITATION};

		my $sth = $dbh->prepare('SELECT * FROM EXPERIMENT_RESULTS WHERE EXPERIMENT_ID = "'.$id.'" AND CONFIDENCE <= "'.$threshold.'"');
		my $experiment_results = $dbh->selectall_hashref('SELECT * FROM EXPERIMENT_RESULTS WHERE EXPERIMENT_ID = "'.$id.'" AND CONFIDENCE <= "'.$threshold.'"', 'ID');

		foreach my $result_id (keys %$experiment_results)
		{
			$hash->{$experiment_results->{$result_id}->{GENE_ID}}->{$id."_".$experiment_results->{$result_id}->{REPLICATE_ID}}->{CONFIDENCE} = $experiment_results->{$result_id}->{CONFIDENCE};
			$hash->{$experiment_results->{$result_id}->{GENE_ID}}->{$id."_".$experiment_results->{$result_id}->{REPLICATE_ID}}->{MEASUREMENT} = $experiment_results->{$result_id}->{MEASUREMENT};
		}
		print "</li>";
	}
	print "</ul>";

	print "Click column header to sort ascending by that column (click again for descending order)<BR><BR>";
	print "<table border=1 class=\"sortable\">";
	print "<tr>";
	#print "<th>Gene ID</th>";
	print "<th>Gene Symbol</th>";
	print "<th>Replicates</th>";
	print "<th>Average Confidence</th>";
#	print "<th>Average Measurement</th>";
#	print "<th>Cell Type ID</th>";
	print "</tr>";

	foreach my $gene (keys %$hash)
	{
		print "<tr>";

		#print "<td>".$gene."</td>";
		print "<td>";
		print '<a href="http://genome.ucsc.edu/cgi-bin/hgTracks?position='.$genes->{$gene}->{ENSEMBL_ID}.'">';
		print $genes->{$gene}->{SYMBOL};
		if($genes->{$gene}->{UCSC_ID})
		{
			print "</a>";
		}
		print "</td>";
		print "<td>".scalar(keys %{$hash->{$gene}})."</td>";

		my $confidence = 0;
		my $measurement = 0;
		foreach my $replicate (keys %{$hash->{$gene}})
		{
			$confidence += $hash->{$gene}->{$replicate}->{CONFIDENCE};
			$measurement += $hash->{$gene}->{$replicate}->{MEASUREMENT};
		}
		my $conf = $confidence / scalar(keys %{$hash->{$gene}});
		my $meas = $measurement / scalar(keys %{$hash->{$gene}});

#		print "<td>".sprintf("%.4f", $meas)."</td>";
		print "<td>".sprintf("%.4f", $conf)."</td>";

		print "</tr>";
	}
	print "</table>";
}
else
{
	if($cgi->param("cell_id"))
	{
		print "No ".$experiment_type." experiment for ".$cgi->param("cell_id")." currently in the database. Please check back later."
	}
	elsif($cgi->param("branch_id"))
	{
		print "No ".$experiment_type." experiment for ".$cgi->param("branch_id")." currently in the database. Please check back later."
	}
}

BP::footer();

1;
