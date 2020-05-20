using Microsoft.VisualStudio.TestTools.UnitTesting;
using OneCSharp.Messaging;

namespace tests
{
    [TestClass]
    public class TestMessagingService
    {
        private readonly string serverName = "ZHICHKIN";

        [TestMethod]
        public void CreatePublicEndPoint()
        {
            MessagingService messaging = new MessagingService();
            messaging.UseServer(serverName);
            messaging.CreatePublicEndpoint("ServerBrokerEndpoint", 1234);
        }
        [TestMethod]
        public void SetupServiceBroker()
        {
            MessagingService messaging = new MessagingService();
            messaging.UseServer(serverName);
            messaging.SetupServiceBroker();
        }
        [TestMethod]
        public void CreateQueue()
        {
            MessagingService messaging = new MessagingService();
            messaging.UseServer(serverName);
            messaging.SetupServiceBroker();
            messaging.CreateQueue("test");
        }
    }
}