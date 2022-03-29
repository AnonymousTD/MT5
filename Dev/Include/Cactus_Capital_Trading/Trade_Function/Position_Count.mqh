//+------------------------------------------------------------------+
//|                                               Position_Count.mqh |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//| Count Position in that symbol and magic number                   |
//+------------------------------------------------------------------+

int total_symbol_position(const string symbol,const int magic_number, bool print_mode = true )
   {
      //--- Declare parameter
      int      total_position;
      string   position_symbol;
      int      i;
      int      product_position = 0;
      
      //--- Check Total Position
      total_position = PositionsTotal();
      
      //--- Loop through all position
      for( i = 0; i <= total_position-1; i++)
      {
      
         //--- Get position symbol by using index
         position_symbol = PositionGetSymbol(i);
         
         //--- In case of not know magic number
         if (magic_number != NULL)
         {
         
            //--- If position symbol is open then sum up
            if ( ( position_symbol == symbol ) && ( PositionGetInteger(POSITION_MAGIC) == magic_number ) )
         
            {
            
               product_position++;
               
            }
            
         }
        
        //--- If magic number is not know
        if (magic_number == NULL)
        {
        
            //--- If position symbol is open then sum up
            if ( position_symbol == symbol )
            {
            
               product_position++;
               
            }
            
        }
        
      }
      
      if( print_mode == true )
      {  
         //--- Print 
         //--- In case that already trade in that product
         if( product_position > 0 )
            {
               
               Print("Products : " + symbol + " has " + IntegerToString(product_position) + " position");
            }
            
         else
            {
            
               Print("No position on " + symbol);
            
            }
            
      }
      
      return(product_position);     
      
   }