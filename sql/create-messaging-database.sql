SELECT * FROM sys.symmetric_keys;
SELECT * FROM sys.certificates;
SELECT * FROM sys.services;
SELECT * FROM sys.service_queues;


USE [one-c-sharp-messaging];

IF NOT EXISTS(SELECT 1 FROM sys.certificates WHERE name='ServiceBrokerAuthenticationCertificate')
BEGIN
	IF NOT EXISTS(SELECT 1 FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
	BEGIN
		CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'MessagingDatabaseMasterKey';
	END

	--CREATE USER 

	CREATE CERTIFICATE ServiceBrokerAuthenticationCertificate
	WITH
	SUBJECT = 'ServiceBrokerAuthenticationCertificate',
	START_DATE = '20200101',
	EXPIRY_DATE = '20300101'
END
GO