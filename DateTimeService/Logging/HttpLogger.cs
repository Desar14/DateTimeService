﻿using DateTimeService.Logging;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Net.Sockets;
using System.Text;
using System.Text.Json;

namespace DateTimeService
{
    public class HttpLogger : ILogger
    {
        private readonly string logsHost;
        private readonly int logsPort;
        readonly UdpClient udpClient;
        TcpClient tcpClient;
        //NetworkStream netStream;

        public HttpLogger(string host, int port)
        {
            logsHost = host;
            logsPort = port;
            udpClient = new UdpClient(logsHost, logsPort);
            //tcpClient = new TcpClient(logsHost, logsPort);
            //netStream = tcpClient.GetStream();
        }
        public IDisposable BeginScope<TState>(TState state)
        {
            return null;
        }

        public bool IsEnabled(LogLevel logLevel)
        {
            //return logLevel == LogLevel.Trace;
            return true;
        }

        public async void Log<TState>(LogLevel logLevel, EventId eventId, TState state, Exception exception, Func<TState, Exception, string> formatter)
        {
            if (formatter != null)
            {

                var logMessage = new ElasticLogMessage();
                logMessage.message.Add(formatter(state, exception));

                var resultLog = JsonSerializer.Serialize(logMessage);

                // UdpClient udpClient = new UdpClient("192.168.2.16", 5048);
                Byte[] sendBytes = Encoding.UTF8.GetBytes(resultLog);

                //if (!tcpClient.Connected)
                //    tcpClient = new TcpClient(logsHost, logsPort);

                //var netStream = tcpClient.GetStream();

                //if (netStream.CanWrite)
                //{
                //    await netStream.WriteAsync(sendBytes.AsMemory(0, sendBytes.Length));
                //}
                //else
                //{
                //    Console.WriteLine("You cannot write data to this stream.");
                //    tcpClient.Close();

                //    // Closing the tcpClient instance does not close the network stream.
                //    netStream.Close();
                //    return;
                //}
                //netStream.Close();
                try
                {
                    await udpClient.SendAsync(sendBytes, sendBytes.Length);
                }
                catch (Exception e)
                {
                    Console.WriteLine(e.ToString());
                }


            }
        
        }
    }
}
