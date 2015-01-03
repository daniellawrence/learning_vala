// using Glib;

static int main (string[] args) {
	VolumeMonitor monitor = VolumeMonitor.get();
	List<Volume> volumes = monitor.get_volumes();

	foreach (Volume volume in volumes) {
				// bool screm = identifier.contains ("/dev/sd");
                // bool scremPart = identifier.contains ("/dev/sda");
                // if (screm == true && scremPart == false) {
					// nomeDevice[i] = volume.get_name ();
					stderr.printf("%s\n", volume.get_name());
					stderr.printf("%s\n", volume.get_drive().get_name());
					stderr.printf("%s\n", volume.get_drive().is_media_removable().to_string());
				//}
			// }
			string[] kinds = volume.enumerate_identifiers ();
			foreach (unowned string kind in kinds) {
				string identifier = volume.get_identifier(kind);
				stderr.printf("%s\n", identifier);
			}
			stderr.printf("-------------------------\n");
	 };
	
	monitor.volume_added.connect ((volume) => {
			//List<Volume> variabiledimantenimento = monitor.get_volumes ();
			monitor.get_volumes ();
			// print_volume(volume);
			string[] kinds = volume.enumerate_identifiers ();
			foreach (unowned string kind in kinds) {
				string identifier = volume.get_identifier (kind);
				bool screm = identifier.contains ("/dev/sd");
                bool scremPart = identifier.contains ("/dev/sda");
                if (screm == true && scremPart == false) {
					// nomeDevice[i] = volume.get_name ();
					stderr.printf("\n%s\n", volume.get_name());
				}
			}
		});
	
	// monitor.volume_removed.connect ((volume) => {
			// print_volume(volume);
	//	}); 
	return 0;
}
