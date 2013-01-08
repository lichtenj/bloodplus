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

BP::header("Cell Types Overview");
my $cgi = new CGI;

print '<img src="../../Images/Cell_Tree.png" usemap = #example border=0>';
print '<map name=example>';
#Mapped
print '<area shape=Rect Coords=1,284,96,314 Href="./BP_CELLTYPES.pl#internal_link_1">';		#Hematopoiesis
print '<area shape=Rect Coords=120,284,214,314 Href="./BP_CELLTYPES.pl#internal_link_2">';		#LT-HSC
print '<area shape=Rect Coords=236,284,330,314 Href="./BP_CELLTYPES.pl#internal_link_3">';		#ST-HSC
print '<area shape=Rect Coords=353,137,446,165 Href="./BP_CELLTYPES.pl#internal_link_4">';		#CMP
print '<area shape=Rect Coords=353,431,446,460 Href="./BP_CELLTYPES.pl#internal_link_16">';		#LMPP
print '<area shape=Rect Coords=469,44,564,71 Href="./BP_CELLTYPES.pl#internal_link_5">';		#MEP
print '<area shape=Rect Coords=469,107,564,134 Href="./BP_CELLTYPES.pl#internal_link_22">';		#CFU-MC
print '<area shape=Rect Coords=469,148,564,177 Href="./BP_CELLTYPES.pl#internal_link_51">';		#CFU-EO
print '<area shape=Rect Coords=469,191,564,218 Href="./BP_CELLTYPES.pl#internal_link_50">';		#CFU-BA
print '<area shape=Rect Coords=469,233,564,261 Href="./BP_CELLTYPES.pl#internal_link_53">';		#CFU-GEMM
print '<area shape=Rect Coords=469,357,564,386 Href="./BP_CELLTYPES.pl#internal_link_17">';		#CLP
print '<area shape=Rect Coords=469,504,564,533 Href="./BP_CELLTYPES.pl#internal_link_18">';		#GMP
print '<area shape=Rect Coords=586,23,681,50 Href="./BP_CELLTYPES.pl#internal_link_6">';		#BFU-E
print '<area shape=Rect Coords=586,65,681,93 Href="./BP_CELLTYPES.pl#internal_link_11">';		#CFU-MEG
print '<area shape=Rect Coords=586,106,681,135 Href="./BP_CELLTYPES.pl#internal_link_38">';		#Mast Cell
print '<area shape=Rect Coords=586,148,681,178 Href="./BP_CELLTYPES.pl#internal_link_59">';		#EO Promyelocyte
print '<area shape=Rect Coords=586,192,681,218 Href="./BP_CELLTYPES.pl#internal_link_48">';		#BA Promyelocyte
print '<area shape=Rect Coords=586,234,681,260 Href="./BP_CELLTYPES.pl#internal_link_54">';		#CFU-GM
print '<area shape=Rect Coords=586,275,681,303 Href="./BP_CELLTYPES.pl#internal_link_34">';		#CDP
print '<area shape=Rect Coords=586,379,681,407 Href="./BP_CELLTYPES.pl#internal_link_56">';		#CTNKP
print '<area shape=Rect Coords=586,442,681,469 Href="./BP_CELLTYPES.pl#internal_link_36">';		#Pre BII
print '<area shape=Rect Coords=586,484,681,511 Href="./BP_CELLTYPES.pl#internal_link_52">';		#CFU-G
print '<area shape=Rect Coords=586,526,681,553 Href="./BP_CELLTYPES.pl#internal_link_55">';		#CFU-M
print '<area shape=Rect Coords=702,23,797,50 Href="./BP_CELLTYPES.pl#internal_link_7">';		#CFU-E
print '<area shape=Rect Coords=702,65,797,93 Href="./BP_CELLTYPES.pl#internal_link_12">';		#MK-3
print '<area shape=Rect Coords=702,148,797,176 Href="./BP_CELLTYPES.pl#internal_link_58">';		#EO Myelocyte
print '<area shape=Rect Coords=702,190,797,217 Href="./BP_CELLTYPES.pl#internal_link_47">';		#BA Myelocyte
print '<area shape=Rect Coords=702,232,797,260 Href="./BP_CELLTYPES.pl#internal_link_68">';		#Conv DC CD 8+
print '<area shape=Rect Coords=702,275,797,301 Href="./BP_CELLTYPES.pl#internal_link_69">';		#Conv DC CD 8-
print '<area shape=Rect Coords=702,315,797,344 Href="./BP_CELLTYPES.pl#internal_link_63">';		#Plasma DC
print '<area shape=Rect Coords=702,359,797,387 Href="./BP_CELLTYPES.pl#internal_link_23">';		#DN-1
print '<area shape=Rect Coords=702,400,797,428 Href="./BP_CELLTYPES.pl#internal_link_65">';		#Pre NK
print '<area shape=Rect Coords=702,441,797,471 Href="./BP_CELLTYPES.pl#internal_link_31">';		#Large Pre BII
print '<area shape=Rect Coords=702,485,797,513 Href="./BP_CELLTYPES.pl#internal_link_67">';		#Promyelocyte
print '<area shape=Rect Coords=702,527,797,554 Href="./BP_CELLTYPES.pl#internal_link_60">';		#Monoblast
print '<area shape=Rect Coords=819,22,914,51 Href="./BP_CELLTYPES.pl#internal_link_8">';		#Erythroblast
print '<area shape=Rect Coords=819,65,914,93 Href="./BP_CELLTYPES.pl#internal_link_13">';		#MK-4
print '<area shape=Rect Coords=819,148,914,175 Href="./BP_CELLTYPES.pl#internal_link_57">';		#Eosinophil
print '<area shape=Rect Coords=819,189,914,219 Href="./BP_CELLTYPES.pl#internal_link_46">';		#Basophil
print '<area shape=Rect Coords=819,357,914,386 Href="./BP_CELLTYPES.pl#internal_link_24">';		#DN-2
print '<area shape=Rect Coords=819,399,914,427 Href="./BP_CELLTYPES.pl#internal_link_35">';		#NK
print '<area shape=Rect Coords=819,441,914,469 Href="./BP_CELLTYPES.pl#internal_link_37">';		#Small Pre BII
print '<area shape=Rect Coords=819,483,914,511 Href="./BP_CELLTYPES.pl#internal_link_61">';		#Myelocyte
print '<area shape=Rect Coords=819,525,914,554 Href="./BP_CELLTYPES.pl#internal_link_66">';		#Promonocyte
print '<area shape=Rect Coords=936,22,1031,51 Href="./BP_CELLTYPES.pl#internal_link_9">';		#Normoblast
print '<area shape=Rect Coords=936,65,1031,94 Href="./BP_CELLTYPES.pl#internal_link_14">';		#MEG
print '<area shape=Rect Coords=936,358,1031,386 Href="./BP_CELLTYPES.pl#internal_link_25">';		#DN-3
print '<area shape=Rect Coords=936,440,1031,468 Href="./BP_CELLTYPES.pl#internal_link_30">';		#Immature B Cell
print '<area shape=Rect Coords=936,483,1031,512 Href="./BP_CELLTYPES.pl#internal_link_62">';		#Neutrophil
print '<area shape=Rect Coords=936,525,1031,552 Href="./BP_CELLTYPES.pl#internal_link_41">';		#Monocyte
print '<area shape=Rect Coords=1053,22,1146,50 Href="./BP_CELLTYPES.pl#internal_link_10">';		#Erythrocyte
print '<area shape=Rect Coords=1053,64,1146,92 Href="./BP_CELLTYPES.pl#internal_link_15">';		#Platelet
print '<area shape=Rect Coords=1053,356,1146,385 Href="./BP_CELLTYPES.pl#internal_link_26">';		#DN-4
print '<area shape=Rect Coords=1053,441,1146,469 Href="./BP_CELLTYPES.pl#internal_link_19">';		#Mature B-Cell
print '<area shape=Rect Coords=1053,525,1146,553 Href="./BP_CELLTYPES.pl#internal_link_33">';		#Macrophage
print '<area shape=Rect Coords=1170,357,1264,385 Href="./BP_CELLTYPES.pl#internal_link_27">';		#DPL
print '<area shape=Rect Coords=1170,442,1264,468 Href="./BP_CELLTYPES.pl#internal_link_63">';		#Plasma
print '<area shape=Rect Coords=1287,357,1382,385 Href="./BP_CELLTYPES.pl#internal_link_28">';		#DPS
print '<area shape=Rect Coords=1403,337,1497,363 Href="./BP_CELLTYPES.pl#internal_link_20">';		#CD4TH
print '<area shape=Rect Coords=1403,378,1497,406 Href="./BP_CELLTYPES.pl#internal_link_21">';		#CD8TH

print '</map>';

BP::footer();

1;
