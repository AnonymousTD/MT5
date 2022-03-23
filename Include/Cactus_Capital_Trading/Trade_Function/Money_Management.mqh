//+------------------------------------------------------------------+
//|                                             Money_Management.mqh |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//| Money Management Function                                        |
//+------------------------------------------------------------------+

double mm_lots(const int         mm_type,
               const double      start_lots_size, 
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
      datetime       start_date = TimeCurrent() - ( look_back_date * 24 * 60 * 60 );
      int            loss_sequence = 0;
      int            volume_multipler = 1;

      //--- Get Historical Data Period Time
      HistorySelect( start_date,TimeCurrent() );
      
      //--- Get Total Deal Closed
      total_history_deal = HistoryDealsTotal();

      //--- Print All Closed Deal
      for(j = 0; j < total_history_deal; j++)
      {
         
         //--- Select Close Order
         history_deal_ticket = HistoryDealGetTicket(j);
         
         //--- Get Other Information
         //--- Select Order first
         if( history_deal_ticket > 0 )
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
            if( ( history_deal_type == 1 ) && ( history_deal_name == symbol ) )
            {
               
               //--- In case that magic number is assigned
               if( magic_number != NULL )
               {
               
                  if( ( history_deal_profit <= 0 ) && ( history_deal_magic == magic_number ) )
                  {
                     
                     loss_sequence++;
                     
                  }
                  else
                  {
                  
                     loss_sequence = 0;
                     
                  }
               
               }
               
               //--- In case that magic number is not assigned
               if( magic_number == NULL )
               {
               
                  if( ( history_deal_profit <= 0 ) )
                  {
                     
                     loss_sequence++;
                     
                  }
                  else
                  {
                  
                     loss_sequence = 0;
                     
                  }
               
               }
               
            }
         
         }
         
         //-- In case of no historical deals in this period
         else
         {
            
            Print( "No historical deals in this period" );
         
         }
         
      }
      
      //+------------------------------------------------------------------+
      //| Martingle Money Management                                       |
      //+------------------------------------------------------------------+

      if( mm_type == 1 )
      {
      
         //--- When loss, double position size
         if( loss_sequence > 0 )
         {
         
            volume_multipler = volume_multipler * ( pow( 2, loss_sequence ) );
         
         }
         
         //--- When win, change position size to start lot size
         else
         {
         
            volume_multipler = 1;
         
         }
      
      }
      
      //--- Normal MM
      else
      {
      
         volume_multipler = 1;
      
      }
            
      //--- Print Mode
      if(print_mode == true)
      {
      
         //--- Print total deal in history period
         Print("Total History Deal : " + IntegerToString(total_history_deal) );
         
         //--- Print total loss sequence in period
         Print("Total Loss Sequence : " + IntegerToString(loss_sequence) );
         
         //--- Print total loss sequence in period
         Print("Volume Multiplier : " + IntegerToString(volume_multipler) );
         
      }
      
      return ( volume_multipler * start_lots_size );

   }
 
