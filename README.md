# Ballerina HTTP service for telecommunication data backend

This Ballerina-based HTTP service serves as the backend for an telecommunication service provider. It processes a JSON array containing new telecom package request details and performs the following tasks upon receipt:

1. Computes and transforms the input payload into the necessary output payload.
2. Utilizes OpenAI for risk analysis of the provided policy.
3. Updates a Google Sheet with the Plan ID, Customer Name, Annual Payment, and Additional Services.

<img src="../images/InsuranceService/InsuranceService.png" width='550' align=center/>

## Prerequisites

### Ballerina 
1. Download and install [Ballerina Swan Lake](https://ballerina.io/downloads/)
2. Visual Studio Code with the [Ballerina extension](https://wso2.com/ballerina/vscode/docs/) installed.

### Other 

1. Create a Google Account and obtain the tokens by following the blog.[Using OAuth 2.0 to access Google APIs](https://medium.com/@anupama.pathirage/using-oauth-2-0-to-access-google-apis-1dbd01edea9a)
2. Create the sample MySQL database and  populate data with the [db.sql](db.sql) script as follows.
```
mysql -u root -p < /path/to/db.sql
```
3. Create a new Google sheet with the following structure. The sheet name is `packages`.

## Input JSON structure


