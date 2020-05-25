using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Reflection;
using System.Runtime.InteropServices;

namespace tests
{
    [TestClass]
    public class Test_V83COMConnector
    {
        [TestMethod]
        public void ShowCatalogsMetadata()
        {
            {
                object connector = null;
                object metadata = null;
                object catalogs = null;
                object item = null;
                string name;
                string progId = "V83.COMConnector";
                Type type = Type.GetTypeFromProgID(progId);
                object v83 = Activator.CreateInstance(type);
                try
                {
                    connector =  type.InvokeMember("Connect", BindingFlags.InvokeMethod, null, v83, new object[] { "Srvr=\"Zhichkin\";Ref=\"my_exchange\";" });
                    Type COMObject = connector.GetType();
                    metadata = COMObject.InvokeMember("Метаданные", BindingFlags.GetProperty, null, connector, null);
                    catalogs = COMObject.InvokeMember("Справочники", BindingFlags.GetProperty, null, metadata, null);
                    int count = (int)COMObject.InvokeMember("Количество", BindingFlags.InvokeMethod, null, catalogs, null);
                    for (int i = 0; i < count; i++)
                    {
                        item = COMObject.InvokeMember("Получить", BindingFlags.InvokeMethod, null, catalogs, new object[] { i });
                        name = (string)COMObject.InvokeMember("Имя", BindingFlags.GetProperty, null, item, null);
                        Console.WriteLine(name);
                    }
                }
                catch
                {
                    throw;
                }
                finally
                {
                    if (v83 != null)
                    {
                        if (Marshal.FinalReleaseComObject(v83) == 0)
                        {
                            Console.WriteLine("v83 is successfully released.");
                        }
                    }
                    if (connector != null) Marshal.FinalReleaseComObject(connector);
                    if (metadata != null) Marshal.FinalReleaseComObject(metadata);
                    if (catalogs != null) Marshal.FinalReleaseComObject(catalogs);
                    if (item != null) Marshal.FinalReleaseComObject(item);
                    GC.Collect();
                    GC.WaitForPendingFinalizers();
                }
            }
        }
    }
}