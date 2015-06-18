//+------------------------------------------------------------------+
//|                                                  GetPosition.mq4 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
#property library

#include "..\_Include\Define.mqh"


// SendPositionRequest
void SendPositionRequest(int cmd, double mLot = 0, double sl = 0, double tp = 0, int amount = ALL)
{
	int price = 0;
	switch (cmd){
	case OP_BUY:
	case OP_BUYSTOP:
	case OP_BUYLIMIT:
		price = Ask;
	break;
	
	case OP_SELL:
	case OP_SELLSTOP:
	case OP_SELLLIMIT:
		price = Bid;
	break;
	}
	
	if (mLot == 0){
		int property;
		double lot;
		
		property = AccountFreeMargin();
		lot = (property * MAX_LEVERAGE) / (price * LOTBY * amount);
	}
	else {
		lot = mLot;
	}
	
	if (OrdersTotal() == 0){
		OrderSend(Symbol(), OP_BUY, lot, price, 3, sl, tp, "Buy", 10, 0, Black);
	}
}

// GetPosition
void GetPositionBUY(double mLot = 0, int amount = ALL)
{
   if (mLot == 0){
      int property;
      double lot;
   
      property = AccountFreeMargin();
      lot = (property * MAX_LEVERAGE) / (Ask * LOTBY * amount);
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
      lot = (property * MAX_LEVERAGE) / (Bid * LOTBY * amount);
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

bool EmergencyLoss(int index = 0, int select = SELECT_BY_POS, int pips = 200)
{
	bool bResult = false;

	if (OrderSelect(index, select) == true){
		if (OrderProfit() < (OrderLots() * pips - 1)){
			MyOrderClose();
			bResult = true;
		}
	}
	
	return bResult;
}

bool EmergencyTime(int index = 0, int select = SELECT_BY_POS, int pips = 200)
{
	bool bResult = false;

	if (OrderSelect(index, select) == true){
		if (OrderProfit() < (OrderLots() * pips)){
			MyOrderClose();
			bResult = true;
		}
	}
	
	return bResult;
}



