using Microsoft.VisualStudio.TestTools.UnitTesting;
using OneCSharp.Messaging;

namespace tests
{
    [TestClass]
    public class TestMessagingService
    {
        private readonly string serverName = "ZHICHKIN";
        private readonly string databaseName = "DataExchangeNode";

        [TestMethod]
        public void TestServiceBrokerSetup()
        {
            MessagingService messaging = new MessagingService();
            messaging.UseServer(serverName);
            messaging.CreateDatabase(databaseName);
            Assert.AreEqual(messaging.Database.Name, databaseName);
        }
        [TestMethod]
        public void TestCreateQueue()
        {
            MessagingService messaging = new MessagingService();
            messaging.UseServer(serverName);
            messaging.CreateDatabase(databaseName);
            messaging.CreateQueue("Test");
        }
        [TestMethod]
        public void TestCreateEndPoint()
        {
            MessagingService messaging = new MessagingService();
            messaging.UseServer(serverName);
            messaging.UseDatabase("master");
            messaging.CreatePublicEndPoint("ServerBrokerEndpoint1234", 1234);
        }
    }
}