//# vim:set foldmethod=marker:
//+------------------------------------------------------------------+
//|                                                 PositionInfo.mqh |
//|                                   Copyright 2015, SENAGA Yusuke. |
//|                                       aganesy.personal@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, SENAGA Yusuke."
#property link      "aganesy.personal@gmail.com"

// Standard Library
#include <Object.mqh>

// MyInclude
#include "Define.mqh"
#include "initMQL4.mqh"
#include "ObjectMQL4.mqh"

// MyLib
#include "TimeStamp.mqh"
#include "TemplateArray.mqh"

extern double Ask;
extern double Bid;

// Note //{{{
/*

*/

//}}}

class CPositionInfo : public CObject //{{{
{
protected:
    MqlTradeRequest m_stTradeRequestInfo;
    
    CTimeStamp      *m_pTimeStamp;

    double          m_dSLPrice;
    double          m_dTPPrice;

    bool            m_bIsRelease;
    double          m_dFirstHurdlePrice;
    double          m_dReleasePrice;
    int             m_nReleaseBorderPips;

public:
    CPositionInfo()
    {
        Print("Constructor PositionInfo.");
        
        MqlTradeRequest stInitRequest = {0};
        m_stTradeRequestInfo    = stInitRequest;

        m_pTimeStamp            = new CTimeStamp;

        m_dSLPrice			    = 0.0;
        m_dTPPrice			    = 0.0;

        m_bIsRelease 		    = false;
        m_dFirstHurdlePrice     = 0.0;
        m_dReleasePrice		    = 0.0;
        m_nReleaseBorderPips    = 0;
    }
    
    ~CPositionInfo()
    {
        Print("Destructor PositionInfo.");
        
        if (m_pTimeStamp != NULL)
        {
            delete m_pTimeStamp;
            m_pTimeStamp = NULL;
        }
        
        EraseStopLossLine();
        EraseTakeProfitLine();
        EraseFirstHundleLine();
        EraseReleaseLine();
        
        SetOrderPrice(0.0);
        SetOrderLots(0.0);
        SetTicketNumber(0);
        SetMagicNumber(0);
        SetOrderType(ORDER_TYPE_BUY);
    }

    bool Open(MqlTradeRequest& tradeRequest)
    {
        bool bResult = false;
        bResult = Open(tradeRequest.type, tradeRequest.volume, tradeRequest.price, tradeRequest.sl, tradeRequest.tp, tradeRequest.comment, tradeRequest.deviation);
        
        return bResult;
    }
    // Open
    bool Open(ENUM_ORDER_TYPE orderType, double lots, double price, double stopLoss = 0.0, double takeProfit = 0.0, string comment = "", ulong slippage = 3)
    {
        bool bResult = false;
        if(GetOrderPrice() > 0)
        {
            Print("Warning : Already ordered.");
        }
        else
            if(lots <= 0.0)
            {
                Print("Warning : Request Lots = 0.0");
            }
            else
            {
                ulong ulMagicNumber = 0;
                for(int i = 1; i < LONG_MAX_COUNT; i++)
                {
                    string strVarName = IntegerToString(i, 0);
                    double dVarValue = GlobalVariableGet(strVarName);
                    if(!dVarValue)
                    {
                        ulMagicNumber = (ulong)i;
                        break;
                    }
                }

                if(ulMagicNumber)
                {
                    MqlTradeRequest tradeRequest = {0};
                    tradeRequest.action = TRADE_ACTION_DEAL;
                    tradeRequest.symbol = _Symbol;
                    tradeRequest.type = orderType;
                    tradeRequest.volume = lots;
                    tradeRequest.price = price;
                    //tradeRequest.sl = stopLoss; // ストップロスは自前で実装する。
                    //tradeRequest.tp = takeProfit; // テイクプロフィットは自前で実装する。
                    tradeRequest.comment = comment;
                    tradeRequest.deviation = slippage;
                    tradeRequest.magic = ulMagicNumber;
                    tradeRequest.type_filling = ORDER_FILLING_IOC;
                    
                    MqlTradeResult tradeResult = {0};
                    
                    //Print("Symbol=", Symbol(), ", cmd=", orderType, ", volume=", lots, ", price=", dOrderPrice, ", slippage=", slippage, ", stoploss=", stopLoss, ", takeprofit=", takeProfit, ", magic=", nMagicNumber);
                    // ↓MQL4のコード
                    //bResult = MyOrderSend(Symbol(), orderType, lots, price, slippage, 0, 0, comment, nMagicNumber, 0, arrowColor);
                    bResult = MyOrderSend(tradeRequest, tradeResult);

                    Print("Order send result : ", bResult);
                    if(bResult)
                    {
                        // MQL5において、OrdersTotal()は未約定注文の合計値を返す関数らしい。
                        // 未決済注文の合計が必要であるため、PositionsTotal()で値を取得するのが正解。
                        int nOrdersTotal = PositionsTotal();
                        ulong ulTicketNum = PositionGetTicket(nOrdersTotal - 1);
                        if(ulTicketNum > 0)
                        {
                            tradeRequest.position = ulTicketNum;
                            m_stTradeRequestInfo = tradeRequest;
                            GlobalVariableSet(DoubleToString(GetMagicNumber()), GetMagicNumber());

                            if(stopLoss > 0.0)
                            {
                                SetStopLossPrice(stopLoss);
                            }
                            if(takeProfit > 0.0)
                            {
                                SetTakeProfitPrice(takeProfit);
                            }

                            CTimeStamp time(TimeCurrent());
                            SetOrderTime(time);
                        }
                    }
                }
            }

        return bResult;
    }

