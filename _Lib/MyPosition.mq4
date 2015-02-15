//+------------------------------------------------------------------+
//|                                                  GetPosition.mq4 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
#property library

#include "..\MyInclude\Define.mqh"


// SendPositionRequest
void SendPositionRequest(double mLot = 0, int amount = ALL)
{
   if (mLot == 0){
      int property;
      double lot;
   
      property = AccountFreeMargin();
      lot = (property * LEVERAGE) / ((Close[0] + 1) * LOTBY * amount);
   }
   else {
      lot = mLot;
   }
   
   if (OrdersTotal() == 0){
      OrderSend(Symbol(), OP_BUY, lot, Ask, 3, 0, 0, "Buy", 10, 0, Red);
   }
}

// GetPosition
void GetPositionBUY(double mLot = 0, int amount = ALL)
{
   if (mLot == 0){
      int property;
      double lot;
   
      property = AccountFreeMargin();
      lot = (property * LEVERAGE) / ((Close[0] + 1) * LOTBY * amount);
   }
   else {
      lot = mLot;
   }
   
   if (OrdersTotal() == 0){
      OrderSend(Symbol(), OP_BUY, lot, Ask, 3, 0, 0, "Buy", 10, 0, Red);
   }
}

void GetPositionSELL(double mLot = 0, int amount = ALL)
{
   if (mLot == 0){
      int property;
      double lot;
   
      property = AccountFreeMargin();
      lot = (property * LEVERAGE) / ((Close[0] + 1) * LOTBY * amount);
   }
   else {
      lot = mLot;
   }
   
   if (OrdersTotal() == 0){
      OrderSend(Symbol(), OP_SELL, lot, Bid, 3, 0, 0, "Sell", 10, 0, Blue);
   }
}


void MyOrderClose()
{
   int myOrderType;
   
   if (OrdersTotal() > 0){
      if (OrderSelect(0, SELECT_BY_POS) == true){
         myOrderType = OrderType();
      
         switch (myOrderType){
         case OP_BUY:
         case OP_BUYLIMIT:
         case OP_BUYSTOP:
            OrderClose(OrderTicket(), OrderLots(), Bid, 3, Yellow);
            break;
            
         case OP_SELL:
         case OP_SELLLIMIT:
         case OP_SELLSTOP:
            OrderClose(OrderTicket(), OrderLots(), Ask, 3, Green);
            break;
         }
      }
   }
}

int Emergency(int pips = CLOSE_PIPS)
{
   if (OrderSelect(0, SELECT_BY_POS) == true){
      if (OrderProfit() < (OrderLots() * pips)){
         MyOrderClose();
         return (true);
      }
   }
   return (false);
}



