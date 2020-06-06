USE [master];
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_create_public_endpoint]
	@port int = 4022
AS
BEGIN
	SET NOCOUNT ON;

	IF (@port IS NULL) SET @port = 4022;
	IF (NOT @port BETWEEN 1024 AND 32767) THROW 50001, N'Invalid port number.', 1;

	IF NOT EXISTS(SELECT 1 FROM sys.symmetric_keys WHERE [name] = '##MS_DatabaseMasterKey##')
	BEGIN
		CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'DaJet_(c)_2020_MasterKey';
	END;

	IF NOT EXISTS(SELECT 1 FROM sys.certificates WHERE [name] = 'DaJetTransportAuthenticationCertificate')
	BEGIN
		CREATE CERTIFICATE DaJetTransportAuthenticationCertificate
		WITH
		SUBJECT = 'DaJet (c) 2020 Transport Authentication Certificate',
		START_DATE = '20200101',
		EXPIRY_DATE = '20300101'
	END;

	IF NOT EXISTS(SELECT 1 FROM sys.service_broker_endpoints WHERE [type] = 3) -- Service Broker endpoint type
	BEGIN
		DECLARE @port_number nvarchar(5) = CAST(@port AS nvarchar(5));
		EXEC(N'CREATE ENDPOINT ServiceBrokerEndpoint
		STATE = STARTED
		AS TCP
		(
			LISTENER_PORT = ' + @port_number + N'
		)
		FOR SERVICE_BROKER
		(
			AUTHENTICATION = CERTIFICATE DaJetTransportAuthenticationCertificate
		)
		GRANT CONNECT ON ENDPOINT::ServiceBrokerEndpoint TO [PUBLIC];');
	END;

END;
GO