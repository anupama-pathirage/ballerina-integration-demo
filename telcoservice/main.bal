import ballerina/http;
import ballerina/lang.'string as string0;
import ballerinax/googleapis.sheets;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerina/log;

configurable string sheetsToken = ?;
configurable string sheetsName = ?;
configurable string sheetsId = ?;

configurable string host = ?;
configurable string user = ?;
configurable string password = ?;
configurable string database = ?;

final sheets:Client sheets = check new (config = {
    auth: {
        token: sheetsToken
    }
});

final mysql:Client mysql = check new (host, user, password, database);

service /telco on new http:Listener(9090) {

    //http://localhost:9090/telco/packages
    resource function post packages(PackageRequest[] payload) returns Package[] {
        Package[] packages = [];
        foreach PackageRequest packageReq in payload {
            //Create summary 
            Package package = transformRequestToPackage(packageReq);

            do {
                //Add to sheet
                _ = check sheets->appendValue(sheetsId, [package.planId, package.user.name, package.serviceSummary.annualPayment, package.serviceSummary.additionalServices], {sheetName: sheetsName});
                //Add to db
                _ = check mysql->execute(`INSERT INTO Packages (id, name, payment, services) VALUES (${package.planId}, ${package.user.name}, ${package.serviceSummary.annualPayment}, ${package.serviceSummary.additionalServices})`);
            } on fail error err {
                log:printError("Failed to persist package details", err, id = packageReq.id);
            }
            //Add to array
            packages.push(package);
        }
        return packages;
    }
}

type Address record {
    string street;
    string city;
    string state;
    string zipCode;
};

type Customer record {
    string firstName;
    string lastName;
    string email;
    string phoneNumber;
    Address address;
};

type ServiceDetails record {
    string serviceType;
    string activationDate;
    string contractExpirationDate;
    decimal monthlyFee;
    decimal initialPayment;
    string[] additionalServices;
};

type PackageRequest record {
    string id;
    Customer customer;
    ServiceDetails serviceDetails;
};

type User record {
    string name;
    string email;
    string phoneNumber;
};

type ServiceSummary record {|
    string serviceType;
    string activationDate;
    string contractExpirationDate;
    decimal annualPayment;
    string additionalServices;
|};

type Package record {|
    string planId;
    User user;
    ServiceSummary serviceSummary;
|};

function transformRequestToPackage(PackageRequest packageRequest) returns Package => {
    planId: packageRequest.id,
    user: {
        name: packageRequest.customer.firstName + packageRequest.customer.lastName,
        email: packageRequest.customer.email,
        phoneNumber: packageRequest.customer.phoneNumber
    },
    serviceSummary: {
        serviceType: packageRequest.serviceDetails.serviceType,
        activationDate: packageRequest.serviceDetails.activationDate,
        contractExpirationDate: packageRequest.serviceDetails.contractExpirationDate,
        annualPayment: packageRequest.serviceDetails.monthlyFee * 12 + packageRequest.serviceDetails.initialPayment,
        additionalServices: string0:'join(",", ...packageRequest.serviceDetails.additionalServices)
    }
};
