<#The objective of the script is to fetch text from the description field of a ServiceNow incident from a ServiceNow instance. These incidents are raised by end-users and the text in the description field contains customer comments. The extracted text is then analyzed using IBM Watson Natural Language Understanding to get insights. For example, an incident that contains the words 'doc' or 'documentation' will automatically inform the documentation team that a particular incident may require doc update. This may eliminate the manual way of triaging and routing documentation related incidents. #>



Invoke-WebRequest -Uri 'https://<instance>.service-now.com/api/now/v1/table/incident?sysparm_query=number=INC0000001' -Method Get -Headers @{ Authorization = "Basic "+ [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("<user_name>:<password>")) } -ContentType 'application/json' | Select-Object -Expand Content | ConvertFrom-Json | Select -ExpandProperty result | ConvertTo-Json | Out-File instance_response.txt 
#The above command calls a GET request to the ServiceNow instance and fetches the details of the incident 'INC0000001' | Expands the 'Content' part of the response | Converts the Content object details to a PSCustomObject object | Expands the 'result' property | Converts the custom object to JSON | Writes the JSON output to a text file.
$instance_response = Get-Content .\instance_response.txt | ConvertFrom-Json
#Reads the content of the text file, converts the content of the file to JSON and assigns the value to the 'instance_response' variable
$desc = $instance_response.description
#Extracts the description of the incident and assigns it to the variable 'desc'

<# The following commands makes a POST REST call to IBM Watson Natural Language Understanding to analyze text. The analyzed text contains extract categories, classification, entities, keywords, sentiment, emotion, relations, and syntax for the description.
#>

$headers = @{
apikey = '<api_key_value>'
} 
$param = @{
Uri = 'https://api.eu-gb.natural-language-understanding.watson.cloud.ibm.com/instances/<token>/v1/analyze?version=2019-07-12'
# IBM NLU REST API that analyzes text using NLU engine.
Body = '{"text":"$desc","features":{"sentiment":{},"categories":{},"concepts":{},"entities":{},"keywords":{}}}'
# The extracted description is sent for text analysis; the received JSON analysis response contains, sentiment, categories, entities, and keywords.
ContentType = "application/json"
Method      = "Post"
}
Invoke-RestMethod -Headers $headers @param | Out-File IBM_NLU.txt
<##>
