//+------------------------------------------------------------------+
//|                                Reverse_Martingle_V0_20220523.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Import library                                                   |
//+------------------------------------------------------------------+

#include <Cactus_Capital_Trading\Trade_Function\Position_Count.mqh>
#include <Cactus_Capital_Trading\Trade_Function\Order_Cancel_All.mqh>
#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Global Variable                                                  |
//+------------------------------------------------------------------+

#define  max_random   32767

//+------------------------------------------------------------------+
//|Input parameters                                                  |
//+------------------------------------------------------------------+

input int            Max_Position            =  1;

//+------------------------------------------------------------------+
//| Declare Variable                                                 |
//+------------------------------------------------------------------+

MqlTick     last_tick;
bool        last_tick_check;

int         product_position;
bool        position_condition;
double      trade_random_number;
double      trade_side_random_number;
double      trade_prob[3] = {30.00, 60.00, 80.00};
bool        trade_cond_1;
bool        buy_cond_1;
bool        sell_cond_1;

CTrade      trade;
int         deviation      =  10;
double      sl_point_value;
double      sl_price;
double      tp_price;
double      stop_order_price_1;
double      stop_order_price_2;
double      stop_order_price_3;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  
   //--- create timer
   EventSetTimer(3600);
   
   //--- Generate random number
   MathSrand(GetTickCount64());
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
  
   //+------------------------------------------------------------------+
   //| Generate Last Tick Value                                         |
   //+------------------------------------------------------------------+
   
   //--- Generate Last Tick
   last_tick_check = SymbolInfoTick(_Symbol, last_tick);
   
   if( last_tick_check == false )
      {
      
         PrintFormat("SymbolInfoTick() call error. Error code=%d",GetLastError());
         return;
          
      }
      
   //+------------------------------------------------------------------+
   //| Generate Random Number                                           |
   //+------------------------------------------------------------------+
   
   //--- Get Trade Random Number
   trade_random_number = ( double( MathRand() ) / (double) max_random ) * 100;
   
   //--- Get Trade Side Random Number
   trade_side_random_number = ( double( MathRand() ) / (double) max_random ) * 100;
   
   //+------------------------------------------------------------------+
   //| Check Total Product Position                                     |
   //+------------------------------------------------------------------+
   
   //--- Get total product position
   product_position = total_symbol_position(_Symbol, NULL, false);
   
   //--- Create Product Position Condition
   if(product_position < Max_Position)
   {
   
      //--- Allow trade if there is no position
      position_condition = true;
      
      //--- Clear All Pending Order when market position already profit
      symbol_all_order_cancel(_Symbol, NULL, false);
   
   }
   else
   {
   
      //--- Do not trade if there are some position
      position_condition = false; 
   
   }
   
   //+------------------------------------------------------------------+
   //| Generate Trading Condition                                       |
   //+------------------------------------------------------------------+
   
   //--- Create Trading or Not Condition
   trade_cond_1 = (trade_random_number < trade_prob[0]) ? true : false ;
   
   //--- Create Trading Condition
   buy_cond_1 = ( trade_side_random_number > 50 );
   sell_cond_1 = ( trade_side_random_number <= 50 );
   
   //+------------------------------------------------------------------+
   //| Generate Trading                                                 |
   //| Try using standard library                                       |
   //+------------------------------------------------------------------+
   
   //--- Set up trading configure
   trade.LogLevel(1);
   trade.SetDeviationInPoints(deviation);      
   trade.SetTypeFilling(ORDER_FILLING_RETURN);
   trade.SetAsyncMode(false);
   
   //--- Buy Condition
   if( ( trade_cond_1 ) && (buy_cond_1) && (position_condition) )
   {
      
      //-- Calculate Stop Loss and Target Profit Price
      sl_price = NormalizeDouble( last_tick.ask - ( 300 * _Point ), _Digits );
      tp_price = NormalizeDouble( last_tick.ask + ( 2 * ( 300 * _Point ) ), _Digits );

      //--- Calculate Limit Order Price
      stop_order_price_1 = NormalizeDouble( last_tick.ask + ( 100 * _Point ), _Digits );
      stop_order_price_2 = NormalizeDouble( last_tick.ask + ( 200 * _Point ), _Digits );
      stop_order_price_3 = NormalizeDouble( last_tick.ask + ( 300 * _Point ), _Digits );

      trade.SetExpertMagicNumber(1);
      trade.Buy(0.01, NULL, last_tick.ask, sl_price, tp_price);
      
      trade.SetExpertMagicNumber(2);
      trade.BuyStop(0.01, stop_order_price_1, NULL, sl_price, tp_price);
      trade.BuyStop(0.01, stop_order_price_2, NULL, sl_price, tp_price);
      trade.BuyStop(0.01, stop_order_price_3, NULL, sl_price, tp_price);
   
  }
  
}
//+------------------------------------------------------------------+
