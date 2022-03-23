//+------------------------------------------------------------------+
//|                                         Breakout_V1_20220131.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description " Only Long Breakout EA "

//+------------------------------------------------------------------+
//|Input parameters                                                  |
//+------------------------------------------------------------------+

input double      Lots                    =  0.01;
input int         HHV_Period              =  15;
input int         LLV_Period              =  15;
input bool        Allow_Send_Order        =  false;


//+------------------------------------------------------------------+
//| Global Variable                                                  |
//+------------------------------------------------------------------+
int      magic_number = 20220131;
string   datetime_str = TimeToString(TimeCurrent(), TIME_SECONDS);
double   high  = iHigh( _Symbol, PERIOD_CURRENT, 0);

//+------------------------------------------------------------------+
//|Declare parameters                                                |
//+------------------------------------------------------------------+

double   HHV;
double   HHV_array[];
int      HHV_array_count;
int      HHV_index;
double   LLV;
double   LLV_array[];
int      LLV_index;
int      LLV_array_count;

int      i;
int      total_position;
string   position_symbol;
bool     position_condition = true;

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
         
      //--- Generate High of Bar Series start from previous bar
      ArraySetAsSeries(HHV_array,true);
      HHV_array_count = CopyHigh(_Symbol, PERIOD_CURRENT, 0, HHV_Period, HHV_array);
      
      if(HHV_array_count != -1)
         {
         
            //PrintFormat("CopyHigh() call pass");
         
         }
         
      else
         {
         
            PrintFormat("CopyHigh() call error. Error code=%d",GetLastError());
            return;
         }
         
      //--- Generate Highest High Value start from previous bar
      HHV_index = iHighest( _Symbol, PERIOD_CURRENT, MODE_HIGH, HHV_Period - 1, 1 );
      
      if(HHV_index != 0)
      
         {
         
            HHV = HHV_array[HHV_index];
            
         }
         
      else
         {
         
            PrintFormat("iHighest() call error. Error code=%d",GetLastError());
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
         
      //--- Test Print
      Print("The Highest High Index is " + IntegerToString(HHV_index) );
      Print("The Highest High Value is " + DoubleToString(HHV) );
      //Print( "Last Bid Price: " + DoubleToString( last_tick.bid ) );
      
      //+------------------------------------------------------------------+
      //| Generate Trading Condition                                       |
      //+------------------------------------------------------------------+
      
      //--- Create Buy Condition
      buy_cond_1 = ( last_bar_value[0].high > HHV );
      
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

            trade_request.action = TRADE_ACTION_DEAL;                                 // immediate order execution
            trade_request.price = NormalizeDouble(last_tick.ask, _Digits);           // latest Bid price
            trade_request.sl = NormalizeDouble(last_tick.ask - 20*_Point,_Digits);     // Stop Loss
            trade_request.tp = NormalizeDouble(last_tick.ask + 30*_Point,_Digits);     // Take Profit
            trade_request.symbol = _Symbol;                                           // currency pair
            trade_request.volume = 0.1;                                               // number of lots to trade
            trade_request.magic = magic_number;                                       // Order Magic Number
            trade_request.type= ORDER_TYPE_BUY;                                     // Sell Order
            trade_request.type_filling = ORDER_FILLING_IOC;                          // Order execution type
            trade_request.deviation=10;                                           // Deviation from current price
            
            Print( "In Trade Condition" );
            
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
