SELECT 'CREATE CERTIFICATE ' +
QUOTENAME(C.name) +
' FROM BINARY = ' +
CONVERT(NVARCHAR(MAX),CERTENCODED(C.certificate_id),1) +
';' AS create_cmd
FROM sys.certificates AS C
WHERE C.name = 'ServiceBrokerDatabaseAuthenticationCertificate';

--Scripting a certificate through SQL Server Management Studio is not (yet) possible. Instead we have to generate the CREATE CERTIFICATE statement ourselves. For that we can use the CERTENCODED built-in function. CERTENCODED takes one parameter, the certificate_id of the certificate we want to script, and returns a VARBINARY value that contains all the public information of the certificate, including the public key.

--Let us look at an example. First, we need a certificate to script:

--[sql] IF(CERT_ID('ACertificate') IS NOT NULL) DROP CERTIFICATE ACertificate;
--GO
--CREATE CERTIFICATE ACertificate WITH SUBJECT = 'A Subject';
--[/sql]
--This snippet uses a conditional drop technique to first clean up. Then it creates a simple certificate that is protected by the database master key.

--With the certificate in place, we can now use the CERTENCODED function:

--[sql] SELECT CERTENCODED(CERT_ID('ACertificate'));
--[/sql]
--As CERTENCODED takes the certificate_id and not the name, we have to use the CERT_ID function to get to that value.

--The output of CERTENCODED is a lengthy VARBINARY value: