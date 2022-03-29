//+------------------------------------------------------------------+
//|                                          Read_CSV_file_Array.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Structure for storing command and value                          |
//+------------------------------------------------------------------+
struct parameter
  {
  
   string        command; // date
   int           value;  // bid price
   
   //---Default constructor ( Initial Process??)
   parameter()
   {
      command = "";
      value   = 0.0;
   }
   
   void read(int handler)
   {
      command = FileReadString(handler);
      value = FileReadString(handler);
   }
   
  };
  
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
  
   //--- Generate Datapath
   //--- Data Path is restricted in Files Sandbox can't use out of this path
   string subfolder="Input_CSV";
   string filename = subfolder+"\\test_input_array.csv";
   
   //--- Read File
   int filehandle=FileOpen(filename,FILE_READ|FILE_ANSI, ",");
   Print(filename);
   
   //--- Declare Variable
   string str;
   int   i = 0;
   parameter array[];
   
   ArrayResize(array, i+1, 0);
   
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
          array[i].read(filehandle) ;
          
          //--- Print Value
          Print(" Command : " + array[i].command + " Value : " + array[i].value );                                  
          
          i++;
          
          ArrayResize(array, i+1, 0);
          
      }
      
      FileClose(filehandle);
            
   }
   
  }
//+------------------------------------------------------------------+
