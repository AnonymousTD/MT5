//+------------------------------------------------------------------+
//|                                            Calculate_Balance.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Calculate Balance                                                |
//+------------------------------------------------------------------+
void OnStart()
  {
  
      //--- Declare Parameter
      uint           i;
      uint           total_history_deal;
      ulong          history_deal_ticket;
      double         history_deal_profit;
      string         history_deal_name;
      long           history_deal_side;
      long           history_deal_type;
      double         history_deal_comm;
      double         history_deal_swap;
      datetime       start_date = 0; // Get all deals data
      int            loss_sequence = 0;
      int            volume_multipler = 1;
      double         initial_balance = 0;
      double         balance_array[];
      int            max_position;       
      
      //--- Get Historical Data Period Time
      HistorySelect( start_date,TimeCurrent() );
      
      //--- Get Total Deal Closed
      total_history_deal = HistoryDealsTotal();
      
      //--- Print Total Deal
      Print("Total History Deal : " + IntegerToString(total_history_deal) );
      
      //--- Print All Closed Deal
      for(i = 0; i < total_history_deal; i++)
      {
         
         //--- Select Close
         history_deal_ticket = HistoryDealGetTicket(i);
         
         //--- Get Other Information
         //--- Select Order first
         if( history_deal_ticket > 0 )
         {
            
            //--- Get Product Name of Order
            history_deal_name = HistoryDealGetString(history_deal_ticket, DEAL_SYMBOL);
            
            //--- Get Deal Profit
            history_deal_profit = HistoryDealGetDouble(history_deal_ticket, DEAL_PROFIT);
            
            //--- Get Deal Side
            history_deal_side = HistoryDealGetInteger(history_deal_ticket, DEAL_TYPE);
            
            //--- Get Deal Type
            history_deal_type = HistoryDealGetInteger(history_deal_ticket, DEAL_ENTRY);
            
            //--- Get Deal Commission
            history_deal_comm = HistoryDealGetDouble(history_deal_ticket, DEAL_COMMISSION);
            
            //--- Get Deal Swap
            history_deal_swap = HistoryDealGetDouble(history_deal_ticket, DEAL_SWAP);
            
            //--- Print Information
            //PrintFormat(" Deal Ticket : %d SIDE : %s  SYMBOL : %s with Profit : %f ",
            //            history_deal_ticket, EnumToString((ENUM_DEAL_TYPE)history_deal_side),
            //            history_deal_name, history_deal_profit);
               
            //--- Calculate Balance
            initial_balance = initial_balance + history_deal_profit + history_deal_comm + history_deal_swap;
            
            //--- Print
            //Print(" Balance : " + DoubleToString(initial_balance) );
            
            //--- Resize Array
            ArrayResize(balance_array, i+1);
            
            //--- Collect value in array
            balance_array[i] = initial_balance;
            
         }
         
         //--- In case of Error
         else
         {
            
            //--- Get Last Error
            Print( "Error with Code" + IntegerToString(_LastError) );
            
            return;
         
         }
         
         
      }
      
      //--- Find the max position in array
      max_position = ArrayMaximum(balance_array);
      
      //--- Get the maximum balance
      Print("Max Balance : " + DoubleToString(balance_array[max_position]));
      Print("Max Position : " + IntegerToString(max_position));
      
  }
  
//+------------------------------------------------------------------+
