//+------------------------------------------------------------------+
//|                                                         Test.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

//--- input parameters
input double Lots                   =  0.1;
input int    MovingPeriod           =  3;
input int    MovingShift            =  0;
input double Price_Rate             =  1.17000;
input bool    Allow_Send_Order      =  false;

//--- Declare parameters
int      maHandle;
double   maVal[];
double   p_close;
int      buy_position;

//+------------------------------------------------------------------+
//| Global Variable                                                  |
//+------------------------------------------------------------------+
int      magic_number = 111111;
string   datetime_str = TimeToString(TimeCurrent(), TIME_SECONDS);


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

      //--- Generate Start Time
      datetime_str = TimeToString(TimeCurrent(), TIME_SECONDS);
      Print("Initial Time \n" + datetime_str );
      
      //--- Get the handle for Moving Average indicator
      maHandle=iMA(_Symbol,_Period,MovingPeriod,MovingShift,MODE_SMA,PRICE_CLOSE);
      
      //--- What if handle returns Invalid Handle
      if(maHandle<0)
        {
            Alert("Error Creating Handles for indicators - error: ",GetLastError(),"!!");
        }
      
      //--- Set new position
      buy_position = 0;
      
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
      //--- 
      Print("Deintial Time \n" + datetime_str );
      IndicatorRelease(maHandle);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
      
      //--- Declare Variable
      MqlTick latest_tick;
      MqlRates mrate[];
      MqlTradeRequest mrequest;
      MqlTradeResult mresult;
      ZeroMemory(mrequest);
      bool buy_cond_1, buy_cond_2;
      
      
      //--- Set Array as Series
      ArraySetAsSeries(maVal,true);
      ArraySetAsSeries(mrate,true);
      
      //--- Collect Indicator Value to Array
      if(CopyBuffer(maHandle,0,0,3,maVal)<0)
         {
            Alert("Error copying Moving Average indicator buffer - error:",GetLastError());
            return;
         }
      else
         {
            Print( "Successful Create Indicator Data \n With Latest Value: " + DoubleToString(maVal[0]) );
         }
   
      //--- Copy Last OHLC
      if(CopyRates(_Symbol,_Period,0,3,mrate)<0)
         {
            Alert("Error copying rates/history data - error:",GetLastError(),"!!");
            return;
         }
      else
         {
            Print( "Successful Create Last Price Data \n With Latest Value: " + DoubleToString(mrate[0].close) );
         }
      
      //--- Copy Last Tick
      if( SymbolInfoTick(Symbol(), latest_tick) )
         {
            //--- Last Bid Price
            Print( "Last Bid Price: " + DoubleToString( latest_tick.bid ) );
         }

      //--- Create Buy Sell Condition
      buy_cond_1 = ( mrate[0].close >= Price_Rate );
      buy_cond_2 = ( buy_position == 0 );
      
      //--- Sending Order
      if( ( buy_cond_1 ) && ( buy_cond_2 ) && (Allow_Send_Order) )
         {
            mrequest.action = TRADE_ACTION_DEAL;                                 // immediate order execution
            mrequest.price = NormalizeDouble(latest_tick.bid, _Digits);           // latest Bid price
            //mrequest.sl = NormalizeDouble(SYMBOL_BID + 20*_Point,_Digits);     // Stop Loss
            //mrequest.tp = NormalizeDouble(SYMBOL_BID - 20*_Point,_Digits);     // Take Profit
            mrequest.symbol = _Symbol;                                           // currency pair
            mrequest.volume = 0.1;                                               // number of lots to trade
            mrequest.magic = magic_number;                                       // Order Magic Number
            mrequest.type= ORDER_TYPE_SELL;                                     // Sell Order
            mrequest.type_filling = ORDER_FILLING_IOC;                          // Order execution type
            mrequest.deviation=10;                                           // Deviation from current price
            
            Print( "Buy Position" + IntegerToString(buy_position) );
            Print( "In Trade Condition" );
            
            //--- send order
            if(OrderSend(mrequest,mresult))
            {
            
               Print(mresult.retcode);
               
               Alert("A Buy order has been successfully placed with Ticket#:",mresult.order,"!!");
                  
               //--- Create Portfolio Oder Count
               buy_position++;
               
               Print( "Buy Position" + IntegerToString(buy_position) );
               
               return;
                 
            }
            else
              {
               Alert("The Buy order request could not be completed -error:",GetLastError());
               Print(mresult.retcode);
               ResetLastError();           
               return;
              }
              
         }
         
  }
//+------------------------------------------------------------------+