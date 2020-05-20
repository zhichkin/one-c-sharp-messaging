using Microsoft.Data.SqlClient;
using System;
using System.Data;

namespace OneCSharp.Messaging
{
    public interface IMessagingService
    {
        string CurrentServer { get; }
        string ConnectionString { get; }
        void UseServer(string address);
        void SetupServiceBroker();
        void CreatePublicEndpoint(string name, int port);
        void CreateQueue(string name);
    }
    public sealed class MessagingService : IMessagingService
    {
        private const string ERROR_SERVER_IS_NOT_DEFINED = "Server is not defined. Try to call \"UseServer\" method first.";
        public string CurrentServer { get; private set; } = string.Empty;
        public string ConnectionString { get; private set; } = string.Empty;
        public void UseServer(string address)
        {
            if (string.IsNullOrWhiteSpace(address)) throw new ArgumentNullException(nameof(address));

            SqlConnectionStringBuilder csb;
            if (string.IsNullOrWhiteSpace(ConnectionString))
            {
                csb = new SqlConnectionStringBuilder() { IntegratedSecurity = true };
            }
            else
            {
                csb = new SqlConnectionStringBuilder(ConnectionString);
            }
            csb.DataSource = address;
            ConnectionString = csb.ToString();

            CurrentServer = address;
        }

        public void CreatePublicEndpoint(string name, int port)
        {
            if (string.IsNullOrWhiteSpace(CurrentServer)) throw new InvalidOperationException(ERROR_SERVER_IS_NOT_DEFINED);

            { /* start of limited scope */

                SqlConnection connection = new SqlConnection(ConnectionString);
                SqlCommand command = connection.CreateCommand();
                command.CommandType = CommandType.Text;
                command.CommandText = SqlScripts.CreatePublicEndpointScript(name, port);
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
            } /* end of limited scope */
        }
        public void SetupServiceBroker()
        {
            if (string.IsNullOrWhiteSpace(CurrentServer)) throw new InvalidOperationException(ERROR_SERVER_IS_NOT_DEFINED);

            SqlScripts.ExecuteScript(ConnectionString, SqlScripts.CreateDatabaseScript());
            Guid brokerId = SqlScripts.ExecuteScalar<Guid>(ConnectionString, SqlScripts.SelectServiceBrokerIdentifierScript());
            SqlScripts.ExecuteScript(ConnectionString, SqlScripts.CreateDatabaseUserScript(brokerId));
            SqlScripts.ExecuteScript(ConnectionString, SqlScripts.CreateChannelsTableScript());
        }
        public void CreateQueue(string name)
        {
            Guid brokerId = SqlScripts.ExecuteScalar<Guid>(ConnectionString, SqlScripts.SelectServiceBrokerIdentifierScript());
            SqlScripts.ExecuteScript(ConnectionString, SqlScripts.CreateServiceQueueScript(brokerId, name));
        }
        public void CreateChannel(string name, string sourceQueue, string targetQueue)
        {
            string sql = "";
            //BEGIN DIALOG @handle
            //FROM SERVICE [local service name]
            //TO SERVICE 'remote service name', 'remote service_broker_guid'
            //ON CONTRACT [DEFAULT]
            //WITH ENCRYPTION = OFF;

            //CREATE ROUTE [route name]
            //  WITH
            //    SERVICE_NAME = 'remote service name',
            //    ADDRESS = 'TCP://targetserver:4022';

            //CREATE REMOTE SERVICE BINDING [binding name]
            //  TO SERVICE 'remote service name'
            //  WITH
            //    USER = [remote user name],
            //    ANONYMOUS = ON;
        }



        public void CreateTopic()
        {

        }



        public void SendMessage(string channelName, string payload)
        {
            string sql = "SEND ON CONVERSATION @handle MESSAGE TYPE [DEFAULT] (@message);";
        }
        public string ReceiveMessage(string queueName)
        {
            return null;
        }
        public void Commit()
        {
            
        }
    }
}