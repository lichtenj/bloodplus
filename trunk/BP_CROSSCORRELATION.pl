#!/usr/bin/perl

use strict; 
use warnings;
use CGI::Simple;
use DBI;
use CGI; 
use CGI::Carp qw ( fatalsToBrowser ); 
use File::Basename;
use Statistics::Descriptive;
use Statistics::Distributions;
use Data::Dumper;

use BP;
use BP_HELP;

my $helplink = "./BP_HELP.pl";

my $dsn = sprintf(
    'DBI:mysql:database=blood_plus_v2;host=localhost',
    'cdcol', 'localhost'
);

my $dbh = DBI->connect($dsn, $BP::MYSQL_USER,$BP::MYSQL_PASS);

BP::header("Crosscorrelation");

my $cgi = new CGI;

my $sth = $dbh->prepare('SELECT * FROM CELL_TYPES');
my $cell_types = $dbh->selectall_hashref('SELECT * FROM CELL_TYPES', 'ID');

$sth = $dbh->prepare('SELECT * FROM CHIP_FACTORS');
my $factors = $dbh->selectall_hashref('SELECT * FROM CHIP_FACTORS', 'ID');

$sth = $dbh->prepare('SELECT * FROM HISTONE_MARKS');
my $marks = $dbh->selectall_hashref('SELECT * FROM HISTONE_MARKS', 'ID');

$sth = $dbh->prepare('SELECT * FROM DIFFERENTIATION_BRANCH');
my $branches = $dbh->selectall_hashref('SELECT * FROM DIFFERENTIATION_BRANCH', 'ID');

$sth = $dbh->prepare('SELECT * FROM PARTITIONS');
my $partitions = $dbh->selectall_hashref('SELECT * FROM PARTITIONS', 'ID');

$sth = $dbh->prepare('SELECT * FROM PUBLICATIONS');
my $publications = $dbh->selectall_hashref('SELECT * FROM PUBLICATIONS', 'ID');

$sth = $dbh->prepare('SELECT * FROM EXPERIMENT_TYPES');
my $experiment_type_info = $dbh->selectall_hashref('SELECT * FROM EXPERIMENT_TYPES', 'ID');

my $experiment_types;

