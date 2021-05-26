﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace DateTimeService.Models
{
    public class ResponseAvailableDate
    {
        public List<string> article { get; set; }
        public List<string> code { get; set; }
        public List<DateTimeOffset> courier { get; set; }
        public List<DateTimeOffset> self { get; set; }

        public ResponseAvailableDate()
        {
            article = new List<string>();
            code = new List<string>();
            courier = new List<DateTimeOffset>();
            self = new List<DateTimeOffset>();
        }


    }
}
