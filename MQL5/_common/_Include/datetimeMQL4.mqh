//+------------------------------------------------------------------+
//|                                                       Define.mqh |
//|                                   Copyright 2013, SENAGA Yusuke. |
//|                                               mi081321@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, SENAGA Yusuke."
#property link      "mi081321@gmail.com"

int Day()
{
    MqlDateTime tm;
    TimeCurrent(tm);
    return(tm.day);
}

int DayOfWeek()
{
    MqlDateTime tm;
    TimeCurrent(tm);
    return(tm.day_of_week);
}

int DayOfYear()
{
    MqlDateTime tm;
    TimeCurrent(tm);
    return(tm.day_of_year);
}

int Hour()
{
    MqlDateTime tm;
    TimeCurrent(tm);
    return(tm.hour);
}

int Minute()
{
    MqlDateTime tm;
    TimeCurrent(tm);
    return(tm.min);
}

int Month()
{
    MqlDateTime tm;
    TimeCurrent(tm);
    return(tm.mon);
}

int Seconds()
{
    MqlDateTime tm;
    TimeCurrent(tm);
    return(tm.sec);
}

int TimeDay(datetime date)
{
    MqlDateTime tm;
    TimeToStruct(date,tm);
    return(tm.day);
}

int TimeDayOfWeek(datetime date)
{
    MqlDateTime tm;
    TimeToStruct(date,tm);
    return(tm.day_of_week);
}

int TimeDayOfYear(datetime date)
{
    MqlDateTime tm;
    TimeToStruct(date,tm);
    return(tm.day_of_year);
}

int TimeHour(datetime date)
{
    MqlDateTime tm;
    TimeToStruct(date,tm);
    return(tm.hour);
}

int TimeMinute(datetime date)
{
    MqlDateTime tm;
    TimeToStruct(date,tm);
    return(tm.min);
}

int TimeMonth(datetime date)
{
    MqlDateTime tm;
    TimeToStruct(date,tm);
    return(tm.mon);
}

int TimeSeconds(datetime date)
{
    MqlDateTime tm;
    TimeToStruct(date,tm);
    return(tm.sec);
}

int TimeYear(datetime date)
{
    MqlDateTime tm;
    TimeToStruct(date,tm);
    return(tm.year);
}

int Year()
{
    MqlDateTime tm;
    TimeCurrent(tm);
    return(tm.year);
}
