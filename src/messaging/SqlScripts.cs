using Microsoft.Data.SqlClient;
using System;
using System.Data;
using System.Text;

namespace OneCSharp.Messaging
{
    internal static class SqlScripts
    {
        internal const string SERVICE_BROKER_DATABASE = "one-c-sharp-messaging";
        private const string CHANNELS_TABLE = "channels";
        private const string ServiceBrokerTransportAuthenticationCertificate = "ServiceBrokerTransportAuthenticationCertificate";
        private const string ServiceBrokerDatabaseAuthenticationCertificate = "ServiceBrokerDatabaseAuthenticationCertificate";

        internal static void ExecuteScript(string connectionString, string sqlScript)
        {
            { /* start of the limited scope */

                SqlConnection connection = new SqlConnection(connectionString);
                SqlCommand command = connection.CreateCommand();
                command.CommandType = CommandType.Text;
                command.CommandText = sqlScript;
                try
                {
                    connection.Open();
                    int result = command.ExecuteNonQuery();
                }
                catch (Exception error)
                {
                    // TODO: log error
                    _ = error.Message;
                    throw;
                }
                finally
                {
                    if (command != null) command.Dispose();
                    if (connection != null) connection.Dispose();
                }
            } /* end of the limited scope */
        }
        internal static T ExecuteScalar<T>(string connectionString, string sqlScript)
        {
            T result = default;

            { // start of the limited scope
                SqlConnection connection = new SqlConnection(connectionString);
                SqlCommand command = connection.CreateCommand();
                SqlDataReader reader = null;
                command.CommandType = CommandType.Text;
                command.CommandText = sqlScript;
                try
                {
                    connection.Open();
                    result = (T)command.ExecuteScalar();
                }
                catch (Exception error)
                {
                    // TODO: log error
                    _ = error.Message;
                }
                finally
                {
                    if (reader != null)
                    {
                        if (reader.HasRows)
                        {
                            command.Cancel();
                        }
                        reader.Dispose();
                    }
                    if (command != null) command.Dispose();
                    if (connection != null) connection.Dispose();
                }
            } // end of the limited scope

            return result;
        }

        private static string CreateQueueName(Guid brokerId, string name)
        {
            return $"{brokerId}/Queue/{name}";
        }
        private static string CreateServiceName(Guid brokerId, string name)
        {
            return $"{brokerId}/Service/{name}";
        }
        private static string CreateBrokerUserName(Guid brokerId)
        {
            return $"{brokerId}/User";
        }

