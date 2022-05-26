//+------------------------------------------------------------------+
//|                                           Random_V8_20220501.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//|                                                                  |
//| Noted                                                            |
//|   - Add Dynamic Stop Loss                                        |
//|   - Split Trading order to 2 order                               |
//|      -  one market order                                         |
//|      -  one limit order                                          |
//|   - Add Trailing Stop                                            |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property script_show_inputs

//+------------------------------------------------------------------+
//|Import Function                                                   |
//+------------------------------------------------------------------+
#include <Cactus_Capital_Trading\Trade_Function\Position_Count.mqh>
#include <Cactus_Capital_Trading\Trade_Function\Order_Count.mqh>
#include <Cactus_Capital_Trading\Trade_Function\Order_Cancel_All.mqh>
#include <Cactus_Capital_Trading\Trade_Function\Money_Management_Multi_Orders.mqh>
#include <Cactus_Capital_Trading\Trade_Function\Maximum_Balance_Calculation.mqh>
#include <Cactus_Capital_Trading\Trade_Function\Dynamic_Stop_Loss.mqh>
#include <Cactus_Capital_Trading\Trade_Function\Position_Modify.mqh>
#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//|Input parameters                                                  |
//+------------------------------------------------------------------+

//--- Add array for Money Management select
enum mm_type
  {
      Normal,
      Martingle,
      Martingle_Fix_Profit,
      Martingle_Fix_Profit_Step,
      Reverse_Martingle
  };
  
//--- Add array for Trading Period Select
enum trading_period
  {
      H1,
      H4,
      H6
  };
  
//--- Add Order type which coordinate with magic number
enum order_type
   {
      market_order   =  1,
      limit_order    =  2
   };

input group          "Trading Parameter"
input double         Start_Lots              =  0.01;
input trading_period Trading_Period          =  H1;
input int            Max_Position            =  1;
input double         RR_Ratio                =  2;
input int            SL_Point                =  500;
input bool           Allow_Send_Order        =  true;

input group          "Limit Order Parameter"
input int            Max_Order               =  1;
input double         Range_from_Market_Order =  2;

input group          "Money Management Parameter"
input mm_type        MM_Type                 =  Normal;
input int            Look_Back_Period        =  365;

input group          "Martingle Fix Profit Parameter"
input double         Fix_Profit_USD          =  100;

input group          "Martingle Fix Profit with Step Parameter"
input double         Step_Profit_USD         =  100;

input group          "Optimization Parameter"
input bool           Optimization            =  false;
input int            Optimization_Round      =  1;


//+------------------------------------------------------------------+
//| Global Variable                                                  |
//+------------------------------------------------------------------+
#define  max_random   32767
int      magic_number = 20222402;
string   datetime_str = TimeToString(TimeCurrent(), TIME_SECONDS);

//+------------------------------------------------------------------+
//| Declare Variable                                                 |
//+------------------------------------------------------------------+

int      select_trading_period;
int      order_magic_number;
double   max_volume;
bool     last_tick_check;
int      product_position;
bool     position_condition;
int      product_order;
bool     order_condition;
double   trade_random_number;
double   trade_side_random_number;
double   trade_prob[3] = {30.00, 60.00, 80.00};
bool     trade_cond_1;
bool     buy_cond_1;
bool     sell_cond_1;

double   position_size;

CTrade   trade;
int      deviation      =  10;
double   sl_point_value;
double   sl_price;
double   tp_price;
double   tp_price_limit;
double   limit_order_price;
double   trigger_price;
double   mod_sl_price;
  
