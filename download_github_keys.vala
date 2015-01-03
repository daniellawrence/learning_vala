// $ valac --pkg gio-2.0 --pkg gee-0.8 download_github_keys.vala
// $ ./download_github_keys
MainLoop main_loop;

async void copy_file_async(File source, File destination) {
	try {
		if (destination.query_exists()) {
			destination.delete();
		}

		var dis = new DataInputStream(source.read());
		var dos = new DataOutputStream(destination.create(FileCreateFlags.REPLACE_DESTINATION));
		yield;

		string line = null;
		while( (line = yield dis.read_line_async(Priority.DEFAULT)) != null) {
			dos.put_string(line);
			dos.put_string("\n");
		}
	} catch(Error e) {
		error(e.message);
	}
//	main_loop.quit();
}

async void download_github_keys(string username) {
	print(@"downloading keys for $(username)\n");
	var source_file = File.new_for_uri(@"https://github.com/$(username).keys");
	var destination_file = File.new_for_path(@"$(username).keys");
	copy_file_async.begin(source_file, destination_file);
	print(@"Downloaded keys for $(username)\n");
}

public static int main(string[] args) {
	var usernames = new Gee.HashSet<string>();
	usernames.add("daniellawrence");
	// source to download from

	main_loop = new MainLoop();
	foreach(string username in usernames){
		download_github_keys.begin((username), (obj, res) => {
				download_github_keys.end(res);
				main_loop.quit();
			});
	}

	main_loop.run();
	return 0;
}