#FORM SETUP
if(! ($cgi->param("correlation_type_1")))
{
	print '<h2>Index</h2>';
	print '<a href="#differentiation">Differentiation Specific Crosscorrelation</a><br>';
	print '<a href="#celltype">Cell Type Specific Crosscorrelation</a><br>';
	print '<a href="#analysis">Analysis</a><br>';

	print "<FORM action=\"BP_CROSSCORRELATION.pl\" method=\"POST\" ENCTYPE=\"multipart/form-data\">";
#	print "<FORM action=\"dump.pl\" method=\"POST\" ENCTYPE=\"multipart/form-data\">";

	print '<h2 id="differentiation">Differentiation Specific</h2>';
	print "<table border=1>";
	print "<tr>";
	print '<th><a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{'Differentiation Branch'}.'\',\'Differentiation Branch\'); return true;" onmouseout="nd(); return true;">Differentiation Branch</a></th>';
	print '<th><a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{'Cell Type'}.'\',\'Cell Type\'); return true;" onmouseout="nd(); return true;">Cell Type</a></th>';
	my $experiment_type_structure;
	foreach my $experiment_type (sort keys %$experiment_type_info)
	{
		$experiment_type_structure->{$experiment_type_info->{$experiment_type}->{NAME}}->{TYPES}->{$experiment_type} = 1;

		if($experiment_type_structure->{$experiment_type_info->{$experiment_type}->{NAME}}->{ID} > $experiment_type)
		{
			$experiment_type_structure->{$experiment_type_info->{$experiment_type}->{NAME}}->{ID} = $experiment_type;
		}
		else
		{
			$experiment_type_structure->{$experiment_type_info->{$experiment_type}->{NAME}}->{ID} = $experiment_type;
		}
	}
	foreach my $experiment_type (sort {$experiment_type_structure->{$a}->{ID} <=> $experiment_type_structure->{$b}->{ID}} keys %$experiment_type_structure)
	{
		print '<th><a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{''.$experiment_type.''}.'\',\''.$experiment_type.'\'); return true;" onmouseout="nd(); return true;">'.$experiment_type.'</a></th>';
	}
	print "</tr>";

	foreach my $branch_id (keys %$branches)
	{
		if($branches->{$branch_id}->{NAME} eq "-")
		{
			next;
		}
		$sth = $dbh->prepare('SELECT * FROM DIFFERENTIATION_BRANCH_CELLS');
		my $branch_cell_types = $dbh->selectall_hashref('SELECT * FROM DIFFERENTIATION_BRANCH_CELLS WHERE BRANCH_ID = "'.$branch_id.'"', 'CELL_TYPE_ID');

		if(scalar(keys %$branch_cell_types) == 0)
		{
			print "<tr>";
			print "<td>".$branches->{$branch_id}->{NAME}."</td>";
			print "<td>";
			print "</td>";
			print "</tr>";
		}
		else
		{
			my $publication_row = 0;

			my $specific_experiment_types;
			my $specific_experiments;
			foreach my $branch_cell_type_id (keys %$branch_cell_types)
			{				
				$sth = $dbh->prepare('SELECT * FROM EXPERIMENT WHERE CELL_TYPE_ID="'.$branch_cell_type_id.'"');
				my $experiments = $dbh->selectall_hashref('SELECT * FROM EXPERIMENT WHERE CELL_TYPE_ID="'.$branch_cell_type_id.'"', 'ID');
	
		                foreach my $experiment (keys %$experiments)
		                {
					$specific_experiments->{$experiment}->{EXPERIMENT_TYPE_ID} = $experiments->{$experiment}->{EXPERIMENT_TYPE_ID};
					$specific_experiments->{$experiment}->{PUBLICATION_ID} = $experiments->{$experiment}->{PUBLICATION_ID};
					$specific_experiments->{$experiment}->{CELL_TYPE_ID} = $experiments->{$experiment}->{CELL_TYPE_ID};
					$specific_experiments->{$experiment}->{CHIP_FACTOR_ID} = $experiments->{$experiment}->{CHIP_FACTOR_ID};

					$specific_experiment_types->{$experiments->{$experiment}->{EXPERIMENT_TYPE_ID}} = 1;

					print '<input type="hidden" name="cell_id_'.$publication_row.'" value="'.$branch_cell_type_id.'" />';
				}
			}

			print '<input type="hidden" name="branch_id" value="'.$branch_id.'" />';
			print "<tr>";
			print "<td>".$branches->{$branch_id}->{NAME}."</td>";

			print '<td>';
			foreach my $branch_cell_type_id (sort {$cell_types->{$a}->{NAME} cmp $cell_types->{$b}->{NAME}} keys %$branch_cell_types)
			{
				print $cell_types->{$branch_cell_type_id}->{NAME}."<br>";
			}
			print '</td>';

			my $specific_experiment_types;
			foreach my $experiment (keys %$specific_experiments)
			{
				$specific_experiment_types->{$specific_experiments->{$experiment}->{EXPERIMENT_TYPE_ID}} = 1;
			}
			foreach my $experiment_type (sort {$experiment_type_structure->{$a}->{ID} <=> $experiment_type_structure->{$b}->{ID}} keys %$experiment_type_structure)
			{
				print '<td valign=top>';
				print "Type: ".$experiment_type."<br>";
				foreach my $subtype (keys %{$experiment_type_structure->{$experiment_type}->{TYPES}})
				{
					print "Subtype: ".$subtype."<br>";
					if($specific_experiment_types->{$subtype})
					{
						if($experiment_type_info->{$subtype}->{FACTORING})
						{
							BP::selection($experiment_type_info->{$subtype}->{PLATFORM},"branch_".$branch_id,$specific_experiments,$publications,$subtype,$partitions,eval('$'.$experiment_type_info->{$subtype}->{FACTORING}));
						}
						elsif($experiment_type_info->{$subtype}->{PARTITIONING})
						{
							BP::selection($experiment_type_info->{$subtype}->{PLATFORM},"branch_".$branch_id,$specific_experiments,$publications,$subtype,$partitions);
						}
						else
						{
							BP::selection($experiment_type_info->{$subtype}->{PLATFORM},"branch_".$branch_id,$specific_experiments,$publications,$subtype);
						}
					}
				}
				print '</td>';
			}

			$publication_row++;
			print "</tr>";
			print '</form>';				
		}
	}
	print "</table>";

	print '<h2 id="celltype">Cell Type Specific</h2>';
	print "<table border=1 class=\"../../sortable\">";
	print "<thead>";
	print "<tr>";
	print '<th><a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{'Cell Type'}.'\',\'Cell Type\'); return true;" onmouseout="nd(); return true;">Cell Type</a></th>';
	print '<th><a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{'Differentiation Branch'}.'\',\'Differentiation Branch\'); return true;" onmouseout="nd(); return true;">Differentiation Branch</a></th>';
	my $experiment_type_structure;
	foreach my $experiment_type (sort keys %$experiment_type_info)
	{
		$experiment_type_structure->{$experiment_type_info->{$experiment_type}->{NAME}}->{TYPES}->{$experiment_type} = 1;

		if($experiment_type_structure->{$experiment_type_info->{$experiment_type}->{NAME}}->{ID} > $experiment_type)
		{
			$experiment_type_structure->{$experiment_type_info->{$experiment_type}->{NAME}}->{ID} = $experiment_type;
		}
		else
		{
			$experiment_type_structure->{$experiment_type_info->{$experiment_type}->{NAME}}->{ID} = $experiment_type;
		}
	}
	foreach my $experiment_type (sort {$experiment_type_structure->{$a}->{ID} <=> $experiment_type_structure->{$b}->{ID}} keys %$experiment_type_structure)
	{
		print '<th><a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{''.$experiment_type.''}.'\',\''.$experiment_type.'\'); return true;" onmouseout="nd(); return true;">'.$experiment_type.'</a></th>';
	}
	print "<tr>";
	print "</thead>";

	foreach my $cell_type (sort {$cell_types->{$a}->{NAME} cmp $cell_types->{$b}->{NAME}} keys %$cell_types)
	{
		print '<tr>';
		print '<td>';
		print $cell_types->{$cell_type}->{NAME};
		print '</td>';

		$sth = $dbh->prepare('SELECT * FROM DIFFERENTIATION_BRANCH_CELLS WHERE CELL_TYPE_ID="'.$cell_type.'"');
		my $cell_branches = $dbh->selectall_hashref('SELECT * FROM DIFFERENTIATION_BRANCH_CELLS WHERE CELL_TYPE_ID="'.$cell_type.'"', 'ID');

		$sth = $dbh->prepare('SELECT * FROM EXPERIMENT WHERE CELL_TYPE_ID="'.$cell_type.'"');
		my $experiments = $dbh->selectall_hashref('SELECT * FROM EXPERIMENT WHERE CELL_TYPE_ID="'.$cell_type.'"', 'ID');

		print "<td>";
		foreach my $branch (keys %$cell_branches)
		{
			print $branches->{$cell_branches->{$branch}->{BRANCH_ID}}->{NAME}."<br>";
		}
		print "</td>";

		my $specific_experiment_types;
		foreach my $experiment (keys %$experiments)
		{
			$specific_experiment_types->{$experiments->{$experiment}->{EXPERIMENT_TYPE_ID}} = 1;
			#print '<option value="'.$experiments->{$experiment}->{PUBLICATION_ID}.'" selected>'.$publications->{$experiments->{$experiment}->{PUBLICATION_ID}}->{CITATION}."</option>";
		}
		foreach my $experiment_type (sort {$experiment_type_structure->{$a}->{ID} <=> $experiment_type_structure->{$b}->{ID}} keys %$experiment_type_structure)
		{
			print '<td valign=top>';
			foreach my $subtype (keys %{$experiment_type_structure->{$experiment_type}->{TYPES}})
			{
				if($specific_experiment_types->{$subtype})
				{
					if($experiment_type_info->{$subtype}->{FACTORING})
					{
						BP::selection($experiment_type_info->{$subtype}->{PLATFORM},$cell_type,$experiments,$publications,$subtype,$partitions,eval('$'.$experiment_type_info->{$subtype}->{FACTORING}));
					}
					elsif($experiment_type_info->{$subtype}->{PARTITIONING})
					{
						BP::selection($experiment_type_info->{$subtype}->{PLATFORM},$cell_type,$experiments,$publications,$subtype,$partitions);
					}
					else
					{
						BP::selection($experiment_type_info->{$subtype}->{PLATFORM},$cell_type,$experiments,$publications,$subtype);
					}
				}
			}
			print '</td>';
		}
		print '</tr>';
	}
	print '</table>';

	print '<br>';
	print '<h2 id="analysis">Analysis</h2>';
	print '<table>';
	print '<tr>';
	print '<td align=center><input type="checkbox" name="verbose" value="1"></td>';
	print '<td>Verbose</td>';
	print '</tr>';
	print '<tr>';
	print '<td><input type="text" name="general_expression_threshold_similar" value="0.005" style="width: 50px;"></td>';
	print '<td>Statistical Significance Threshold</td>';
	print '</tr>';
	print '</table>';
	print '<br>';
	print '<input type="submit" name="correlation_type_1" style="width: 150px;" value="Analyze"><br>';
#	print '<table>';
#	print '<tr><td>Correlation</td><td>Submission</td></tr>';
#	print '<tr><td><a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{'Union'}.'\',\'Union\'); return true;" onmouseout="nd(); return true;">Union</a></td><td><input type="submit" name="correlation_type_1" value="Go"></td></tr>';
#	print '<tr><td><a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{'Intersection'}.'\',\'Intersection\'); return true;" onmouseout="nd(); return true;">Intersection</td></a></td><td><input type="submit" name="correlation_type_2" value="Go"></td></tr>';
#	print '<tr><td><a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{'Intersection (Similar Genes)'}.'\',\'Intersection (Similar Genes)\'); return true;" onmouseout="nd(); return true;">Intersection (Similar Genes)</td></a><td><input type="submit" name="correlation_type_2" value="Go"></td></tr>';
#	print '<tr><td><a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{'Intersection (Different Genes)'}.'\',\'Intersection (Different Genes)\'); return true;" onmouseout="nd(); return true;">Intersection (Different Genes)</td></a><td><input type="submit" name="correlation_type_3" value="Go"></td></tr>';
#	print '</table>';
	print '<input type="reset" name="clear" style="width: 150px;" value="Clear">';
	print "</FORM>";

	exit;
}

