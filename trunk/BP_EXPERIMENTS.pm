package BP_EXPERIMENTS;

use DBI;
use LWP::UserAgent;
use XML::Simple;
use BP;

# Configure the program
# The various parameters passed in the UA POST are documented on Google's page
# Authentication: http://bit.ly/1apxYA
# Spreadsheets access: http://bit.ly/Qfcxg

# Create browser and XML objects, and send a request for authentication
my $objUA = LWP::UserAgent->new;
my $objXML = XML::Simple->new;
my $objResponse = $objUA->post(
        'https://www.google.com/accounts/ClientLogin',
        {
	        accountType     => 'GOOGLE',
	        Email           => $BP::GOOGLE_USER,
	        Passwd          => $BP::GOOGLE_PASS,
	        service         => 'wise',
	        source          => 'Populate Database',
	        "GData-Version" => '2',
        }
);

# Fail if the HTTP request didn't work
die "\nError: ", $objResponse->status_line unless $objResponse->is_success;

#my $key = '0AijOb-M7RXOYdC1jcEJJUDZucWNBaXRINjdwTkxVU1E'; #BloodPlus
#my $key = '0AijOb-M7RXOYdFpsOGlybHJYdGpQZzRNazQtc0I4YkE'; #BloodPlus Reads
#my $key = '0AijOb-M7RXOYdEdUR0txbUtsNGM5ak1CNmlQU3dUNEE'; #BloodPlus Help
#my $key = '0AijOb-M7RXOYdHR3UW45RUdESU0zN3pXUUVNSWF2c2c'; #BloodPlus Cell Markers
my $key = '0AijOb-M7RXOYdC1jcEJJUDZucWNBaXRINjdwTkxVU1E'; # BloodPlus Integrated Experiments

my $authtoken = ExtractAuth($objResponse->content);
$objUA->default_header('Authorization' => "GoogleLogin auth=$authtoken");

$objResponse = Fetch($objUA, "http://spreadsheets.google.com/feeds/list/".$key."/od6/private/full");
my $objWorksheet = $objXML->XMLin($objResponse, ForceArray => 1);

our $experimenthash;

foreach my $sRow (@{$objWorksheet->{entry}}) 
{
	my $experiment = $sRow->{'gsx:experiment0'}[0];
	my $publication = $sRow->{'gsx:publication1'}[0];
	my $paper_file = 'BloodPlus/Papers/'.$sRow->{'gsx:publication1'}[0].'.pdf';
	my $data_file = 'BloodPlus/';
	if($sRow->{'gsx:experimenttypeid5'}[0] == 1 || $sRow->{'gsx:experimenttypeid5'}[0] == 2)
	{
		$data_file .= 'Expression/'.$sRow->{'gsx:file3'}[0];
	}
	if($sRow->{'gsx:experimenttypeid5'}[0] == 3 || $sRow->{'gsx:experimenttypeid5'}[0] == 4)
	{
		$data_file .= 'Methylation/'.$sRow->{'gsx:file3'}[0];
	}
	if($sRow->{'gsx:experimenttypeid5'}[0] == 5 || $sRow->{'gsx:experimenttypeid5'}[0] == 6)
	{
		$data_file .= 'ChIP/'.$sRow->{'gsx:file3'}[0];
	}
	if($sRow->{'gsx:experimenttypeid5'}[0] == 7 || $sRow->{'gsx:experimenttypeid5'}[0] == 8)
	{
		$data_file .= 'Histone/'.$sRow->{'gsx:file3'}[0];
	}

	my $experiment_type = $sRow->{'gsx:experimenttype4'}[0];
	my $cell_type = $sRow->{'gsx:celltype7'}[0];
	my $factor = $sRow->{'gsx:chipfactor9'}[0];
	my $histone = $sRow->{'gsx:histonemark11'}[0];

	my $animalmodel = $sRow->{'gsx:animalmodel17'}[0];
	my $tissue = $sRow->{'gsx:tissue19'}[0];
	my $platform = $sRow->{'gsx:platform21'}[0];

	$experimenthash->{$experiment}->{PUBLICATION} = $publication;
	$experimenthash->{$experiment}->{PAPER} = $paper_file;
	$experimenthash->{$experiment}->{DATA} = $data_file;

	$experimenthash->{$experiment}->{EXPERIMENTTYPE} = $experiment_type;
	$experimenthash->{$experiment}->{CELLTYPE} = $cell_type;
	$experimenthash->{$experiment}->{FACTOR} = $factor;
	$experimenthash->{$experiment}->{HISTONE} = $histone;

	$experimenthash->{$experiment}->{ANIMALMODEL} = $animalmodel;
	$experimenthash->{$experiment}->{TISSUE} = $tissue;
	$experimenthash->{$experiment}->{PLATFORM} = $platform;
}

# Extract the authorization token from Google's return string
sub ExtractAuth {
	# Split the input into lines, loop over and return the value for the 
	# one starting Auth=
   	for (split /\n/, shift) { 
   		return $1 if $_ =~ /^Auth=(.*)$/; 
   	}
   	return '';
 }
 
# Fetch a URL
sub Fetch {
	# Create the local variables and pull in the UA and URL
	my ($objUA, $sURL) = @_;
 
	# Grab the URL, but fail if you can't get the content
	my $objResponse = $objUA->get($sURL);
	die "Failed to fetch $sURL " . $objResponse->status_line if !$objResponse->is_success;
 
	# Return the result
	return $objResponse->content;
}

1;
