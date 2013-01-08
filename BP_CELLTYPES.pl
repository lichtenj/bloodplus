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

BP::header("Cell Types Listing");
my $cgi = new CGI;

my $CSM = $cgi->param("csm");

my $sth = $dbh->prepare('SELECT * FROM CELL_TYPES');
my $cell_types = $dbh->selectall_hashref('SELECT * FROM CELL_TYPES', 'ID');

my $sth = $dbh->prepare('SELECT * FROM CELL_SURFACE_MARKERS');
my $cell_surface_markers = $dbh->selectall_hashref('SELECT * FROM CELL_SURFACE_MARKERS', 'ID');

my $sth = $dbh->prepare('SELECT * FROM PUBLICATIONS');
my $publications = $dbh->selectall_hashref('SELECT * FROM PUBLICATIONS', 'ID');

my $sth = $dbh->prepare('SELECT * FROM PARTITIONS');
my $partitions = $dbh->selectall_hashref('SELECT * FROM PARTITIONS', 'ID');

my $sth = $dbh->prepare('SELECT * FROM CHIP_FACTORS');
my $factors = $dbh->selectall_hashref('SELECT * FROM CHIP_FACTORS', 'ID');

my $sth = $dbh->prepare('SELECT * FROM CELL_TYPE_MARKERS');
my $type_markers = $dbh->selectall_hashref('SELECT * FROM CELL_TYPE_MARKERS', 'CELL_TYPE_ID');

my $sth = $dbh->prepare('SELECT * FROM DIFFERENTIATION_BRANCH');
my $branch_info = $dbh->selectall_hashref('SELECT * FROM DIFFERENTIATION_BRANCH', 'ID');

my $sth = $dbh->prepare('SELECT * FROM EXPERIMENT_TYPES');
my $experiment_type_info = $dbh->selectall_hashref('SELECT * FROM EXPERIMENT_TYPES', 'ID');

my $branch_bool = 1;

