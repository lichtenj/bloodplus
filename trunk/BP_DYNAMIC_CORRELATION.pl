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

BP::header("Dynamic Correlation");
my $cgi = new CGI;

$CGI::POST_MAX = 1024 * 500000;
my $safe_filename_characters = "a-zA-Z0-9_.-";

my $sth = $dbh->prepare('SELECT * FROM GENES');
my $genes = $dbh->selectall_hashref('SELECT * FROM GENES', 'GENE_ID');

my $sth = $dbh->prepare('SELECT * FROM PARTITIONS');
my $partitions = $dbh->selectall_hashref('SELECT * FROM PARTITIONS', 'ID');

my $sth = $dbh->prepare('SELECT * FROM EXPERIMENT');
my $experiments = $dbh->selectall_hashref('SELECT * FROM EXPERIMENT', 'ID');

my $sth = $dbh->prepare('SELECT * FROM EXPERIMENT_TYPES');
my $experiment_types = $dbh->selectall_hashref('SELECT * FROM EXPERIMENT_TYPES', 'ID');

my $sth = $dbh->prepare('SELECT * FROM CHIP_FACTORS');
my $factors = $dbh->selectall_hashref('SELECT * FROM CHIP_FACTORS', 'ID');

my $sth = $dbh->prepare('SELECT * FROM CELL_TYPES');
my $cell_types = $dbh->selectall_hashref('SELECT * FROM CELL_TYPES', 'ID');

