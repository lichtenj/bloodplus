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
                         
BP::header("Cell Surface Marker Information");

my $cgi = new CGI;
my $marker = $cgi->param('marker');

print '<h1>'.$marker.'</h1>';
print '<table>';
foreach my $symbol (keys %{$BP_CELLMARKERS::markerhash->{$marker}->{OTHER_SYMBOLS}})
{
	print '<tr><td>Other Symbols</td><td>'.$BP_CELLMARKERS::markerhash->{$marker}->{OTHER_SYMBOLS}->{$symbol}.'</td></tr>';
}
print '<tr><td>Name</td><td>'.$BP_CELLMARKERS::markerhash->{$marker}->{NAME}.'</td></tr>';
if($BP_CELLMARKERS::markerhash->{$marker}->{NCBI_LINK})
{
	print '<tr><td>Additional Information</td><td>[<a href="'.$BP_CELLMARKERS::markerhash->{$marker}->{NCBI_LINK}.'">NCBI</a>]</td></tr>';
}
foreach my $order_no (keys %{$BP_CELLMARKERS::markerhash->{$marker}->{ORDER_NUMBERS}})
{
	print '<tr><td>Order Information</td><td>'.$BP_CELLMARKERS::markerhash->{$marker}->{ORDER_NUMBERS}->{$order_no}.'</td></tr>';
}
print '</table>';

BP::footer();
