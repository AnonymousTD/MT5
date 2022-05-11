//+------------------------------------------------------------------+
//|                                               Order_Count.mqh |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//| Count order in that symbol and magic number                      |
//+------------------------------------------------------------------+

int total_symbol_order(const string symbol,const int magic_number, bool print_mode = true )
   {
      //--- Declare parameter
      int      total_order;
      ulong    order_ticket;
      string   order_symbol;
      int      i;
      int      product_order = 0;
      
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
            
               product_order++;
               
            }
            
         }
        
        //--- If magic number is not know
        if (magic_number == NULL)
        {
        
            //--- If position symbol is open then sum up
            if ( order_symbol == symbol )
            {
            
               product_order++;
               
            }
            
        }
        
      }
      
      if( print_mode == true )
      {  
         //--- Print 
         //--- In case that already trade in that product
         if( product_order > 0 )
            {
               
               Print("Products : " + symbol + " has " + IntegerToString(product_order) + " position");
            }
            
         else
            {
            
               Print("No position on " + symbol);
            
            }
            
      }
      
      return(product_order);     
      
   }