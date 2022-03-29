//+------------------------------------------------------------------+
//|                                             Portfolio_Manage.mq5 |
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
  
   //--- Declare Variable
   int   i;
   int   total_position;
   string   position_symbol;
   
   //--- Declare Static Array
   string   product_array[2] = {"EURUSD.a", "USDJPY.a"};
   int      product_position[2] = {0, 0};
   
   //--- Check Total Position
   total_position = PositionsTotal();
   
   //--- Print Total Position
   Print( "Total Position: " + IntegerToString(total_position) );
   Print( "Total EURUSD Position: " + IntegerToString(product_position[0]) );
   //--- Print Total Product
   //Print( "Total Product: " + ArraySize(product_array) );
   //Print( "Total Product: " + product_array[1] );
   
   //--- Check Product Position
   //--- Loop through all position by index ( each position has unique indedx and order by open time )
   for( i = 0; i <= total_position-1; i++)
      {
         
         position_symbol = PositionGetSymbol(i);
         
         if (position_symbol == product_array[0])
            {
               product_position[0]++;
            }
            
         else if (position_symbol == product_array[1])
            {
               product_position[1]++;
            }
            
      }
      
      //--- Print All Position by Product
      for( i = 0; i <= ArraySize(product_array)-1; i++)
      {   
      
         //--- Print All Position
         Print( product_array[i] + " " + IntegerToString(product_position[i]) );
         
      }
   
   
  }