#ANALYSIS

my $used_cell_types_expression;
my $used_cell_types_methylation;
my $used_cell_types_chip;

my $general_expression_threshold = 0.005;
my $correlation_type = 0;

my $analysis_id = time();
my $verbose = $cgi->param('verbose');

open(OUT, ">../../ANALYSIS/".$analysis_id.".html");
open(OUT_UNION, ">../../ANALYSIS/".$analysis_id."_union.html");
open(OUT_DIFF, ">../../ANALYSIS/".$analysis_id."_different.html");
open(OUT_SIM, ">../../ANALYSIS/".$analysis_id."_similar.html");

$general_expression_threshold = $cgi->param("general_expression_threshold");
if($cgi->param("correlation_type_3"))
{
	$correlation_type = 3;
	print OUT_DIFF "<h2>Inverse Intersection (Significantly Different Genes) - Correlation Threshold ".$cgi->param("general_expression_threshold_different")."</h2>";
	$general_expression_threshold = $cgi->param("general_expression_threshold_similar");
}
elsif($cgi->param("correlation_type_4"))
{
	$correlation_type = 4;
	print OUT "<h2>Intersection</h2>";
	$general_expression_threshold = $cgi->param("general_expression_threshold_similar");
}
elsif($cgi->param("correlation_type_2"))
{
	$correlation_type = 2;
	print OUT_SIM "<h2>Intersection (Similar Genes) - Correlation Threshold ".$cgi->param("general_expression_threshold_similar")."</h2>";
	$general_expression_threshold = $cgi->param("general_expression_threshold_similar");
}
elsif($cgi->param("correlation_type_1"))
{
	$correlation_type = 1;
	print OUT_UNION "<h2>Union</h2>";
}
else
{
	print "No correlation type specified";
	exit;
}

foreach my $branch (keys %$branches)
{
	foreach my $experiment_type (keys %$experiment_type_info)
	{
		if($cgi->param("branch_".$branch."_".$experiment_type))
		{
			print "<h3>".$experiment_type_info->{$experiment_type}->{NAME}." in ".$branches->{$branch}->{NAME}." (Threshold ".$cgi->param("branch_".$branch."_".$experiment_type."_threshold").")</h3>";

			$sth = $dbh->prepare('SELECT * FROM DIFFERENTIATION_BRANCH_CELLS WHERE BRANCH_ID = "'.$branch.'"');
			my $branch_cell_types = $dbh->selectall_hashref('SELECT * FROM DIFFERENTIATION_BRANCH_CELLS WHERE BRANCH_ID = "'.$branch.'"', 'CELL_TYPE_ID');

			foreach my $cell_type (keys %$branch_cell_types)
			{
				$cgi->param(-name=>$cell_type."_".$experiment_type,-value=>1);
				$cgi->param(-name=>$cell_type."_".$experiment_type."_threshold",-value=>$cgi->param("branch_".$branch."_".$experiment_type."_threshold"));
				$cgi->param(-name=>$cell_type."_".$experiment_type."_fixed_experiment",-value=>$cgi->param("branch_".$branch."_".$experiment_type."_fixed_experiment"));
			}
		}
	}
}

print '<ul>';
my $specific_experiments;
foreach my $cell_type (keys %$cell_types)
{
	foreach my $experiment_type (keys %$experiment_type_info)
	{
		if($cgi->param($cell_type."_".$experiment_type))
		{
			print "<li>".$experiment_type_info->{$experiment_type}->{NAME}." in ".$cell_types->{$cell_type}->{NAME}." (Threshold ".$cgi->param($cell_type."_".$experiment_type."_threshold").")</li>";
			my @fixed_experiments = $cgi->param(-name=>$cell_type."_".$experiment_type."_fixed_experiment");
			foreach my $fixed_experiment (@fixed_experiments)
			{
				my @multi_experiments = split(/\_/, $fixed_experiment);
				foreach my $experiment (@multi_experiments)
				{
					$specific_experiments->{$experiment_type}->{$experiment}->{INCLUDE} = 1;
	
					my @fixed_partitions = $cgi->param(-name=>$cell_type."_".$experiment_type."_partition");
					foreach my $fixed_partition (@fixed_partitions)
					{
						$specific_experiments->{$experiment_type}->{$experiment}->{PARTITIONS}->{$fixed_partition} = 1;
					}
					my @fixed_factors = $cgi->param(-name=>$cell_type."_".$experiment_type."_factor");
					foreach my $fixed_factor (@fixed_factors)
					{
						$specific_experiments->{$experiment_type}->{$experiment}->{FACTORS}->{$fixed_factor} = 1;
					}
				}
			}
		}
	}
}
print '</ul>';

