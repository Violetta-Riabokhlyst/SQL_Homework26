class CurrencyLogger
{
    public void Write(string text)
    {
        using (StreamWriter writer = new StreamWriter("server_log.txt", true))
        {
            writer.WriteLine(DateTime.Now + " - " + text);
        }
    }
}

class CurrencyServer
{
    private Socket server;
    private CurrencyLogger logger;

    public CurrencyServer()
    {
        logger = new CurrencyLogger();
    }

    public void Start()
    {
        IPAddress ip = IPAddress.Parse("127.0.0.1");
        IPEndPoint endpoint = new IPEndPoint(ip, 8888);

        server = new Socket(
            AddressFamily.InterNetwork,
            SocketType.Stream,
            ProtocolType.Tcp);

        server.Bind(endpoint);
        server.Listen(10);

        Console.WriteLine("Currency server started.");

        while (true)
        {
            Socket client = server.Accept();

            Thread thread = new Thread(HandleClient);
            thread.Start(client);
        }
    }

    private void HandleClient(object clientObject)
    {
        Socket client = (Socket)clientObject;

        string clientAddress = client.RemoteEndPoint.ToString();

        logger.Write("Client connected: " + clientAddress);

        try
        {
            while (true)
            {
                byte[] buffer = new byte[1024];

                int length = client.Receive(buffer);

                if (length == 0)
                    break;

                string request = Encoding.ASCII.GetString(
                    buffer, 0, length);

                if (request == "exit")
                    break;

                string[] currencies = request.Split(' ');

                if (currencies.Length != 2)
                {
                    SendMessage(client, "Invalid request.");
                    continue;
                }

                string firstCurrency = currencies[0].ToUpper();
                string secondCurrency = currencies[1].ToUpper();

                string rate = GetRate(
                    firstCurrency,
                    secondCurrency);

                SendMessage(client, rate);

                logger.Write(
                    "Currency rate: " +
                    firstCurrency + " " +
                    secondCurrency + " = " +
                    rate);
            }
        }
        catch (SocketException ex)
        {
            logger.Write("Socket error: " + ex.Message);
        }

        client.Shutdown(SocketShutdown.Both);
        client.Close();

        logger.Write("Client disconnected: " + clientAddress);
        logger.Write("Disconnect time: " + DateTime.Now);
    }

    private string GetRate(string first, string second)
    {
        if (first == "USD" && second == "EUR")
            return "1 USD = 0.85 EUR";

        if (first == "EUR" && second == "USD")
            return "1 EUR = 1.18 USD";

        if (first == "USD" && second == "GBP")
            return "1 USD = 0.74 GBP";

        if (first == "GBP" && second == "USD")
            return "1 GBP = 1.35 USD";

        if (first == "EUR" && second == "GBP")
            return "1 EUR = 0.87 GBP";

        if (first == "GBP" && second == "EUR")
            return "1 GBP = 1.15 EUR";

        return "Currency pair not found.";
    }

    private void SendMessage(Socket client, string message)
    {
        byte[] data = Encoding.ASCII.GetBytes(message);
        client.Send(data);
    }
}

class Program
{
    static void Main()
    {
        CurrencyServer server = new CurrencyServer();
        server.Start();
    }
}