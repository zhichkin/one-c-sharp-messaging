USE [master];
GO

IF NOT EXISTS(SELECT 1 FROM sys.symmetric_keys WHERE [name] = '##MS_DatabaseMasterKey##')
BEGIN
	CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'DaJet_(c)_2020_MasterKey';
END;
GO

IF NOT EXISTS(SELECT 1 FROM sys.certificates WHERE [name] = 'DaJetTransportAuthenticationCertificate')
BEGIN
	CREATE CERTIFICATE DaJetTransportAuthenticationCertificate
	WITH
	SUBJECT = 'DaJet (c) 2020 Transport Authentication Certificate',
	START_DATE = '20200101',
	EXPIRY_DATE = '20300101'
END;
GO

IF NOT EXISTS(SELECT 1 FROM sys.service_broker_endpoints WHERE [type] = 3) -- Service Broker endpoint type
BEGIN
	CREATE ENDPOINT ServiceBrokerEndpoint
	STATE = STARTED
	AS TCP
	(
		LISTENER_PORT = 4022
	)
	FOR SERVICE_BROKER
	(
		AUTHENTICATION = CERTIFICATE DaJetTransportAuthenticationCertificate
	)
	GRANT CONNECT ON ENDPOINT::ServiceBrokerEndpoint TO [PUBLIC];
END;
GO