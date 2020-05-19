SELECT * FROM sys.symmetric_keys;
SELECT * FROM sys.certificates;
SELECT * FROM sys.service_broker_endpoints;

USE [master];
GO

IF NOT EXISTS(SELECT 1 FROM sys.certificates WHERE name='ServiceBrokerTransportCertificate')
BEGIN
	IF NOT EXISTS(SELECT 1 FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
	BEGIN
		--DROP MASTER KEY;
		CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'ServiceBrokerMasterKey';
	END

	CREATE CERTIFICATE ServiceBrokerTransportAuthenticationCertificate
	WITH
	SUBJECT = 'Service Broker Endpoint Transport Authentication Certificate',
	START_DATE = '20200101',
	EXPIRY_DATE = '20300101'
END

IF NOT EXISTS(SELECT 1 FROM sys.service_broker_endpoints WHERE name = 'ServerBrokerEndpoint1234')
BEGIN
	CREATE ENDPOINT ServerBrokerEndpoint1234
	STATE = STARTED
	AS TCP
	(
		LISTENER_PORT = 1234
	)
	FOR SERVICE_BROKER
	(
		AUTHENTICATION = CERTIFICATE ServiceBrokerTransportAuthenticationCertificate
	)
END
GO