using Microsoft.VisualStudio.TestTools.UnitTesting;
using OneCSharp.Messaging;
using System;

namespace tests
{
    [TestClass]
    public class TestMessagingService
    {
        private readonly string sourceServerName = @"ZHICHKIN";
        private readonly string targetServerName = @"ZHICHKIN\SQLEXPRESS";

        [TestMethod]
        public void CreatePublicEndPoint()
        {
            MessagingService messaging = new MessagingService();
            messaging.UseServer(sourceServerName);
            messaging.CreatePublicEndpoint("ServerBrokerEndpoint", 1234);
        }
        [TestMethod]
        public void SetupServiceBroker()
        {
            MessagingService messaging = new MessagingService();
            messaging.UseServer(sourceServerName);
            messaging.SetupServiceBroker();
        }
        [TestMethod]
        public void CreateQueue()
        {
            MessagingService messaging = new MessagingService();
            messaging.UseServer(sourceServerName);
            messaging.SetupServiceBroker();
            messaging.CreateQueue("SourceQueue");
        }
        [TestMethod]
        public void SetupSourceServer()
        {
            MessagingService messaging = new MessagingService();
            messaging.UseServer(sourceServerName);
            messaging.SetupServiceBroker();
            messaging.CreateQueue("SourceQueue");
            messaging.CreatePublicEndpoint("ServerBrokerEndpoint", 1234);
        }
        [TestMethod]
        public void SetupTargetServer()
        {
            MessagingService messaging = new MessagingService();
            messaging.UseServer(targetServerName);
            messaging.SetupServiceBroker();
            messaging.CreateQueue("TargetQueue");
            messaging.CreatePublicEndpoint("ServerBrokerEndpoint", 4321);
        }
        [TestMethod]
        public void CreateRouteFromSourceToTarget()
        {
            string routeName = "RouteFromSourceToTarget";
            string targetAddress = $"localhost:4321";
            string sourceQueueFullName = @"2677a8fb-b2ca-4d9b-a51d-3699bbc89e1a/Queue/SourceQueue";
            string targetQueueFullName = @"7d027278-6734-48c3-814e-180f0892dd00/Queue/TargetQueue";

            MessagingService messaging = new MessagingService();

            messaging.UseServer(targetServerName);
            string certificateData = messaging.GetUserCertificateBinaryData();

            messaging.UseServer(sourceServerName);
            messaging.CreateRemoteUser(targetQueueFullName, certificateData);
            messaging.CreateRoute(routeName, sourceQueueFullName, targetAddress, targetQueueFullName);
        }
        [TestMethod]
        public void CreateRouteFromTargetToSource()
        {
            string routeName = "RouteFromTargetToSource";
            string sourceAddress = $"localhost:1234";
            string sourceQueueFullName = @"2677a8fb-b2ca-4d9b-a51d-3699bbc89e1a/Queue/SourceQueue";
            string targetQueueFullName = @"7d027278-6734-48c3-814e-180f0892dd00/Queue/TargetQueue";

            MessagingService messaging = new MessagingService();

            messaging.UseServer(sourceServerName);
            string certificateData = messaging.GetUserCertificateBinaryData();

            messaging.UseServer(targetServerName);
            messaging.CreateRemoteUser(sourceQueueFullName, certificateData);
            messaging.CreateRoute(routeName, targetQueueFullName, sourceAddress, sourceQueueFullName);
        }
        [TestMethod]
        public void SendMessageFromSourceToTarget()
        {
            string routeName = "RouteFromSourceToTarget";

            MessagingService messaging = new MessagingService();
            messaging.UseServer(sourceServerName);
            messaging.SendMessage(routeName, "test message from source to target");
        }
        [TestMethod]
        public void SendMessageFromTargetToSource()
        {
            string routeName = "RouteFromTargetToSource";

            MessagingService messaging = new MessagingService();
            messaging.UseServer(targetServerName);
            messaging.SendMessage(routeName, "test message from target to source");
        }
        [TestMethod]
        public void ReceiveMessageOnTargetQueue()
        {
            string targetQueueFullName = @"7d027278-6734-48c3-814e-180f0892dd00/Queue/TargetQueue";

            MessagingService messaging = new MessagingService();
            messaging.UseServer(targetServerName);
            string message = messaging.ReceiveMessage(targetQueueFullName);
            if (string.IsNullOrEmpty(message))
            {
                Console.WriteLine("message is empty");
            }
            else
            {
                Assert.AreEqual("test message from source to target", message);
                Console.WriteLine($"message: {message}");
            }
            //if (!string.IsNullOrEmpty(message))
            //{
            //    messaging.Commit();
            //}
        }
    }
}