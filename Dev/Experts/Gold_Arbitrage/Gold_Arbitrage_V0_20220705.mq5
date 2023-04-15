//+------------------------------------------------------------------+
//|                                           Random_V3_20220224.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property script_show_inputs

//+------------------------------------------------------------------+
//|Import Function                                                   |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include <Cactus_Capital_Trading\Trade_Function\Position_Count.mqh>
#include <Cactus_Capital_Trading\Trade_Function\Position_Close_All.mqh>
//+------------------------------------------------------------------+
//|Input parameters                                                  |
//+------------------------------------------------------------------+

input string   Spot_Product;
input string   Future_Product;
input double   Position_Size;
input int      Max_Position;
input bool     Allow_Short_Spread;
input bool     Allow_Long_Spread;
input double   Noise_Open_Short_Spread;
input double   Noise_Close_Short_Spread;
input double   Noise_Open_Long_Spread;
input double   Noise_Close_Long_Spread;
input bool     Alert_Function;

//+------------------------------------------------------------------+
//| Global Variable                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Declare Variable                                                 |
//+------------------------------------------------------------------+

string      product_list[2] = {Spot_Product, Future_Product};
bool        spot_check;
bool        future_check;
double      short_spread;
double      long_spread;
MqlRates    last_bar_spot[];
MqlRates    last_bar_future[];
double      previous_spot_open;
double      previous_spot_close;
double      previous_future_open;
double      previous_future_close;
double      previous_spread_open;
double      previous_spread_close;
double      proxy_spread;
double      expected_spread;
MqlTick     last_tick_spot;
MqlTick     last_tick_future;
bool        open_short_cond_1;
bool        close_short_cond_1;
bool        open_long_cond_1;
bool        close_long_cond_1;
int         spot_position;
int         future_position;   
double      position_condition;

