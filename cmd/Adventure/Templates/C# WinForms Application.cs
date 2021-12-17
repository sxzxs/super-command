using System;
using System.ComponentModel;
using System.Drawing;
using System.Windows.Forms;

namespace SampleApp
{
    public class MainForm : Form
    {
        private Button btnHello;

        // The form's constructor: this initializes the form and its controls.
        public MainForm()
        {
            // Set the form's caption, which will appear in the title bar.
            this.Text = "WinForms GUI";
            this.Size = new Size(800, 600);

            // Create a button control and set its properties.
            btnHello = new Button();
            btnHello.Name = "btnHello";
            btnHello.Location = new Point(12, 12);
            btnHello.Size = new Size(84, 24);
            btnHello.Text = "Hello!";

            // Wire up an event handler to the button's "Click" event
            // (see the code in the btnHello_Click function below).
            btnHello.Click += new EventHandler(btnHello_Click);

            // Add the button to the form's control collection,
            // so that it will appear on the form.
            this.Controls.Add(btnHello);
        }

        // When the button is clicked, display a message.
        private void btnHello_Click(object sender, EventArgs e)
        {
            MessageBox.Show("Hello, World!", "Message");
        }

        // This is the main entry point for the application.
        // All C# applications have one and only one of these methods.
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.Run(new MainForm());
        }
    }
}
