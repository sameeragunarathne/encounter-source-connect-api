import ballerina/http;
import wso2healthcare/healthcare.clients.fhirr4;

configurable string base = "https://fhir.epic.com/interconnect-fhir-oauth/api/FHIR/R4";
configurable string tokenUrl = "https://fhir.epic.com/interconnect-fhir-oauth/oauth2/token";
configurable string clientId = "801f42e8-485c-4afb-b34f-9a0ca0d9ae2e";

// FHIR client configuration for Epic.
fhirr4:FHIRConnectorConfig epicConfig = {
    baseURL: base,
    mimeType: fhirr4:FHIR_JSON,
    authConfig: {
        clientId: clientId,
        tokenEndpoint: tokenUrl,
        keyFile: "./privatekey.pem"
    }
};

// Initialize the FHIR client for Epic.
final fhirr4:FHIRConnector fhirConnectorObj = check new (epicConfig);

// You don't have to change the following service declaration
service / on new http:Listener(9091) {

    # This API operation will be called by the WSO2 Healthcare Accelerator to get a FHIR resource by `id` 
    # path parameter. 
    # You are required to implement this API operation to connect to the source system and return the
    # FHIR resource as a json payload.
    # If the source system is non-FHIR, you can use Choreo visual data mapper to convert the source
    # system payload to a FHIR resource. 
    # see https://github.com/nirmal070125/patient-source-connect-api/blob/master/patient_data_mapper.bal for an example.
    #
    # + id - FHIR resource id.
    # + return - Returns the FHIR resource as a json payload or an error.
    resource function get read/[string id]() returns json|error {

        // The following example is using FHIR client to connect to the Epic FHIR server to read an Encounter resource.
        fhirr4:FHIRResponse|fhirr4:FHIRError fhirResponse = fhirConnectorObj->getById("Encounter", id);
        return handleResponse(fhirResponse);
    }

    # This API operation will be called by the WSO2 Healthcare Accelerator to search FHIR resources based 
    # on the query parameters.
    # You are required to implement this API operation to connect to the source system and return the
    # FHIR resource as a json payload.
    # If the source system is non-FHIR, you can use Choreo visual data mapper to convert the source
    # system payload to a FHIR resource. 
    # see https://github.com/nirmal070125/patient-source-connect-api/blob/master/patient_data_mapper.bal for an example.
    #
    # + req - HTTP request object.
    # + return - Returns the FHIR Bundle resource or FHIR resources array as a json payload or an error.
    resource function get search(http:Request req) returns json|error {

        map<string|string[]> queryParams = req.getQueryParams();
        fhirr4:SearchParameters searchParams = {};

        //Construct the search parameters based on the query parameters to be passed to the FHIR client connector.
        if queryParams.hasKey("_id") {
            string|string[] idVal = queryParams.get("_id");
            if idVal is string[] {
                searchParams._id = idVal[0];
            }
        } else if queryParams.hasKey("patient") {
            string|string[] patientVal = queryParams.get("patient");
            if patientVal is string[] {
                searchParams["patient"] = patientVal[0];
            }
        } else if queryParams.hasKey("_profile") {
            string|string[] profileVal = queryParams.get("_profile");
            if profileVal is string[] {
                searchParams._profile = profileVal[0];
            }
        } else if queryParams.hasKey("_lastUpdated") {
            string|string[] lastUpdatedVal = queryParams.get("_lastUpdated");
            if lastUpdatedVal is string[] {
                searchParams._lastUpdated = lastUpdatedVal;
            }
        }
        // This following code segment is using FHIR client to connect to the Epic FHIR server to searcg Encounter resources.
        fhirr4:FHIRResponse|fhirr4:FHIRError fhirResponse = fhirConnectorObj->search("Encounter", searchParams);
        return handleResponse(fhirResponse);
    }
}
