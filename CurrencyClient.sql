class CurrencyClient
{
    private Socket client;

    public void Connect()
    {
        IPAddress ip = IPAddress.Parse("127.0.0.1");
        IPEndPoint endpoint = new IPEndPoint(ip, 8888);

        client = new Socket(
            AddressFamily.InterNetwork,
            SocketType.Stream,
            ProtocolType.Tcp);

        client.Connect(endpoint);

        Console.WriteLine("Connected to currency server.");

        while (true)
        {
            Console.WriteLine();
            Console.WriteLine("Enter two currencies.");
            Console.WriteLine("Example: USD EUR");
            Console.WriteLine("Enter exit to disconnect.");

            string request = Console.ReadLine();

            byte[] data = Encoding.ASCII.GetBytes(request);
            client.Send(data);

            if (request.ToLower() == "exit")
                break;

            byte[] buffer = new byte[1024];

            int length = client.Receive(buffer);

            string response = Encoding.ASCII.GetString(
                buffer, 0, length);

            Console.WriteLine("Server: " + response);
        }

        client.Shutdown(SocketShutdown.Both);
        client.Close();

        Console.WriteLine("Disconnected.");
    }
}

class Program
{
    static void Main()
    {
        CurrencyClient client = new CurrencyClient();
        client.Connect();
    }
}