//+------------------------------------------------------------------+
//|                                                Read_CSV_file.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
  
   //--- Generate Datapath
   //--- Data Path is restricted in Files Sandbox can't use out of this path
   string subfolder="Input_CSV";
   string filename = subfolder+"\\test_input.csv";
   
   int filehandle=FileOpen(filename,FILE_READ|FILE_CSV|FILE_ANSI, ",");
   
   Print(filename);
   
   //--- Declare Variable
   string str;
   
   //--- In case of Error, show error
   if(filehandle<0)
   {
   
      Print("File can't be read ",GetLastError());
      
   }
   else
   {
      //--- Read file until file end
      while(!FileIsEnding(filehandle))
      {   
      
          //--- Read data in file as string
          //--- Data will read in line level first (from left to right) then
          //--- new line will be read
          str    = FileReadString(filehandle);
          
          Print(str);                                  
          
      }
      
      FileClose(filehandle);
            
   }
   
  }
//+------------------------------------------------------------------+