if($cgi->param("file"))
{
	my $filename = $cgi->param("file");
	$filename =~ s/.*[\/\\](.*)/$1/;

	my $upload_filehandle = $cgi->upload("file");
	print "upload_filehandle not defined\n" unless (defined $upload_filehandle);

	my $show = 0;
	my $sample = "";

	my $counts;

	while ( my $rec = <$upload_filehandle> )
	{
		chomp($rec);
		my @field = split(/\t/, $rec);
		foreach my $gene (keys %$genes)
		{
			#if($genes->{$gene}->{CHROMOSOME} eq $field[0] && (($genes->{$gene}->{STRAND} eq "+" && $genes->{$gene}->{START} <= $field[1] && $genes->{$gene}->{END} >= $field[2]) ||($genes->{$gene}->{STRAND} eq "-" && $genes->{$gene}->{START} >= $field[1] && $genes->{$gene}->{END} <= $field[2])))
			#{
			#	#print $genes->{$gene}->{SYMBOL}."<br>";
			#	$counts->{TOTAL}->{$genes->{$gene}->{GENE_ID}} = 1;
			#}

			foreach my $partition (keys %$partitions)
			{
				if($partitions->{$partition}->{TSS_TES} eq "TSS")
				{
					if($genes->{$gene}->{CHROMOSOME} eq $field[0] && (($genes->{$gene}->{STRAND} eq "+" && ($genes->{$gene}->{START} + $partitions->{$partition}->{START}) <= $field[1] && ($genes->{$gene}->{START} + $partitions->{$partition}->{END}) >= $field[2]) || ($genes->{$gene}->{STRAND} eq "-" && ($genes->{$gene}->{END} + ((-1) * $partitions->{$partition}->{START})) >= $field[1] && ($genes->{$gene}->{END} - $partitions->{$partition}->{END}) <= $field[2])))
					{
						#print $genes->{$gene}->{SYMBOL}."<br>";
						$counts->{$partition}->{$genes->{$gene}->{GENE_ID}} = 1;
					}
				}
				else
				{
					if($genes->{$gene}->{CHROMOSOME} eq $field[0] && (($genes->{$gene}->{STRAND} eq "+" && ($genes->{$gene}->{END} + $partitions->{$partition}->{START}) <= $field[1] && ($genes->{$gene}->{END} + $partitions->{$partition}->{END}) >= $field[2]) || ($genes->{$gene}->{STRAND} eq "-" && ($genes->{$gene}->{START} - $partitions->{$partition}->{END}) >= $field[1] && ($genes->{$gene}->{START} - $partitions->{$partition}->{START}) <= $field[2])))
					{
						#print $genes->{$gene}->{SYMBOL}."<br>";
						$counts->{$partition}->{$genes->{$gene}->{GENE_ID}} = 1;
					}
				}
			}
		}
	}

	print "<h1>Dynamic Correlation</h1>";

	print "Click column header to sort ascending by that column (click again for descending order)<BR><BR>";

	print "<table border=1 class=\"sortable\">";
	print "<tr>";
	print "<th>Cell Type</th>";
	foreach my $type (keys %$experiment_types)
	{
		if($type == 3)
		{
			foreach my $factor (keys %$factors)
			{
				foreach my $count (keys %$counts)
				{
					print "<th>".$experiment_types->{$type}->{NAME}."<br>".$factors->{$factor}->{NAME}."<br>".$partitions->{$count}->{NAME}."</th>";
				}
			}
		}
		else
		{
			foreach my $count (keys %$counts)
			{
				print "<th>".$experiment_types->{$type}->{NAME}."<br>".$partitions->{$count}->{NAME}."</th>";
			}
		}
	}
	print "</tr>";

	foreach my $cell (keys %$cell_types)
	{
		print "<tr>";
		print "<td>".$cell_types->{$cell}->{NAME}."</td>";

		foreach my $type (keys %$experiment_types)
		{
			if($type == 3)
			{
				foreach my $factor (keys %$factors)
				{
					foreach my $count (keys %$counts)
					{
			#			if($count ne "TOTAL")
			#			{
							my $sql = 'SELECT * FROM EXPERIMENT_RESULTS WHERE PARTITION_ID = '.$count;
							my $bool = 0;
							foreach my $gene_id (keys %{$counts->{$count}})
							{
								if($bool == 0)
								{
									$sql .= " AND (GENE_ID =\"".$gene_id."\"";
									$bool = 1;
								}
								else
								{
									$sql .= " OR GENE_ID =\"".$gene_id."\"";
								}
							}
							$sql .= ")";

							my $sth = $dbh->prepare($sql);
							my $experiment_results = $dbh->selectall_hashref($sql, 'ID');

							my $cell_found = 0;
							foreach my $experiment (keys %$experiment_results)
							{
								#print $experiment."<br>";
								if($experiments->{$experiment_results->{$experiment}->{EXPERIMENT_ID}}->{CELL_TYPE_ID} == $cell && $experiments->{$experiment_results->{$experiment}->{EXPERIMENT_ID}}->{EXPERIMENT_TYPE_ID} == $type && $experiments->{$experiment_results->{$experiment}->{EXPERIMENT_ID}}->{CHIP_FACTOR_ID} == $factor)
								{
									$cell_found++;
								}
							}
							if($cell_found > 0)
							{
								print "<td align=\"right\">".$cell_found."</td>";
							}
							else
							{
								print "<td align=\"right\"></td>";
							}
			#			}
					}
				}
			}
			else
			{
				foreach my $count (keys %$counts)
				{
		#			if($count ne "TOTAL")
		#			{
						my $sql = 'SELECT * FROM EXPERIMENT_RESULTS WHERE PARTITION_ID = '.$count;
						my $bool = 0;
						foreach my $gene_id (keys %{$counts->{$count}})
						{
							if($bool == 0)
							{
								$sql .= " AND (GENE_ID =\"".$gene_id."\"";
								$bool = 1;
							}
							else
							{
								$sql .= " OR GENE_ID =\"".$gene_id."\"";
							}
						}
						$sql .= ")";

						my $sth = $dbh->prepare($sql);
						my $experiment_results = $dbh->selectall_hashref($sql, 'ID');

						my $cell_found = 0;
						foreach my $experiment (keys %$experiment_results)
						{
							#print $experiment."<br>";
							if($experiments->{$experiment_results->{$experiment}->{EXPERIMENT_ID}}->{CELL_TYPE_ID} == $cell && $experiments->{$experiment_results->{$experiment}->{EXPERIMENT_ID}}->{EXPERIMENT_TYPE_ID} == $type)
							{
								$cell_found++;
							}
						}
						if($cell_found > 0)
						{
							print "<td align=\"right\">".$cell_found."</td>";
						}
						else
						{
							print "<td align=\"right\"></td>";
						}
		#			}
				}
			}
		}
		print "</tr>";
	}
	print "<table>";
}
else
{
	print "<FORM action=\"BP_DYNAMIC_CORRELATION.pl\" method=\"POST\" ENCTYPE=\"multipart/form-data\">";
	print "Track File: <input type=\"file\" name=\"file\" /><BR><input type=\"submit\" name=\"dynamic\" value=\"Submit\">";
	print "</FORM>";
}

BP::footer();

1;