    // Close
    bool Close(string comment = "", color arrowColor = Blue)
    {
        bool bResult = false;

        bool bSelectByTicketResult = PositionSelectByTicket(GetTicketNumber());
        if(!bSelectByTicketResult)
        {
            Print("Error Order select failed : ", GetLastError());
        }
        else
        {
            double dClosePrice = 0.0;
            ENUM_ORDER_TYPE nCloseType = 0;
            // GetOrderType から OrderType を取得
            ENUM_ORDER_TYPE nOrderType = GetOrderType();
            
            // Open()時のｔｙｐｅとは逆のtypeを指定してOrderSend()する
            switch(nOrderType)
            {
                case ORDER_TYPE_BUY:
                case ORDER_TYPE_BUY_LIMIT:
                case ORDER_TYPE_BUY_STOP:
                    dClosePrice = Bid;
                    nCloseType = ORDER_TYPE_SELL;
                    break;

                case ORDER_TYPE_SELL:
                case ORDER_TYPE_SELL_LIMIT:
                case ORDER_TYPE_SELL_STOP:
                    dClosePrice = Ask;
                    nCloseType = ORDER_TYPE_BUY;
                    break;

                default:
                    break;
            }

            MqlTradeRequest closeRequest = {0};
            closeRequest.action = TRADE_ACTION_DEAL;
            closeRequest.symbol = _Symbol;
            closeRequest.type = nCloseType;
            closeRequest.volume = GetOrderLots();
            closeRequest.price = dClosePrice;
            closeRequest.comment = comment;
            closeRequest.position = GetTicketNumber();
            closeRequest.type_filling = ORDER_FILLING_IOC;
            
            MqlTradeResult closeResult = {0};
            
            // ↓MQL4のコード
            //bResult = MyOrderSend(GetTicketNumber(), GetOrderLots(), dClosePrice, 3, arrowColor);
            bResult = MyOrderSend(closeRequest, closeResult);
            if(bResult)
            {
                GlobalVariableDel(DoubleToString(GetMagicNumber()));
            }
        }

        return bResult;
    }

