# GH-Users
 UIKit app for displaying Github Users

## Execution
 The project depends upon two external libraries integrated via Swift Package Manager

### Dependencies
 SkeletonView - Displays shimmering effect for loading.
 Reachability - To monitor network status
 
## Tasks
### Required Tasks
1. Code must be done in Swift 5.1. using Xcode 12.x, target iOS13 - Written in Swift 5.1 with iOS 13.0 as the minimum deployment target.
2. CoreData must be used for data persisting - the `PersistanceManager` class uses CoreData to persist API call data.
3. UI must be done with UIKit using AutoLayout - Both the user list page and user details page are done using AutoLayout.
4. All network calls must be queued and limited to 1 request at a time. - Network calls are queued and limited to 1 request using OperationQueue in the `NetworkOperationsManager` class
5. All media has to be cached on disk. - Image caching to memory, disk is managed by `ImageCacheService` and `ImagePersistanceManager` classes respectively 
6. For GitHub API requests, for image loading & caching and for CoreData integration only Apple's APIs are allowed (no 3rd party libraries). - `NetworkOperationsManager` uses URLSession to make the api calls and image loading, `PersistanceManager` uses apples core data library directly, `ImagePersistanceManager` uses file manager to save and retrive image data from disk.
7. Use Codable to inflate models fetched from api. - `JSONResponseDecoder` uses `JSONDecoder` to decode the api data to the codable models `UsersListResponse` and `UserDetailsResponse`.
8. Write Unit tests using XCTest library for data processing logic & models, CoreData models (validate creation & update). - Unit test for creation, update for the persistance service class have been added, test cases for the repository class that handle network request and cached data fetch from persistence have been added, only limited test cases have been written for view models due to time constraints.
9. If functional programming approach is used then only Combine is permitted (instead of e.g. ReactiveSwift). - Combine is used by the view models(`UsersListViewModel`, `UserDetailsViewModel` and `UsersListCellViewModel`) for allowing the views to subscribe to value changes for updating the UI.

### Offline Support
1. The app has to be able to work offline if data has been previously loaded. - The app initially loads the content if present from persistent storage and then load the data from api.
2. The app must handle no internet scenario, show appropriate UI indicators. - Offline banners are displayed in both the user list page and user details page.
3. The app must automatically retry loading data once the connection is available. - Using the reachability library both the user list page and user details page are reloaded when the internet is available again.
4. When there is data available (saved in the database) from previous launches, that
data should be displayed first, then (in parallel) new data should be fetched from the backend. The app initially loads the content if present from persistent storage and then load the data from api.

### Bonus Tasks
1. Empty views such as list items (while data is still loading) should have Loading Shimmer aka Skeletons. - Implemented using third party library SkeletonView
2. Exponential backoff must be used when trying to reload the data. - Implemented in the class `NetworkDataService` under the method `requestWithRetry` 
3. Any data fetch should utilize Result types. - All data fetch methods return result type
4. CoreData stack implementation must use two managed contexts - 1.main context to be used for reading data and feeding into UI 2. write (background) context - that is used for writing data. - `viewContext` is used for fetching data used for rendering the view, `backgroundContext` is used for saving new data and updating new data 
5. All CoreData write queries must be queued while allowing one concurrent query at any time. - The `backgroundContext` is created using the core data persistence container method `newBackgroundContext()` this method creates a new background context in which the queries are executed based on the FIFO method.
6. Coordinator and/or MVVM patterns are used. - Both coordinator and MVVM patterns are used.
7. Users list UI must be done in code and Profile - with Interface Builder. - User List and its children are done in code and the profile page is done using interface builder
8. Items in the users list are greyed out a bit for seen profiles (seen status being saved to DB). - Viewed users list cell is greyed out.
9. The app has to support dark mode. - Supports dark mode.
