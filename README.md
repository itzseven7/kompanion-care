# kompanion-care

# 📋 State of the Application

- **UI** is very simple, I mainly focused on understanding TCA basics and implementing a clean architecture
- **Loading states and errors** are handled in the weather feature only
- **Progress issue** when changing a story with the timer

# 🏗️ Architecture

The project is separated into three parts (fictive Swift packages):

- **Shared**:  
  Contains Story domain object and data repository and services protocols.
  
- **Service**:  
  Contains all the fetch logic for location with CoreLocation and the weather API, it also has a simple repository to create stories
  
- **Feature**:  
  Contains the Weather and Story views and their associated reducer
  
# 💬 How it works

For the weather, the reducer uses the location service to know if permissions and state are valid to request a location
The view will display the different states of the process
Then the reducer will request temperature and city name from the weather repository (and displays any related error accordingly)

For the story, the reducer will ask the **StoryRepository** a list of stories
Then it will send the startTime action that will create an effect to enable the timer and send an action for every update (that will update the progress bar)
At every update, the reducer checks the duration to know if it must go to the next story or not

# 💬 Remarks

- I don't think that I have used all the recent/optimal mechanisms of TCA
- I wanted to use a remote service to generate images
- The transition animation is really basic