    // OrderSend()の結果をエラーハンドリングしたラッパー関数
    // 以下のリンクよりコピペで実装
    // https://www.mql5.com/ja/docs/constants/structures/mqltraderesult
	bool MyOrderSend(MqlTradeRequest &tradeRequest, MqlTradeResult &tradeResult)
	{
		bool bResult = false;

		// 最後のエラーコードをゼロにリセットする
		ResetLastError();

		// リクエストを送信する
		bResult = OrderSend(tradeRequest, tradeResult);

		// 失敗したら、理由を見つける
		if(!bResult)
		{
			uint answer = tradeResult.retcode;
			Print("TradeLog: Trade tradeRequest failed. Error = ", GetLastError());
			switch(answer)
			{
				// リクオート
				case 10004:
					Print("TRADE_RETCODE_REQUOTE");
					Print("tradeRequest.price = ", tradeRequest.price, ", tradeResult.ask = ",  tradeResult.ask, ", tradeResult.bid = ", tradeResult.bid);
					break;

				// 注文がサーバに受け入れられない
				case 10006:
					Print("TRADE_RETCODE_REJECT");
					Print("tradeRequest.price = ", tradeRequest.price, ", tradeResult.ask = ",  tradeResult.ask, ", tradeResult.bid = ", tradeResult.bid);
					break;

				// 無効な価格
				case 10015:
					Print("TRADE_RETCODE_INVALID_PRICE");
					Print("tradeRequest.price = ", tradeRequest.price, ", tradeResult.ask = ",  tradeResult.ask, ", tradeResult.bid = ", tradeResult.bid);
					break;

				// 無効な SL 及び/または TP
				case 10016:
					Print("TRADE_RETCODE_INVALID_STOPS");
					Print("tradeRequest.sl = ", tradeRequest.sl, ", tradeRequest.tp = ", tradeRequest.tp);
					Print("tradeResult.ask = ", tradeResult.ask, ", tradeResult.bid = ", tradeResult.bid);
					break;

				// 無効なボリューム
				case 10014:
					Print("TRADE_RETCODE_INVALID_VOLUME");
					Print("tradeRequest.volume = ", tradeRequest.volume, ", tradeResult.volume = ",  tradeResult.volume);
					break;

				// 取引操作に不充分なメモリ
				case 10019:
					Print("TRADE_RETCODE_NO_MONEY");
					Print("tradeRequest.volume = ", tradeRequest.volume, ", tradeResult.volume = ",  tradeResult.volume, ", tradeResult.comment = ", tradeResult.comment);
					break;

				// 他の理由。サーバ応答コードを出力する
				default:
					Print("Other answer = ", answer);
					break;
			}
		}

		return(bResult);
	}

    // Order Price
    void SetOrderPrice(double price)
    {
        m_stTradeRequestInfo.price = price;
    }
    double GetOrderPrice()
    {
        return m_stTradeRequestInfo.price;
    }

    // Magic Number
    void SetMagicNumber(ulong number)
    {
        m_stTradeRequestInfo.magic = number;
    }
    ulong GetMagicNumber()
    {
        return m_stTradeRequestInfo.magic;
    }

    // Ticket Number
    void SetTicketNumber(ulong number)
    {
        m_stTradeRequestInfo.position = number;
    }
    ulong GetTicketNumber()
    {
        return m_stTradeRequestInfo.position;
    }

    // Order Lots
    void SetOrderLots(double lots)
    {
        m_stTradeRequestInfo.volume = lots;
    }
    double GetOrderLots()
    {
        return m_stTradeRequestInfo.volume;
    }

    // Order Comment
    void SetOrderComment(string comment)
    {
        m_stTradeRequestInfo.comment = comment;
    }
    string GetOrderComment()
    {
        return m_stTradeRequestInfo.comment;
    }

    // Order Type
    void SetOrderType(ENUM_ORDER_TYPE type)
    {
        m_stTradeRequestInfo.type = (ENUM_ORDER_TYPE)type;
    }
    ENUM_ORDER_TYPE GetOrderType()
    {
        return m_stTradeRequestInfo.type;
    }

