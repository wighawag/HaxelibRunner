package ;
import sys.FileSystem;
import sys.io.Process;

class Main 
{
	
	static function main() 
	{
		var args = Sys.args();
		var command = args[0];
		
		var process : Process;
		var output : String;
		
		var libraryName : String;
		var version : String;
		
		if (args.length < 3)
		{
			Sys.println("need to specify library name");
		}
		libraryName = args[1];
		
		if (args.length < 4)
		{
			version = "";
		}
		else
		{
			version = args[2];
		}
		
		
		process = new Process("haxelib", ["list"]);
		output = process.stdout.readAll().toString();		
		var libLine = getLibLine(output, libraryName);
		
		switch(command)
		{
			case "install":
				var installed : Bool = false;
				
				//DEBUG (install cannot work on test package.zip) : Sys.exit(1);
				if (libLine != null)
				{
					var versionIndex = libLine.indexOf(" " + version + " ");
					if (versionIndex == -1)
					{
						versionIndex = libLine.indexOf("[" + version + "]");
					}
					if (versionIndex != -1)
					{
						installed = true;
						Sys.println("already installed " + libraryName + " "  + version);
						Sys.exit(1);
					}
				}
				
				if (!installed)
				{
					if (version == "")
					{
						process = new Process("haxelib", ["install", libraryName]);
					}
					else
					{
						process = new Process("haxelib", ["install", libraryName, version]);
					}
					
					process.stdin.writeString("n\n"); // do not set if older version was choosen while the newest version was already installed
					output = process.stdout.readAll().toString();//wait
					Sys.println(output);
					if (output.indexOf("You already have ") != -1)
					{
						Sys.println("already installed " + libraryName + " "  + version);
						Sys.exit(1);
					}
					else if (output.indexOf("No such Project : " + libraryName) != -1)
					{
						#if debug
							Sys.println("Debug mode : assume you install library through haxelib test and zip package");
							Sys.exit(1); // already installed
						#else
							Sys.exit(2);
						#end
					}
					else if (output.indexOf("No such version " + version) != -1)
					{
						Sys.exit(2);
					}
				}
				
			case "set":
				if (libLine == null)
				{
					Sys.println(" not installed :" + libraryName);
					Sys.exit(2);
				}
				if (version == "")
				{
					var tmp = libLine.substr(libLine.lastIndexOf(" "));	
					var bracket = tmp.indexOf("[");
					if (bracket != -1)
					{
						Sys.println("already set " + libraryName + " "  + version);
						Sys.exit(1);
					}
					version = StringTools.trim(version);
				}
				else
				{
					var bracket = libLine.indexOf("[");
					if (libLine.substr(bracket + 1, libLine.indexOf("]") - bracket - 1) == version)
					{
						Sys.println("already set " + libraryName + " "  + version);
						Sys.exit(1);
					}
				}
				var p = new Process("haxelib", ["set", libraryName, version]);
				Sys.println(p.stdout.readAll().toString());
				Sys.exit(0);
		}
		
	}
	
	private static function getLibLine(output : String, libraryName : String) : String
	{
		var libLineIndex = output.indexOf("\n" + libraryName + ":");
		if (libLineIndex != -1)
		{
			var afterLib = output.substr(libLineIndex + 1);
			var libLineEndIndex = afterLib.indexOf("\n");
			return afterLib.substr(0, libLineEndIndex);
		}
		return null;
	}
	
}