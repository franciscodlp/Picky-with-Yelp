# Picky-with-Yelp
## Yelp Client
This is a Yelp search app using the [Yelp API](https://www.yelp.com/developers/documentation).

Time spent: `<Number of hours spent>`

### Features

#### Required

- [X] Search results page
   - [X] Table rows should be dynamic height according to the content height
   - [X] Custom cells should have the proper Auto Layout constraints
   - [X] Search bar should be in the navigation bar (doesn't have to expand to show location like the real Yelp app does).
- [X] Filter page. Unfortunately, not all the filters are supported in the Yelp API.
   - [X] The filters you should actually have are: category, sort (best match, distance, highest rated), radius (meters), deals (on/off).
   - [X] The filters table should be organized into sections as in the mock.
   - [X] You can use the default UISwitch for on/off states. Optional: implement a custom switch
   - [X] Clicking on the "Search" button should dismiss the filters page and trigger the search w/ the new filter settings.
   - [X] Display some of the available Yelp categories (choose any 3-4 that you want).

#### Optional

- [X] Search results page - List View
   - [X] Infinite scroll for restaurant results
   - [X] Implement map view of restaurant results
   - [X] Both search modes (Map & List) share the state of the filters
- [X] Search results page - Map View
   - [X] App requests permission to access user location
   - [X] Added custom AnnotationViews (little hamburguers) to mark Restaurant Location
   - [X] Map automatically centers at user location
   - [X] User can go to Details Page by clicking on Pin and then on the CallOut view that pops up
   - [X] Custom CallOut View
- [X] Filter page
   - [X] Radius filter should expand as in the real Yelp app
   - [X] Categories should show a subset of the full list with a "See All" row to expand. Category list is here: http://www.yelp.com/developers/documentation/category_list (Links to an external site.)
- [X] Detail Page - Implement the restaurant detail page.
   - [X] User can save restaurant to favorite list by tapping on button
   - [X] User can CALL the restaurant by tapping on the phone icon
   - [X] Detail page shows map view with the restaurant location
      - At bottom when in portrait
      - At right side when in landscape 
- [X] Favorites Page
   - [X] User can swipe left to delete items
- [X] Others
   - [X] Added custom views to NavBar Title Item

### Walkthrough

![Video Walkthrough](http://i.imgur.com/AfskpE8.gif)
![Video Walkthrough](http://i.imgur.com/BkneDaS.gif)
Credits
---------
* [Yelp API](https://www.yelp.com/developers/documentation)
* [AFNetworking](https://github.com/AFNetworking/AFNetworking)
* [BDBOAuth1Manager](https://github.com/bdbergeron/BDBOAuth1Manager)
