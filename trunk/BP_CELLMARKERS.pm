package BP_CELLMARKERS;

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
my $key = '0AijOb-M7RXOYdHR3UW45RUdESU0zN3pXUUVNSWF2c2c'; #BloodPlus Cell Markers

my $authtoken = ExtractAuth($objResponse->content);
$objUA->default_header('Authorization' => "GoogleLogin auth=$authtoken");

$objResponse = Fetch($objUA, "http://spreadsheets.google.com/feeds/list/".$key."/od6/private/full");
my $objWorksheet = $objXML->XMLin($objResponse, ForceArray => 1);

our $markerhash;

foreach my $sRow (@{$objWorksheet->{entry}}) 
{
	my $marker = $sRow->{'gsx:marker'}[0];
	my $othersymbols = $sRow->{'gsx:othersymbols'}[0];
	my $name = $sRow->{'gsx:name'}[0];
	my $ncbilink = $sRow->{'gsx:ncbilink'}[0];
	my $ordernumbers = $sRow->{'gsx:ordernumbers'}[0];

	my @symbols = split(/\,/, $othersymbols);
	my $count = 0;
	foreach my $othersymbol (@symbols)
	{
		$count++;
		$markerhash->{$marker}->{OTHER_SYMBOLS}->{$count} = $othersymbol;
	}
	$markerhash->{$marker}->{NAME} = $name;

	if($ncbilink && $ncbilink ne "-")
	{
		$markerhash->{$marker}->{NCBI_LINK} = $ncbilink;
	}

	my @orders = split(/\,/, $ordernumbers);
	my $order_count = 0;
	foreach my $ordernumber (@orders)
	{
		$order_count++;
		$markerhash->{$marker}->{ORDER_NUMBERS}->{$order_count} = $ordernumber;
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
