//+------------------------------------------------------------------+
//|                                                         Test.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//--- input parameters
input double Lots = 0.1;
input int    MovingPeriod  =3;
input int    MovingShift   =0;
input int    Test = 10;

int maHandle;
double maVal[];
double p_close;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

      string datetime_str = TimeToString(TimeCurrent(), TIME_SECONDS);
      Print("Hello World \n" + datetime_str );
      
      //--- Get the handle for Moving Average indicator
      maHandle=iMA(_Symbol,_Period,MovingPeriod,MovingShift,MODE_SMA,PRICE_CLOSE);
      
      //--- What if handle returns Invalid Handle
      if(maHandle<0)
        {
            Alert("Error Creating Handles for indicators - error: ",GetLastError(),"!!");
        }
      
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
      Print("Goodbye World");
      IndicatorRelease(maHandle);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
      
      //--- Declare Variable
      //double ma;
      //datetime current;
      //bool check, check_2;
      //int ticket;
      bool buy_cond_1;
      
      
      //--- Create Indicator
      //ma=iMA( Symbol(),PERIOD_CURRENT,MovingPeriod,MovingShift,MODE_SMA,PRICE_CLOSE);
      
      MqlTick latest_price;
      MqlRates mrate[];
      MqlTradeRequest mrequest;
      MqlTradeResult mresult;
      ZeroMemory(mrequest);
      
      //--- Get Technical Indicator 
      ArraySetAsSeries(maVal,true);
      ArraySetAsSeries(mrate,true);
      
      if(CopyBuffer(maHandle,0,0,3,maVal)>0)
         {
            int Size=ArraySize(maVal);
            Print( DoubleToString(maVal[0]) );
            Print( IntegerToString(Size) );
         }
      else
         {
            Alert("Error copying Moving Average indicator buffer - error:",GetLastError());
            return;
         }
   
      if(CopyRates(_Symbol,_Period,0,3,mrate)<0)
      
         {
            Alert("Error copying rates/history data - error:",GetLastError(),"!!");
            return;
         }
        
      Print( "Close" + mrate[0].close );
      Print( "Last" + latest_price.bid );
      Print( "normalize" + NormalizeDouble(7.88889,4) );
      Print( "Last" + NormalizeDouble(SymbolInfoDouble(Symbol(),SYMBOL_BID),5) );
      Print(_Symbol);
      buy_cond_1 = ( mrate[0].close >= 1.14000 );
      
      if(buy_cond_1)
         Print(" In Cond ");
         {
            mrequest.action = TRADE_ACTION_DEAL;                                 // immediate order execution
            //mrequest.price = SymbolInfoDouble(Symbol(),SYMBOL_BID);
            mrequest.price = NormalizeDouble(SYMBOL_BID,_Digits);          // latest Bid price
            //mrequest.sl = NormalizeDouble(SYMBOL_BID + 20*_Point,_Digits); // Stop Loss
            //mrequest.tp = NormalizeDouble(SYMBOL_BID - 20*_Point,_Digits); // Take Profit
            mrequest.symbol = _Symbol;                                         // currency pair
            mrequest.volume = 0.1;                                            // number of lots to trade
            mrequest.magic = 123456;                                        // Order Magic Number
            mrequest.type= ORDER_TYPE_SELL;                                     // Sell Order
            mrequest.type_filling = ORDER_FILLING_IOC;                          // Order execution type
            mrequest.deviation=10;                                           // Deviation from current price
            //--- send order
            OrderSend(mrequest,mresult);
            
            Print(mresult.retcode);
            
            // get the result code
            if(mresult.retcode==10009 || mresult.retcode==10008) //Request is completed or order placed
              {
               Alert("A Buy order has been successfully placed with Ticket#:",mresult.order,"!!");
              }
            else
              {
               Alert("The Buy order request could not be completed -error:",GetLastError());
               ResetLastError();           
               return;
              }
              
         }
         
  }
//+------------------------------------------------------------------+