#Extract the pooled data;
my $sql = 'SELECT * FROM EXPERIMENT_RESULTS WHERE ';
my $count_types = 0;
foreach my $experiment_type (keys %$specific_experiments)
{
	$count_types++;
	my $count_experiments = 0;
	foreach my $experiment (keys %{$specific_experiments->{$experiment_type}})
	{
		$count_experiments++;
		$sql .= '(';
		$sql .= 'EXPERIMENT_ID = '.$experiment;
		if($specific_experiments->{$experiment_type}->{$experiment}->{PARTITIONS})
		{
			$sql .= ' AND ';
			$sql .= '(';
			my $count = 0;
			foreach my $partition (keys %{$specific_experiments->{$experiment_type}->{$experiment}->{PARTITIONS}})
			{
				$count++;
				$sql .= 'PARTITION_ID = '.$partition;
				if($count < scalar(keys %{$specific_experiments->{$experiment_type}->{$experiment}->{PARTITIONS}}))
				{
					$sql .= ' || ';
				}
			}
			$sql .= ')';
		}
		$sql .= ')';
		if($count_experiments < scalar(keys %{$specific_experiments->{$experiment_type}}))
		{
			$sql .= ' || ';
		}
	}
	if($count_types < scalar(keys %$specific_experiments))
	{
		$sql .= ' || ';
	}
}

$sth = $dbh->prepare($sql);
my $experiment_results = $dbh->selectall_hashref($sql, 'ID');

$sth = $dbh->prepare('SELECT * FORM EXPERIMENT');
my $experiments = $dbh->selectall_hashref('SELECT * FROM EXPERIMENT', 'ID');

$sth = $dbh->prepare('SELECT * FROM GENES');
my $genes = $dbh->selectall_hashref('SELECT * FROM GENES', 'GENE_ID');

$sth = $dbh->prepare('SELECT * FROM GENES');
my $transcripts = $dbh->selectall_hashref('SELECT * FROM GENES', 'ENSEMBL_ID');

my $specific_cells;

foreach my $cell_type (keys %$cell_types)
{
	foreach my $type (sort keys %$specific_experiments)
	{
		if($cgi->param($cell_type."_".$type))
		{
			$specific_cells->{$type}->{$cell_type} = 1;
		}
	}
}

my $hash;
my $maximum_hash;
my $fpkm_cells;
my $fpkm_stats;

foreach my $result_id (keys %$experiment_results)
{
	if($experiment_results->{$result_id}->{GENE_ID} !~ /\,/)
	{
		foreach my $type (sort keys %$specific_experiments)
		{
			if($specific_experiments->{$type}->{$experiment_results->{$result_id}->{EXPERIMENT_ID}})
			{
				my $id = $experiment_results->{$result_id}->{GENE_ID};

				if($id =~ /ENSMUST/)
				{
					$id = $transcripts->{$id}->{GENE_ID};
				}

#				if($type == 2)
#				{
					if($experiment_results->{$result_id}->{MEASUREMENT} != 0)
					{
						$fpkm_cells->{$type}->{$experiments->{$experiment_results->{$result_id}->{EXPERIMENT_ID}}->{CELL_TYPE_ID}} .= $experiment_results->{$result_id}->{MEASUREMENT}.",";
					}
#				}
				if($experiment_results->{$result_id}->{MEASUREMENT})
				{

					$hash->{$id}->{$type}->{$experiments->{$experiment_results->{$result_id}->{EXPERIMENT_ID}}->{CELL_TYPE_ID}} .= $experiment_results->{$result_id}->{MEASUREMENT}.",";
					if((! $maximum_hash->{$type}->{ALL}) || $maximum_hash->{$type}->{ALL} < $experiment_results->{$result_id}->{MEASUREMENT})
					{
						$maximum_hash->{$type}->{ALL} = $experiment_results->{$result_id}->{MEASUREMENT};
					}
				}
				else
				{
					$hash->{$id}->{$type}->{$experiments->{$experiment_results->{$result_id}->{EXPERIMENT_ID}}->{CELL_TYPE_ID}} .= $experiment_results->{$result_id}->{CONFIDENCE}.",";
					$hash->{$id}->{$type}->{$experiments->{$experiment_results->{$result_id}->{EXPERIMENT_ID}}->{CELL_TYPE_ID}} .= $experiment_results->{$result_id}->{CONFIDENCE}.",";
					$hash->{$id}->{$type}->{$experiments->{$experiment_results->{$result_id}->{EXPERIMENT_ID}}->{CELL_TYPE_ID}} .= $experiment_results->{$result_id}->{CONFIDENCE}.",";
					if((! $maximum_hash->{$type}->{ALL}) || $maximum_hash->{$type}->{ALL} < $experiment_results->{$result_id}->{CONFIDENCE})
					{
						$maximum_hash->{$type}->{ALL} .= $experiment_results->{$result_id}->{CONFIDENCE};
					}
				}
			}
		}
	}
}

print '<h2>Thresholds</h2>';
print '<table border=1>';
print '<tr><th>Cell Type</th><th>Experiment Type</th><th>Low</th><th>Medium</th><th>High</th></tr>';
foreach my $type (keys %$fpkm_cells)
{
	foreach my $cell_type (keys %{$fpkm_cells->{$type}})
	{
		my $stats = Statistics::Descriptive::Full->new();
	
		my @measurements = split(/\,/, $fpkm_cells->{$type}->{$cell_type});
		foreach my $measurement (@measurements)
		{
			$stats->add_data($measurement);
		}
	
		#
		# Quartile based expression detection based on Toung et al. "RNA-sequence analysis of human B-cells" in Genome Research 2011
		#
		$fpkm_stats->{$type}->{$cell_type}->{25} = $stats->percentile(25);
		$fpkm_stats->{$type}->{$cell_type}->{50} = $stats->percentile(50);
		$fpkm_stats->{$type}->{$cell_type}->{75} = $stats->percentile(75);
		print '<tr><td>'.$cell_types->{$cell_type}->{NAME}.'</td>';
		print '<td>'.$experiment_type_info->{$type}->{NAME}.'</td>';
		print '<td>'.$fpkm_stats->{$type}->{$cell_type}->{25}.'</td>';
		print '<td>'.$fpkm_stats->{$type}->{$cell_type}->{50}.'</td>';
		print '<td>'.$fpkm_stats->{$type}->{$cell_type}->{75}.'</td>';
		print '</tr>';
	}
}
print '</table><br>';

