WeatherApp
==========

An [open-meteo](https://open-meteo.com) was choosen as a data source: it's free, simple to use and provides a decent amount of data.
The minimal iOS version is 14. The UI is simple, native fonts are used for text and SF symbols are used for icons. Storyboards aren't used to simplify merge conflicts in future. Dynamic font and localization aren't supported to save some time. No 3rd party libraries are used to avoid any future issues with them being outdated or even not supported anymore. The data is fetched with URLSession, stored with CoreData, and handled by managers.
For future improvements the good candidates are increase the amount of data being shown to the user and implement today widget and apple watch extensions.
