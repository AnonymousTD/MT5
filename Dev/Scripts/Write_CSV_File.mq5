//+------------------------------------------------------------------+
//|                                               Write_CSV_File.mq5 |
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
   string filename = subfolder+"\\test_output_array.csv";
   
   //--- Read File
   int filehandle=FileOpen(filename,FILE_WRITE|FILE_CSV);
   Print(filename);
   
   //--- Loop for Write File
   for(int i=0;i<10;i++)
   {
   
      //--- Write data in each line 
      FileWrite(filehandle,i,i+1);
     
   }
   
   //--- close the file
   FileClose(filehandle);
   
  }
//+------------------------------------------------------------------+
