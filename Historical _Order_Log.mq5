//+------------------------------------------------------------------+
//|                                        Historical _Order_Log.mq5 |
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
   uint           i;
   uint           total_history_order;
   ulong          history_order_ticket;
   double         history_order_price;
   string         history_order_name;
   int            history_order_side;
   datetime       start_date = D'2022.01.17'; 
   
   //--- Get Historical Data Period Time
   HistorySelect( start_date,TimeCurrent() );
   
   //--- Get Total Order Open
   total_history_order = HistoryOrdersTotal();
   
   //--- Print Total Order
   Print("Total Pending Order: " + IntegerToString(total_history_order) );
   
   //--- Print All Pending Ticket
   for(i = 0; i < total_history_order; i++)
   {
   
      ZeroMemory(history_order_ticket);
      
      //--- Get Order Ticket
      history_order_ticket = HistoryOrderGetTicket(i);
      
      Print("Order Ticket :" + IntegerToString(history_order_ticket) + " is Print");
      
      //--- Get Other Information
      //--- Select Order first
      if( history_order_ticket > 0 )
      {
         
         //--- Get Product Name of Order
         history_order_name = HistoryOrderGetString(history_order_ticket, ORDER_SYMBOL);
         
         //--- Get Price of Order
         history_order_price = HistoryOrderGetDouble(history_order_ticket, ORDER_PRICE_OPEN);
         
         //--- Get Order Side
         history_order_side = HistoryOrderGetInteger(history_order_ticket, ORDER_TYPE);
         
         //--- Print Information
         PrintFormat(" Order Ticket : %d SIDE : %d  SYMBOL : %s with Price : %f ",
                     history_order_ticket, history_order_side, history_order_name, history_order_price);
      
      }
      else
      {
         
         //--- Get Last Error
         Print( "Error with Code" + IntegerToString(_LastError) );
         
         return;
      
      }
      
   }
         
  }
//+------------------------------------------------------------------+