MqlRates    last_bar_value[];
MqlTick     last_tick;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{

   //---
   switch(Trading_Period)
   {
      //--- One Hour
      case H1:
         
         select_trading_period = ( 1 * 60 * 60 );
         
         break;
         
      //--- Four Hour
      case H4:
         
         select_trading_period = ( 4 * 60 * 60 );
         
         break;
         
      //--- Six Hour
      case H6:
         
         select_trading_period = ( 6 * 60 * 60 );
   
   }

   //--- Set order magic number for using in calculate trading lots size
   switch(MM_Type)
   {
      //--- Martingle We count loss base on market order only order number 1
      case Martingle:
         
         order_magic_number = 1;
         
         break;
         
      //--- Other case order number is null
      default:
         
         order_magic_number = NULL;
         
         break;

   }
      
   //--- Set Seed from Random number
   switch(Optimization)
   {
      //--- In case of optimization, use seed number to optimization
      case true:
         
         MathSrand(Optimization_Round);
         
         break;
      
      //--- In case of not optimization, use get tick count for set seed 
      case false:
      
         MathSrand(GetTickCount64());
         
         break;
   }
   
   //--- Set Timer
   EventSetTimer(select_trading_period);
   
   //--- Print Start Time when EA is initialized
   Print("Initial Time \n" + datetime_str );
   
   //--- Get symbol information
   max_volume = SymbolInfoDouble( _Symbol, SYMBOL_VOLUME_MAX );
   
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
   //| Trigger Point                                                    |
   //+------------------------------------------------------------------+
   
   //--- Last tick meet trigger point
   if( last_tick.last == trigger_price )
   {
   
      //--- modify position
      modify_position(_Symbol, NULL, mod_sl_price, tp_price, true);
      
      //---
      trigger_price = NULL;
   
   }
      
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
   
   //--- Get Trade Random Number
   trade_random_number = ( double( MathRand() ) / (double) max_random ) * 100;
   
   //--- Get Trade Side Random Number
   trade_side_random_number = ( double( MathRand() ) / (double) max_random ) * 100;
   
   //+------------------------------------------------------------------+
   //| Generate Trading Condition                                       |
   //+------------------------------------------------------------------+
   
   //--- Create Trading or Not Condition
   trade_cond_1 = (trade_random_number < trade_prob[Trading_Period]) ? true : false ;
   
   //--- Create Trading Condition
   buy_cond_1 = ( trade_side_random_number > 50 );
   sell_cond_1 = ( trade_side_random_number <= 50 );

   //Print("Trade Random Number : " + IntegerToString(trade_random_number));
   //Print("Trade Condition : " + trade_cond_1);
   
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
   //| Check Total Order Position                                     |
   //+------------------------------------------------------------------+
   
   //--- Get total product position
   product_order = total_symbol_order(_Symbol, NULL, false);
   
   //--- Create Product Position Condition
   if(product_order < Max_Order)
   {
   
      //--- Allow trade if there is no position
      order_condition = true;
   
   }
   else
   {
   
      //--- Do not trade if there are some position
      order_condition = false; 
   
   }
   
   //+------------------------------------------------------------------+
   //| Money Management for Position Sizing                             |
   //+------------------------------------------------------------------+
   
   //--- Get total product position
   position_size = mm_lots_multi_orders(MM_Type, Start_Lots, _Symbol, Look_Back_Period, order_magic_number, RR_Ratio, SL_Point, Fix_Profit_USD, Step_Profit_USD, false);
   
   //--- In case of split order
   position_size = NormalizeDouble( MathMax( position_size / ( Max_Position + Max_Order ), 0.01 ), 2);
   
   //--- Max position size at product maximum position size
   position_size = MathMin( position_size, max_volume );
   
   //Print("Max Position Size : " + DoubleToString(max_volume) );
   
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
   if( ( trade_cond_1 ) && (buy_cond_1) && (Allow_Send_Order) && (position_condition) && (order_condition) )
   {
   
      //--- Calculate Stop Loss Point
      sl_point_value =  stop_loss_point(1, SL_Point, _Symbol, Look_Back_Period, NULL, true);
      
      //-- Calculate Stop Loss and Target Profit Price for Market Order
      sl_price = NormalizeDouble( last_tick.ask - ( sl_point_value * _Point ), _Digits );
      tp_price = NormalizeDouble( last_tick.ask + ( RR_Ratio * ( sl_point_value * _Point ) ), _Digits );
      
      //--- Generate Trigger Price for Trailing Stop (Half of RR Ratio)
      trigger_price = NormalizeDouble( last_tick.ask + ( ( RR_Ratio / 2 ) * ( sl_point_value * _Point ) ), _Digits );
      
      //--- Generate nodify stop loss price
      mod_sl_price = last_tick.ask;

      //--- Calculate Limit Order Price
      limit_order_price = NormalizeDouble( last_tick.ask - ( ( sl_point_value / Range_from_Market_Order ) * _Point ), _Digits );;

      //--- Send market order and assign magic number as 1
      trade.SetExpertMagicNumber(market_order);
      trade.Buy(position_size, NULL, last_tick.ask, sl_price, tp_price );
      Print(trade.ResultRetcodeDescription());
      
      //--- Send limit order and assign magic number as 2
      trade.SetExpertMagicNumber(limit_order);
      trade.BuyLimit(position_size, limit_order_price, NULL, sl_price, tp_price );
      Print(trade.ResultRetcodeDescription());

   }
   
   //--- Sell Condition
   if( ( trade_cond_1 ) && ( sell_cond_1 ) && (Allow_Send_Order) && (position_condition) && (order_condition) )
   {
   
      //--- Calculate Stop Loss Point
      sl_point_value =  stop_loss_point(1, SL_Point, _Symbol, Look_Back_Period, NULL, true);
      
      //-- Calculate Stop Loss and Target Profit Price for Market Order
      sl_price = NormalizeDouble( last_tick.bid + ( sl_point_value * _Point ), _Digits );
      tp_price = NormalizeDouble( last_tick.bid - ( RR_Ratio * ( sl_point_value * _Point ) ), _Digits );
      
      //--- Generate Trigger Price for Trailing Stop (Half of RR Ratio)
      trigger_price = NormalizeDouble( last_tick.bid - ( ( RR_Ratio / 2 ) * ( sl_point_value * _Point ) ), _Digits );
      
      //--- Generate nodify stop loss price
      mod_sl_price = last_tick.bid;
      
      //--- Calculate Limit Order Price
      limit_order_price = NormalizeDouble( last_tick.bid + ( ( sl_point_value / Range_from_Market_Order ) * _Point ), _Digits );

      //--- Sending Market Order
      trade.SetExpertMagicNumber(market_order);
      trade.Sell(position_size, NULL, last_tick.bid, sl_price, tp_price );
      Print(trade.ResultRetcodeDescription());
      
      //--- Sending Limit Order
      trade.SetExpertMagicNumber(limit_order);
      trade.SellLimit(position_size, limit_order_price, NULL, sl_price, tp_price );
      Print(trade.ResultRetcodeDescription());

   }
   
}

//+------------------------------------------------------------------+
//| Get test result function                                         |
//+------------------------------------------------------------------+
double OnTester()
   {
   
      //--- Get maximum balance
      return( max_balance(false) );
   
   }
