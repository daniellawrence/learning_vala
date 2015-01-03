// using Gtk;
// using GLib;
// using Gee;

Image selectedImage;
Device selectedDevice;


public void on_button1_clicked (Gtk.Button source) {
    source.label = "Thank you!";
}

public void on_button2_clicked (Gtk.Button source) {
    source.label = "Thanks!";
}

public void on_treeview_selection4_changed (Gtk.TreeSelection selection) {
	Gtk.TreeModel model;
	Gtk.TreeIter iter;
	string image;
	string size;
	
	selection.get_selected(out model, out iter);
	model.get(iter, 
			  0, out image,
			  1, out size
		);

	// global selected Image
	selectedImage = new Image(image, size);
	stderr.printf("Selected %s @ %s\n", selectedImage.image, selectedImage.size);
}

public void on_treeview_selection3_changed (Gtk.TreeSelection selection) {
	Gtk.TreeModel model;
	Gtk.TreeIter iter;
	string name;
	string path;
	
	selection.get_selected(out model, out iter);
	model.get(iter, 
			  0, out name,
			  1, out path
		);

	// global selected Image
	selectedDevice = new Device(name, path);
	stderr.printf("Selected %s @ %s\n", selectedDevice.name, selectedDevice.path);
}


static int main (string[] args) {
    Gtk.init (ref args);
    var app = new App ();
    app.start ();
    Gtk.main ();
    return 0;
}

public class Image : GLib.Object {
    public string image;
	public string size;

	 /* Constructor */
    public Image(string image, string size) {
        this.image = image;
        this.size = size;
    }

	public string get_pretty_size() {
		uint64 int_size = (uint64)this.size;
		string pretty_size = format_size(int_size);
		return @"$(pretty_size)";
	}
	public string to_string() {
		return @"$(this.image), $(this.size)";
	}
}

public class Device : GLib.Object {
    public string name;
	public string path;

    public Device(string name, string path) {
        this.name = name;
        this.path = path;
    }

	public string to_string() {
		return @"$(this.name), $(this.path)";
	}
}


public class App: Object {

    Gtk.Window window;
    Gtk.TreeView treeview;
    Gtk.ListStore liststore;
    Gtk.ListStore deviceliststore;
	Gtk.Button writebutton;
	Gee.List<Image?> data = new Gee.ArrayList<Image?>();


	internal void device_changed (Gtk.ListStore deviceliststore, 
									  VolumeMonitor monitor) {

		bool anydevices = false;

		List<Volume> volumes = monitor.get_volumes();

		foreach (Volume volume in volumes) {

			string volume_uuid = volume.get_identifier(GLib.VolumeIdentifier.UUID);
			if (volume_uuid == null){
				continue;
			}
			anydevices = true;

			string volume_label = volume.get_identifier(GLib.VolumeIdentifier.LABEL);
			// string volume_class = volume.get_identifier(GLib.VolumeIdentifier.CLASS);

            Gtk.TreeIter iter;
            deviceliststore.append(out iter);
            deviceliststore.set(
				iter, 
				0, volume.get_drive().get_name(),
				1, volume_label,
				2, "2",
				3, "3"
			);
									 
		};
		stderr.printf("anydevices: %s\n", anydevices.to_string());
	}

    construct {
        var builder = new Gtk.Builder();
        try {
            builder.add_from_file("iso2usb.ui");
        }
        catch (Error e) {
            stderr.printf (@"$(e.message)\n");
            // Posix.exit(1);
        }

        builder.connect_signals (this);
        this.window = builder.get_object("window") as Gtk.Window;
        // this.msg_label = builder.get_object("msg-label") as Gtk.Label;
        this.treeview = builder.get_object("treeview") as Gtk.TreeView;

        // Load list data.
        this.liststore = builder.get_object("ImageListStore") as Gtk.ListStore;
        this.writebutton = builder.get_object("WriteToDriveButton") as Gtk.Button;
        this.liststore.clear();

		find_images(data);

		foreach(Image p in data) {
            Gtk.TreeIter iter;
			p.to_string();
            this.liststore.append(out iter);
            this.liststore.set(iter, 0, p.image, 1, p.get_pretty_size());
        }

        // Load list data.
        this.deviceliststore = builder.get_object("DeviceListStore") as Gtk.ListStore;
        this.deviceliststore.clear();

		VolumeMonitor monitor = VolumeMonitor.get();
		device_changed(this.deviceliststore, monitor);
		monitor.volume_removed.connect ((volume) => {
			this.deviceliststore.clear();
			device_changed(this.deviceliststore, monitor);
		}); 
		monitor.volume_added.connect ((volume) => {
			this.deviceliststore.clear();
			device_changed(this.deviceliststore, monitor);
		}); 



        // Monitor list double-clicks.
        this.treeview.row_activated.connect(on_row_activated);
        // Monitor list selection changes.
        this.treeview.get_selection().changed.connect(on_selection);
        this.window.destroy.connect(Gtk.main_quit);
    }

    public void start () {
        this.window.show_all();
    }

	private void find_images (Gee.List data) {
		stderr.printf("in setup_imagelist\n");
	
		try {

			var home_dir = GLib.Environment.get_home_dir();
			var download_dir = home_dir + "/Downloads/";
			
			var directory = File.new_for_path(download_dir);
			var enumerator = directory.enumerate_children("standard::*", 0);
			var file_name = "";
			
			
			FileInfo file_info;
			while ((file_info = enumerator.next_file()) != null) {
				
				file_name = file_info.get_name();
				var file_name_ends_with_iso = file_name.has_suffix(".iso");
				
				if ( file_name_ends_with_iso == false ) {
					continue;
				}
				
				var file_size = file_info.get_size().to_string();
				
				Image x = new Image(file_name, file_size);
				this.data.add(x);
				
				stderr.printf("adding %s -- %s\n", file_name, file_size);
			}
			
		} catch (Error e) {
			stderr.printf("Error: %s\n", e.message);
		}
		
	}


    private static Image get_selection (Gtk.TreeModel model, Gtk.TreeIter iter) {
        var p = new Image("new", "0");
        model.get (iter, 0, out p.image, 1, out p.size);
        return p;
    }

    /* List item double-click handler. */
    private void on_row_activated (Gtk.TreeView treeview , Gtk.TreePath path, Gtk.TreeViewColumn column) {
        Gtk.TreeIter iter;
        if (treeview.model.get_iter (out iter, path)) {
            Image p = get_selection (treeview.model, iter);
            // this.msg_label.label = @"Double-clicked: $(p)";
			stderr.printf(@"Clicked $(p)");
        }
    }

    /* List item selection handler. */
    private void on_selection (Gtk.TreeSelection selection) {
        Gtk.TreeModel model;
        Gtk.TreeIter iter;
        if (selection.get_selected (out model, out iter)) {
            Image p = get_selection (model, iter);
            // this.msg_label.label = @"Selected: $(p)";
			stderr.printf(@"Selected $(p)");
        }
    }

}