    // OrderTime
    void SetOrderTime(CTimeStamp& time)
    {
        m_pTimeStamp.SetTime(time.GetTime());
    }
    CTimeStamp* GetOrderTime()
    {
        return m_pTimeStamp;
    }

    // Stop Loss 価格
    void SetStopLossPrice(double price)
    {
        double dOrderPrice = GetOrderPrice();
        bool bIsReasonableValue = false;
        
        string note = "";
        
        // GetOrderType から OrderType を取得
        ENUM_ORDER_TYPE nOrderType = GetOrderType();
        switch(nOrderType)
        {
            // 買い注文なら、購入価格より小さい値でないとストップロスを成立させない
            case ORDER_TYPE_BUY:
            case ORDER_TYPE_BUY_LIMIT:
            case ORDER_TYPE_BUY_STOP:
                if(price < dOrderPrice)
                {
                    bIsReasonableValue = true;
                    note = "Because order type is buy, but Stoploss price is upper than order price.";
                }
                break;
            // 売り注文なら、売却価格より大きい値でないとストップロスを成立させない
            case ORDER_TYPE_SELL:
            case ORDER_TYPE_SELL_LIMIT:
            case ORDER_TYPE_SELL_STOP:
                if(price > dOrderPrice)
                {
                    bIsReasonableValue = true;
                    note = "Because order type is sell, but Stoploss price is lower than order price.";
                }
                break;
        }
        
        if (bIsReasonableValue)
        {
            m_dSLPrice = price;
            DrawStopLossLine(price);
            Print("Set Stoploss success. value : ", price);
        }
        else
        {
            Print("Set Stoploss failed. Stoploss value is not reasonable price. ", note);
        }
    }
    double GetStopLossPrice()
    {
        return m_dSLPrice;
    }
    void DrawStopLossLine(double price)
    {
        // マジックナンバーがユニークな値なのでそのままオブジェクト名として利用
        string strObjectName = "Stoploss" + DoubleToString(GetMagicNumber());
        ObjectCreate(strObjectName, OBJ_HLINE, 0, 1, price);
        ObjectSet(strObjectName, OBJPROP_COLOR, Red);
        ObjectSet(strObjectName, OBJPROP_STYLE, STYLE_DOT);
    }
    void EraseStopLossLine()
    {
        string strObjectName = "Stoploss" + DoubleToString(GetMagicNumber());
        ObjectDelete(strObjectName);
    }
    // Stop Loss 監視
    bool OvserveStopLoss()
    {
        bool bResult = false;

        //Print("Stop Loss price : ", m_dSLPrice);
        if(m_dSLPrice > 0.0)
        {
            // GetOrderType から OrderType を取得
            ENUM_ORDER_TYPE nOrderType = GetOrderType();
            switch(nOrderType)
            {
                case ORDER_TYPE_BUY:
                case ORDER_TYPE_BUY_LIMIT:
                case ORDER_TYPE_BUY_STOP:
                    if(m_dSLPrice > Bid && m_dSLPrice <= GetOrderPrice())
                    {
                        bResult = true;
                    }
                    break;
                case ORDER_TYPE_SELL:
                case ORDER_TYPE_SELL_LIMIT:
                case ORDER_TYPE_SELL_STOP:
                    if(m_dSLPrice < Ask && m_dSLPrice >= GetOrderPrice())
                    {
                        bResult = true;
                    }
                    break;
            }
        }

        return bResult;
    }

