//estrategia solo con estocastico y RSI!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#include <Trade/Trade.mqh>

CTrade trade;

input ENUM_TIMEFRAMES timeframe=PERIOD_M15;
int Rsi;
double RSI[], RSIvalue;
int stoch;
double KArray[], DArray[];
double KAvalue0, DAvalue0, KAvalue1, DAvalue1;
double ask, bid;
double accountBalance;

double lots=0.1;



int OnInit(){

   Rsi = iRSI(_Symbol, timeframe, 14, PRICE_CLOSE);
   stoch = iStochastic(_Symbol, timeframe, 6, 3, 3, MODE_SMA, STO_LOWHIGH);
   
   ArrayResize(KArray, 3); // Resize the arrays for Stochastic
   ArrayResize(DArray, 3);

   if(stoch == INVALID_HANDLE) {
      Print("Failed to create Stochastic handle");
      return INIT_FAILED;
   }

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){

}

void OnTick() {

    double balance=GetAccountBalance();
    Comment("Account Balance: ", balance);
    
   // Copy RSI values
    ArraySetAsSeries(RSI, true);
    int copiedRSI = CopyBuffer(Rsi, 0, 0, 3, RSI);
    if (copiedRSI <= 0) {
        Print("Failed to get RSI data. copiedRSI: ", copiedRSI);
        return;
    }
    RSIvalue = NormalizeDouble(RSI[0], _Digits);
    
    //STOCHASTIC
    // Ensure arrays are set as series
    ArraySetAsSeries(KArray, true);
    ArraySetAsSeries(DArray, true);

    // Copy the stochastic indicator values
    int copiedK = CopyBuffer(stoch, 0, 0, 3, KArray);
    int copiedD = CopyBuffer(stoch, 1, 0, 3, DArray);

    if (copiedK <= 0 || copiedD <= 0) {
        Print("Failed to get Stochastic data. copiedK: ", copiedK, ", copiedD: ", copiedD);
        return;
    }
    
    //D% es el rojo
    //k% es el azul
    //si el rojo es mayor que el azul vendemos= si D%>K% buying
    //si azul mayor que rojo, compramos= si K%>D% selling

    KAvalue0 = NormalizeDouble(KArray[0], _Digits);
    DAvalue0 = NormalizeDouble(DArray[0], _Digits);
    KAvalue1 = NormalizeDouble(KArray[1], _Digits);
    DAvalue1 = NormalizeDouble(DArray[1], _Digits);
    
    ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
    bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
    
    //UPTREND
    /*
    if(RSIvalue<50){
      if(KAvalue0<20 && DAvalue0<20){
        if(KAvalue1>DAvalue1){
          double sl = ask - 0.0003;
          double tp = ask+0.00025;;
          bool result = trade.Buy(lots, _Symbol, ask, sl, tp);
          if (result) {
            Print("buy order executed successfully");
          } else {
            int error = GetLastError();
            Print("Error executing sell order: ", error);
            ResetLastError();
          }
        }
      }
    }
    */
    //NI LO TOQUES, ESTÁ MAS QUE PERFECTO
    if(RSIvalue>75){
      if(KAvalue0>80 && DAvalue0>80){
        double sl = bid + 0.0007;
        double tp = bid-0.0006;
        bool result = trade.Sell(lots, _Symbol, bid, sl, tp);
        if (result) {
          Print("sell order executed successfully");
        } else {
          int error = GetLastError();
          Print("Error executing buy order: ", error);
          ResetLastError();
        }
      }
    }
    
    //ESTRATEGIA ESTOCASTICO, DESPUES DE LA TENDENCIA RSI
}

double GetAccountBalance(){
   double info=AccountInfoDouble(ACCOUNT_BALANCE);
   return info;
}