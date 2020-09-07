//+------------------------------------------------------------------+
//|                                                    TestEA001.mq4 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

// MyInclude
#include "MyInclude\Define.mqh"


// MyLib
#import "MyLib\BollingerBands.ex4"
   int BandsExValue(int deviation = 2);
   
#import "MyLib\ParabolicSAR.ex4"
   int IsParabolic(double SAR_Maximum=0.2, double SAR_Step=0.02);
   int ParabolicObserverBack(double SAR_Maximum=0.2, double SAR_Step=0.02);
   
#import "MyLib\RSI.ex4"
   int RSIExValue(int n = 0);
   
#import "MyLib\CCI.ex4"
   int IsCCI(int n, int period = 14);
   
#import "MyLib\TripleWindow.ex4"
   int TripleWindow();
   
#import "MYLib\HeikinAshi.ex4"
   double HeikinAshiOpen(int n = 0);
   double HeikinAshiClose(int n = 0);
   double HeikinAshiDiff(int n = 0);
   
#import "MyLib\MyPosition.ex4"
   void GetPositionAsk();
   void GetPositionBid();
   void MyOrderClose();
   void Emergency(int pips = CLOSE_PIPS);


#define RSI_NICE_CLOSE_PIPS    30
#define RSI_BAD_CLOSE_PIPS    -40


//---- input parameters

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----
   //bool window_flag = false;
   
//----
   return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
   double heikinashiDiff;
   
   //----
   
   Emergency(-40);
   
   
   if (OrdersTotal() == 0){
      //if (-0.003 <= heikinashiDiff && heikinashiDiff <= 0.003){
         if (RSIExValue(1) <= -15 && RSIExValue(0) <= -8/* && RSIExValue(1) > RSIExValue(0)*/){
            if (HeikinAshiOpen(1) > HeikinAshiClose(1) && HeikinAshiOpen(0) < HeikinAshiClose(0)){
               GetPositionAsk();
            }
         }
         if (RSIExValue(1) >=  15 && RSIExValue(0) >=  8/* && RSIExValue(0) > RSIExValue(1)*/){
            if (HeikinAshiOpen(1) < HeikinAshiClose(1) && HeikinAshiOpen(0) > HeikinAshiClose(0)){
               GetPositionBid();
            }
         }
      //}
   }
   else {
      if (OrderSelect(0, SELECT_BY_POS) == true){
         /*
         if (OrderProfit() >= (OrderLots() * RSI_NICE_CLOSE_PIPS) || OrderProfit() <= (OrderLots() * RSI_BAD_CLOSE_PIPS)){
            MyOrderClose();
         }
         */
         switch (OrderType()){
         case OP_BUY:
            //-- 
            if ((-0.005 <= HeikinAshiDiff(0) && HeikinAshiDiff(0) <= 0.005) ||
                  (HeikinAshiDiff(1) <= 0 && 0 <= HeikinAshiDiff(0))){
               MyOrderClose();
            }
            break;
         case OP_SELL:
            //-- 
            if ((-0.005 <= HeikinAshiDiff(0) && HeikinAshiDiff(0) <= 0.005) ||
                  (HeikinAshiDiff(0) <= 0 && 0 <= HeikinAshiDiff(1))){
               MyOrderClose();
            }
            break;
         }
      }
   }
   //----
   return (0);
}

  
//+------------------------------------------------------------------+
//| SubRoutin                                                        |
//+------------------------------------------------------------------+

//-------------------------Now_Type-------------------------//


//-------------------------Ex_Type--------------------------//


//--------------------------Other---------------------------//

// Position
/*
int ObserverBack()
{
   int myOrderType;
   
   if (OrdersTotal() > 0){
      if (OrderSelect(0, SELECT_BY_POS) == true){
         myOrderType = OrderType();
         
         if (ParabolicObserverBack(SAR_MAXIMUM_DEFAULT, SAR_STEP_DEFAULT) == BACK){
            MyOrderClose();
            return (BACK);
         }
      }
   }
   
   return (QUO);
}
*/
//+------------------------------------------------------------------+