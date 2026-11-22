// Game launcher for the portable Windows package.
// CHANGE FOR YOUR GAME: the packager (package_game.ps1) replaces the placeholders "My Game"
// (display name) and "MyGame" (file name, no spaces) with its -GameName / -GameFileName values.
// If you compile this by hand, replace them yourself.
using System;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Text;
using System.Windows.Forms;

[assembly: AssemblyTitle("My Game")]
[assembly: AssemblyDescription("My Game portable game launcher")]
[assembly: AssemblyProduct("My Game")]
[assembly: AssemblyVersion("0.1.0.0")]

internal static class Launcher
{
    [STAThread]
    private static int Main(string[] args)
    {
        string folder = AppDomain.CurrentDomain.BaseDirectory;
        string engine = Path.Combine(folder, "runtime", "engine.exe");
        string pack = Path.Combine(folder, "MyGame.pck");
        if (!File.Exists(engine) || !File.Exists(pack))
        {
            MessageBox.Show("Keep the whole game folder together. Extract the ZIP, then run MyGame.exe inside the extracted folder.", "My Game", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return 1;
        }
        try
        {
            StringBuilder arguments = new StringBuilder("--path ");
            arguments.Append(Quote(folder));
            arguments.Append(" --main-pack ");
            arguments.Append(Quote(pack));
            foreach (string argument in args)
            {
                arguments.Append(' ');
                arguments.Append(Quote(argument));
            }
            ProcessStartInfo info = new ProcessStartInfo(engine, arguments.ToString());
            info.WorkingDirectory = folder;
            info.UseShellExecute = false;
            info.CreateNoWindow = true;
            using (Process game = Process.Start(info))
            {
                if (game == null) throw new InvalidOperationException("The game could not start.");
                game.WaitForExit();
                return game.ExitCode;
            }
        }
        catch (Exception error)
        {
            MessageBox.Show("The game could not start.\n\n" + error.Message, "My Game", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return 1;
        }
    }

    // Windows command-line escaping: preserve spaces, quotes and trailing slashes.
    private static string Quote(string value)
    {
        StringBuilder result = new StringBuilder("\"");
        int slashes = 0;
        foreach (char character in value)
        {
            if (character == '\\') { slashes++; continue; }
            if (character == '"')
            {
                result.Append('\\', slashes * 2 + 1);
                result.Append('"');
            }
            else
            {
                result.Append('\\', slashes);
                result.Append(character);
            }
            slashes = 0;
        }
        result.Append('\\', slashes * 2);
        result.Append('"');
        return result.ToString();
    }
}
