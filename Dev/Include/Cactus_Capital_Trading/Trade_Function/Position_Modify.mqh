//+------------------------------------------------------------------+
//|                                              Position_Modify.mqh |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//| Import Library                                                   |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Modify Positions Function                                        |
//+------------------------------------------------------------------+

void  modify_position(  const string      symbol,
                        const int         magic_number,
                        const double      sl_price = NULL,
                        const double      tp_price = NULL,
                        bool              print_mode = true )
                        
   {
      //--- Declare Parameter
      CTrade         trade;
      uint           j;
      uint           total_position;
      ulong          position_ticket;
   
      //--- Get total position
      total_position = PositionsTotal();
      
      //--- Get all position ticket and modify
      for( j = 0; j < total_position; j++ )
      {
         
         //--- get position ticket
         position_ticket = PositionGetTicket(j);
         
         //--- modify position
         if( !trade.PositionModify(position_ticket, sl_price, tp_price ) && print_mode == true )
         {
            Print("Fail to modify position : " + DoubleToString(position_ticket) );
         }

      }
      
   }