using Gtk;
using GLib;
// using f;

public class TreeViewSample : Window {

    public TreeViewSample () {
        this.title = "TreeView Sample";
        set_default_size (250, 100);
        var view = new TreeView ();
        setup_treeview (view);
        add (view);
        this.destroy.connect (Gtk.main_quit);
    }

    private void setup_treeview (TreeView view) {

        /*
         * Use ListStore to hold accountname, accounttype, balance and
         * color attribute. For more info on how TreeView works take a
         * look at the GTK+ API.
         */
		try {

			var listmodel = new ListStore (2, typeof (string), typeof (string));
			view.set_model (listmodel);

			view.insert_column_with_attributes(-1, "Image", new CellRendererText (), "text", 0);
			view.insert_column_with_attributes(-1, "Size", new CellRendererText (), "text", 1);

			TreeIter iter;
			
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

				listmodel.append(out iter);
				listmodel.set(iter, 0, file_name, 1, file_size);
				
			}

			view.clicked.connect (() => {
					// Emitted when the button has been activated:
					// button.label = "Click me (%d)".printf (++this.click_counter);
					stdout.printf("click");
			});

		} catch (Error e) {
			stderr.printf("Error: %s\n", e.message);
		}
		
    }

    public static int main (string[] args) {
        Gtk.init(ref args);

        var sample = new TreeViewSample(); 
		sample.show_all();
        Gtk.main();

        return 0;
    }
}