if($verbose == 1){print '<table border=1>';}
print OUT '<table border=1>';
print OUT_UNION '<table border=1>';
print OUT_DIFF '<table border=1>';
print OUT_SIM '<table border=1>';

if($verbose == 1){print '<tr>';}
print OUT '<tr>';
print OUT_UNION '<tr>';
print OUT_DIFF '<tr>';
print OUT_SIM '<tr>';

if($verbose == 1){print '<th rowspan=2><a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{'Gene Symbol'}.'\',\'Gene Symbol\'); return true;" onmouseout="nd(); return true;">Gene Symbol</th>';}
print OUT '<th rowspan=2><a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{'Gene Symbol'}.'\',\'Gene Symbol\'); return true;" onmouseout="nd(); return true;">Gene Symbol</th>';
print OUT_UNION '<th rowspan=2><a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{'Gene Symbol'}.'\',\'Gene Symbol\'); return true;" onmouseout="nd(); return true;">Gene Symbol</th>';
print OUT_DIFF '<th rowspan=2><a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{'Gene Symbol'}.'\',\'Gene Symbol\'); return true;" onmouseout="nd(); return true;">Gene Symbol</th>';
print OUT_SIM '<th rowspan=2><a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{'Gene Symbol'}.'\',\'Gene Symbol\'); return true;" onmouseout="nd(); return true;">Gene Symbol</th>';

if($verbose == 1){print '<th rowspan=2><a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{'Gene Symbol'}.'\',\'Gene Symbol\'); return true;" onmouseout="nd(); return true;">Transcript ID</th>';}
print OUT '<th rowspan=2><a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{'Gene Symbol'}.'\',\'Gene Symbol\'); return true;" onmouseout="nd(); return true;">Transcript ID</th>';
print OUT_UNION '<th rowspan=2><a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{'Gene Symbol'}.'\',\'Gene Symbol\'); return true;" onmouseout="nd(); return true;">Transcript ID</th>';
print OUT_DIFF '<th rowspan=2><a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{'Gene Symbol'}.'\',\'Gene Symbol\'); return true;" onmouseout="nd(); return true;">Transcript ID</th>';
print OUT_SIM '<th rowspan=2><a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{'Gene Symbol'}.'\',\'Gene Symbol\'); return true;" onmouseout="nd(); return true;">Transcript ID</th>';

foreach my $type (sort keys %$specific_experiments)
{
	if($verbose == 1){print '<th colspan='.(scalar(keys %{$specific_cells->{$type}}) + 1).'>';}
	if($verbose == 1){print '<a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{$experiment_type_info->{$type}->{NAME}}.'\',\''.$experiment_type_info->{$type}->{NAME}.'\'); return true;" onmouseout="nd(); return true;">';}
	if($verbose == 1){print $experiment_type_info->{$type}->{NAME}.'<br>'.$experiment_type_info->{$type}->{PLATFORM};}
	if($verbose == 1){print '</a>';}
	if($verbose == 1){print '</th>';}

	print OUT '<th colspan='.(scalar(keys %{$specific_cells->{$type}}) + 1).'>';
	print OUT '<a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{$experiment_type_info->{$type}->{NAME}}.'\',\''.$experiment_type_info->{$type}->{NAME}.'\'); return true;" onmouseout="nd(); return true;">';
	print OUT $experiment_type_info->{$type}->{NAME}.'<br>'.$experiment_type_info->{$type}->{PLATFORM};
	print OUT '</a>';
	print OUT '</th>';

	print OUT_UNION '<th colspan='.(scalar(keys %{$specific_cells->{$type}}) + 1).'>';
	print OUT_UNION '<a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{$experiment_type_info->{$type}->{NAME}}.'\',\''.$experiment_type_info->{$type}->{NAME}.'\'); return true;" onmouseout="nd(); return true;">';
	print OUT_UNION $experiment_type_info->{$type}->{NAME}.'<br>'.$experiment_type_info->{$type}->{PLATFORM};
	print OUT_UNION '</a>';
	print OUT_UNION '</th>';

	print OUT_DIFF '<th colspan='.(scalar(keys %{$specific_cells->{$type}}) + 1).'>';
	print OUT_DIFF '<a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{$experiment_type_info->{$type}->{NAME}}.'\',\''.$experiment_type_info->{$type}->{NAME}.'\'); return true;" onmouseout="nd(); return true;">';
	print OUT_DIFF $experiment_type_info->{$type}->{NAME}.'<br>'.$experiment_type_info->{$type}->{PLATFORM};
	print OUT_DIFF '</a>';
	print OUT_DIFF '</th>';

	print OUT_SIM '<th colspan='.(scalar(keys %{$specific_cells->{$type}}) + 1).'>';
	print OUT_SIM '<a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{$experiment_type_info->{$type}->{NAME}}.'\',\''.$experiment_type_info->{$type}->{NAME}.'\'); return true;" onmouseout="nd(); return true;">';
	print OUT_SIM $experiment_type_info->{$type}->{NAME}.'<br>'.$experiment_type_info->{$type}->{PLATFORM};
	print OUT_SIM '</a>';
	print OUT_SIM '</th>';
}
if($verbose == 1){print '</tr>';}
print OUT '</tr>';
print OUT_UNION '</tr>';
print OUT_DIFF '</tr>';
print OUT_SIM '</tr>';

my $cell_behavior = 0;

if($verbose == 1){print '<tr>';}
print OUT '<tr>';
print OUT_UNION '<tr>';
print OUT_DIFF '<tr>';
print OUT_SIM '<tr>';

