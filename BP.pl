#!/usr/bin/perl

use strict; 
use warnings;

use CGI::Simple;
use DBI;
use CGI; 
use CGI::Carp qw ( fatalsToBrowser ); 
use File::Basename;

use BP;

BP::header();
my $cgi = new CGI;

print "<h1>Welcome to the Blood<sup>+</sup> instance for <i>Mus musculus</i></h1>";

print "<p>Blood<sup>+</sup> is a database, or more imaginative a data ranch, where data are curated/cultivated, repositories grown and analyses harvested. Blood<sup>+</sup> contains next-generation sequencing and array-based data for different cell types in the hematopoietic stem-cell differentiation process. The management system associated with the boutique provides capabilities for the analysis (in particular union and intersection correlations) of single and multiple cell types as well as branches of the hematopoietic stem cell differentiation tree.</p>";

print "<h2>Features</h2>";
print "<table>";
print "<tr><td>[</td><td align=center>Representation</td><td>]</td><td><a href=\"./BP_TREE_BRANCHES.pl\">Branches</a> within the model of hematopoietic stem cell differentiation is used to provide an overview of the data</td></tr>";
print "<tr><td>[</td><td align=center>Representation</td><td>]</td><td>Each sequence-based experiment is now annotated with a quality assessment of the associated sequencing reads</td></tr>";
print "<tr><td>[</td><td align=center>Analysis</td><td>]</td><td><a href=\"../../BloodPlus/Correlations.html\">Correlation Overview</a> illustrating the relationships between different cell types according to the underlying analysis experiment</td></tr>";
print "<tr><td>[</td><td align=center>Analysis</td><td>]</td><td><a href=\"./BP_CROSSCORRELATION.pl\">Cross-Correlations</a> between different experiment and cell types as well as various differentiation branches</td></tr>";
print "<tr><td>[</td><td align=center>Analysis</td><td>]</td><td><a href=\"./BP_GENE_ANALYSIS.pl\">Gene centric view</a> of the data</td></tr>";
print "<tr><td>[</td><td align=center>Analysis</td><td>]</td><td><a href=\"./BP_DYNAMIC_CORRELATION.pl\">Dynamic Correlation</a> of user generated sequencing (peak) data against the database</td></tr>";
print "<tr><td>[</td><td align=center>Result</td><td>]</td><td>Visualization/integration with the UCSC Genome Browser</td></tr>";
print "<tr><td>[</td><td align=center>Result</td><td>]</td><td>Sortability within each presented data view</td></tr>";
print "<tr><td>[</td><td align=center>Result</td><td>]</td><td>Export into a variety of formats (coordinates, lists and sequences)</td></tr>";
print "</table>";

print "<h2>Abstract</h2>";

print "<p>The formation and maturation of blood cellular components, known as hematopoiesis, in human as well as mouse has been studied extensively over several decades of research, resulting in a highly detailed model of the process. In light of an every increasing amount of hematopoietic high-throughput sequencing data it is surprising that databases dedicated to host associated experimental data (e.g. BloodExpress and EpoDB) focus on microarray expression data while database dedicated to host generic experimental data (e.g. NCBI GEO) do not provide methodologies to compare different experimental datasets on the fly. The reliance of existing hematopoietic repositories on microarray expression data requires a new database framework that incorporates existing expression data and enriches them with next-generation sequencing data (e.g. RNA-Seq or Methylation-Seq).</p>";

print "<p>The Blood<sup>+</sup> data boutique presented here, offers the user access to not only array-based hematopoietic data but also high-throughput hematopoietic sequencing data and the methodologies required to analyse them. The database organizes the data in accordance with the cell differentiation process and the various cell surface markers that allow the unique identification of specific cell types (e.g. hematopoietic stem cells) or paths in the differentiation process (e.g. erythropoiesis). The data are annotated with the type of experiment used to generate them and the associated publication. Each cell type or path in the differentiation process can be intersected or combined with others to generate gene and peak lists that can be mined for functional or regulatory information.</p>";

print "<p>The current version of the Blood<sup>+</sup> is restricted to hematopoiesis in mouse and contains microarray expression data made available through the BloodExpress database as well as high-throughput sequencing data for methylation, expression, histone modification and transcription factor binding behaviour.</p>";

BP::footer();

1;
