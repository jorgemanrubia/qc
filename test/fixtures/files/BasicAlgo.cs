namespace QuantConnect
{
    /*
    *   Basic Template Algorithm
    *
    *   The underlying QCAlgorithm class has many methods which enable you to use QuantConnect.
    *   We have explained some of these here, but the full base class can be found at:
    *   https://github.com/QuantConnect/Lean/tree/master/Algorithm
    */
    public class BasicAlgo : QCAlgorithm
    {
        public override void Initialize()
        {
        	// backtest parameters
            SetStartDate(2016, 1, 1);
            SetStartDate(2016, 1, 3);

            // cash allocation
            SetCash(25000);

            // request specific equities
            // including forex. Options and futures in beta.
            AddEquity("SPY", Resolution.Minute);
            //AddForex("EURUSD", Resolution.Minute);
        }

        /*
        *	New data arrives here.
        *	The "Slice" data represents a slice of time, it has all the data you need for a moment.
        */
        public override void OnData(Slice data)
        {
        	// slice has lots of useful information
        	TradeBars bars = data.Bars;
        	Splits splits = data.Splits;
        	Dividends dividends = data.Dividends;

        	//Get just this bar.
        	TradeBar bar;
        	if (bars.ContainsKey("SPY")) bar = bars["SPY"];

            if (!Portfolio.HoldStock)
            {
                // place an order, positive is long, negative is short.
                // Order("SPY",  quantity);

                // or request a fixed fraction of a specific asset.
                // +1 = 100% long. -2 = short all capital with 2x leverage.
                SetHoldings("SPY", 1);

                // debug message to your console. Time is the algorithm time.
                // send longer messages to a file - these are capped to 10kb
                Debug("Purchased SPY on " + Time.ToShortDateString());
                //Log("This is a longer message send to log.");
            }
        }
    }
}
