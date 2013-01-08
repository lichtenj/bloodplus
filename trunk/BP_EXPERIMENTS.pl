#!/usr/bin/perl
 
use strict;
use warnings;           
use CGI::Simple;
use DBI; 
use CGI;
use CGI::Carp qw ( fatalsToBrowser );
use File::Basename;
                        
use BP;                                 
use BP_EXPERIMENTS;
use BP_READQUALITY;
                         
BP::header("Experiments");

my $cgi = new CGI;
my $experiment = $cgi->param('experiment');
my $publication = $cgi->param('publication');

if($publication)
{
	print '<h1>'.$publication.'</h1>';
	print '<table border=1>';
	print '<tr>';
	print '<th>ID</th>';
	print '<th>Cell Type</th>';
	print '<th>Experiment Type</th>';
	print '<th>Citation</th>';
	print '<th>Data Link</th>';
	print '<th>Paper Link</th>';
	print '<th>Animal Model</th>';
	print '<th>Source Tissue</th>';
	print '<th>Analysis Platform</th>';
	print '<th>ChIP Factor</th>';
	print '<th>Histone Mark</th>';
	print '</tr>';
	my $count = 0;
	foreach my $pub_experiment (keys %$BP_EXPERIMENTS::experimenthash)
	{
		if($BP_EXPERIMENTS::experimenthash->{$pub_experiment}->{PUBLICATION} eq $publication)
		{
			$count++;
			print '<tr>';
			print '<td><a href="./BP_EXPERIMENTS.pl?experiment='.$pub_experiment.'">'.$count.'</a></td>';
			print '<td>'.$BP_EXPERIMENTS::experimenthash->{$pub_experiment}->{CELLTYPE}.'</td>';
			print '<td>'.$BP_EXPERIMENTS::experimenthash->{$pub_experiment}->{EXPERIMENTTYPE}.'</td>';
			print '<td>'.$BP_EXPERIMENTS::experimenthash->{$pub_experiment}->{PUBLICATION}.'</td>';
			if(-e '/var/www/'.$BP_EXPERIMENTS::experimenthash->{$pub_experiment}->{DATA})
			{
				print '<td align=center>[<a href="../../'.$BP_EXPERIMENTS::experimenthash->{$pub_experiment}->{DATA}.'">Data</a>]</td>';
			}
			else
			{
				print '<td></td>';
			}
			if(-e '/var/www/'.$BP_EXPERIMENTS::experimenthash->{$pub_experiment}->{PAPER})
			{
				print '<td align=center>[<a href="../../'.$BP_EXPERIMENTS::experimenthash->{$pub_experiment}->{PAPER}.'">Paper</a>]</td>';
			}
			else
			{
				print '<td></td>';
			}
			if($BP_EXPERIMENTS::experimenthash->{$pub_experiment}->{ANIMALMODEL} ne "-")
			{
				print '<td>'.$BP_EXPERIMENTS::experimenthash->{$pub_experiment}->{ANIMALMODEL}.'</td>';
			}
			else
			{
				print '<td></td>';
			}
			if($BP_EXPERIMENTS::experimenthash->{$pub_experiment}->{TISSUE} ne "-")
			{
				print '<td>'.$BP_EXPERIMENTS::experimenthash->{$pub_experiment}->{TISSUE}.'</td>';
			}
			else
			{
				print '<td></td>';
			}
			if($BP_EXPERIMENTS::experimenthash->{$pub_experiment}->{PLATFORM} ne "-")
			{
				print '<td>'.$BP_EXPERIMENTS::experimenthash->{$pub_experiment}->{PLATFORM}.'</td>';
			}
			else
			{
				print '<td></td>';
			}
			if($BP_EXPERIMENTS::experimenthash->{$pub_experiment}->{FACTOR} ne "-")
			{
				print '<td>'.$BP_EXPERIMENTS::experimenthash->{$pub_experiment}->{FACTOR}.'</td>';
			}
			else
			{
				print '<td></td>';
			}
			if($BP_EXPERIMENTS::experimenthash->{$pub_experiment}->{HISTONE} ne "-")
			{
				print '<td>'.$BP_EXPERIMENTS::experimenthash->{$pub_experiment}->{HISTONE}.'</td>';
			}
			else
			{
				print '<td></td>';
			}
			print '</tr>';
		}
	}
	print '</table>';
}
if($experiment)
{
	print '<h1>Experiment #'.$experiment.'</h1>';
	print '<table border=1>';
	print '<tr>';
	print '<th>Experiment ID</th>';
	print '<th>Citation</th>';
	print '<th>Data Link</th>';
	print '<th>Paper Link</th>';
	print '<th>Animal Model</th>';
	print '<th>Source Tissue</th>';
	print '</tr>';

	print '<tr>';
	print '<td>'.$experiment.'</td>';
	print '<td><a href="./BP_EXPERIMENTS.pl?publication='.$BP_EXPERIMENTS::experimenthash->{$experiment}->{PUBLICATION}.'">'.$BP_EXPERIMENTS::experimenthash->{$experiment}->{PUBLICATION}.'</a></td>';
	if(-e '/var/www/'.$BP_EXPERIMENTS::experimenthash->{$experiment}->{DATA})
	{
		print '<td align=center>[<a href="../../'.$BP_EXPERIMENTS::experimenthash->{$experiment}->{DATA}.'">Data</a>]</td>';
	}
	else
	{
		print '<td></td>';
	}
	if(-e '/var/www/'.$BP_EXPERIMENTS::experimenthash->{$experiment}->{PAPER})
	{
		print '<td align=center>[<a href="../../'.$BP_EXPERIMENTS::experimenthash->{$experiment}->{PAPER}.'">Paper</a>]</td>';
	}
	else
	{
		print '<td></td>';
	}
	print '<td>'.$BP_EXPERIMENTS::experimenthash->{$experiment}->{ANIMALMODEL}.'</td>';
	print '<td>'.$BP_EXPERIMENTS::experimenthash->{$experiment}->{TISSUE}.'</td>';
	print '</tr>';

	print '</table>';

	my $target = "";
	foreach my $set (keys %{$BP_READQUALITY::readhash->{$experiment}})
	{
		if(! $target)
		{
			$target = '../../BloodPlus/Read_Quality/'.$BP_READQUALITY::readhash->{$experiment}->{$set}->{FILE}.'/fastqc_report.html';
		}
		print '<a href="../../BloodPlus/Read_Quality/'.$BP_READQUALITY::readhash->{$experiment}->{$set}->{FILE}.'/fastqc_report.html" target="iframe">'.$BP_READQUALITY::readhash->{$experiment}->{$set}->{TYPE}.'</a>&nbsp;&nbsp;&nbsp;';
	}

	print '<iframe src="'.$target.'" name="iframe" width="100%" height="75% seamless frameborder="0"></iframe>';
}
BP::footer();
