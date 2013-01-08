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

my $sth = $dbh->prepare('SELECT * FROM EXPERIMENT');
my $experiment_info = $dbh->selectall_hashref('SELECT * FROM EXPERIMENT', 'ID');

my $sth = $dbh->prepare('SELECT * FROM EXPERIMENT');
my $cell_type_info = $dbh->selectall_hashref('SELECT * FROM CELL_TYPES', 'ID');


BP::header("Gene Centric Analysis");
my $cgi = new CGI;

print "<h1>Gene-centric Analysis</h1>";

my $input_genes = $cgi->param("input_genes");
my $analysis_threshold = $cgi->param("analysis_threshold");

my $genes;
$input_genes =~ s/\ //g;
my @gene_array = split(/\,/,$input_genes);
foreach my $gene (@gene_array)
{
	$genes->{$gene} = 1;
}

if($genes)
{
	my $result_hash;

	foreach my $gene (keys %$genes)
	{
		my $sth = $dbh->prepare('SELECT * FROM GENES WHERE SYMBOL="'.$gene.'"');
		my $gene_info = $dbh->selectall_hashref('SELECT * FROM GENES WHERE SYMBOL="'.$gene.'"', 'GENE_ID');

		foreach my $id (keys %$gene_info)
		{
			my $sth = $dbh->prepare('SELECT * FROM EXPERIMENT_RESULTS WHERE GENE_ID ="'.$id.'" AND CONFIDENCE <= "'.$analysis_threshold.'"');
			my $results = $dbh->selectall_hashref('SELECT * FROM EXPERIMENT_RESULTS WHERE GENE_ID ="'.$id.'" AND CONFIDENCE <= "'.$analysis_threshold.'"', 'ID');

			foreach my $result (keys %$results)
			{
				$result_hash->{$experiment_info->{$results->{$result}->{EXPERIMENT_ID}}->{CELL_TYPE_ID}}->{$gene} = 1
			}
		}
	}

	print "<table border=1 class=\"sortable\">";
	print "<tr>";
	print "<th>Cell Type</th>";
	foreach my $gene (keys %$genes)
	{
		print "<th>".$gene."</th>";
	}
	print "</tr>";
	foreach my $cell_type (keys %$cell_type_info)
	{
		print "<tr>";
		print "<td>".$cell_type_info->{$cell_type}->{NAME}."</td>";
		foreach my $gene (keys %$genes)
		{
			if($result_hash->{$cell_type}->{$gene} == 1)
			{
				print "<td bgcolor=green>Yes</td>";
			}
			else
			{
				print "<td bgcolor=red>No</td>";
			}
		}
		print "</tr>";
	}
	print "</table>";
}
else
{
	print "<FORM action=\"BP_GENE_ANALYSIS.pl\" method=\"POST\" ENCTYPE=\"multipart/form-data\">";

	print 'Genes (as Gene Symbols): <input type="text" name="input_genes"> (Separate multiple entries through comma)<br><br>';
	print 'Threshold <input type="text" name="analysis_threshold" value="0.05"><br>';
	print '<input type="submit" name="submit" value="Analyze">';
	print '<input type="reset" name="clear" value="Clear">';
	print "</FORM>";
}

BP::footer();

1;
