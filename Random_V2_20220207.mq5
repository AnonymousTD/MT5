//+------------------------------------------------------------------+
//|                                         Breakout_V1_20220131.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description " Only Long Breakout EA "

#define max_random   32767

//+------------------------------------------------------------------+
//|Input parameters                                                  |
//+------------------------------------------------------------------+

input double      Lots                    =  0.01;
input int         RR_Ratio                =  2;
input double      SL_percent              =  15.00;
input bool        Allow_Send_Order        =  false;

//+------------------------------------------------------------------+
//| Global Variable                                                  |
//+------------------------------------------------------------------+
int      magic_number = 20220203;
string   datetime_str = TimeToString(TimeCurrent(), TIME_SECONDS);

//+------------------------------------------------------------------+
//|Declare parameters                                                |
//+------------------------------------------------------------------+

double   random_number;
int      i;
int      total_position;
string   position_symbol;
bool     position_condition = true;
double   sl_price;
double   tp_price;

string   product_array[1] = {"EURUSD.a"};
int      product_position[1] = {0};

bool     last_tick_check;
bool     buy_cond_1;


MqlRates last_bar_value[];
MqlTick last_tick;
MqlTradeRequest trade_request;
MqlTradeResult trade_result;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
      //--- Generate Start Time
      datetime_str = TimeToString(TimeCurrent(), TIME_SECONDS);
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
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
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
      else
         {
         
            //Print( "Successful Create Last Price Data \n With Latest Value: " + DoubleToString(last_bar_value[0].high) );
            
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

      //--- Test Print
      //Print( "Last Bid Price: " + DoubleToString( last_tick.bid ) );
      Print("Random Number : " + DoubleToString(random_number) );
      
      //+------------------------------------------------------------------+
      //| Generate Trading Condition                                       |
      //+------------------------------------------------------------------+
      
      //--- Create Buy Condition
      buy_cond_1 = ( random_number > 50 );
      
      Print( "Buy Con " + IntegerToString(buy_cond_1) );
      
      //+------------------------------------------------------------------+
      //| Check Portfolio Position                                         |
      //+------------------------------------------------------------------+
      
      //--- Check Total Position
      total_position = PositionsTotal();
      
      for( i = 0; i <= total_position-1; i++)
      {
         position_symbol = PositionGetSymbol(i);
         
         if ( ( position_symbol == product_array[0] ) && ( PositionGetInteger(POSITION_MAGIC) == magic_number ) )
         
            {
            
               product_position[0]++;
               
            }
      
      }
      
      //--- In casr that already trade in that product
      if( product_position[0] > 0 )
         {
            
            //--- Not allow to trade
            position_condition = false;
            
            //--- Reset product position
            product_position[0] = 0;
      
         }
         
      else
         {
         
            position_condition = true;
         
         }
      
      Print( "Position Con " + IntegerToString(position_condition) );
      
      //+------------------------------------------------------------------+
      //| Generate Trading                                                 |
      //+------------------------------------------------------------------+
            
      if( ( buy_cond_1 ) && (Allow_Send_Order) && (position_condition) )
      //if( (Allow_Send_Order) && (position_condition) )
      
         {

            //-- Calculate Stop Loss and Target Profit Price
            sl_price = NormalizeDouble( last_tick.ask * ( 1 - ( SL_percent / 100 ) ), _Digits );
            tp_price = NormalizeDouble( last_tick.ask * ( 1 + RR_Ratio * ( SL_percent / 100 ) ), _Digits );
            
            trade_request.action = TRADE_ACTION_DEAL;                                                 // immediate order execution
            trade_request.price = NormalizeDouble(last_tick.ask, _Digits);                            // latest Bid price
            trade_request.sl = sl_price;                                                              // Stop Loss
            trade_request.tp = tp_price;                                                              // Take Profit
            trade_request.symbol = _Symbol;                                                           // currency pair
            trade_request.volume = 0.1;                                                               // number of lots to trade
            trade_request.magic = magic_number;                                                       // Order Magic Number
            trade_request.type= ORDER_TYPE_BUY;                                                       // Sell Order
            trade_request.type_filling = ORDER_FILLING_IOC;                                           // Order execution type
            trade_request.deviation=10;                                                               // Deviation from current price
            
            Print( "SL : " + DoubleToString(sl_price) + " TP : " + DoubleToString(sl_price * RR_Ratio) );
            
            //--- send order
            if(OrderSend(trade_request, trade_result))
            {
            
               Print(trade_result.retcode);
               
               Alert("A Buy order has been successfully placed with Ticket#:",trade_result.order,"!!");
                  
               return;
                 
            }
            
            else
              {
               Alert("The Buy order request could not be completed -error:",GetLastError());
               Print(trade_result.retcode);
               ResetLastError();           
               return;
              }

         }
      
  }
//+------------------------------------------------------------------+