if(scalar(keys %$cell_types))
{
	#print '<img src="../../Images/rainbow.gif" usemap = #example border=0>';
	#print '<map name=example>';
	#print '<area shape=Rect Coords=0,0,29,29 Href="http://www.yahoo.com">';
	#print '<area shape=Rect Coords=30,30,59,59 Href="http://www.hotbot.com">';
	#print '</map>';

	print "<table border=1 class=\"sortable\">";
	print "<tr>";
	print "<th>Cell Type</th>";
	print "<th><a href=\"./BP_BRANCHES.pl\">Differentiation Branch</a></th>";
	print "<th>Source</th>";
	print "<th>Cell Surface Marker</th>";
	print "<th>Associated Data</th>";
	print "</tr>";

	foreach my $cell_type_id (sort {$cell_types->{$a}->{NAME} cmp $cell_types->{$b}->{NAME}} keys %$cell_types)
	{
		my $sth = $dbh->prepare('SELECT * FROM DIFFERENTIATION_BRANCH_CELLS');
		my $branches = $dbh->selectall_hashref('SELECT * FROM DIFFERENTIATION_BRANCH_CELLS WHERE CELL_TYPE_ID = "'.$cell_type_id.'"', 'BRANCH_ID');

		my $sth = $dbh->prepare('SELECT * FROM EXPERIMENT');
		my $experiments = $dbh->selectall_hashref('SELECT * FROM EXPERIMENT WHERE CELL_TYPE_ID = "'.$cell_type_id.'"', 'PUBLICATION_ID');

		if(! $experiments)
		{
			print '<tr>';
			print '<td><p id="internal_link_'.$cell_type_id.'">'.$cell_types->{$cell_type_id}->{NAME}.'</td>';
			print '</tr>';
		}
		else
		{
			my $count = 0;
			foreach my $experiment (keys %$experiments)
			{
				print "<tr>";
				if($count == 0)
				{
					print '<td rowspan='.scalar(keys %$experiments).'><p id="internal_link_'.$cell_type_id.'">'.$cell_types->{$cell_type_id}->{NAME}.'</td>';
					if(scalar(keys %$branches) > 0)
					{
						print "<td rowspan=".scalar(keys %$experiments).">";
						foreach my $branch (keys %$branches)
						{
							print $branch_info->{$branch}->{NAME}."<br>";
						}
						print "</td>";
					}
					else
					{
						print "<td rowspan=".scalar(keys %$experiments)."></td>";
					}
				}	
	
				if($experiments->{$experiment}->{PUBLICATION_ID} != 0)
				{
					my $sth = $dbh->prepare('SELECT * FROM CELL_TYPE_MARKERS');
					my $experiment_markers = $dbh->selectall_hashref('SELECT * FROM CELL_TYPE_MARKERS WHERE CELL_TYPE_ID = "'.$cell_type_id.'" AND PUBLICATION_ID = "'.$experiments->{$experiment}->{PUBLICATION_ID}.'"', 'ID');		
	
					my $directory;
					print '<td><a href="./BP_EXPERIMENTS.pl?publication='.$publications->{$experiments->{$experiment}->{PUBLICATION_ID}}->{CITATION}.'">'.$publications->{$experiments->{$experiment}->{PUBLICATION_ID}}->{CITATION}.'</a></td>';
					print "<td>";
					foreach my $marker (keys %$experiment_markers)
					{
						print '<a href="./BP_CELLMARKERS.pl?marker='.$cell_surface_markers->{$experiment_markers->{$marker}->{CELL_SURFACE_MARKER_ID}}->{NAME}.'">';
						print $cell_surface_markers->{$experiment_markers->{$marker}->{CELL_SURFACE_MARKER_ID}}->{NAME}.'</a>'.$experiment_markers->{$marker}->{LEVEL}."<br>";
					}
					print "</td>";
					print "<td>";
#					if($experiments->{$experiment}->{EXPERIMENT_TYPE_ID} == 1 || $experiments->{$experiment}->{EXPERIMENT_TYPE_ID} == 2)
#					{
						print "View Associated Expression Data<br>";
#						print '<form action="dump.pl" method="POST" ENCTYPE="multipart/form-data">';
						print '<form action="BP_CROSSCORRELATION.pl" method="POST" ENCTYPE="multipart/form-data">';
						#print '<input type="hidden" name="cell_'.$cell_type_id.'_expression" value="1">';
						#print '<input type="hidden" name="correlation_type" value="1">';
						#print '<input type="hidden" name="fixed_experiment" value="'.$experiment.'">';
						#print 'Threshold: <input type="text" name="'.$cell_type_id.'_expression_threshold" value="0.05"><br>';
						#print '<input type="submit" name="submit" value="Submit">';

#						if($specific_experiment_types->{$subtype})
#                                        	{
						print '<input type="text" name="general_expression_threshold" value="0.005" style="width: 50px;">';

						if($experiment_type_info->{$experiments->{$experiment}->{EXPERIMENT_TYPE_ID}}->{FACTORING})
                                       		{
                                       		        BP::selection($experiment_type_info->{$experiments->{$experiment}->{EXPERIMENT_TYPE_ID}}->{PLATFORM},$cell_type_id,$experiments,$publications,$experiments->{$experiment}->{EXPERIMENT_TYPE_ID},$partitions,eval('$'.$experiment_type_info->{$experiments->{$experiment}->{EXPERIMENT_TYPE_ID}}->{FACTORING}));
                                       		}
                                       		elsif($experiment_type_info->{$experiments->{$experiment}->{EXPERIMENT_TYPE_ID}}->{PARTITIONING})
                                       		{
                                       		        BP::selection($experiment_type_info->{$experiments->{$experiment}->{EXPERIMENT_TYPE_ID}}->{PLATFORM},$cell_type_id,$experiments,$publications,$experiments->{$experiment}->{EXPERIMENT_TYPE_ID},$partitions);
                                       		}
                                       		else
                                       		{
                                               		BP::selection($experiment_type_info->{$experiments->{$experiment}->{EXPERIMENT_TYPE_ID}}->{PLATFORM},$cell_type_id,$experiments,$publications,$experiments->{$experiment}->{EXPERIMENT_TYPE_ID});
                                       		}
#                                        	}
						print '<input type="submit" name="correlation_type_1" style="width: 150px;" value="Analyze"><br>';
						print '</form>';
#
#					}
#					if($experiments->{$experiment}->{EXPERIMENT_TYPE_ID} == 3 || $experiments->{$experiment}->{EXPERIMENT_TYPE_ID} == 4)
#					{
#						print "View Associated Methylation Data<br>";
#						print '<form action="BP_CROSSCORRELATION.pl" method="POST" ENCTYPE="multipart/form-data">';
#						print '<input type="hidden" name="cell_'.$cell_type_id.'_methylation" value="1">';
#						print '<input type="hidden" name="correlation_type" value="1">';
#						print '<input type="hidden" name="fixed_experiment" value="'.$experiment.'">';
#						print '<select name"'.$cell_type_id.'_methylation_partition">';
#						foreach my $id (keys %$partitions)
#						{
#							if($id == 2)
#							{
#								print '<option selected value="'.$id.'">'.$partitions->{$id}->{NAME}.'</option>';
#							}
#							else
#							{
#								print '<option value="'.$id.'">'.$partitions->{$id}->{NAME}.'</option>';
#							}
#						}
#						print '</select><br>';
#						print 'Threshold: <input type="text" name="'.$cell_type_id.'_methylation_threshold" value="0.00005"><br>';
#						print '<input type="submit" name="submit" value="Submit">';
#						print '</form>';
#					}
#					if($experiments->{$experiment}->{EXPERIMENT_TYPE_ID} == 5 || $experiments->{$experiment}->{EXPERIMENT_TYPE_ID} == 6)
#					{
#						print "View Associated ChIP Data<br>";
#						print '<form action="BP_CROSSCORRELATION.pl" method="POST" ENCTYPE="multipart/form-data">';
#						print '<input type="hidden" name="cell_'.$cell_type_id.'_chip" value="1">';
#						print '<input type="hidden" name="correlation_type" value="1">';
#						print '<input type="hidden" name="fixed_experiment" value="'.$experiment.'">';
#						print '<select name"'.$cell_type_id.'_chip_partition">';
#						foreach my $id (keys %$partitions)
#						{
#							if($id == 2)
#							{
#								print '<option selected value="'.$id.'">'.$partitions->{$id}->{NAME}.'</option>';
#							}
#							else
#							{
#								print '<option value="'.$id.'">'.$partitions->{$id}->{NAME}.'</option>';
#							}
#						}
#						print '</select><br>';
#						print '<select multiple name"'.$cell_type_id.'_chip_factor">';
#						foreach my $id (keys %$factors)
#						{
#							print '<option value="'.$id.'">'.$factors->{$id}->{NAME}.'</option>';
#						}
#						print '</select><br>';
#						print 'Threshold: <input type="text" name="'.$cell_type_id.'_chip_threshold" value="0.00005"><br>';
#						print '<input type="submit" name="submit" value="Submit">';
#						print '</form>';
#					}
#					if($experiments->{$experiment}->{EXPERIMENT_TYPE_ID} == 7 || $experiments->{$experiment}->{EXPERIMENT_TYPE_ID} == 8)
#					{
#						print "View Associated Histone Data";
#					}
					print "</td>";
				}
				else
				{
					print "<td></td>";
				}
				print "</tr>";
				$count++;
			}
		}
	}	
	print "</table>";
}
else
{
	my $sth = $dbh->prepare(qq{INSERT INTO CELL_SURFACE_MARKERS (ID,NAME) VALUES (?, ?)});
  	$sth->execute(undef,$CSM);
}

BP::footer();

1;
