using System;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Reflection;
using System.Runtime.InteropServices;

namespace update_1c_from_zip
{
    class Program
    {
        static int Main(string[] args)
        {
            int exitCode = 0;
            try
            {
                WriteToLog("start " + DateTime.Now.ToString());
                string connectionString = args[0]; // "Srvr=\"Zhichkin\";Ref=\"my_exchange\";"
                string sourceCatalog = args[1];
                exitCode = Update(connectionString, sourceCatalog);
            }
            catch (Exception ex)
            {
                exitCode = 1;
                WriteToLog(GetErrorMessage(ex));
            }
            finally
            {
                WriteToLog("end " + DateTime.Now.ToString());
            }
            return exitCode;
        }
        public static string GetErrorMessage(Exception ex)
        {
            string errorText = string.Empty;
            Exception error = ex;
            while (error != null)
            {
                errorText += (errorText == string.Empty) ? error.Message : Environment.NewLine + error.Message;
                error = error.InnerException;
            }
            return errorText;
        }
        private static void WriteToLog(string entry)
        {
            string path = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
            path = Path.Combine(path, "update_1c_from_zip_log.txt");
            using (StreamWriter sw = new StreamWriter(path, true))
            {
                sw.WriteLine(entry);
            }
        }
        private static int Update(string connectionString, string sourceCatalog)
        {
            int returnCode = 0;
            {
                object connector = null;
                object metadata = null;
                object catalogs = null;
                object item = null;

                object xml_reader = null;
                object exchange_plans = null;
                object message_reader = null;

                //string name;
                string progId = "V83.COMConnector";
                Type type = Type.GetTypeFromProgID(progId);
                object v83 = Activator.CreateInstance(type);
                Type COMObject;
                try
                {
                    type = Type.GetTypeFromProgID(progId);
                    v83 = Activator.CreateInstance(type);

                    connector = type.InvokeMember("Connect", BindingFlags.InvokeMethod, null, v83, new object[] { connectionString });
                    COMObject = connector.GetType();

                    string destination = Path.Combine(sourceCatalog, "update-1c-from-zip");
                    if (Directory.Exists(destination))
                    {
                        Directory.Delete(destination, true);
                    }
                    _ = Directory.CreateDirectory(destination);

                    string zip_file = Directory.GetFiles(sourceCatalog, "*.zip").FirstOrDefault();
                    if (zip_file != null)
                    {
                        WriteToLog(zip_file);
                        ZipFile.ExtractToDirectory(zip_file, destination);
                    }

                    string update_file = Directory.GetFiles(destination, "*.xml").FirstOrDefault();
                    if (update_file != null)
                    {
                        WriteToLog(update_file);

                        xml_reader = COMObject.InvokeMember("NewObject", BindingFlags.InvokeMethod, null, connector, new object[] { "ЧтениеXML" });
                        exchange_plans = COMObject.InvokeMember("ПланыОбмена", BindingFlags.GetProperty, null, connector, null);
                        message_reader = COMObject.InvokeMember("СоздатьЧтениеСообщения", BindingFlags.InvokeMethod, null, exchange_plans, null);
                        _ = COMObject.InvokeMember("ОткрытьФайл", BindingFlags.InvokeMethod, null, xml_reader, new object[] { update_file });
                        _ = COMObject.InvokeMember("НачатьЧтение", BindingFlags.InvokeMethod, null, message_reader, new object[] { xml_reader });
                        bool is_config_changed = false;
                        try
                        {
                            _ = COMObject.InvokeMember("ПрочитатьИзменения", BindingFlags.InvokeMethod, null, exchange_plans, new object[] { message_reader });
                        }
                        catch (Exception ex)
                        {
                            string error_message = GetErrorMessage(ex);
                            is_config_changed = error_message.Contains("Обновление может быть выполнено в режиме Конфигуратор.");
                            WriteToLog(error_message);
                        }
                        if (!is_config_changed)
                        {
                            returnCode = 1;
                            _ = COMObject.InvokeMember("ЗакончитьЧтение", BindingFlags.InvokeMethod, null, message_reader, null);
                        }
                        _ = COMObject.InvokeMember("Закрыть", BindingFlags.InvokeMethod, null, xml_reader, null);
                    }
                    //metadata = COMObject.InvokeMember("Метаданные", BindingFlags.GetProperty, null, connector, null);
                    //catalogs = COMObject.InvokeMember("Справочники", BindingFlags.GetProperty, null, metadata, null);
                    //int count = (int)COMObject.InvokeMember("Количество", BindingFlags.InvokeMethod, null, catalogs, null);
                    //for (int i = 0; i < count; i++)
                    //{
                    //    item = COMObject.InvokeMember("Получить", BindingFlags.InvokeMethod, null, catalogs, new object[] { i });
                    //    name = (string)COMObject.InvokeMember("Имя", BindingFlags.GetProperty, null, item, null);
                    //    Console.WriteLine(name);
                    //}
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

                    if (xml_reader != null) Marshal.FinalReleaseComObject(xml_reader);
                    if (exchange_plans != null) Marshal.FinalReleaseComObject(exchange_plans);
                    if (message_reader != null) Marshal.FinalReleaseComObject(message_reader);

                    GC.Collect();
                    GC.WaitForPendingFinalizers();
                }
            }
            return returnCode;
        }
    }
}

//ЧтениеXML = Новый ЧтениеXML();
//ЧтениеXML.ОткрытьФайл(ИмяФайлаКонфигурацииXML);
		
//		ЕстьИзмененияКонфигурации = Ложь;
//		ЧтениеСообщения = ПланыОбмена.СоздатьЧтениеСообщения();
//		ЧтениеСообщения.НачатьЧтение(ЧтениеXML);
		
//		Попытка

//            ПланыОбмена.ПрочитатьИзменения(ЧтениеСообщения);

//Исключение
//    ТекстОшибки = ОписаниеОшибки();
//Если СтрНайти(ТекстОшибки, "Обновление может быть выполнено в режиме Конфигуратор.") > 0 Тогда
//    // Такое исключение после успешного обновления - ожидаемый результат !
//    ЕстьИзмененияКонфигурации = Истина;
//Иначе
//    // Произошла критическая ошибка при загрузке изменений конфигурации или данных
//    ВызватьИсключение(ТекстОшибки);
//КонецЕсли;
//		КонецПопытки;
		
//		Если ЕстьИзмененияКонфигурации Тогда
//        // Ничего не делаем - обновилась конфигурация
//        Иначе
//            // Увеличиваем номер принятого сообщения на 1
//ЧтениеСообщения.ЗакончитьЧтение();
//		КонецЕсли;
	
//		ЧтениеXML.Закрыть();
//		ЧтениеXML = Неопределено;