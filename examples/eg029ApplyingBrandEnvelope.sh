# Applying a Brand to an envelope

# Step 1: Obtain your OAuth token
# Note: Substitute these values with your own
# Set up variables for full code example
ACCESS_TOKEN="{ACCESS_TOKEN}"
API_Account_ID="{API_ACCOUNT_ID}" 
Brand_ID="{BRAND_ID}"

# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi
base_path="https://demo.docusign.net/restapi"

#Step 2: Construct your API headers
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
					'--header' "Accept: application/json" \
					'--header' "Content-Type: application/json")

# Step 3: Construct the request body
# Create a temporary file to store the request body
request_data=$(mktemp /tmp/request-brand-001.XXXXXX)
printf \
'{
	"documents": [{
		"documentBase64": "DQoNCg0KCQkJCXRleHQgZG9jDQoNCg0KDQoNCg0KUk0gIwlSTSAjCVJNICMNCg0KDQoNClxzMVwNCg0KLy9hbmNoMSANCgkvL2FuY2gyDQoJCS8vYW5jaDM=",
		"documentId": "1",
		"fileExtension": "txt",
		"name": "NDA"
	}],
	"emailBlurb": "Sample text for email body",
	"emailSubject": "Please Sign",
	"envelopeIdStamping": "true",
	"recipients": {
	"signers": [{
		"name": "Alice UserName",
		"email": "alice.username@example.com",
		"roleName": "signer",
		"note": "",
		"routingOrder": 1,
		"status": "sent",
				"tabs": {
				"signHereTabs": [{
					"documentId": "1",
					"name": "SignHereTab",
					"pageNumber": "1",
					"recipientId": "1",
					"tabLabel": "SignHereTab",
					"xPosition": "75",
					"yPosition": "572"
				}]
			},
		"deliveryMethod": "email",
		"recipientId": "1",
        "brandId": "'"$BRAND_ID"'"
	}]
	},
	"status": "Sent"
}' >> $request_data

# Step 4: a) Call the eSignature API
#         b) Display the JSON response
# Create a temporary file to store the response
response=$(mktemp /tmp/response-brand.XXXXXX)
Status=$(curl -w '%{http_code}' -i --request POST ${BASE_PATH}/v2.1/accounts/${API_ACCOUNT_ID}/envelopes \
     "${Headers[@]}" \
     --data-binary @${request_data} \
     --output ${response})
# If the Status code returned is greater than 201 (OK/Accepted), display an error message along with the API response
if [[ "$Status" -gt "201" ]] ; then
    echo ""
	echo "Creating a new envelope has failed."
	echo ""
	cat $response
	exit 1
fi
echo ""
echo "Response:"
cat $response
echo ""
# Remove the temporary files
rm "$request_data"
rm "$response"