foreach my $type (sort keys %$specific_experiments)
{
	foreach my $cell_type (sort keys %$cell_types)
        {
                if($cgi->param($cell_type."_".$type))
                {
			if($verbose == 1){print '<th>';}
			if($verbose == 1){print '<a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{$experiment_type_info->{$type}->{NAME}}.'\',\''.$experiment_type_info->{$type}->{NAME}.'\'); return true;" onmouseout="nd(); return true;">';}
			if($verbose == 1){print 'Mean</a>';}
			if($verbose == 1){print '<br>';}
			if($verbose == 1){print $cell_types->{$cell_type}->{NAME};}
			if($verbose == 1){print '</th>';}

			print OUT '<th>';
			print OUT '<a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{$experiment_type_info->{$type}->{NAME}}.'\',\''.$experiment_type_info->{$type}->{NAME}.'\'); return true;" onmouseout="nd(); return true;">';
			print OUT 'Mean</a>';
			print OUT '<br>';
			print OUT $cell_types->{$cell_type}->{NAME};
			print OUT '</th>';

			print OUT_UNION '<th>';
			print OUT_UNION '<a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{$experiment_type_info->{$type}->{NAME}}.'\',\''.$experiment_type_info->{$type}->{NAME}.'\'); return true;" onmouseout="nd(); return true;">';
			print OUT_UNION 'Mean</a>';
			print OUT_UNION '<br>';
			print OUT_UNION $cell_types->{$cell_type}->{NAME};
			print OUT_UNION '</th>';

			print OUT_DIFF '<th>';
			print OUT_DIFF '<a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{$experiment_type_info->{$type}->{NAME}}.'\',\''.$experiment_type_info->{$type}->{NAME}.'\'); return true;" onmouseout="nd(); return true;">';
			print OUT_DIFF 'Mean</a>';
			print OUT_DIFF '<br>';
			print OUT_DIFF $cell_types->{$cell_type}->{NAME};
			print OUT_DIFF '</th>';

			print OUT_SIM '<th>';
			print OUT_SIM '<a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{$experiment_type_info->{$type}->{NAME}}.'\',\''.$experiment_type_info->{$type}->{NAME}.'\'); return true;" onmouseout="nd(); return true;">';
			print OUT_SIM 'Mean</a>';
			print OUT_SIM '<br>';
			print OUT_SIM $cell_types->{$cell_type}->{NAME};
			print OUT_SIM '</th>';
                }
        }

	if($verbose == 1){print '<th>';}
	if($verbose == 1){print '<a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{$experiment_type_info->{$type}->{NAME}}.'\',\''.$experiment_type_info->{$type}->{NAME}.'\'); return true;" onmouseout="nd(); return true;">';}
	if($verbose == 1){print 'Behavior<br>';}
	if($verbose == 1){print '</a>';}

	print OUT '<th>';
	print OUT '<a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{$experiment_type_info->{$type}->{NAME}}.'\',\''.$experiment_type_info->{$type}->{NAME}.'\'); return true;" onmouseout="nd(); return true;">';
	print OUT 'Behavior<br>';
	print OUT '</a>';

	print OUT_UNION '<th>';
	print OUT_UNION '<a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{$experiment_type_info->{$type}->{NAME}}.'\',\''.$experiment_type_info->{$type}->{NAME}.'\'); return true;" onmouseout="nd(); return true;">';
	print OUT_UNION 'Behavior<br>';
	print OUT_UNION '</a>';

	print OUT_DIFF '<th>';
	print OUT_DIFF '<a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{$experiment_type_info->{$type}->{NAME}}.'\',\''.$experiment_type_info->{$type}->{NAME}.'\'); return true;" onmouseout="nd(); return true;">';
	print OUT_DIFF 'Behavior<br>';
	print OUT_DIFF '</a>';

	print OUT_SIM '<th>';
	print OUT_SIM '<a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'Crosscorrelation'}->{$experiment_type_info->{$type}->{NAME}}.'\',\''.$experiment_type_info->{$type}->{NAME}.'\'); return true;" onmouseout="nd(); return true;">';
	print OUT_SIM 'Behavior<br>';
	print OUT_SIM '</a>';

	my $output = "";
	foreach my $cell_type (sort keys %$cell_types)
	{
                if($cgi->param($cell_type."_".$type))
                {
			$cell_behavior++;
			$output .= $cell_types->{$cell_type}->{NAME}.' -> ';
		}
	}
	$output =~ s/....$//;

	if($verbose == 1){print $output;}
	print OUT $output;
	print OUT_UNION $output;
	print OUT_DIFF $output;
	print OUT_SIM $output;

	if($verbose == 1){print '</th>';}
	print OUT '</th>';
	print OUT_UNION '</th>';
	print OUT_DIFF '</th>';
	print OUT_SIM '</th>';
}
if($verbose == 1){print '</tr>';}
print OUT '</tr>';
print OUT_UNION '</tr>';
print OUT_DIFF '</tr>';
print OUT_SIM '</tr>';

