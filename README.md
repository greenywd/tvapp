# Watchlist
An app to track TV Shows (and eventually movies - if there's a suitable api :p).

## Project Requirements
- [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)
- [Alamofire](https://github.com/Alamofire/Alamofire)

## To-Do

### - General
- [ ] Next episode - "airs in x minutes"
- [ ] Send a notification when a user defined show airs
- [ ] App icons (both on homescreen and inside the app)
- [ ] userDefaults - favourite shows
- [ ] Setup ads and iAP to remove them
- [ ] Cache images(?) for favourited shows - would speed up loading times a lot
- [ ] Make sure the app works offline - right now it'll probably crash when searching or opening a view Controller

### - Home View Controller
- [ ] Everything ¯\\\_(ツ)\_/¯
- [ ] Need to decide on layout - tableview or a more visual way (i.e posters)

### - Show View Controller
- [ ] Change 'Add' to a Star icon or similar and highlight it
- [ ] Fix layout of almost every label
- [ ] Possibly an 'actors' section
- [ ] Paged horizontal scroll view to scroll through fanart
- [x] If no fanart - pretty sure the view controller either doesn't work, or crashes

### - Episode View Controller
- [ ] Pretty it up a little :p
- [ ] Possibly change to custom table cells - subtitle cells will do for now though.
- [ ] Have a new view controller for each episode, could possibly reuse Show View Controller without a few things

### - Settings View Controller
- [ ] Everything ¯\\\_(ツ)\_/¯
- [ ] An option to load 720p or 1080p images in the Show View Controller
- [ ] Legal section - acknowledge libraries, tvdb, etc

### - API
- [ ] Code is a little messy, but it works. Would like to clean it up a little sometime
- [x] If no fanart for banner in Show View Controller is found, try searching for different resolutions
