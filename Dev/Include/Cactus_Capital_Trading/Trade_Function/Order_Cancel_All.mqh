//+------------------------------------------------------------------+
//|                                             Order_Cancel_All.mqh |
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

CTrade   trade_order;

//+------------------------------------------------------------------+
//| Cancel order in that symbol and magic number                     |
//+------------------------------------------------------------------+

int symbol_all_order_cancel(const string symbol,const int magic_number, bool print_mode = true )
   {
      //--- Declare parameter
      int      total_order;
      ulong    order_ticket;
      string   order_symbol;
      int      i;
      
      //--- Check Total Position
      total_order = OrdersTotal();
      
      //--- Loop through all position
      for( i = 0; i <= total_order-1; i++)
      {
      
         //--- Get order ticket
         order_ticket = OrderGetTicket(i);
         
         //--- Select Order
         if( !OrderSelect(order_ticket) )
         {
         
            Print( "Unsuccessful select pending order");
            
         }
         
         //--- Get position symbol by using index
         order_symbol = OrderGetString(ORDER_SYMBOL); 
         
         //--- In case of not know magic number
         if (magic_number != NULL)
         {
         
            //--- If position symbol is open then sum up
            if ( ( order_symbol == symbol ) && ( PositionGetInteger(POSITION_MAGIC) == magic_number ) )
         
            {
            
               trade_order.OrderDelete(order_ticket);
               
            }
            
         }
        
        //--- If magic number is not know
        if (magic_number == NULL)
        {
        
            //--- If position symbol is open then sum up
            if ( order_symbol == symbol )
            {
            
               trade_order.OrderDelete(order_ticket);
               
            }
            
        }
        
      }
      
      if( print_mode == true )
      {  
         //--- Print 
         Print("All pending order are deleted");
           
      }
      
      return(NULL);
      
   }