        internal static string CreatePublicEndpointScript(string name, int port)
		{
			StringBuilder script = new StringBuilder();
            script.AppendLine("USE [master];");
            script.AppendLine("IF NOT EXISTS(SELECT 1 FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')");
            script.AppendLine("BEGIN");
            script.AppendLine("\tCREATE MASTER KEY ENCRYPTION BY PASSWORD = 'ServiceBrokerMasterKey';");
            script.AppendLine("END");
            script.AppendLine($"IF NOT EXISTS(SELECT 1 FROM sys.certificates WHERE name='{ServiceBrokerTransportAuthenticationCertificate}')");
            script.AppendLine("BEGIN");
            script.AppendLine($"\tCREATE CERTIFICATE {ServiceBrokerTransportAuthenticationCertificate}");
            script.AppendLine("\tWITH");
            script.AppendLine($"\tSUBJECT = '{ServiceBrokerTransportAuthenticationCertificate}',");
            script.AppendLine("\tSTART_DATE = '20200101',");
            script.AppendLine("\tEXPIRY_DATE = '20500101'");
            script.AppendLine("END");
            script.AppendLine($"IF NOT EXISTS(SELECT 1 FROM sys.service_broker_endpoints WHERE name = '{name}{port}')");
            script.AppendLine("BEGIN");
            script.AppendLine($"\tCREATE ENDPOINT {name}{port}");
            script.AppendLine("\tSTATE = STARTED");
            script.AppendLine("\tAS TCP");
            script.AppendLine("\t(");
            script.AppendLine($"\t\tLISTENER_PORT = {port}");
            script.AppendLine("\t)");
            script.AppendLine("\tFOR SERVICE_BROKER");
            script.AppendLine("\t(");
            script.AppendLine($"\t\tAUTHENTICATION = CERTIFICATE {ServiceBrokerTransportAuthenticationCertificate},");
            script.AppendLine($"\t\tENCRYPTION = DISABLED");
            script.AppendLine("\t)");
            script.AppendLine($"\tGRANT CONNECT ON ENDPOINT::{name}{port} TO [PUBLIC];");
            script.Append("END");
            return script.ToString();
		}
        internal static string CreateDatabaseScript()
        {
            StringBuilder script = new StringBuilder();
            script.AppendLine("USE [master];");
            script.AppendLine($"IF NOT EXISTS(SELECT 1 FROM sys.databases WHERE name = '{SERVICE_BROKER_DATABASE}')");
            script.AppendLine("BEGIN");
            script.AppendLine($"\tCREATE DATABASE [{SERVICE_BROKER_DATABASE}];");
            script.AppendLine($"\tALTER DATABASE [{SERVICE_BROKER_DATABASE}] SET ENABLE_BROKER;");
            script.Append("END");
            return script.ToString();
        }
        internal static string CreateDatabaseUserScript(Guid brokerId)
        {
            string userName = CreateBrokerUserName(brokerId);

            StringBuilder script = new StringBuilder();
            script.AppendLine($"USE [{SERVICE_BROKER_DATABASE}];");
            script.AppendLine("IF NOT EXISTS(SELECT 1 FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')");
            script.AppendLine("BEGIN");
            script.AppendLine("\tCREATE MASTER KEY ENCRYPTION BY PASSWORD = 'ServiceBrokerDatabaseMasterKey';");
            script.AppendLine("END");
            script.AppendLine($"IF NOT EXISTS(SELECT 1 FROM sys.database_principals WHERE name = '{userName}')");
            script.AppendLine("BEGIN");
            script.AppendLine($"\tCREATE USER [{userName}] WITHOUT LOGIN;");
            script.AppendLine("END");
            script.AppendLine($"IF NOT EXISTS(SELECT 1 FROM sys.certificates WHERE name = '{ServiceBrokerDatabaseAuthenticationCertificate}')");
            script.AppendLine("BEGIN");
            script.AppendLine($"\tCREATE CERTIFICATE {ServiceBrokerDatabaseAuthenticationCertificate}");
            script.AppendLine($"\t\tAUTHORIZATION [{userName}]");
            script.AppendLine("\t\tWITH");
            script.AppendLine($"\t\tSUBJECT = '{ServiceBrokerDatabaseAuthenticationCertificate}',");
            script.AppendLine("\t\tSTART_DATE = '20200101',");
            script.AppendLine("\t\tEXPIRY_DATE = '20500101';");
            script.Append("END");
            return script.ToString();
        }
        internal static string CreateChannelsTableScript()
        {
            StringBuilder script = new StringBuilder();
            script.AppendLine($"USE [{SERVICE_BROKER_DATABASE}];");
            script.AppendLine($"IF NOT EXISTS(SELECT 1 FROM sys.tables WHERE type = 'U' AND name = '{CHANNELS_TABLE}')");
            script.AppendLine("BEGIN");
            script.AppendLine($"\tCREATE TABLE [dbo].[{CHANNELS_TABLE}]");
            script.AppendLine("\t(");
            script.AppendLine("\t\t[id]     int IDENTITY(1,1) NOT NULL,");
            script.AppendLine("\t\t[name]   nvarchar(256)     NOT NULL,");
            script.AppendLine("\t\t[handle] uniqueidentifier  NOT NULL,");
            script.AppendLine("\t\tCONSTRAINT [pk_channels] PRIMARY KEY CLUSTERED ([id] ASC)");
            script.AppendLine("\t);");
            script.AppendLine($"\tCREATE UNIQUE NONCLUSTERED INDEX [unx_channels_name] ON [dbo].[{CHANNELS_TABLE}]([name] ASC);");
            script.Append("END");
            return script.ToString();
        }
        internal static string SelectServiceBrokerIdentifierScript()
        {
            StringBuilder script = new StringBuilder();
            script.AppendLine($"SELECT service_broker_guid FROM sys.databases WHERE [name] = '{SERVICE_BROKER_DATABASE}';");
            return script.ToString();
        }
        internal static string CreateServiceQueueScript(Guid brokerId, string name)
        {
            string userName = CreateBrokerUserName(brokerId);
            string queueName = CreateQueueName(brokerId, name);
            string serviceName = CreateServiceName(brokerId, name);

            StringBuilder script = new StringBuilder();
            script.AppendLine($"USE [{SERVICE_BROKER_DATABASE}];");
            script.AppendLine($"IF NOT EXISTS(SELECT 1 FROM sys.service_queues WHERE name = '{queueName}')");
            script.AppendLine("BEGIN");
            script.AppendLine($"\tCREATE QUEUE [{queueName}] WITH POISON_MESSAGE_HANDLING (STATUS = OFF);");
            script.AppendLine("END");
            script.AppendLine($"IF NOT EXISTS(SELECT 1 FROM sys.services WHERE name = '{serviceName}')");
            script.AppendLine("BEGIN");
            script.AppendLine($"\tCREATE SERVICE [{serviceName}] ON QUEUE [{queueName}] ([DEFAULT]);");
            script.AppendLine($"\tGRANT CONTROL ON SERVICE::[{serviceName}] TO [{userName}];");
            script.AppendLine($"\tGRANT SEND ON SERVICE::[{serviceName}] TO [PUBLIC];");
            script.AppendLine("END");

            // TODO: backup certificate to binary !

            // for initiator side:
            // 1. create user for remote service
            // 2. certificate for remote service user from binary backuped at target side !
            // 3. create remote service binding

            return script.ToString();
        }
    }
}