my $result_count_union = 0;
my $result_count_intersect = 0;
my $result_count_intersect_different = 0;
my $result_count_intersect_similar = 0;
foreach my $gene_id (keys %$hash)
{
	my $union = 1;
	my $intersect = 0;
	my $intersect_similar = 0;
	my $intersect_different = 0;

	my $output = '<tr>';
	$output .= '<td><a href="http://genome.ucsc.edu/cgi-bin/hgTracks?org=Mouse&db=mm9&position='.$genes->{$gene_id}->{ENSEMBL_ID}.'">'.$genes->{$gene_id}->{SYMBOL}.'</td>';
	$output .= '<td>'.$gene_id.'</td>';

	my $bool_intersections;
	my $union_bool = 0;
	foreach my $type (sort keys %$specific_experiments)
	{
		if($hash->{$gene_id}->{$type})
		{
			my $mean = mean_hash($hash->{$gene_id}->{$type});
			my $decision = anova(0.05,$hash->{$gene_id}->{$type},$mean);
	
			#Is the gene is expressed in all cell types?
			my $bool_expressed;
			foreach my $cell_type (sort keys %$cell_types)
		        {
		                if($cgi->param($cell_type."_".$type) && $hash->{$gene_id}->{$type}->{$cell_type})
				{
					my $mean_cell = mean_array($hash->{$gene_id}->{$type}->{$cell_type});
					if($mean_cell >= $fpkm_stats->{$type}->{$cell_type}->{$cgi->param($cell_type.'_'.$type.'_thresholdlevel')})
					{
						$bool_expressed->{$cell_type} = 1;
						$union_bool = 1;
						$output .= '<td align=right>'.sprintf("%.5f",$mean_cell);
						$output .= '</td>';
					}
					else
					{
						$output .= '<td></td>'; #Means
					}
					
				}
				elsif($cgi->param($cell_type."_".$type))
				{
					$output .= '<td></td>'; #Means
				}
			}

			if(scalar(keys %$bool_expressed) == scalar(keys %{$hash->{$gene_id}->{$type}}))
			{
				#$output .= "<td>Intersect: ".$decision."</td>";
				$bool_intersections->{$type} = 1;

				if($decision == 2 || $decision == 0 || $decision == 1)
				{
					$intersect = 1;
				}
				if($decision == 0)
				{
					$intersect_different = 1;
				#	$output .= " (Different)";
				}
				if($decision == 1)
				{
					$intersect_similar = 1;
				#	$output .= " (Similar)";
				}
			}
			
			#Behavior of the measurement development between the various cell types
			$output .= '<td>';
			if($hash->{$gene_id}->{$type})
			{
				my $previous_mean;
				foreach my $cell_type (sort keys %{$hash->{$gene_id}->{$type}})
				{
					if(!$previous_mean)
					{
						$previous_mean = mean_array($hash->{$gene_id}->{$type}->{$cell_type});
					}
					else
					{
						if(mean_array($hash->{$gene_id}->{$type}->{$cell_type}) < $previous_mean + 1 && mean_array($hash->{$gene_id}->{$type}->{$cell_type}) > $previous_mean - 1)
						{
							$output .= 'Maintain -> ';
						}
						else
						{
							if($previous_mean > mean_array($hash->{$gene_id}->{$type}->{$cell_type}))
							{
								$output .= 'Decrease -> ';					
							}
							else#if($previous_mean > mean_array($hash->{$gene_id}->{$type}->{$cell_type}))
							{
								$output .= 'Increase -> ';
							}
						}
					}
				}
				$output =~ s/\ \-\>\ $//;
			}
			$output .= '</td>';
		}
		else
		{
			foreach my $cell_type (keys %$cell_types)
		        {
		                if($cgi->param($cell_type."_".$type))
		                {
					$output .= '<td></td>'; #Means
				}
			}
			$output .= '<td></td>'; #Behavior
		}
	}
	$output .= '</tr>';

#	print $result_count_union." - ".$result_count_intersect." - ".$intersect." - ".scalar(keys %{$hash->{$gene_id}})." - ".scalar(keys %$bool_intersections)."<br>";

	if($intersect == 1 && scalar(keys %{$hash->{$gene_id}}) == scalar(keys %$bool_intersections))
	{
		print OUT $output;
		$result_count_intersect++;
	}
	if($union == 1 && $union_bool == 1)
	{
		print OUT_UNION $output;
		$result_count_union++;
	}
	if($intersect_different == 1 && scalar(keys %{$hash->{$gene_id}}) == scalar(keys %$bool_intersections))
	{
		print OUT_DIFF $output;
		$result_count_intersect_different++;
	}
	if($intersect_similar == 1 && scalar(keys %{$hash->{$gene_id}}) == scalar(keys %$bool_intersections))
	{
		print OUT_SIM $output;
		$result_count_intersect_similar++;
	}

	if($verbose == 1)
	{
		if($correlation_type == 4 && $intersect == 1 && scalar(keys %{$hash->{$gene_id}}) == scalar(keys %$bool_intersections))
		{
			print $output;
		}
		if($correlation_type == 1 && $union == 1 && $union_bool == 1)
		{
			print $output;
		}
		if($correlation_type == 3 && $intersect_different == 1 && scalar(keys %{$hash->{$gene_id}}) == scalar(keys %$bool_intersections))
		{
			print $output;
		}
		if($correlation_type == 2 && $intersect_similar == 1 && scalar(keys %{$hash->{$gene_id}}) == scalar(keys %$bool_intersections))
		{
			print $output;
		}
	}
}
if($verbose == 1)
{
	print '<table>';
	print '<br>';
}
print OUT '</table>';
print OUT_UNION '</table>';
print OUT_DIFF '</table>';
print OUT_SIM '</table>';

print '<h2>Correlations</h2>';
print '<table border=1>';
print '<tr><th>Correlation Type</th><th># of Genes</th></tr>';
print '<tr><td>Union</td><td><a href="../../ANALYSIS/'.$analysis_id.'_union.html">'.$result_count_union.'</a></td></tr>';
print '<tr><td>Intersection</td><td><a href="../../ANALYSIS/'.$analysis_id.'.html">'.$result_count_intersect.'</a></td></tr>';
print '<tr><td>Intersection (Different Genes)</td><td><a href="../../ANALYSIS/'.$analysis_id.'_different.html">'.$result_count_intersect_different.'</a></td></tr>';
print '<tr><td>Intersection (Similar Genes)</td><td><a href="../../ANALYSIS/'.$analysis_id.'_similar.html">'.$result_count_intersect_similar.'</a></td></tr>';
print '</table>';

#Sequence Output

