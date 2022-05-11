//+------------------------------------------------------------------+
//|                                 Money_Management_Multi_Order.mqh |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//| Money Management Function                                        |
//+------------------------------------------------------------------+

double mm_lots_multi_orders(  const int         mm_type,
                              const double      start_lots_size,
                              const string      symbol,
                              const int         look_back_date,
                              const int         magic_number,
                              const int         rr_ratio,
                              const int         sl_point,
                              const double      fix_profit_usd,
                              const double      step_profit_usd,
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
   long           history_deal_order_num;
   long           history_order_type;
   uint           total_closed_deal = 0;
   datetime       start_date = TimeCurrent() - (look_back_date * 24 * 60 * 60);
   int            loss_sequence = 0;
   double         total_loss_sequence = 0;
   int            profit_sequence = 0;
   double         total_profit_sequence = 0;   
   double         volume_multipler = 1.00;

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
         
         //--- Get Order Number from Deal
         history_deal_order_num = HistoryDealGetInteger(history_deal_ticket, DEAL_ORDER);
         
         //--- Get Order Type by using order number
         history_order_type = HistoryOrderGetInteger(history_deal_order_num, ORDER_TYPE);

         //--- Collect Loss Sequence
         if((history_deal_type == 1) && (history_deal_name == symbol))
         {
            
            //--- Select only when it is market buy sell order 
            if( history_order_type == 0 || history_order_type == 1 )
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
   
                  }
                  
                  else if(history_deal_magic == magic_number)
                  {
   
                     //--- Reset loss sequence
                     loss_sequence = 0;
   
                     //--- Reset loss value
                     total_loss_sequence = 0;
                     
                     //--- Start Count profit sequence
                     profit_sequence++;
   
                  }
   
               }
   
               //--- In case that magic number is not assigned
               else if(magic_number == NULL)
               {
   
                  if((history_deal_profit <= 0))
                  {
   
                     //--- Start count loss sequence
                     loss_sequence++;
   
                     ////--- Start collect loss value
                     total_loss_sequence += history_deal_profit;
                     
                     //--- Reset profit sequence
                     profit_sequence = 0;
   
                  }
                  else
                  {
   
                     //--- Reset loss sequence
                     loss_sequence = 0;
   
                     //--- Reset loss value
                     total_loss_sequence = 0;
                     
                     //--- Start Count profit sequence
                     profit_sequence++;
   
                  }
   
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
//| Martingle Money Management                                       |
//+------------------------------------------------------------------+

//--- Martingle Double Position
   if(mm_type == 1)
     {

      //--- When loss, double position size
      if(loss_sequence > 0)
        {

         volume_multipler = volume_multipler * (pow(2, loss_sequence));

        }

      //--- When win, change position size to start lot size
      else
        {

         volume_multipler = 1;

        }

     }

//+------------------------------------------------------------------+
//| Martingle Money Management Fix Profit                            |
//+------------------------------------------------------------------+
   else if(mm_type == 2)
        {

         //--- When loss, double position size
         if(loss_sequence > 0)
           {

            //-- Calculate formula
            //-- Multiply by 100 to change to multiplier factor
            volume_multipler = double(MathCeil((fix_profit_usd - total_loss_sequence) * 100 / (rr_ratio * sl_point)));

           }

         //--- When win, change position size to start lot size
         else
           {

            volume_multipler = double(MathCeil((fix_profit_usd * 100) / (rr_ratio * sl_point)));

           }

        }

//+------------------------------------------------------------------+
//| Martingle Money Management Fix Profit and Step                   |
//+------------------------------------------------------------------+
else if(mm_type == 3)
     {

      //--- When loss, double position size
      if(loss_sequence > 0)
        {

         //-- Calculate formula
         //-- Multiply by 100 to change to multiplier factor
         volume_multipler = double(MathCeil((fix_profit_usd + (loss_sequence * step_profit_usd) - total_loss_sequence) * 100 / (rr_ratio * sl_point)));

        }

      //--- When win, change position size to start lot size
      else
        {

         volume_multipler = double(MathCeil((fix_profit_usd * 100) / (rr_ratio * sl_point)));

        }

     }

   //--- Normal MM
   else
     {

      volume_multipler = 1;

     }
           
//+------------------------------------------------------------------+
//| Reverse Martingle Money Management                               |
//+------------------------------------------------------------------+

//--- Martingle Double Position
   if(mm_type == 4)
     {

      //--- When loss, double position size
      if(profit_sequence > 0)
        {

         volume_multipler = volume_multipler * (pow(2, profit_sequence));

        }

      //--- When win, change position size to start lot size
      else
        {

         volume_multipler = 1;

        }

     }

//--- Print Mode
   if(print_mode == true)
     {

      //--- Print total deal in history period
      Print("Total History Deal : " + IntegerToString(total_history_deal));

      //--- Print total loss sequence in period
      Print("Total Loss Sequence : " + IntegerToString(loss_sequence));

      //--- Print total loss value of sequence in period
      Print("Total Loss Value : " + DoubleToString(total_loss_sequence));

      //--- Print total loss sequence in period
      Print("Volume Multiplier : " + DoubleToString(volume_multipler));

     }

   return (volume_multipler * start_lots_size);

  }

//+------------------------------------------------------------------+
