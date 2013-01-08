#!/usr/bin/perl

use strict; 
use warnings;
use CGI::Simple;
use DBI;
use CGI; 
use CGI::Carp qw ( fatalsToBrowser ); 
use File::Basename;

use BP;
use BP_CELLMARKERS;

my $dsn = sprintf(
    'DBI:mysql:database=blood_plus_v2;host=localhost',
    'cdcol', 'localhost'
);

my $dbh = DBI->connect($dsn, $BP::MYSQL_USER,$BP::MYSQL_PASS);

BP::header("Cell Surface Marker Listing");
my $cgi = new CGI;

my $sth = $dbh->prepare('SELECT * FROM CELL_SURFACE_MARKERS');
my $cell_surface_markers = $dbh->selectall_hashref('SELECT * FROM CELL_SURFACE_MARKERS', 'ID');

print '<table border=1>';
print '<tr>';
print '<th>Marker</th>';
print '<th>Alias</th>';
print '<th>Name</th>';
print '<th>Additional Information</th>';
print '<th>Order Number</th>';
print '</tr>';
foreach my $marker (keys %$cell_surface_markers)
{
	print '<tr>';
	print '<td>'.$cell_surface_markers->{$marker}->{NAME}.'</td>';
	print '<td>';
	foreach my $symbol (keys %{$BP_CELLMARKERS::markerhash->{$cell_surface_markers->{$marker}->{NAME}}->{OTHER_SYMBOLS}})
	{
		print $BP_CELLMARKERS::markerhash->{$cell_surface_markers->{$marker}->{NAME}}->{OTHER_SYMBOLS}->{$symbol}.'</BR>';
	}
	print '</td>';
	print '<td>'.$BP_CELLMARKERS::markerhash->{$cell_surface_markers->{$marker}->{NAME}}->{NAME}.'</td>';
	if($BP_CELLMARKERS::markerhash->{$cell_surface_markers->{$marker}->{NAME}}->{NAME})
	{
		print '<td>[<a href="'.$BP_CELLMARKERS::markerhash->{$cell_surface_markers->{$marker}->{NAME}}->{NCBI_LINK}.'">NCBI</a>]</td>';
	}
	else
	{
		print '<td></td>';
	}
	print '<td>';
	foreach my $number (keys %{$BP_CELLMARKERS::markerhash->{$cell_surface_markers->{$marker}->{NAME}}->{ORDER_NUMBERS}})
	{
		print $BP_CELLMARKERS::markerhash->{$cell_surface_markers->{$marker}->{NAME}}->{ORDER_NUMBERS}->{$number}.'</BR>';
	}
	print '</td>';
	print '</tr>';
}
print '</table>';

BP::footer();
1;