#	if($result_count > 0 && $result_count < 1000)
#	{
#	    	# child
#		my $export_seq = time();
#		open(OUT, ">../../EXPORT/".$export_seq.".bed") or die "Cannot open for writing";
#		open(OUTGENES, ">../../EXPORT/".$export_seq.".genes") or die "Cannot open for writing";
#		foreach my $gene (keys %$found_genes)
#		{
#			if($found_genes->{$gene}->{CHR})
#			{
#				print OUT $found_genes->{$gene}->{CHR}."\t";
#				print OUT $found_genes->{$gene}->{START}."\t";
#				print OUT $found_genes->{$gene}->{END}."\t";
#				print OUT $genes->{$gene}->{SYMBOL}."\n";
#	
#				print OUTGENES $genes->{$gene}->{SYMBOL}."\n";
#			}
#		}
#		close OUT;
#		close OUTGENES;
#		my $cmd = '/home/darklichti/bin/i386-redhat-linux-gnu/twoBitToFa -bed=/var/www/EXPORT/'.$export_seq.'.bed ../../EXPORT/mm9.2bit /var/www/EXPORT/'.$export_seq.'.fa';
#		system($cmd);
#		print "Extract Data:<br>";
#		print "<ul>";
#		print '<li><a href="../../EXPORT/'.$export_seq.'.genes">Genelist</a></li>';
#		print '<ul>';
#		foreach my $partition (keys %$partitions)
#		{
#			print '<li><a href="../../EXPORT/'.$export_seq.'_'.$partitions->{$partition}->{NAME}.'.bed">Genelist ('.$partitions->{$partition}->{NAME}.')</a></li>';
#		}
#		print '</ul>';	
#		print '<li><a href="../../EXPORT/'.$export_seq.'.bed">Genomic Coordinates</a></li>';
#		print '<li><a href="../../EXPORT/'.$export_seq.'.fa">Sequences</a></li>';
#		print '<ul>';
#		foreach my $partition (keys %$partitions)
#		{
#			open(OUT, ">../../EXPORT/".$export_seq."_".$partitions->{$partition}->{NAME}.".bed") or die "Cannot open for writing";
#			foreach my $gene (keys %$found_genes)
#			{
#				if($found_genes->{$gene}->{CHR})
#				{
#					print OUT $found_genes->{$gene}->{CHR}."\t";
#					if($genes->{$gene}->{STRAND} eq "+")
#					{
#						if($partitions->{$partition}->{TSS_TES} eq "TSS")
#						{
#							print OUT ($found_genes->{$gene}->{START} + $partitions->{$partition}->{START})."\t";
#							print OUT ($found_genes->{$gene}->{START}  + $partitions->{$partition}->{END})."\t";
#						}
#						else
#						{
#							print OUT ($found_genes->{$gene}->{END} + $partitions->{$partition}->{START})."\t";
#							print OUT ($found_genes->{$gene}->{END} + $partitions->{$partition}->{END})."\t";
#						}
#					}
#					else
#					{
#						if($partitions->{$partition}->{TSS_TES} eq "TSS")
#						{
#							print OUT ($found_genes->{$gene}->{END} + ((-1) * $partitions->{$partition}->{START}))."\t";
#							print OUT ($found_genes->{$gene}->{END} + ((-1) *  $partitions->{$partition}->{END}))."\t";
#						}
#						else
#						{
#							print OUT ($found_genes->{$gene}->{START} - $partitions->{$partition}->{START})."\t";
#							print OUT ($found_genes->{$gene}->{START} - $partitions->{$partition}->{END})."\t";
#						}
#					}
#					print OUT $genes->{$gene}->{SYMBOL}."\n";
#					print OUTGENES $genes->{$gene}->{SYMBOL}."\n";
#				}
#			}
#			close OUT;
#			close OUTGENES;
#
#			my $cmd = '/home/darklichti/bin/i386-redhat-linux-gnu/twoBitToFa -bed=/var/www/EXPORT/'.$export_seq.'_'.$partitions->{$partition}->{NAME}.'.bed ../../EXPORT/mm9.2bit /var/www/EXPORT/'.$export_seq.'_'.$partitions->{$partition}->{NAME}.'.fa';
#			exec($cmd);
#
#			print '<li><a href="../../EXPORT/'.$export_seq.'_'.$partitions->{$partition}->{NAME}.'.fa">Sequences ('.$partitions->{$partition}->{NAME}.')</a></li>';
#		}
#		print '</ul>';
#		print "</ul>";
#	}
#	else
#	{
#		print "</ul>";
#		print "Sequence related export is currently to 1000 results or less<br>";
#	}
#
#	print "Total: ".$result_count." Records<br>";
#}

sub mean_hash
{
	my $hash = shift or die;

	my $mean = 0;
	my $count = 0;
	foreach my $cell_type (keys %$hash)
	{
		$count++;

		my @measurements = split(/\,/,$hash->{$cell_type});
		foreach my $measurement (@measurements)
		{
		$mean += $measurement;
		}
	}
	$mean = $mean / $count;

	return $mean;
}

sub mean_array
{
	my $array = shift or die;

	my $mean = 0;
	my $count = 0;
	my @measurements = split(/\,/,$array);
	foreach my $measurement (@measurements)
	{
		$count++;

		$mean += $measurement;
	}
	$mean = $mean / $count;

	return $mean;
}

#ANOVA Test to see if groups of measurements are significantly different
sub anova
{
	my $threshold = shift or die;
	my $hash = shift or die; #This is a subhash containing the cell_types as keys and the associated measurements as entries
	my $mean = shift or die; #Total mean accross all replicates and cell_types

	if(scalar(keys %$hash) < 2) #If only one of the groups has measurements, nothing can be said about the significance of group difference
	{
		return 2;
	}

	#Compute TOTAL, SST and SSB
	my $sst = 0;
	my $ssb = 0;
	my $total = 0;

	foreach my $cell_type (keys %$hash)
	{
		my $sample_total = 0;

		my @measurements = split(/\,/,$hash->{$cell_type});

		foreach my $measure (@measurements)
		{
			$total++;
			$sample_total += $measure;
			$sst += ($measure - $mean) * ($measure - $mean);
		}
		if(scalar(@measurements) > 0)
		{
			$ssb += scalar(@measurements) * ((($sample_total / scalar(@measurements)) - $mean) * ( ($sample_total / scalar(@measurements)) - $mean) );
		}
	}

	#Compute DFT
	my $dft = $total - 1;

	#Compute SSW
	my $ssw = $sst - $ssb;

	#Compute DFB and DFW
	my $dfb = scalar(keys %$hash) - 1;
	my $dfw = $dft - scalar(keys %$hash);

	#Compute MSB and MSW
	my $msb = "NA";
	if($dfb != 0)
	{
		$msb = ($ssb / $dfb);
	}
	my $msw = "NA";
	if($dfw != 0)
	{
		$msw = ($ssw / $dfw);
	}
	
	#Compute experimental F and critical F for a given threshold
	my $f = "NA";
	my $f_critical_similar = "NA";
	my $f_critical_different = "NA";
	if($msw ne "NA" && $msb ne "NA" && $msw * $msw != 0)
	{
		$f = ($msb * $msb) / ($msw * $msw);
		$f_critical_similar = Statistics::Distributions::fdistr($dfb,$dfw,$threshold);
		$f_critical_different = Statistics::Distributions::fdistr($dfb,$dfw,1-$threshold);
	}

	if($f > $f_critical_similar)
	{
		return 1;
	}
	elsif($f > $f_critical_different)
	{
		return 0;
	}
	else
	{
		return 2;
	}
}

BP::footer();

1;
