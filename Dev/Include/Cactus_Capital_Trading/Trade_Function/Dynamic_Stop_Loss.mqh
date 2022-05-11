//+------------------------------------------------------------------+
//|                                            Dynamic_Stop_Loss.mqh |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//| Dynamic Stop Loss Function                                       |
//+------------------------------------------------------------------+

double stop_loss_point(const int         dynamic_type,
                       const double      start_stop_loss_point,
                       const string      symbol,
                       const int         look_back_date,
                       const int         magic_number,
                       bool              print_mode = true)

  {
//--- Declare Parameter
   uint           j;
   uint           total_history_deal;
   ulong          history_deal_ticket;
   double         history_deal_profit;
   string         history_deal_name;
   long           history_deal_side;
   long           history_deal_type;
   long           history_deal_magic;
   uint           total_closed_deal = 0;
   datetime       start_date = TimeCurrent() - (look_back_date * 24 * 60 * 60);
   int            loss_sequence = 0;
   double         total_loss_sequence = 0;
   int            profit_sequence = 0;
   double         total_profit_sequence = 0;   
   double         stop_loss_multipler = 1.00;

//--- Get Historical Data Period Time
   HistorySelect(start_date,TimeCurrent());

//--- Get Total Deal Closed
   total_history_deal = HistoryDealsTotal();

//--- Print All Closed Deal
   for(j = 0; j < total_history_deal; j++)
     {

      //--- Select Close Order
      history_deal_ticket = HistoryDealGetTicket(j);

      //--- Get Other Information
      //--- Select Order first
      if(history_deal_ticket > 0)
        {

         //--- Get Product Name of Order
         history_deal_name = HistoryDealGetString(history_deal_ticket, DEAL_SYMBOL);

         //--- Get Price of Order
         history_deal_profit = HistoryDealGetDouble(history_deal_ticket, DEAL_PROFIT);

         //--- Get Order Side
         history_deal_side = HistoryDealGetInteger(history_deal_ticket, DEAL_TYPE);

         //--- Get Order Type
         history_deal_type = HistoryDealGetInteger(history_deal_ticket, DEAL_ENTRY);

         //--- Get Magic Number
         history_deal_magic = HistoryDealGetInteger(history_deal_ticket, DEAL_MAGIC);

         //--- Collect Loss Sequence
         if((history_deal_type == 1) && (history_deal_name == symbol))
           {

            //--- Count when deal is already closed ( Didn't use but has potential for futher use)
            total_closed_deal += 1;
            
            //--- In case that magic number is assigned
            if(magic_number != NULL)
              {

               if((history_deal_profit <= 0) && (history_deal_magic == magic_number))
                 {

                  //--- Start count loss sequence
                  loss_sequence++;

                  //--- Start collect loss value
                  total_loss_sequence += history_deal_profit;
                  
                  //--- Reset profit sequence
                  profit_sequence = 0;
                  
                  //--- Need to add total profit sequence

                 }
               else
                 {

                  //--- Reset loss sequence
                  loss_sequence = 0;

                  //--- Reset loss value
                  total_loss_sequence = 0;
                  
                  //--- Start Count profit sequence
                  profit_sequence++;
                  
                  //--- Need to add total profit sequence

                 }

              }

            //--- In case that magic number is not assigned
            else if(magic_number == NULL)
              {

               if((history_deal_profit <= 0))
                 {

                  //--- Start count loss sequence
                  loss_sequence++;

                  //--- Start collect loss value
                  total_loss_sequence += history_deal_profit;
                  
                  //--- Reset profit sequence
                  profit_sequence = 0;
                  
                  //--- Need to add total profit sequence

                 }
               else
                 {

                  //--- Reset loss sequence
                  loss_sequence = 0;

                  //--- Reset loss value
                  total_loss_sequence = 0;
                  
                  //--- Start Count profit sequence
                  profit_sequence++;

                  //--- Need to add total profit sequence
                  
                 }

              }

           }

        }

      //-- In case of no historical deals in this period
      else
        {

         Print("No historical deals in this period");

        }

     }

//+------------------------------------------------------------------+
//| Divide by 2 Type in case of win                                  |
//+------------------------------------------------------------------+

//--- Martingle Double Position
   if(dynamic_type == 1)
     {

      //--- When loss, double position size
      if(profit_sequence > 0)
        {

         //--- Adjust Dynamic Stop Loss Factor
         stop_loss_multipler = stop_loss_multipler / (pow(1.2, profit_sequence));

        }

      //--- When win, change position size to start lot size
      else
        {

         stop_loss_multipler = 1;

        }

     }

//--- Print Mode
   if(print_mode == true)
     {

      //--- Print total deal in history period
      Print("Total History Deal : " + IntegerToString(total_history_deal));

      //--- Print total loss sequence in period
      Print("Total Loss Sequence : " + IntegerToString(profit_sequence));

      //--- Print total loss value of sequence in period
      Print("Total Loss Value : " + DoubleToString(total_profit_sequence));

      //--- Print total loss sequence in period
      Print("Stop Loss Multiplier : " + DoubleToString(stop_loss_multipler));

     }

   return (stop_loss_multipler * start_stop_loss_point);

  }

//+------------------------------------------------------------------+

