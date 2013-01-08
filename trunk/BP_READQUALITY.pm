package BP_READQUALITY;

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
	#       Email           => 'lichtenj@gmail.com',
	#       Passwd          => 'tb5013li',
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
#my $key = '0AijOb-M7RXOYdC1jcEJJUDZucWNBaXRINjdwTkxVU1E'; # BloodPlus Integrated Experiments
my $key = '0AijOb-M7RXOYdFpsOGlybHJYdGpQZzRNazQtc0I4YkE'; #BloodPlus Reads

my $authtoken = ExtractAuth($objResponse->content);
$objUA->default_header('Authorization' => "GoogleLogin auth=$authtoken");

$objResponse = Fetch($objUA, "http://spreadsheets.google.com/feeds/list/".$key."/od6/private/full");
my $objWorksheet = $objXML->XMLin($objResponse, ForceArray => 1);

our $readhash;

foreach my $sRow (@{$objWorksheet->{entry}}) 
{
	my $read_id = $sRow->{'gsx:id'}[0];
	my $experiment_id = $sRow->{'gsx:experimentid'}[0];

	if($experiment_id ne "-")
	{		
		my $type = $sRow->{'gsx:type'}[0];
		my $file = $sRow->{'gsx:filename'}[0];
		$file =~ s/\.bam/\_fastqc/;	

		$readhash->{$experiment_id}->{$read_id}->{FILE} = $file;
		$readhash->{$experiment_id}->{$read_id}->{TYPE} = $type;
	}
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
