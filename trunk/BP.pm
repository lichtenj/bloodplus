package BP;

use BP_HELP;

$MYSQL_USER = [ENTER MYSQL USER];
$MYSQL_PASS = [ENTER MYSQL PASS];
$GOOGLE_USER = [ENTER GOOGLE DRIVE USER ACCOUNT];
$GOOGLE_PASS = [ENTER GOOGLE DRIVE PASS];

sub selection
{
	my $title = shift or die;
	my $cell_type = shift or die;
	my $experiments = shift or die;
	my $publications = shift or die;
	my $experiment_type = shift or die;
	my $partitions = shift;
	my $factors = shift;

	print $title."<br>";
	print '<table>';

	print '<tr>';
	print '<td><a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'General Analysis'}->{'Include'}.'\',\'Include\'); return true;" onmouseout="nd(); return true;">Include</a></td>';
	print '<td><input style="width: 120px" type="checkbox" name="'.$cell_type.'_'.$experiment_type.'"  value="1" /></td>';
	print '</tr>';

	print '<tr>';
	print '<td>';
	print '<a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'General Analysis'}->{'Positive Inclusion'}.'\',\'Positive Inclusion\'); return true;" onmouseout="nd(); return true;">Positive Inclusion</a></br>';
	print '<a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'General Analysis'}->{'Negative Inclusion'}.'\',\'Negative Inclusion\'); return true;" onmouseout="nd(); return true;">Negative Inclusion</a>';
	print '</td>';
	print '<td>';
	print '<input style="width: 120px" type="radio" name="'.$cell_type.'_'.$experiment_type.'_include"  value="include" checked/></br>';
	print '<input style="width: 120px" type="radio" name="'.$cell_type.'_'.$experiment_type.'_include"  value="exclude" />';
	print '</td>';
	print '</tr>';

	print '<tr>';
	print '<td><a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'General Analysis'}->{'Threshold'}.'\',\'Threshold\'); return true;" onmouseout="nd(); return true;">Threshold</a></td>';
	print '<td><input style="width: 120px" type="text" name="'.$cell_type.'_'.$experiment_type.'_threshold"  value="0.05"></td>';
	print '</tr>';

	my $pub_hash;
	foreach my $experiment (keys %$experiments)
	{
		if($experiments->{$experiment}->{EXPERIMENT_TYPE_ID} == $experiment_type)
		{
			if($pub_hash->{$experiments->{$experiment}->{PUBLICATION_ID}})
			{
				$pub_hash->{$experiments->{$experiment}->{PUBLICATION_ID}} .= "_".$experiment;
			}
			else
			{
				$pub_hash->{$experiments->{$experiment}->{PUBLICATION_ID}} = $experiment;
			}
		}
	}

	print '<tr>';
	print '<td><a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'General Analysis'}->{'Source'}.'\',\'Source\'); return true;" onmouseout="nd(); return true;">Source</a></td>';
	print '<td><select style="width: 120px" multiple="yes" name="'.$cell_type.'_'.$experiment_type.'_fixed_experiment">';
	foreach my $pubs (keys %$pub_hash)
	{
		print '<option value="'.$pub_hash->{$pubs}.'" selected>'.$publications->{$pubs}->{CITATION};
		print " (".$pub_hash->{$pubs}.")";
		print "</option>";
	}
	print '</select></td>';
	print '</tr>';

	if($experiment_type == 2 || $experiment_type == 1)
	{
		print '<tr>';
		print '<td><a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'General Analysis'}->{'Threshold Level'}.'\',\'Threshold Level\'); return true;" onmouseout="nd(); return true;">Threshold Level(s)</a></td>';

		print '<td><select style="width: 120px" multiple="yes" name="'.$cell_type.'_'.$experiment_type.'_thresholdlevel">';
		print '<option value="25">Low</option>';
		print '<option value="50">Medium</option>';
		print '<option selected value="75">High</option>';
		print '</select></td>';

		print '</tr>';
	}

	if($partitions)
	{
		print '<tr>';
		print '<td><a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'General Analysis'}->{'Genomic Partitions'}.'\',\'Genomic Partitions\'); return true;" onmouseout="nd(); return true;">Genomic Partition(s)</a></td>';
		print '<td><select style="width: 120px" multiple="yes" name="'.$cell_type.'_'.$experiment_type.'_partition">';
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
		print '</tr>';
	}

	if($factors)
	{
		print '<tr>';
		if($experiment_type <= 6)
		{
			print '<td><a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'General Analysis'}->{'Chipping Factors'}.'\',\'Chipping Factors\'); return true;" onmouseout="nd(); return true;">Chipping Factor(s)</a></td>';
		}
		elsif($experiment_type <= 8)
		{
			print '<td><a href="'.$helplink.'" onmouseover="drc(\''.$BP_HELP::helphash->{'General Analysis'}->{'Histone Marks'}.'\',\'Histone Marks\'); return true;" onmouseout="nd(); return true;">Histone Mark(s)</a></td>';
		}
		print '<td><select style="width: 120px" multiple="yes" name="'.$cell_type.'_'.$experiment_type.'_factor">';
		my $specific_factors;
		foreach my $experiment (keys %$experiments)
		{
			if($experiments->{$experiment}->{CHIP_FACTOR_ID} != 0)
			{
				#print '<option value="'.$experiment.'">'.$experiments->{$experiment}->{CELL_TYPE_ID}.'</option>';
				$specific_factors->{$experiments->{$experiment}->{EXPERIMENT_TYPE_ID}}->{$experiments->{$experiment}->{CHIP_FACTOR_ID}} = 1;
			}
		}
#		foreach my $id (keys %$factors)
		foreach my $id (keys %{$specific_factors->{$experiment_type}})
		{
			print '<option value="'.$id.'">'.$factors->{$id}->{'NAME'}.'</option>';
		}
		print '</select></td>';
		print '</tr>';
	}

	print '</table>';
}

