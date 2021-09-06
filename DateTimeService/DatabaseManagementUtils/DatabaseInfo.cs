﻿using DateTimeService.Data;
using System;
using System.Collections.Generic;

namespace DateTimeService.Models
{
    public class DatabaseInfo : DatabaseConnectionParameter
    {

        public string ConnectionWithoutCredentials { get; set; }

        public bool AvailableToUse { get; set; }
        public DateTimeOffset LastFreeProcCacheCommand { get; set; }
        public DateTimeOffset LastCheckAvailability { get; set; }
        public DateTimeOffset LastCheckAggregations { get; set; }
        public DateTimeOffset LastCheckPerfomance { get; set; }
        public int ActualPriority { get; set; }
        public bool ExistsInFile { get; set; }
        public bool CustomAggregationsAvailable { get; set; }
        public int CustomAggsFailCount { get; set; }


        public DatabaseInfo(DatabaseConnectionParameter connectionParameter)
        {
            Connection = connectionParameter.Connection;
            ConnectionWithoutCredentials = LoadBalancing.RemoveCredentialsFromConnectionString(connectionParameter.Connection);
            Priority = connectionParameter.Priority;
            Type = connectionParameter.Type;
            ActualPriority = connectionParameter.Priority;
        }
    }


}
