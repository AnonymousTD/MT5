//+------------------------------------------------------------------+
//|                                            History_Order_Log.mq5 |
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
  
   //--- Declare Parameter
   int            i;
   int            total_order_position;
   ulong          order_ticket;
   double         order_price;
   string         order_name;
   int            order_side;
   
   //--- Get Total Order Open
   total_order_position = OrdersTotal();
   
   //--- Print Total Order
   Print("Total Pending Order: " + IntegerToString(total_order_position) );
   
   //--- Print All Pending Ticket
   for(i = 0; i <= total_order_position - 1; i++)
   {
      
      //--- Get Order Ticket
      order_ticket = OrderGetTicket(i);
      
      Print("Order Ticket :" + order_ticket + " is Print");
      
      //--- Get Other Information
      //--- Select Order first
      if( OrderSelect(order_ticket) )
      {
         
         //--- Get Product Name of Order
         order_name = OrderGetString(ORDER_SYMBOL);
         
         //--- Get Price of Order
         order_price = OrderGetDouble(ORDER_PRICE_OPEN);
         
         //--- Get Order Side
         order_side = OrderGetInteger(ORDER_TYPE);
         
         //--- Print Information
         PrintFormat(" Order Ticket : %d SIDE : %d  SYMBOL : %s with Price : %f ",
                     order_ticket, order_side, order_name, order_price);
      
      }
      else
      {
         
         //--- Get Last Error
         Print( "Error with Code" + IntegerToString(_LastError) );
      
      }
      
   }
      
      
  }
//+------------------------------------------------------------------+

