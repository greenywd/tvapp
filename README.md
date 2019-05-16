# <s>Watchlist</s> <s>tvapp</s> szns
An app to track TV Shows (and eventually movies - if there's a suitable api :p).

## To-Do

### - General Features
- [ ] Send a notification when a user defined show airs
- [ ] App icons (both on homescreen and inside the app)
- [ ] <s>Setup ads and iAP to remove them (either project wonderful or google)</s> tip jar that unlocks a few extra features (can only favourite x shows?)
- [ ] Cache images(?) for favourited shows - would speed up loading times a lot (should happen with CoreData)
- [ ] Make sure the app works offline - right now it'll probably crash when searching or opening a view Controller

### - Home View Controller
- [ ] Everything ¯\\\_(ツ)\_/¯
- [ ] Need to decide on layout - tableview or a more visual way (i.e posters)

### - Show View Controller
- [ ] Fix layout of almost every label
- [ ] Possibly an 'actors' section - actors are already being grabbed via API so the data is there
- [ ] Paged horizontal scroll view to scroll through fanart
- [ ] Next episode - "airs in x minutes"

### - Episode View Controller
- [ ] Pretty it up a little - use Apple Music like controllers (header blurred when scrolling down)?
- [ ] Possibly change to custom table cells - subtitle cells will do for now though.
- [ ] Have a new view controller for each episode, could possibly reuse Show View Controller without a few things

### - Settings View Controller
- [ ] Everything ¯\\\_(ツ)\_/¯
- [ ] An option to load 720p or 1080p images in the Show View Controller
- [ ] Legal section - acknowledge libraries, tvdb, etc
- [ ] Any easter eggs?

### - API
- [ ] If no fanart for banner in Show View Controller is found, try searching for different resolutions
- [ ] Check the structs being used for JSON decoding - tvdb declares almost everything as optional just in case
