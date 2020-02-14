# CompareBookmarks

Compares Bookmarks for the following browsers:
- Safari
- Google Chrome
- Firefox

It tries to detect the location of the "bookmarks" file of these browsers. Via the "Open" button the bookmark file can be located manaually.

With the "Compare" button two different browser bookmarks can be compared.

After comparison, there is an indicator (stepper) of how many bookmarks are additionally available for a browser, but not for the other.
The indicator is located right next to the "Open" button.
A bookmark (or a bookmark folder) which is only available in one of the bookmark files is highligheted in red.
With the indicator one can step through the bookmarks highlighted in red. (Remark: The first click is a bit irritating).

Right-Clicking on a url of a bookmark reveals the possibility to open the url in the standard browser.

If one of the booksmarks file change, they can be reloaded pressing the "Refresh" button. Then a new comparison can be initiated.

Security:
- Since the bookmark file of the Safari browser is secured by MacOS you need to grant full disk access. 
This is done in the Prefences App. 
- Go to "Security & Privacy" -> Privacy -> "Full Disk Access".
- Unlock the key lock and add the app "CompareBookmarks_Ojbc.app" from the installation location, where it is installed. 
Remark: If someone knows of a better way, please let me know.

Technical details:
This is a MacOS App written in Objective-C. It was my first app. There are certainly lots of improvements.