    // Take Profit 価格
    void SetTakeProfitPrice(double price)
    {
        double dOrderPrice = GetOrderPrice();
        bool bIsReasonableValue = false;
        
        string note = "";
        
        // GetOrderType から OrderType を取得
        ENUM_ORDER_TYPE nOrderType = GetOrderType();
        switch(nOrderType)
        {
            // 買い注文なら、購入価格より大きい値でないとテイクプロフィットを成立させない
            case ORDER_TYPE_BUY:
            case ORDER_TYPE_BUY_LIMIT:
            case ORDER_TYPE_BUY_STOP:
                if(price > dOrderPrice)
                {
                    bIsReasonableValue = true;
                    note = "Because order type is buy, but Takeprofit price is lower than order price.";
                }
                break;
            // 売り注文なら、売却価格より小さい値でないとテイクプロフィットを成立させない
            case ORDER_TYPE_SELL:
            case ORDER_TYPE_SELL_LIMIT:
            case ORDER_TYPE_SELL_STOP:
                if(price < dOrderPrice)
                {
                    bIsReasonableValue = true;
                    note = "Because order type is sell, but Takeprofit price is upperer than order price.";
                }
                break;
        }
        
        if (bIsReasonableValue)
        {
            m_dTPPrice = price;
            DrawTakeProfitLine(price);
            Print("Set Takeprofit success. value : ", price);
        }
        else
        {
            Print("Set Takeprofit failed. Takeprofit value is not reasonable price. ", note);
        }
    }
    double GetTakeProfitPrice()
    {
        return m_dTPPrice;
    }
    void DrawTakeProfitLine(double price)
    {
        // マジックナンバーがユニークな値なのでそのままオブジェクト名として利用
        string strObjectName = "Takeprofit" + DoubleToString(GetMagicNumber());
        ObjectCreate(strObjectName, OBJ_HLINE, 0, 1, price);
        ObjectSet(strObjectName, OBJPROP_COLOR, Blue);
        ObjectSet(strObjectName, OBJPROP_STYLE, STYLE_DOT);
    }
    void EraseTakeProfitLine()
    {
        string strObjectName = "Takeprofit" + DoubleToString(GetMagicNumber());
        ObjectDelete(strObjectName);
    }
    // Take Profit 監視
    bool OvserveTakeProfit()
    {
        bool bResult = false;

        //Print("Take profit price : ", m_dTPPrice);
        if(m_dTPPrice > 0.0)
        {
            // GetOrderType から OrderType を取得
            ENUM_ORDER_TYPE nOrderType = GetOrderType();
            switch(nOrderType)
            {
                case ORDER_TYPE_BUY:
                case ORDER_TYPE_BUY_LIMIT:
                case ORDER_TYPE_BUY_STOP:
                    if(m_dTPPrice < Bid && m_dTPPrice > GetOrderPrice())
                    {
                        bResult = true;
                    }
                    break;
                case ORDER_TYPE_SELL:
                case ORDER_TYPE_SELL_LIMIT:
                case ORDER_TYPE_SELL_STOP:
                    if(m_dTPPrice > Ask && m_dTPPrice < GetOrderPrice())
                    {
                        bResult = true;
                    }
                    break;
            }
        }

        return bResult;
    }