sub header
{
	my $title = shift;

	print "Content-type: text/html\n\n";
	print "<SCRIPT LANGUAGE=\"JavaScript\">";
	print "<!--";
	print "function JumpToIt(frm) {";
	print "var newPage = frm.url.options[frm.url.selectedIndex].value";
	print "if (newPage != \"None\") {";
	print "location.href=newPage";
	print "}";
	print "}";
	print "//-->";
	print "</SCRIPT>";

	print "<html><head>
		<title>Blood+</title>
		<script src=\"../../sorttable.js\"></script>
		</head><body>";
#	print "<FORM>";
	print "<FORM name=\"jump1\">";
	print "<table>";
	print "<tr>";
	print "<td>";
	print "<a href=\"./BP.pl\"><img src=\"../../Images/BloodPlus.png\" width=75 alt=\"Cannot find image\"/></a>";
	print "</td><td align=\"left\" valign=\"middle\">&nbsp;Navigation:<BR>";
	print "<select name=\"myjumpbox\" OnChange=\"location.href=jump1.myjumpbox.options[selectedIndex].value\">";
	print "<option selected>Please Select...";
	print "<option value=\"./BP.pl\">Home";
	print "<option value=\"./BP_HELP.pl\">Help";
	print "<option value=\"./BP_CELLMARKERS_LISTING.pl\">Cell Surface Markers (Listing)";
#	print "<option value=\"./BP_CELLMARKER_SINGLE.pl\">Cell Surface Marker Import (Single)";
#	print "<option value=\"./BP_CELLMARKER_FILE.pl\">Cell Surface Marker Import (File)";
#	print "<option value=\"./BP_CELLTYPE_SINGLE.pl\">Cell Type Import (Single)";
#	print "<option value=\"./BP_CELLTYPE_FILE.pl\">Cell Type Import (File)";
	print "<option value=\"./BP_TREE_CELLS.pl\">Overview (Cell Types)";
	print "<option value=\"./BP_CELLTYPES.pl\">Listing (Cell Types)";
	print "<option value=\"./BP_TREE_BRANCHES.pl\">Overview (Branches)";
	print "<option value=\"./BP_BRANCHES.pl\">Listing (Branches)";
	print "<option value=\"./BP_CROSSCORRELATION.pl\">Cross Correlation";
	print "<option value=\"./BP_GENE_ANALYSIS.pl\">Gene-Centric Analysis";
	print "<option value=\"./BP_DYNAMIC_CORRELATION.pl\">Dynamic Correlation";
	print "<option value=\"./BP_CORRELATION_OVERVIEW.pl\">Correlation Overview";
	print "</select>";
	
	#print "<SELECT  NAME=\"url\" WIDTH=20>";
	#print "<OPTION VALUE=\"./BP.pl\">Home</OPTION>";
	#print "<OPTION VALUE=\"./BP_CELLMARKER_SINGLE.pl\">Cell Surface Marker Import (Single)</OPTION>";
	#print "<OPTION VALUE=\"./BP_CELLMARKER_FILE.pl\">Cell Surface Marker Import (File)</OPTION>";
	#print "<OPTION VALUE=\"./BP_CELLTYPE_SINGLE.pl\">Cell Type Import (Single)</OPTION>";
	#print "<OPTION VALUE=\"./BP_CELLTYPE_FILE.pl\">Cell Type Import (File)</OPTION>";
	#print "<OPTION VALUE=\"None\">Select a page from this list ---></OPTION>";
	#print "</SELECT>";
	#print "<INPUT TYPE=BUTTON VALUE=\"Go\" onClick=\"JumpToIt(this.form)\">";
	print "</td>";
	print "</tr>";
	print "</table>";
	print "</FORM>";
	print "<hr>";

	#Courtesy of SimplytheBest.net - http://simplythebest.net/scripts/
	print '<div id="overDiv" style="position:absolute; visibility:hide; z-index:1;">';
	print '</div>';
	print '<script LANGUAGE="JavaScript" SRC="../../overlib.js"></script>';
	
	if($title)
	{
		print "<h1>".$title."</h1>";
		print '<p style="width: 800px;">'.$BP_HELP::helphash->{$title}->{'Documentation'}.'<p>';
	}
}

sub footer
{
	print "<hr>";
	print "Copyright <a href=\"http://msseeker.org\">Jens Lichtenberg</a>";
	print "</body>";

	return;
}

1;
