using Microsoft.Data.SqlClient;
using Microsoft.SqlServer.Management.Common;
using Microsoft.SqlServer.Management.Dmf;
using Microsoft.SqlServer.Management.Smo;
using Microsoft.SqlServer.Management.Smo.Broker;
using Microsoft.SqlServer.Management.SqlParser.Common;
using System;
using System.Data;

namespace OneCSharp.Messaging
{
    public interface IMessagingService
    {

    }
    public sealed class MessagingService : IMessagingService
    {
        private ServerConnection _connection;
        public MessagingService()
        {

        }
        public Database Database { get; private set; }
        public ServerConnection Connection
        {
            private set { _connection = value; }
            get
            {
                if (_connection == null)
                {
                    throw new InvalidOperationException("Server instance is not defined! Try to call \"UseServer\" method first.");
                }
                return _connection;
            }
        }
        public void UseServer(string serverName)
        {
            if (_connection == null)
            {
                _connection = new ServerConnection(serverName);
            }
            else if (_connection.IsOpen)
            {
                throw new InvalidOperationException("Server connection is busy! Try later.");
            }
            else
            {
                _connection.ServerInstance = serverName;
            }
        }
        public void UseDatabase(string databaseName)
        {
            Server server = new Server(Connection);
            try
            {
                Database = server.Databases[databaseName];
                if (Database == null)
                {
                    throw new InvalidOperationException($"Database [{databaseName}] is not found!");
                }
            }
            finally
            {
                if (Connection.IsOpen)
                {
                    Connection.Disconnect();
                }
                server = null;
            }
        }
        public void CreateDatabase(string databaseName)
        {
            Server server = new Server(Connection);

            Database database = server.Databases[databaseName];
            if (database == null)
            {
                database = new Database(server, databaseName);
                database.Create();
            }
            if (!database.BrokerEnabled)
            {
                database.BrokerEnabled = true;
                database.Alter();
            }
            Database = server.Databases[databaseName];
            CreateChannelsTable();
        }
        private void CreateChannelsTable()
        {
            string channelsTableName = "channels";
            Table table = Database.Tables[channelsTableName];
            if (table != null)
            {
                return;
            }

            table = new Table(Database, channelsTableName);

            Column column = new Column()
            {
                Parent = table,
                Name = "handle",
                DataType = DataType.UniqueIdentifier,
                Nullable = false
            };
            table.Columns.Add(column);

            column = new Column()
            {
                Parent = table,
                Name = "name",
                DataType = DataType.NVarChar(256),
                Nullable = false
            };
            table.Columns.Add(column);

            Microsoft.SqlServer.Management.Smo.Index index = new Microsoft.SqlServer.Management.Smo.Index()
            {
                Parent = table,
                Name = "pk_" + table.Name,
                IsClustered = true,
                IsUnique = true,
                IndexKeyType = IndexKeyType.DriPrimaryKey
            };
            index.IndexedColumns.Add(new IndexedColumn(index, column.Name));
            table.Indexes.Add(index);

            table.Create();
        }
        public void CreateQueue(string queueName)
        {
            string queueFullName = queueName + "Queue";
            string serviceFullName = queueName + "Service";

            ServiceQueue queue = Database.ServiceBroker.Queues[queueFullName];
            if (queue == null)
            {
                queue = new ServiceQueue(Database.ServiceBroker, queueFullName);
                queue.Create();
            }

            BrokerService service = Database.ServiceBroker.Services[serviceFullName];
            if (service == null)
            {
                service = new BrokerService(Database.ServiceBroker, serviceFullName);
                service.QueueName = queue.Name;
                service.Create();
            }
        }
        public void CreateChannel(string channelName, string sourceQueue, string targetQueue)
        {
            string sql = "";
            //BEGIN DIALOG @handle
            //FROM SERVICE [{sourceQueue}Service]
            //TO SERVICE N'{targetQueue}Service'
            //ON CONTRACT [DEFAULT]
            //WITH ENCRYPTION = OFF;
            //if (Database.MasterKey == null)
            //{
            //    MasterKey key = new MasterKey(Database);
            //    key.Create("one-c-sharp-messaging");
            //}

            //Server server = new Server(Connection);
            //if (server.ServiceMasterKey == null) return;

            //Certificate certificate = new Certificate(Database, "");
        }

        public void CreatePublicEndPoint(string name, int port)
        {
            string sql = "";
            //BEGIN DIALOG @handle
            //FROM SERVICE [{sourceQueue}Service]
            //TO SERVICE N'{targetQueue}Service'
            //ON CONTRACT [DEFAULT]
            //WITH ENCRYPTION = OFF;
            //if (Database.MasterKey == null)
            //{
            //    MasterKey key = new MasterKey(Database);
            //    key.Create("one-c-sharp-messaging");
            //}



            Server server = new Server(Connection);
            

            Endpoint endpoint = server.Endpoints[name];
            if (endpoint != null)
            {
                return;
            }

            string password = "ServiceBrokerMasterKey";
            Database master = server.Databases["master"];
            MasterKey key = master.MasterKey;
            if (key == null)
            {
                key.Create(password);
            }
            key.Open(password);

            string certificateName = $"ServiceBrokerEndpoint{port}";
            Certificate certificate = master.Certificates[certificateName];
            if (certificate == null)
            {
                DateTime datetime = DateTime.Now;
                certificate = new Certificate(master, certificateName)
                {
                    StartDate = datetime,
                    ExpirationDate = datetime.AddYears(10),
                    Subject = $"Service Broker Endpoint transport certificate on port {port} number"
                };
                certificate.Create();
            }

            endpoint = new Endpoint(server, name)
            {
                ProtocolType = ProtocolType.Tcp,
                EndpointType = EndpointType.ServiceBroker
            };
            endpoint.Protocol.Tcp.ListenerPort = port;
            endpoint.Payload.ServiceBroker.Certificate = certificate.Name;
            endpoint.Payload.ServiceBroker.IsMessageForwardingEnabled = false;
            endpoint.Create();

            endpoint.Grant(new ObjectPermissionSet(ObjectPermission.Connect), "PUBLIC");
            endpoint.Start();
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
            { // limited scope for variables declared in it - using statement does like that - used here to get control over catch block
                SqlConnection connection = new SqlConnection(Connection.ConnectionString);
                SqlCommand command = connection.CreateCommand();
                SqlDataReader reader = null;
                command.CommandType = CommandType.Text;
                command.CommandText = "SELECT database_id, name FROM sys.databases WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb', 'Resource', 'distribution', 'reportserver', 'reportservertempdb');";
                try
                {
                    connection.Open();
                    reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        //list.Add(new Database()
                        //{
                        //    Name = reader.GetString(1),
                        //    Alias = string.Empty
                        //});
                    }
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
            } // end of limited scope
        }
    }
}