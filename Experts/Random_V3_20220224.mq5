//+------------------------------------------------------------------+
//|                                           Random_V3_20220224.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//|Import Function                                                   |
//+------------------------------------------------------------------+
#include <Cactus_Capital_Trading\Trade_Function\Position_Count.mqh>
#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//|Input parameters                                                  |
//+------------------------------------------------------------------+
input double      Lots                    =  0.01;
input double      RR_Ratio                =  2;
input int         SL_Point                =  500;
input bool        Allow_Send_Order        =  true;

//+------------------------------------------------------------------+
//| Global Variable                                                  |
//+------------------------------------------------------------------+
#define  max_random   32767
int      magic_number = 20222402;
string   datetime_str = TimeToString(TimeCurrent(), TIME_SECONDS);

//+------------------------------------------------------------------+
//| Declare Variable                                                 |
//+------------------------------------------------------------------+

double   random_number;
bool     last_tick_check;
int      product_position;
bool     position_condition;
bool     buy_cond_1;
bool     sell_cond_1;

CTrade   trade;
int      deviation      =  10;
double   sl_price;
double   tp_price;

MqlRates    last_bar_value[];
MqlTick     last_tick;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Set Timer
   EventSetTimer(60);
   
   //--- Print Start Time when EA is initialized
   Print("Initial Time \n" + datetime_str );
   
   //--- Set Seed from Random number
   MathSrand(GetTickCount());
   
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
   //| Generate Price and Signal                                        |
   //+------------------------------------------------------------------+
   
   //--- Copy Last OHLC
   if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 1, last_bar_value) < 0)
      {
      
         Alert("Error copying rates/history data - error:",GetLastError(),"!!");
         return;
         
      }
   
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
   
   //--- Get Random Number
   random_number = ( double( MathRand() ) / (double) max_random ) * 100;
   
   //+------------------------------------------------------------------+
   //| Generate Trading Condition                                       |
   //+------------------------------------------------------------------+
   
   //--- Create Buy Condition
   buy_cond_1 = ( random_number > 50 );
   sell_cond_1 = ( random_number <= 50 );

   //+------------------------------------------------------------------+
   //| Check Total Product Position                                     |
   //+------------------------------------------------------------------+
   
   //--- Get total product position
   product_position = total_symbol_position(_Symbol, NULL, true);
   
   //--- Create Product Position Condition
   if(product_position == 0)
   {
   
      //--- Allow trade if there is no position
      position_condition = true;
   
   }
   else
   {
   
      //--- Do not trade if there are some position
      position_condition = false; 
   
   }
   
   //+------------------------------------------------------------------+
   //| Generate Trading                                                 |
   //| Try using standard library                                       |
   //+------------------------------------------------------------------+
   
   //--- Set up trading configure
   trade.LogLevel(1); 
   trade.SetExpertMagicNumber(magic_number);
   trade.SetDeviationInPoints(deviation);      
   trade.SetTypeFilling(ORDER_FILLING_RETURN);
   trade.SetAsyncMode(false);
   
   //--- Buy Condition
   if( ( buy_cond_1 ) && (Allow_Send_Order) && (position_condition) )
   {
   
      //-- Calculate Stop Loss and Target Profit Price
      sl_price = NormalizeDouble( last_tick.ask - ( SL_Point * _Point ), _Digits );
      tp_price = NormalizeDouble( last_tick.ask + ( RR_Ratio * ( SL_Point * _Point ) ), _Digits );

      //--- Buy parameter
      if(!trade.Buy(0.01, NULL, last_tick.ask, sl_price, tp_price))
      {
      //--- failure message
      Print("Buy() method failed. Return code=",trade.ResultRetcode(),
            ". Code description: ",trade.ResultRetcodeDescription());
      }
      
      else
      {
      Print("Buy() method executed successfully. Return code=",trade.ResultRetcode(),
            " (",trade.ResultRetcodeDescription(),")");
      }

   }
   
   //--- Sell Condition
   if( ( sell_cond_1 ) && (Allow_Send_Order) && (position_condition) )
   {
   
      //-- Calculate Stop Loss and Target Profit Price
      sl_price = NormalizeDouble( last_tick.bid + ( SL_Point * _Point ), _Digits );
      tp_price = NormalizeDouble( last_tick.bid - ( RR_Ratio * ( SL_Point * _Point ) ), _Digits );

      //--- Buy parameter
      if(!trade.Sell(0.01, NULL, last_tick.bid, sl_price, tp_price))
      {
      //--- failure message
      Print("Sell() method failed. Return code=",trade.ResultRetcode(),
            ". Code description: ",trade.ResultRetcodeDescription());
      }
      
      else
      {
      Print("Sell() method executed successfully. Return code=",trade.ResultRetcode(),
            " (",trade.ResultRetcodeDescription(),")");
      }

   }
   
}
//+------------------------------------------------------------------+
