SELECT * FROM sys.symmetric_keys;
SELECT * FROM sys.certificates;
SELECT * FROM sys.service_broker_endpoints;
SELECT * FROM sys.tcp_endpoints AS i
INNER JOIN sys.service_broker_endpoints AS e
ON i.endpoint_id = e.endpoint_id;

USE [master];


IF NOT EXISTS(SELECT 1 FROM sys.certificates WHERE name='ServiceBrokerTransportAuthenticationCertificate')
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
	GRANT CONNECT ON ENDPOINT::ServerBrokerEndpoint1234 TO [PUBLIC];
END
GO