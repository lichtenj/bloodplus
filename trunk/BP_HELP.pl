#!/usr/bin/perl
 
use strict;
use warnings;           
use CGI::Simple;
use DBI; 
use CGI;
use CGI::Carp qw ( fatalsToBrowser );
use File::Basename;
                        
use BP;                                 
use BP_HELP;
use BP_DEFINITIONS;
                         
my $dsn = sprintf(
    'DBI:mysql:database=blood_plus_v2;host=localhost',
    'cdcol', 'localhost' 
);
                                
my $dbh = DBI->connect($dsn, $BP::MYSQL_USER,$BP::MYSQL_PASS);
                 
BP::header("Help");

print "<table border=0>";
#print "<tr><th>Program</th><th>Term</th><th>Description</th></tr>";
foreach my $program (keys %$BP_HELP::helphash)
{
#	print $BP_HELP::helphash->{$program}
	my $count = 1;
	foreach my $term (keys %{$BP_HELP::helphash->{$program}})
	{
		if($term ne "Documentation")
		{
			print "<tr>";
			if($count == 1)
			{
				print "<td valign=top rowspan=".(scalar(keys %{$BP_HELP::helphash->{$program}}) - 1).">".$program."</td>";
			}
			print "<td width=50></td>";
			print "<td>".$term."</td>";
			print "<td width=50></td>";
			print "<td>".$BP_HELP::helphash->{$program}->{$term}."</td>";
			print "</tr>";
			$count = 0;
		}
	}
}

my $def_count = 1;
foreach my $id (keys %{$BP_DEFINITIONS::definitionhash})
{
	print '<tr>';
	if($def_count == 1)
	{
		print '<td valign=top rowspan='.scalar(keys %{$BP_DEFINITIONS::definitionhash}).'>Genomic Partitions</td>';
	}
	$def_count = 0;
	print "<td width=50></td>";
	print '<td>'.$BP_DEFINITIONS::definitionhash->{$id}->{NAME}.'</td>';
	print "<td width=50></td>";
	print "<td>";
	print $BP_DEFINITIONS::definitionhash->{$id}->{DIRECTION}.'&nbsp;';
	print $BP_DEFINITIONS::definitionhash->{$id}->{START}.'&nbsp;';
	print $BP_DEFINITIONS::definitionhash->{$id}->{END};
	print "</td>";
	print '</tr>';
}
print "</table>";

BP::footer();
