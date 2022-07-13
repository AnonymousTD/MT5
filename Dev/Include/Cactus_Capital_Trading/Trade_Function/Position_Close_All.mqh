//+------------------------------------------------------------------+
//|                                             Position_Close_All.mqh |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//| Import Function                                                  |
//+------------------------------------------------------------------+

#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Declare Variable                                                 |
//+------------------------------------------------------------------+

CTrade   position;

//+------------------------------------------------------------------+
//| Cancel order in that symbol and magic number                     |
//+------------------------------------------------------------------+

int symbol_all_position_close(const string symbol,const int magic_number, bool print_mode = true )
   {
      //--- Declare parameter
      int      total_position;
      ulong    position_ticket;
      string   position_symbol;
      int      i;
      
      //--- Check Total Position
      total_position = PositionsTotal();
      
      //--- Loop through all position
      for( i = 0; i <= total_position-1; i++)
      {
      
         //--- Get order ticket
         position_ticket = PositionGetTicket(i);
         
         //--- Select Order
         if( !PositionSelectByTicket(position_ticket) )
         {
         
            Print( "Unsuccessful select position");
            
         }
         
         //--- Get position symbol by using index
         position_symbol = PositionGetString(POSITION_SYMBOL); 
         
         //--- In case of not know magic number
         if (magic_number != NULL)
         {
         
            //--- If position symbol is open then sum up
            if ( ( position_symbol == symbol ) && ( PositionGetInteger(POSITION_MAGIC) == magic_number ) )
         
            {
            
               position.PositionClose(position_ticket);
               
            }
            
         }
        
        //--- If magic number is not know
        if (magic_number == NULL)
        {
        
            //--- If position symbol is open then sum up
            if ( position_symbol == symbol )
            {
            
               position.PositionClose(position_ticket);
               
            }
            
        }
        
      }
      
      if( print_mode == true )
      {  
         //--- Print 
         Print("All position are closed");
           
      }
      
      return(NULL);
      
   }