    void SetFirstHurdlePrice(double price)
    {
        m_dFirstHurdlePrice = price;
        DrawFirstHundleLine(price);
    }
    double GetFirstHurdlePrice()
    {
        return m_dFirstHurdlePrice;
    }
    double GetReleasePrice()
    {
        return m_dReleasePrice;
    }
    void SetReleaseBorderPips(int pips)
    {
        m_nReleaseBorderPips = pips;
    }
    int GetReleaseBorderPips()
    {
        return m_nReleaseBorderPips;
    }
    void DrawFirstHundleLine(double price)
    {
        // マジックナンバーがユニークな値なのでそのままオブジェクト名として利用
        string strObjectName = "FirstHundle" + DoubleToString(GetMagicNumber());
        ObjectCreate(strObjectName, OBJ_HLINE, 0, 1, price);
        ObjectSet(strObjectName, OBJPROP_COLOR, White);
        ObjectSet(strObjectName, OBJPROP_STYLE, STYLE_DOT);
    }
    void EraseFirstHundleLine()
    {
        string strObjectName = "FirstHundle" + DoubleToString(GetMagicNumber());
        ObjectDelete(strObjectName);
    }
    void DrawReleaseLine(double price)
    {
        // マジックナンバーがユニークな値なのでそのままオブジェクト名として利用
        string strObjectName = "Release" + DoubleToString(GetMagicNumber());
        ObjectCreate(strObjectName, OBJ_HLINE, 0, 1, price);
        ObjectSet(strObjectName, OBJPROP_COLOR, Yellow);
        ObjectSet(strObjectName, OBJPROP_STYLE, STYLE_DOT);
    }
    void EraseReleaseLine()
    {
        string strObjectName = "Release" + DoubleToString(GetMagicNumber());
        ObjectDelete(strObjectName);
    }
    // Release Price 監視
    bool OvserveReleasePrice()
    {
        bool bResult = false;

        if(m_dFirstHurdlePrice > 0.0 && m_nReleaseBorderPips > 0)
        {
            double dNowPrice = 0;
            // GetOrderType から OrderType を取得
            ENUM_ORDER_TYPE nOrderType = GetOrderType();
            switch(nOrderType)
            {
                case ORDER_TYPE_BUY:
                case ORDER_TYPE_BUY_LIMIT:
                case ORDER_TYPE_BUY_STOP:
                    dNowPrice = Bid;
                    // 現在価格が リリース判定価格より高い状態なら
                    // → リリースしても良いフラグを立てる
                    if(!m_bIsRelease && dNowPrice > m_dFirstHurdlePrice)
                    {
                        m_bIsRelease = true;
                        m_dReleasePrice = dNowPrice - PIPS(m_nReleaseBorderPips);
                        EraseReleaseLine();
                        DrawReleaseLine(m_dReleasePrice);
                    }
                    // 現在価格が リリース判定価格 + 更新幅pips より高い状態なら
                    // → 新しい Release Price をセット
                    if(m_dReleasePrice > 0.0 && dNowPrice > m_dReleasePrice + PIPS(m_nReleaseBorderPips))
                    {
                        m_dReleasePrice = dNowPrice - PIPS(m_nReleaseBorderPips);
                        EraseReleaseLine();
                        DrawReleaseLine(m_dReleasePrice);
                    }
                    // フラグが立っている && 現在価格が リリース判定価格 を割っている
                    // → リリースしましょう
                    if(m_bIsRelease && dNowPrice < m_dReleasePrice)
                    {
                        // リリースする
                        bResult = true;
                    }
                    break;

                case ORDER_TYPE_SELL:
                case ORDER_TYPE_SELL_LIMIT:
                case ORDER_TYPE_SELL_STOP:
                    dNowPrice = Ask;
                    // 現在価格が リリース判定価格より低い状態なら
                    // → リリースしても良いフラグを立てる
                    if(!m_bIsRelease && dNowPrice < m_dFirstHurdlePrice)
                    {
                        m_bIsRelease = true;
                        m_dReleasePrice = dNowPrice + PIPS(m_nReleaseBorderPips);
                        EraseReleaseLine();
                        DrawReleaseLine(m_dReleasePrice);
                    }
                    // 現在価格が リリース判定価格 + 更新幅pips より低い状態なら
                    // → 新しい Release Price をセット
                    if(m_dReleasePrice > 0.0 && dNowPrice < m_dReleasePrice - PIPS(m_nReleaseBorderPips))
                    {
                        m_dReleasePrice = dNowPrice + PIPS(m_nReleaseBorderPips);
                        EraseReleaseLine();
                        DrawReleaseLine(m_dReleasePrice);
                    }
                    // フラグが立っている && 現在価格が リリース判定価格 を超えている
                    // → リリースしましょう
                    if(m_bIsRelease && dNowPrice > m_dReleasePrice)
                    {
                        // リリースする
                        bResult = true;
                    }
                    break;

                default:
                    break;
            }
        }

        return bResult;
    }
}; //}}}
