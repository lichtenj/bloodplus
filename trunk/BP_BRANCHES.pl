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

BP::header("Branches Listing");

my $cgi = new CGI;

my $CSM = $cgi->param("csm");

my $sth = $dbh->prepare('SELECT * FROM CELL_TYPES');
my $cell_types = $dbh->selectall_hashref('SELECT * FROM CELL_TYPES', 'ID');

my $sth = $dbh->prepare('SELECT * FROM CELL_SURFACE_MARKERS');
my $cell_surface_markers = $dbh->selectall_hashref('SELECT * FROM CELL_SURFACE_MARKERS', 'ID');

my $sth = $dbh->prepare('SELECT * FROM PUBLICATIONS');
my $publications = $dbh->selectall_hashref('SELECT * FROM PUBLICATIONS', 'ID');

my $sth = $dbh->prepare('SELECT * FROM CELL_TYPE_MARKERS');
my $type_markers = $dbh->selectall_hashref('SELECT * FROM CELL_TYPE_MARKERS', 'CELL_TYPE_ID');

my $sth = $dbh->prepare('SELECT * FROM DIFFERENTIATION_BRANCH');
my $branches = $dbh->selectall_hashref('SELECT * FROM DIFFERENTIATION_BRANCH', 'ID');

my $sth = $dbh->prepare('SELECT * FROM PARTITIONS');
my $partitions = $dbh->selectall_hashref('SELECT * FROM PARTITIONS', 'ID');

my $sth = $dbh->prepare('SELECT * FROM CHIP_FACTORS');
my $factors = $dbh->selectall_hashref('SELECT * FROM CHIP_FACTORS', 'ID');

if(scalar(keys %$branches))
{
	print "<table border=1>";
	print "<tr>";
	print "<th>Differentiation Branch</th>";
	print "<th><a href=\"./BP_CELLTYPES.pl\">Cell Types</a></th>";
	print "<th>Associated Data</th>";
	print "</tr>";

	foreach my $branch_id (keys %$branches)
	{
		if($branches->{$branch_id}->{NAME} eq "-")
		{
			next;
		}
		my $sth = $dbh->prepare('SELECT * FROM DIFFERENTIATION_BRANCH_CELLS');
		my $branch_cell_types = $dbh->selectall_hashref('SELECT * FROM DIFFERENTIATION_BRANCH_CELLS WHERE BRANCH_ID = "'.$branch_id.'"', 'CELL_TYPE_ID');

		if(scalar(keys %$branch_cell_types) == 0)
		{
			print "<tr>";
			print "<td><p id=\"".$branch_id."\">".$branches->{$branch_id}->{NAME}."</p></td>";
			print "<td>";
			print "</td>";
			print "</tr>";
		}
		else
		{
			my $publication_row = 0;

			foreach my $branch_cell_type_id (sort {$a<=>$b} keys %$branch_cell_types)
			{				
				print '<input type="hidden" name="branch_id" value="'.$branch_id.'" />';
				print '<input type="hidden" name="cell_id_'.$publication_row.'" value="'.$branch_cell_type_id.'" />';
				print "<tr>";
				if($publication_row == 0)
				{
					print "<td rowspan=".scalar(keys %$branch_cell_types)."><p id=\"".$branch_id."\">".$branches->{$branch_id}->{NAME}."</p></td>";
				}
				print "<td>".$cell_types->{$branch_cell_type_id}->{NAME}."</td>";
				if($publication_row == 0)
				{
					print '<td rowspan='.scalar(keys %$branch_cell_types).'>';

					print "<FORM action=\"BP_CROSSCORRELATION.pl\" method=\"POST\" ENCTYPE=\"multipart/form-data\">";
					print "<table><tr>";
					print '<td>Expression</td>';
					print '<input type="hidden" name="correlation_type" value="2" />';
					print '<input type="hidden" name="branch_'.$branch_id.'_expression" value="1" />';
					print '<td></td><td></td>';
					print '<td><input type="text" name="branch_'.$branch_id.'_expression_threshold"  value="0.05"></td>';
					print '<td><input type="submit" name="submit" value="Show"></td>';
					print "</tr>";
					print "<tr></tr>";
					print '</FORM>';

					print "<FORM action=\"BP_CROSSCORRELATION.pl\" method=\"POST\" ENCTYPE=\"multipart/form-data\">";
					print "<tr>";
					print '<td>Methylation</td>';
					print '<input type="hidden" name="branch_'.$branch_id.'_methylation" value="1" />';
					print '<input type="hidden" name="correlation_type" value="2" />';
					print '<td><select name="branch_'.$branch_id.'_methylation_partition">';
					foreach my $id (keys %$partitions)
					{
						if($id == 2)
						{
							print '<option selected value="'.$id.'">'.$partitions->{$id}->{'NAME'}.'</option>';
						}
						else
						{
							print '<option value="'.$id.'">'.$partitions->{$id}->{'NAME'}.'</option>';
						}
					}
					print '</select></td>';
					print '<td></td>';
					print '<td><input type="text" name="branch_'.$branch_id.'_methylation_threshold"  value="0.0005"></td>';
					print '<td><input type="submit" name="submit" value="Show"></td>';
					print "</tr>";
					print '</FORM>';
					print "<tr></tr>";
					print "<FORM action=\"BP_CROSSCORRELATION.pl\" method=\"POST\" ENCTYPE=\"multipart/form-data\">";
					print "<tr>";
					print '<td>ChIP</td>';
					print '<input type="hidden" name="branch_'.$branch_id.'_chip" value="1" />';
					print '<input type="hidden" name="correlation_type" value="2" />';
					print '<td><select name="branch_'.$branch_id.'_chip_partition">';
					foreach my $id (keys %$partitions)
					{
						if($id == 2)
						{
							print '<option selected value="'.$id.'">'.$partitions->{$id}->{'NAME'}.'</option>';
						}
						else
						{
							print '<option value="'.$id.'">'.$partitions->{$id}->{'NAME'}.'</option>';
						}
					}
					print '</select></td>';
					print '<td><select multiple="yes" name="branch_'.$branch_id.'_chip_factor">';
					foreach my $id (keys %$factors)
					{
						#if($id == 2)
						#{
						#	print '<option value="'.$id.'">'.$factors->{$id}->{'NAME'}.'</option>';
						#}
						#else
						#{
							print '<option value="'.$id.'">'.$factors->{$id}->{'NAME'}.'</option>';
						#}
					}
					print '</select></td>';
					print '<td><input type="text" name="branch_'.$branch_id.'chip_threshold"  value="0.0005"></td>';
					print '<td><input type="submit" name="submit" value="Show"></td>';
					print "</tr></table>";
					print '</FORM>';
					print '</td>';
				}
				print '</form>';
				$publication_row++;
				print "</tr>";
			}
		}
	}
	print "</table>";
}

BP::footer();

1;
