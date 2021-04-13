﻿using DateTimeService.Controllers;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using System.Xml.Serialization;

namespace DateTimeService.Data
{
    public interface IGeoZones
    {
        Task<string> GetGeoZoneID(AdressCoords coords);
        Task<AdressCoords> GetAddressCoordinates(string address_id);
        Boolean AdressExists(string connString, string _addressId);
    }

    public class AdressCoords
    {
        public double X_coordinates { get; set; }
        public double Y_coordinates { get; set; }
        public Boolean AvailableToUse { get; set; }
    }

    public class GeoZones : IGeoZones
    {

        private readonly ILogger<DateTimeController> _logger;
        private readonly IConfiguration _configuration;
        private readonly IHttpClientFactory _httpClientFactory;
        public GeoZones(ILogger<DateTimeController> logger, IConfiguration configuration, IHttpClientFactory httpClientFactory)
        {
            _logger = logger;
            _configuration = configuration;
            _httpClientFactory = httpClientFactory;
        }


        public Boolean AdressExists(string connString, string _addressId)
        {

            bool result = false;

            try
            {
                //sql connection object
                using SqlConnection conn = new(connString);



                string queryParametrs = @"Select Top 1 --по адресу находим геозону
	ГеоАдрес._Fld2785RRef 
	From dbo._Reference112 ГеоАдрес With (NOLOCK)
	Where ГеоАдрес._Fld25155 = @P4 
    AND ГеоАдрес._Marked = 0x00
    AND ГеоАдрес._Fld2785RRef <> 0x00000000000000000000000000000000";

                SqlCommand cmd = new(queryParametrs, conn);

                cmd.Parameters.AddWithValue("@P4", _addressId);


                cmd.CommandText = queryParametrs;

                conn.Open();

                //execute the SQLCommand
                SqlDataReader drParametrs = cmd.ExecuteReader();

                //check if there are records
                if (drParametrs.HasRows)
                {
                    result = true;
                }

                //close data reader
                drParametrs.Close();

                //close connection
                conn.Close();

            }
            catch (Exception ex)
            {
                var logElement = new ElasticLogElement
                {
                    TimeSQLExecution = 0,
                    ErrorDescription = ex.Message,
                    Status = "Error",
                    DatabaseConnection = LoadBalancing.RemoveCredentialsFromConnectionString(connString)
                };

                var logstringElement = JsonSerializer.Serialize(logElement);

                _logger.LogInformation(logstringElement);

                result = false;
            }

            return result;
        }

        public async Task<AdressCoords> GetAddressCoordinates(string address_id)
        {

            AdressCoords result = new();
            result.X_coordinates = 0;
            result.Y_coordinates = 0;
            result.AvailableToUse = false;
            
            var client = _httpClientFactory.CreateClient();
           
            client.Timeout = new TimeSpan(0, 0, 1);
            client.DefaultRequestHeaders.Add("Accept", "application/vnd.api+json");
            client.DefaultRequestHeaders.Add("Content-Type", "application/vnd.api+json");

            string connString = _configuration.GetConnectionString("api21vekby_location");

            //var uri = new Uri("https://api.21vek.by/v2/location.ones?address_id="+address_id);           
            var uri = new Uri(connString + address_id);           

            try
            {
                var responseString = await client.GetStringAsync(uri);
                var locationsResponse = JsonSerializer.Deserialize<LocationsResponse>(responseString);
                result.X_coordinates = Double.Parse(locationsResponse.data.attributes.x_coordinate);
                result.Y_coordinates = Double.Parse(locationsResponse.data.attributes.y_coordinate);
                result.AvailableToUse = true;
            }
            catch(Exception ex)
            {
                var logElement = new ElasticLogElement
                {
                    TimeSQLExecution = 0,
                    ErrorDescription = ex.Message,
                    Status = "Error",
                    DatabaseConnection = connString
                };

                var logstringElement = JsonSerializer.Serialize(logElement);

                _logger.LogInformation(logstringElement);
            }

            return result;
        }

        public async Task<string> GetGeoZoneID(AdressCoords coords)
        {
            string connString = _configuration.GetConnectionString("BTS_zones");

            var request = new HttpRequestMessage(HttpMethod.Post,
            connString);
            request.Headers.Add("Content-Type", "text/xml");
            request.Headers.Add("User-Agent", "HttpClientFactory-Sample");

            string content = @"
<soap:Envelope xmlns:soap=""http://schemas.xmlsoap.org/soap/envelope/"">
    <soap:Body>
        <m:getZoneByCoords xmlns:m=""http://ws.vrptwserver.beltranssat.by/"">
            <m:latitude xmlns:xs=""http://www.w3.org/2001/XMLSchema"" 
     xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"">{0}</m:latitude>
            <m:longitude xmlns:xs=""http://www.w3.org/2001/XMLSchema"" 
     xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"">{1}</m:longitude>
            <m:geomNeeded xmlns:xs=""http://www.w3.org/2001/XMLSchema"" 
     xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"">false</m:geomNeeded>
        </m:getZoneByCoords>
    </soap:Body>
</soap:Envelope>";

            content = string.Format(content, coords.X_coordinates, coords.Y_coordinates);

            request.Content = new StringContent(content, Encoding.UTF8, "text/xml");

            var client = new HttpClient();

            var response = await client.SendAsync(request);

            string result = "";
            if (response.IsSuccessStatusCode)
            {
                using var responseStream = await response.Content.ReadAsStreamAsync();
                var xml = new XmlSerializer(typeof(getZoneByCoordsResponse));
                var responseData = (getZoneByCoordsResponse)xml.Deserialize(responseStream);
                result = responseData.zone.id;
            }
            else
            {
                var logElement = new ElasticLogElement
                {
                    TimeSQLExecution = 0,
                    ErrorDescription = response.ToString(),
                    Status = "Error",
                    DatabaseConnection = connString
                };

                var logstringElement = JsonSerializer.Serialize(logElement);

                _logger.LogInformation(logstringElement);
                              
            }
            return result;
        }

    }

    public class LocationsResponse
    {
        public LocationsResponseElem data { get; set; }
    }
    public class LocationsResponseElem
    {
        public LocationsResponseElemAttrib attributes { get; set; }        
        public string type { get; set; }
        public string id { get; set; }
    }
    public class LocationsResponseElemAttrib
    {
        public string x_coordinate { get; set; }
        public string y_coordinate { get; set; }
    }

    public class BTSResponse
    {
        [XmlElement(Namespace = "http://www.cpandl.com")]
        public string ItemName;
        [XmlElement(Namespace = "http://www.cpandl.com")]
        public string Description;
        [XmlElement(Namespace = "http://www.cohowinery.com")]
        public decimal UnitPrice;
        [XmlElement(Namespace = "http://www.cpandl.com")]
        public int Quantity;
        [XmlElement(Namespace = "http://www.cohowinery.com")]
        public decimal LineTotal;
        // A custom method used to calculate price per item.
        public void Calculate()
        {
            LineTotal = UnitPrice * Quantity;
        }
    }

}