CTrade   trade;
int      deviation      =  30;
string   trade_comment;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   
   return(INIT_SUCCEEDED);
   
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{

   
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
   spot_check = SymbolInfoTick(product_list[0], last_tick_spot);
   future_check = SymbolInfoTick(product_list[1], last_tick_future);
   
   if( spot_check == false | future_check == false )
      {
      
         PrintFormat("SymbolInfoTick() call error. Error code=%d",GetLastError());
         return;
          
      }
      
   //+------------------------------------------------------------------+
   //| Generate Trading Model                                           |
   //+------------------------------------------------------------------+
   
   //--- Generate previous bar data of spot and future
   if(CopyRates(product_list[0], PERIOD_D1, 1, 1, last_bar_spot) < 0)
      {
      
         Alert("Error copying spot rates/history data - error:",GetLastError(),"!!");
         return;
         
      }
      
    if(CopyRates(product_list[1], PERIOD_D1, 1, 1, last_bar_future) < 0)
      {
      
         Alert("Error copying future rates/history data - error:",GetLastError(),"!!");
         return;
         
      }
      
    //--- Calculated open and close spread
    previous_spread_open = last_bar_future[0].open - last_bar_spot[0].open ;
    previous_spread_close = last_bar_future[0].close - last_bar_spot[0].close; 
    
    //--- Calculate proxy spread
    proxy_spread = (previous_spread_open + previous_spread_close) / 2;
    
    //--- Calculate expected spread
    expected_spread = 0.95 * proxy_spread;
      
   //+------------------------------------------------------------------+
   //| Generate Trading Condition                                       |
   //+------------------------------------------------------------------+
   
   //--- Create Spread 
   
   //--- Future Value > Spot Value
   //--- Short Spread = Short Future at bid and Long Spot at ask
   short_spread = last_tick_future.bid - last_tick_spot.ask;
   
   //--- Long Spread = Long Future at ask and Short Spot at bid
   long_spread = last_tick_future.ask - last_tick_spot.bid;
   
   //--- Create Short Spread Trading Condition
   if(short_spread > (expected_spread + Noise_Open_Short_Spread) )
   {
   
      open_short_cond_1 = true;
   
   }
   else
   {
      
      open_short_cond_1 = false;
   
   }
   
   if(long_spread < (expected_spread - Noise_Close_Short_Spread) )
   {
   
      close_short_cond_1 = true;
   
   }
   else
   {
   
      close_short_cond_1 = false;
      
   }
   
   //--- Create Long Spread Trading Condition
   if(long_spread < (expected_spread - Noise_Open_Long_Spread) )
   {
   
      open_long_cond_1 = true;
   
   }
   else
   {
      
      open_long_cond_1 = false;
   
   }
   
   if(short_spread > (expected_spread + Noise_Close_Long_Spread) )
   {
   
      close_long_cond_1 = true;
   
   }
   else
   {
   
      close_long_cond_1 = false;
      
   }
   
   //+------------------------------------------------------------------+
   //| Check Total Product Position                                     |
   //+------------------------------------------------------------------+
   
   //--- Get total product position
   spot_position = total_symbol_position(product_list[0], NULL, false);
   future_position = total_symbol_position(product_list[1], NULL, false);
   
   //--- Create Product Position Condition
   if( ( spot_position < Max_Position ) && ( future_position < Max_Position ) )
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
   trade.SetDeviationInPoints(deviation);      
   trade.SetTypeFilling(ORDER_FILLING_RETURN);
   trade.SetAsyncMode(false);
   
   //--- Open Short Spread
   if( open_short_cond_1 && position_condition && Allow_Short_Spread )
   {       

      //--- Set magic number
      trade.SetExpertMagicNumber(1);
      
      //--- Create Comment
      trade_comment = "Short Spread at " + DoubleToString(short_spread);
      
      //--- Short Spread parameter
      if(!trade.Buy(Position_Size, product_list[0], last_tick_spot.ask, 0, 0, trade_comment) | !trade.Sell(Position_Size, product_list[1], last_tick_future.bid, 0, 0, trade_comment) )
      {
      //--- failure message
      Print("Open Short Spread method failed. Return code=",trade.ResultRetcode(),
            ". Code description: ",trade.ResultRetcodeDescription());
      }
      
      else
      {
      Print("Open Short Spread method executed successfully. Return code=",trade.ResultRetcode(),
            " (",trade.ResultRetcodeDescription(),")");
      }
      
      //--- Alert message
      if(Alert_Function)
      {
         
         //--- Send Notification
         SendNotification(trade_comment);
      
      }
      

   }
   
   //--- Close Short Spread
   if( close_short_cond_1 && (spot_position != 0) && (future_position != 0) )
   {       

      //--- Close Position
      symbol_all_position_close(product_list[0], 1, false);
      symbol_all_position_close(product_list[1], 1, false);
      
      //--- Alert message
      if(Alert_Function)
      {
      
         //--- Create Comment
         trade_comment = "Close Short Spread at " + DoubleToString(long_spread);
         
         //--- Send Notification
         SendNotification(trade_comment);
      
      }

   }

   //--- Open Long Spread
   if( open_long_cond_1 && position_condition && Allow_Long_Spread )
   {       

      //--- Set magic number
      trade.SetExpertMagicNumber(2);

      //--- Create Comment
      trade_comment = "Long Spread at " + DoubleToString(long_spread);
      
      //--- Short Spread parameter
      if(!trade.Buy(Position_Size, product_list[1], last_tick_future.ask, 0, 0, trade_comment) | !trade.Sell(Position_Size, product_list[0], last_tick_spot.bid, 0, 0, trade_comment) )
      {
      //--- failure message
      Print("Open Long Spread method failed. Return code=",trade.ResultRetcode(),
            ". Code description: ",trade.ResultRetcodeDescription());
      }
      
      else
      {
      Print("Open Long Spread method executed successfully. Return code=",trade.ResultRetcode(),
            " (",trade.ResultRetcodeDescription(),")");
      }
      
      //--- Alert message
      if(Alert_Function)
      {
         
         //--- Send Notification
         SendNotification(trade_comment);
      
      }

   }
   
   //--- Close Short Spread
   if( close_long_cond_1 && (spot_position != 0) && (future_position != 0) )
   {       

      //--- Close Position
      symbol_all_position_close(product_list[0], 2, false);
      symbol_all_position_close(product_list[1], 2, false);

      //--- Alert message
      if(Alert_Function)
      {
      
         //--- Create Comment
         trade_comment = "Close Long Spread at " + DoubleToString(short_spread);
         
         //--- Send Notification
         SendNotification(trade_comment);
      
      }
      
   }
   
  }