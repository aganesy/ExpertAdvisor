//+------------------------------------------------------------------+
//|                                                    OrderType.mq4 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
#property library

#include "..\MyInclude\Define.mqh"

// OrderType
int MyOderType()
{
   int type;
   int myOrder;
   
   type = OrderType();
   
   if (OrdersTotal() > 0){
      if (OrderSelect(0, SELECT_BY_POS) == true){
         switch (type){
         case OP_BUY:
         case OP_BUYLIMIT:
         case OP_BUYSTOP:
            myOrder = BUYS;
            break;
      
         case OP_SELL:
         case OP_SELLLIMIT:
         case OP_SELLSTOP:
            myOrder = SELLS;
            break;
         }
      }
   }
   else {
      myOrder = NON_ORDER;
   }
   
   return (myOrder);
}





